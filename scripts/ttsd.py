#!/usr/bin/env python3
"""The live channel to a running Tabletop Simulator, and the changelog daemon.

TTS speaks the External Editor API over two localhost TCP connections, and the
asymmetry is the only thing about it that is easy to get wrong:

    you -> TTS      127.0.0.1:39999      one JSON message per connection
    TTS -> you      127.0.0.1:39998      the reply arrives on a *different*
                                         connection, to a server you must
                                         already be listening on

So `exec` binds 39998 before it sends anything, and everything else follows from
that.  See reference/api/externaleditorapi.md; nothing here guesses.

    python3 scripts/ttsd.py status                     # is TTS listening?
    python3 scripts/ttsd.py exec 'return AZ.state()'    # ID 3, returns on ID 5
    python3 scripts/ttsd.py call tint jungle 2E6B33    # sugar over exec
    python3 scripts/ttsd.py push                       # ID 1: script AND ui
    python3 scripts/ttsd.py get                        # ID 0: what TTS holds
    python3 scripts/ttsd.py note 'moved the cubes'     # ID 2 -> onExternalMessage
    python3 scripts/ttsd.py serve                      # the journal daemon
    python3 scripts/ttsd.py log --since last           # the rendered changelog

Two facts that cost a debugging session each if forgotten, both enforced here
rather than documented and hoped for:

  * **ID 1 deletes the UI XML if you send only `script`** (`:161`).  `push`
    always sends both fields, and refuses to send a script without one.
  * **ID 3 needs `guid: "-1"`**.  Executing against any other object requires
    that object to already have a script open in the in-game editor (`:191`);
    Global always has one.

Only one process can hold 39998.  When `serve` is running it owns the port, so
the one-shot verbs relay through its unix socket instead of failing — you can
leave the daemon up and keep using `exec` in the same terminal.

Stdlib only, like everything else in this folder.  Nothing here writes under
Saves/ or Mods/: snapshots live in proto/amazonia/.journal/.
"""

import argparse
import datetime
import errno
import json
import os
import shutil
import socket
import subprocess
import sys
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PROTO = os.path.join(ROOT, "proto", "amazonia")
JOURNAL_DIR = os.path.join(PROTO, ".journal")
EVENTS = os.path.join(JOURNAL_DIR, "events.jsonl")
CURSOR = os.path.join(JOURNAL_DIR, "cursor")
SNAPSHOT = os.path.join(JOURNAL_DIR, "snapshot.json")
SNAPSHOT_META = os.path.join(JOURNAL_DIR, "snapshot.txt")
CONTROL = os.path.join(JOURNAL_DIR, "ttsd.sock")
JOURNAL_MD = os.path.join(PROTO, "JOURNAL.md")

# TTS's ports are fixed, but the tests need a pair of their own: the fake TTS in
# test/bridge_spec.py cannot bind 39999 while the real game is running, and
# quitting the game to run the tests is exactly the friction this tool exists to
# remove. Only the tests set these.
TTS_PORT = int(os.environ.get("TTSD_TTS_PORT", "39999"))
EDITOR_PORT = int(os.environ.get("TTSD_EDITOR_PORT", "39998"))
SAVES = os.path.join(ROOT, "Saves")

# What TTS sends us, by messageID.
INBOUND = {
    0: "pushingNewObject", 1: "scripts", 2: "print", 3: "error",
    4: "custom", 5: "return", 6: "saved", 7: "objectCreated",
}


def die(msg, hint=None):
    sys.stderr.write("ttsd: %s\n" % msg)
    if hint:
        sys.stderr.write("      %s\n" % hint)
    raise SystemExit(1)


def refuse_managed(path):
    """Never write into TTS's own territory.  Mirrors tts.py's corpus guard."""
    full = os.path.abspath(path)
    for managed in ("Mods", "Saves"):
        root = os.path.join(ROOT, managed) + os.sep
        if full == os.path.join(ROOT, managed) or full.startswith(root):
            die("refusing to write under %s/ — that is TTS's, not ours (%s)"
                % (managed, path))


def ensure_journal():
    refuse_managed(JOURNAL_DIR)
    os.makedirs(JOURNAL_DIR, exist_ok=True)


# ----------------------------------------------------------------- the wire


def listening(port=TTS_PORT, timeout=0.4):
    probe = socket.socket()
    probe.settimeout(timeout)
    try:
        return probe.connect_ex(("127.0.0.1", port)) == 0
    finally:
        probe.close()


def send_tts(message, timeout=4.0):
    """One JSON message to TTS, then close.  TTS reads a message per connection."""
    payload = json.dumps(message).encode("utf-8")
    link = socket.socket()
    link.settimeout(timeout)
    try:
        link.connect(("127.0.0.1", TTS_PORT))
    except (ConnectionRefusedError, socket.timeout, OSError) as exc:
        die("nothing is listening on 127.0.0.1:%d (%s)" % (TTS_PORT, exc),
            "Start Tabletop Simulator and load the save. Until then only the "
            "L3 loop works: edit src/, run proto/amazonia/build.sh.")
    try:
        link.sendall(payload)
        link.shutdown(socket.SHUT_WR)
    finally:
        link.close()


def decode_stream(buffer):
    """Split a byte buffer into whole JSON messages, returning the remainder.

    TTS opens a connection, writes one message and closes it, but nothing in the
    protocol promises that, so this copes with several messages arriving in one
    read and with a message split across reads.
    """
    text = buffer.decode("utf-8", "replace")
    decoder = json.JSONDecoder()
    messages, position = [], 0
    while True:
        while position < len(text) and text[position] in " \t\r\n":
            position += 1
        if position >= len(text):
            return messages, b""
        try:
            value, end = decoder.raw_decode(text, position)
        except ValueError:
            return messages, text[position:].encode("utf-8")
        messages.append(value)
        position = end


class Inbox(object):
    """A server on 39998: everything TTS sends us arrives here.

    `handler(message)` runs on the accepting thread, one connection at a time,
    so a handler that writes to a file does not need a lock of its own.
    """

    def __init__(self, handler, port=EDITOR_PORT):
        self.handler = handler
        self.port = port
        self.server = None
        self.thread = None
        self.stopping = threading.Event()

    def open(self):
        self.server = socket.socket()
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            self.server.bind(("127.0.0.1", self.port))
        except OSError as exc:
            self.server.close()
            self.server = None
            if exc.errno in (errno.EADDRINUSE,):
                return False
            raise
        self.server.listen(8)
        self.server.settimeout(0.25)
        self.thread = threading.Thread(target=self._serve, daemon=True)
        self.thread.start()
        return True

    def _serve(self):
        while not self.stopping.is_set():
            try:
                link, _ = self.server.accept()
            except socket.timeout:
                continue
            except OSError:
                return
            buffer = b""
            link.settimeout(2.0)
            try:
                while True:
                    try:
                        chunk = link.recv(65536)
                    except socket.timeout:
                        break
                    if not chunk:
                        break
                    buffer += chunk
                    messages, buffer = decode_stream(buffer)
                    for message in messages:
                        self.handler(message)
                for message in decode_stream(buffer)[0]:
                    self.handler(message)
            finally:
                link.close()

    def close(self):
        self.stopping.set()
        if self.server:
            try:
                self.server.close()
            except OSError:
                pass


# ------------------------------------------------------------ the relay socket
#
# `serve` owns 39998.  A one-shot verb run while it is up cannot bind the port,
# so it asks the daemon to do the round trip on its behalf over a unix socket.


def relay(request, timeout=20.0):
    """Ask a running daemon to do this for us.  None if there is no daemon."""
    if not os.path.exists(CONTROL):
        return None
    link = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    link.settimeout(timeout)
    try:
        link.connect(CONTROL)
    except OSError:
        return None  # a stale socket file from a daemon that is gone
    try:
        link.sendall((json.dumps(request) + "\n").encode("utf-8"))
        link.shutdown(socket.SHUT_WR)
        buffer = b""
        while True:
            chunk = link.recv(65536)
            if not chunk:
                break
            buffer += chunk
        if not buffer:
            return None
        return json.loads(buffer.decode("utf-8"))
    except (OSError, ValueError):
        return None
    finally:
        link.close()


# -------------------------------------------------------------------- verbs


def lua_literal(value):
    """A command-line argument as Lua source: a quoted string, almost always.

    The tempting rule — "send it bare if it parses as a number" — is wrong here,
    and wrong on the build plan's own example verb.  Hex colours arrive as bare
    words on a command line, and `006600` and `1E5000` both parse as floats:
    the first would reach Lua as 6600 and the second as infinity.  Quoting
    everything cannot lose information, and every `AZ.*` verb that wants a number
    already calls `tonumber` on it, because its other caller is a button.

    true, false and nil stay bare: no colour or kind name looks like those, and
    `AZ.lock(false)` reads better than `AZ.lock("false")` — which also works.
    Anything this rule cannot express is what `ttsd exec` is for.
    """
    text = str(value)
    if text in ("true", "false", "nil"):
        return text
    return '"%s"' % text.replace("\\", "\\\\").replace('"', '\\"')


MARK = "@@ttsd:"


def wrap_script(script, token):
    """Wrap an exec so its result comes back as a `print`, not as an ID 5.

    **TTS v14.2.2 never sends message ID 5.**  Measured on 2026-09-21 against a
    live game: an ID 3 executes (a `print` in it arrives as ID 2, a
    `broadcastToAll` shows on the table), but every one of `return true`,
    `return 42`, `return "text"`, `return {1,2}`, `do return 9 end` and
    `return (function() return 7 end)()` produced no reply at all, while an ID 0
    answered normally on the same connection moments later.  The "Return
    messages" section of externaleditorapi.md documents a feature this build
    does not have.

    ID 2 does work, so the answer comes back as a marked print.  `run_exec`
    still accepts an ID 5 if a future build starts sending them.

    pcall means a Lua error is reported through the same channel rather than
    arriving as a separate ID 3 that has no way to say which call it belongs to.
    """
    return (
        "local __ttsd = function() %s end\n"
        "local __ok, __v = pcall(__ttsd)\n"
        "if type(__v) == 'table' then\n"
        "  local __e, __j = pcall(JSON.encode, __v)\n"
        "  __v = __e and __j or tostring(__v)\n"
        "else __v = tostring(__v) end\n"
        "print('%s%s:' .. (__ok and 'ok' or 'err') .. ':' .. __v)\n"
        % (script, MARK, token))


def read_mark(text, token):
    """(ok, payload) if this print is our answer, else None."""
    prefix = "%s%s:" % (MARK, token)
    if not isinstance(text, str) or not text.startswith(prefix):
        return None
    rest = text[len(prefix):]
    status, _, payload = rest.partition(":")
    return (status == "ok", payload)


def run_exec(script, guid="-1", timeout=10.0, quiet=False):
    """messageID 3, and wait on 39998 for the marked print that answers it."""
    if guid != "-1":
        die("ID 3 against object %s will fail unless that object already has a "
            "script open in TTS's in-game editor" % guid,
            "Global (guid -1) always has one. See externaleditorapi.md:191.")

    handed = relay({"op": "exec", "script": script, "timeout": timeout})
    if handed is not None:
        for line in handed.get("prints", []):
            if not quiet:
                sys.stderr.write("%s\n" % line)
        if not handed.get("ok"):
            die(handed.get("error", "the daemon did not answer"))
        return handed.get("returnValue")

    answer = {}
    done = threading.Event()
    noise = []
    token = "%06x" % (int(time.time() * 1000) & 0xFFFFFF)

    def handler(message):
        kind = message.get("messageID")
        if kind == 5:
            # Not sent by v14.2.2; honoured in case a later build restores it.
            answer["value"] = message.get("returnValue")
            done.set()
        elif kind == 3:
            noise.append("TTS error: %s" % message.get("error"))
            answer["error"] = message.get("error")
            done.set()
        elif kind == 2:
            marked = read_mark(message.get("message"), token)
            if marked is None:
                noise.append("TTS print: %s" % message.get("message"))
            elif marked[0]:
                answer["value"] = marked[1]
                done.set()
            else:
                answer["error"] = marked[1]
                done.set()

    inbox = Inbox(handler)
    if not inbox.open():
        die("port %d is busy but no ttsd daemon answered on %s"
            % (EDITOR_PORT, CONTROL),
            "Another editor (Atom, VS Code's TTS plugin) probably holds it. "
            "Close it, or stop the stale daemon.")
    try:
        send_tts({"messageID": 3, "guid": guid,
                  "script": wrap_script(script, token)})
        done.wait(timeout)
    finally:
        inbox.close()

    for line in noise:
        if not quiet:
            sys.stderr.write("%s\n" % line)
    if "error" in answer:
        die("Lua error: %s" % answer["error"])
    if not done.is_set():
        die("no reply from TTS within %.0fs" % timeout,
            "TTS must be running with the save loaded. The answer comes back "
            "as a print, so a game with scripting disabled will also go quiet.")
    return answer.get("value")


def build_global_lua():
    """The same concatenation build.sh makes — literally, via luacat.py.

    Going through one builder is what keeps the save on disk and the script in
    the running game identical.  It also means `push` gets the shadowed-global
    lint for free, and refuses rather than pushing a build whose `local A` in
    ttslib has been overwritten by a later file's global.
    """
    sys.path.insert(0, HERE)
    import luacat

    files = luacat.sources(src=os.path.join(PROTO, "src"),
                           extra=[os.path.join(PROTO, "art", "index.lua")])
    findings, _ = luacat.lint(files)
    if findings:
        for kind, path, number, _, message in findings:
            sys.stderr.write("ttsd: %s:%s: %s: %s\n"
                             % (os.path.relpath(path, ROOT), number or "-",
                                kind, message))
        die("refusing to push a build with %d lint finding(s)" % len(findings),
            "Run `python3 scripts/luacat.py --lint` for the full list.")
    return luacat.concat(files)


def cmd_push(args):
    """messageID 1 — the source tree into the running game, and reload.

    Both fields, every time.  Sending `script` without `ui` deletes the UI XML
    (externaleditorapi.md:161), and that is a silent loss: the panel simply
    stops being there and the script that drives it keeps working.
    """
    script = build_global_lua()
    ui_path = os.path.join(PROTO, "ui.xml")
    if not os.path.exists(ui_path):
        die("no ui.xml at %s" % os.path.relpath(ui_path, ROOT),
            "push refuses to send a script without one: TTS would delete the "
            "save's UI XML.")
    with open(ui_path, encoding="utf-8", newline="") as handle:
        ui = handle.read()

    send_tts({"messageID": 1, "scriptStates": [
        {"name": "Global", "guid": "-1", "script": script, "ui": ui},
    ]})
    print("pushed %d chars of Lua and %d of XML; TTS is reloading the save."
          % (len(script), len(ui)))
    print("This does not write a save file. `proto/amazonia/build.sh` does.")
    return 0


def cmd_get(args):
    """messageID 0 — what TTS currently holds, answered as an ID 1."""
    answer = {}
    done = threading.Event()

    def handler(message):
        if message.get("messageID") == 1:
            answer["states"] = message.get("scriptStates", [])
            done.set()

    inbox = Inbox(handler)
    if not inbox.open():
        die("port %d is busy — stop `ttsd serve` or your other editor first"
            % EDITOR_PORT)
    try:
        send_tts({"messageID": 0})
        done.wait(args.timeout)
    finally:
        inbox.close()

    if not done.is_set():
        die("no reply from TTS within %.0fs" % args.timeout)
    for state in answer["states"]:
        print("  %-28s %-8s %6d chars Lua  %6d chars XML"
              % (state.get("name", "?"), state.get("guid", "?"),
                 len(state.get("script") or ""), len(state.get("ui") or "")))
    if args.out:
        refuse_managed(args.out)
        os.makedirs(args.out, exist_ok=True)
        for state in answer["states"]:
            stem = "%s.%s" % (state.get("name", "object"), state.get("guid", "x"))
            stem = stem.replace("/", "_")
            for field, suffix in (("script", ".lua"), ("ui", ".xml")):
                if state.get(field):
                    with open(os.path.join(args.out, stem + suffix), "w",
                              encoding="utf-8", newline="") as handle:
                        handle.write(state[field])
        print("wrote %d script state(s) to %s"
              % (len(answer["states"]), args.out))
    return 0


def cmd_note(args):
    """messageID 2 — a custom message, which must be a table or it is dropped.

    `customMessage` has to be a JSON object: "If this value is not a table then
    the event is not triggered" (externaleditorapi.md:176).  There is no error
    if you send a string; the event simply never fires.
    """
    send_tts({"messageID": 2, "customMessage": {"note": " ".join(args.text)}})
    print("sent; it reaches Lua as onExternalMessage{ note = ... }")
    return 0


def cmd_status(args):
    up = listening()
    print("TTS on :%d        %s" % (TTS_PORT, "listening" if up else "not listening"))
    held = listening(EDITOR_PORT, 0.2)
    print("editor port :%d   %s" % (EDITOR_PORT, "held" if held else "free"))
    daemon = relay({"op": "ping"})
    print("ttsd serve        %s" % ("running" if daemon else "not running"))
    if not up:
        print()
        print("Start TTS and load Saves/TS_Save_127.json. Without it the L1 and")
        print("L2 loops are unavailable; the L3 loop (build.sh) still works.")
    return 0 if up else 1


# ------------------------------------------------------------------ the daemon


def now():
    return datetime.datetime.now()


def newest_save():
    """The most recently written numbered save — never an autosave.

    Autosaves rotate on a timer (CLAUDE.md #4), so diffing against one would
    report whatever the timer happened to catch rather than what the owner did.
    """
    best, when = None, -1
    if not os.path.isdir(SAVES):
        return None
    for name in os.listdir(SAVES):
        if not name.startswith("TS_Save_") or not name.endswith(".json"):
            continue
        path = os.path.join(SAVES, name)
        try:
            stamp = os.path.getmtime(path)
        except OSError:
            continue
        if stamp > when:
            best, when = path, stamp
    return best


def append_event(record):
    ensure_journal()
    with open(EVENTS, "a", encoding="utf-8") as handle:
        handle.write(json.dumps(record, sort_keys=True) + "\n")


def render_event(record):
    """One journal line.  Compact on purpose: an agent reads these, and the
    whole point of `--since last` is that it never reads the whole file."""
    when = record.get("at", "")[11:16]
    data = record.get("data") or {}
    kind = record.get("kind", "?")

    def where(key):
        value = data.get(key)
        return value if isinstance(value, str) else "?"

    if kind == "move":
        return "[%s] move   %-18s %s -> %s" % (
            when, "%s %s" % (data.get("what", "?"), data.get("guid", "")),
            where("from"), where("to"))
    if kind == "pickUp":
        return "[%s] pickUp %-18s %s" % (
            when, "%s %s" % (data.get("what", "?"), data.get("guid", "")),
            where("from"))
    if kind in ("spawn", "destroy"):
        return "[%s] %-6s %-18s %s" % (
            when, kind, "%s %s" % (data.get("what", "?"), data.get("guid", "")),
            where("at"))
    if kind == "build":
        return "[%s] build  seed %s, %s tiles over %s rings" % (
            when, data.get("seed"), data.get("tiles"), data.get("rings"))
    if kind == "tint":
        return "[%s] tint   %s -> %s (%s tiles)" % (
            when, data.get("kind"), data.get("colour"), data.get("n"))
    if kind == "reskin":
        return "[%s] reskin %s (%s tiles)" % (when, data.get("kind"), data.get("n"))
    if kind == "hub":
        return "[%s] hub    %s cell %s -> %s" % (
            when, data.get("kind"), data.get("cell"), data.get("resource"))
    if kind == "harvest":
        return "[%s] harvest %s cell %s (%s) by %s" % (
            when, data.get("kind"), data.get("cell"), data.get("resource"),
            data.get("who"))
    if kind == "note":
        return "[%s] note   %s" % (when, data.get("text"))
    if kind == "saved":
        return "[%s] saved  %-18s %s" % (when, data.get("file", "?"),
                                         data.get("summary", ""))
    if kind == "error":
        return "[%s] ERROR  %s" % (when, data.get("text"))
    if kind == "print":
        return "[%s] print  %s" % (when, data.get("text"))
    return "[%s] %-6s %s" % (when, kind, json.dumps(data, sort_keys=True))


def diff_summary(text):
    """Pull `(+27, -22, 120 changed)` out of tts.py diff's object line."""
    for line in text.splitlines():
        if line.startswith("objects") and "(" in line:
            return "(" + line.split("(", 1)[1].strip()
    if "identical" in text:
        return "(no object changes)"
    return ""


class Daemon(object):
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.pending = []          # exec replies waiting to be handed back
        self.lock = threading.Lock()
        self.prints = []

    # ------------------------------------------------------------- inbound

    def on_message(self, message):
        kind = message.get("messageID")
        name = INBOUND.get(kind, str(kind))
        stamp = now().isoformat(timespec="seconds")

        if kind == 4:
            payload = (message.get("customMessage") or {}).get("amazonia")
            if isinstance(payload, dict):
                record = {"at": stamp, "kind": payload.get("kind", "custom"),
                          "data": payload}
                append_event(record)
                if self.verbose:
                    print(render_event(record))
                return

        if kind == 2:
            # An exec's answer comes back as a marked print, not an ID 5 — see
            # wrap_script. Claim it for whichever waiter is expecting that
            # token, and keep it out of the journal: it is a reply, not an event.
            text = message.get("message")
            with self.lock:
                for waiter in self.pending:
                    marked = read_mark(text, waiter["token"])
                    if marked is not None:
                        if marked[0]:
                            waiter["value"] = marked[1]
                        else:
                            waiter["error"] = marked[1]
                        waiter["event"].set()
                        return
                self.prints.append(str(text or ""))
            record = {"at": stamp, "kind": "print",
                      "data": {"text": message.get("message")}}
            append_event(record)
            if self.verbose:
                print(render_event(record))
            return

        if kind == 3:
            record = {"at": stamp, "kind": "error",
                      "data": {"text": message.get("error")}}
            append_event(record)
            print(render_event(record))
            with self.lock:
                for waiter in self.pending:
                    waiter["error"] = message.get("error")
                    waiter["event"].set()
            return

        if kind == 5:
            with self.lock:
                if self.pending:
                    waiter = self.pending.pop(0)
                    waiter["value"] = message.get("returnValue")
                    waiter["event"].set()
                    return
            append_event({"at": stamp, "kind": "return",
                          "data": {"value": message.get("returnValue")}})
            return

        if kind == 6:
            # Undocumented, but TTS sends the file it wrote alongside ID 6:
            #   {"messageID": 6, "savePath": "/Users/…/Saves/TS_Save_127.json"}
            # Observed 2026-09-21. Believe it when it is there — it beats
            # guessing from mtimes, which cannot tell our own write from TTS's.
            self.on_saved(stamp, message.get("savePath"))
            return

        append_event({"at": stamp, "kind": name, "data": {
            k: v for k, v in message.items() if k != "messageID"}})

    # --------------------------------------------------------------- saves

    def on_saved(self, stamp, save_path=None):
        """TTS just saved.  Diff it against our snapshot — this is the ground
        truth layer of the changelog, and it catches everything, including the
        cubes the owner moved by hand with the script none the wiser."""
        time.sleep(0.6)  # let TTS finish writing before reading the file
        target = None
        if save_path:
            # TTS writes it with doubled separators — /Users/artur//Library//…
            # — which os.path.normpath flattens.
            candidate = os.path.normpath(save_path)
            if os.path.exists(candidate):
                target = candidate
        target = target or newest_save()
        if not target:
            append_event({"at": stamp, "kind": "saved",
                          "data": {"file": "?", "summary": "(no save found)"}})
            return

        summary, detail = "(first save this session — snapshot taken)", ""
        previous = None
        if os.path.exists(SNAPSHOT_META):
            with open(SNAPSHOT_META, encoding="utf-8") as handle:
                previous = handle.read().strip()

        if os.path.exists(SNAPSHOT) and previous == os.path.basename(target):
            run = subprocess.run(
                [sys.executable, os.path.join(HERE, "tts.py"), "diff",
                 SNAPSHOT, target, "--limit", "40"],
                capture_output=True, text=True)
            detail = (run.stdout or "") + (run.stderr or "")
            summary = diff_summary(detail) or "(no object changes)"
        elif previous and previous != os.path.basename(target):
            summary = "(saved to a different file: %s)" % os.path.basename(target)

        record = {"at": stamp, "kind": "saved",
                  "data": {"file": os.path.basename(target), "summary": summary}}
        append_event(record)
        print(render_event(record))

        self.write_journal(record, detail)

        ensure_journal()
        shutil.copyfile(target, SNAPSHOT)
        with open(SNAPSHOT_META, "w", encoding="utf-8") as handle:
            handle.write(os.path.basename(target))

    def write_journal(self, saved, detail):
        """Append a section to JOURNAL.md — appended, never rewritten."""
        lines = unread_events(mark=True)
        stamp = saved["at"].replace("T", " ")[:16]
        block = ["", "## %s — %s  %s" % (stamp, saved["data"]["file"],
                                         saved["data"]["summary"]), ""]
        narrative = [render_event(e) for e in lines
                     if e.get("kind") not in ("print", "return")]
        if narrative:
            block.append("```")
            block.extend(narrative)
            block.append("```")
        else:
            block.append("_Nothing the script observed; see the diff below._")
        if detail.strip():
            block.extend(["", "<details><summary>tts.py diff</summary>", "",
                          "```", detail.rstrip(), "```", "", "</details>"])
        block.append("")

        header_needed = not os.path.exists(JOURNAL_MD)
        with open(JOURNAL_MD, "a", encoding="utf-8") as handle:
            if header_needed:
                handle.write(
                    "# Amazonia — observed changelog\n\n"
                    "Appended by `scripts/ttsd.py serve`, one section per save "
                    "in TTS. Never rewritten:\nthe point is that nobody has to "
                    "remember what changed.\n\n"
                    "Each section has the narrative the script saw (moves, "
                    "rebuilds, tints) and the\nstructural diff between the "
                    "previous save and this one, which catches everything\nelse "
                    "— including pieces moved by hand.\n")
            handle.write("\n".join(block))

    # ------------------------------------------------------------- control

    def on_control(self, request):
        op = request.get("op")
        if op == "ping":
            return {"ok": True}
        if op == "exec":
            token = "%06x" % (int(time.time() * 1000) & 0xFFFFFF)
            waiter = {"event": threading.Event(), "token": token}
            with self.lock:
                self.pending.append(waiter)
                self.prints = []
            send_tts({"messageID": 3, "guid": "-1",
                      "script": wrap_script(request.get("script", ""), token)})
            waiter["event"].wait(float(request.get("timeout", 10.0)))
            with self.lock:
                if waiter in self.pending:
                    self.pending.remove(waiter)
                prints = list(self.prints)
            if "error" in waiter:
                return {"ok": False, "error": waiter["error"], "prints": prints}
            if not waiter["event"].is_set():
                return {"ok": False, "error": "no reply from TTS",
                        "prints": prints}
            return {"ok": True, "returnValue": waiter.get("value"),
                    "prints": ["TTS print: " + p for p in prints]}
        return {"ok": False, "error": "unknown op %r" % op}


def serve_control(daemon, stop):
    ensure_journal()
    if os.path.exists(CONTROL):
        os.unlink(CONTROL)
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(CONTROL)
    server.listen(4)
    server.settimeout(0.25)

    def loop():
        while not stop.is_set():
            try:
                link, _ = server.accept()
            except socket.timeout:
                continue
            except OSError:
                return
            try:
                link.settimeout(30.0)
                buffer = b""
                while b"\n" not in buffer:
                    chunk = link.recv(65536)
                    if not chunk:
                        break
                    buffer += chunk
                request = json.loads(buffer.decode("utf-8") or "{}")
                reply = daemon.on_control(request)
                link.sendall(json.dumps(reply).encode("utf-8"))
            except (OSError, ValueError):
                pass
            finally:
                link.close()

    thread = threading.Thread(target=loop, daemon=True)
    thread.start()
    return server


def cmd_serve(args):
    ensure_journal()
    daemon = Daemon(verbose=args.verbose)
    inbox = Inbox(daemon.on_message)
    if not inbox.open():
        die("port %d is already held" % EDITOR_PORT,
            "Another ttsd, or an editor plugin. Only one process can listen.")
    stop = threading.Event()
    control = serve_control(daemon, stop)

    if not listening():
        print("TTS is not listening on :%d yet — waiting. Start it and load "
              "the save." % TTS_PORT)
    print("ttsd serve: holding :%d, journal -> %s"
          % (EDITOR_PORT, os.path.relpath(JOURNAL_DIR, ROOT)))
    print("Save in TTS to get a JOURNAL.md section. Ctrl-C to stop.")
    try:
        while True:
            time.sleep(0.5)
    except KeyboardInterrupt:
        print()
    finally:
        stop.set()
        inbox.close()
        try:
            control.close()
        except OSError:
            pass
        if os.path.exists(CONTROL):
            os.unlink(CONTROL)
    return 0


# --------------------------------------------------------------------- log


def read_events():
    if not os.path.exists(EVENTS):
        return []
    out = []
    with open(EVENTS, encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            try:
                out.append(json.loads(line))
            except ValueError:
                continue
    return out


def unread_events(mark=False):
    """Everything since the cursor.  `--since last` is the default because the
    file grows forever and an agent should never read all of it."""
    events = read_events()
    seen = 0
    if os.path.exists(CURSOR):
        try:
            with open(CURSOR, encoding="utf-8") as handle:
                seen = int(handle.read().strip() or 0)
        except ValueError:
            seen = 0
    fresh = events[seen:]
    if mark:
        ensure_journal()
        with open(CURSOR, "w", encoding="utf-8") as handle:
            handle.write(str(len(events)))
    return fresh


def cmd_log(args):
    events = read_events()
    if args.since == "all":
        chosen, mark = events, False
    elif args.since == "last":
        chosen, mark = unread_events(mark=not args.keep), False
    else:
        try:
            count = int(args.since)
        except ValueError:
            die("--since takes 'last', 'all' or a number, not %r" % args.since)
        chosen, mark = events[-count:], False

    if args.since == "last" and not args.keep:
        ensure_journal()
        with open(CURSOR, "w", encoding="utf-8") as handle:
            handle.write(str(len(events)))

    if not chosen:
        print("nothing new (%d events on file)" % len(events))
        return 0
    for record in chosen:
        if record.get("kind") == "print" and not args.verbose:
            continue
        print(render_event(record))
    return 0


# -------------------------------------------------------------------- main


def cmd_exec(args):
    value = run_exec(" ".join(args.script), timeout=args.timeout)
    print(json.dumps(value) if not isinstance(value, str) else value)
    return 0


def cmd_call(args):
    script = "return AZ.%s(%s)" % (
        args.verb, ", ".join(lua_literal(a) for a in args.args))
    if args.dry_run:
        print(script)
        return 0
    value = run_exec(script, timeout=args.timeout)
    print(json.dumps(value) if not isinstance(value, str) else value)
    return 0


def main():
    parser = argparse.ArgumentParser(
        description="External Editor API bridge and changelog daemon for TTS.")
    subs = parser.add_subparsers(dest="command")

    p = subs.add_parser("status", help="is TTS listening, and is a daemon up?")
    p.set_defaults(run=cmd_status)

    p = subs.add_parser("exec", help="run Lua in Global and print what it returns")
    p.add_argument("script", nargs="+")
    p.add_argument("--timeout", type=float, default=10.0)
    p.set_defaults(run=cmd_exec)

    p = subs.add_parser("call", help="sugar: call <verb> a b -> return AZ.verb(a,b)")
    p.add_argument("verb")
    p.add_argument("args", nargs="*")
    p.add_argument("--timeout", type=float, default=10.0)
    p.add_argument("--dry-run", action="store_true",
                   help="print the Lua instead of sending it")
    p.set_defaults(run=cmd_call)

    p = subs.add_parser("push", help="send src/ and ui.xml to the running game")
    p.set_defaults(run=cmd_push)

    p = subs.add_parser("get", help="list the scripts TTS currently holds")
    p.add_argument("--out", help="also write them to this directory")
    p.add_argument("--timeout", type=float, default=10.0)
    p.set_defaults(run=cmd_get)

    p = subs.add_parser("note", help="put a line in the changelog by hand")
    p.add_argument("text", nargs="+")
    p.set_defaults(run=cmd_note)

    p = subs.add_parser("serve", help="hold :39998, journal, diff on every save")
    p.add_argument("--verbose", action="store_true",
                   help="echo every event as it arrives")
    p.set_defaults(run=cmd_serve)

    p = subs.add_parser("log", help="the rendered changelog")
    p.add_argument("--since", default="last",
                   help="'last' (default), 'all', or a number of events")
    p.add_argument("--keep", action="store_true",
                   help="do not advance the cursor")
    p.add_argument("--verbose", action="store_true",
                   help="include TTS print() output")
    p.set_defaults(run=cmd_log)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        return 2
    return args.run(args)


if __name__ == "__main__":
    raise SystemExit(main())
