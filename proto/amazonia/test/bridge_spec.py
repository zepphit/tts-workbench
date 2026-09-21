#!/usr/bin/env python3
"""The External Editor bridge, exercised against a fake TTS.

    python3 proto/amazonia/test/bridge_spec.py

`ttsd.py` cannot be tested against the real thing without the game running, and
the real thing is the step-4 gate in docs/amazonia-build-plan.md.  What *can* be
tested without it is everything that is actually ours: that we bind 39998 before
sending, that we match an ID 5 to the ID 3 that asked for it, that `push` never
sends a script without its UI, that the daemon relays for a one-shot verb
instead of failing on the busy port, and that a Game Saved runs the diff and
appends to JOURNAL.md.

So this runs a fake TTS: a server on 39999 that answers the way
reference/api/externaleditorapi.md says TTS does, including the part that is
easy to get wrong — replying on a *different* connection, to port 39998.

What it does not prove is that TTS behaves as its documentation says. That is
what `ttsd.py status` plus a live `exec` is for, and it is the gate.
"""

import json
import os
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
TTSD = os.path.join(ROOT, "scripts", "ttsd.py")

# A private port pair, so the suite runs while the real game is open on
# 39999/39998. ttsd.py reads these; nothing else does.
TTS_PORT = 39899
EDITOR_PORT = 39898
ENV = dict(os.environ, TTSD_TTS_PORT=str(TTS_PORT),
           TTSD_EDITOR_PORT=str(EDITOR_PORT))

checks = failures = 0
current = "?"


def check(ok, label):
    global checks, failures
    checks += 1
    if not ok:
        failures += 1
        print("  FAIL  %s: %s" % (current, label))
    return ok


def eq(got, want, label):
    return check(got == want, "%s (got %r, want %r)" % (label, got, want))


cases = []


def case(fn):
    cases.append(fn)
    return fn


# ------------------------------------------------------------- the fake TTS


class FakeTTS(object):
    """Listens on 39999; answers on 39998, as the real one does.

    `script_result` is what an ID 3 comes back with. Set `fail_with` to make it
    answer with an ID 3 error instead, which is the path a Lua syntax error
    takes.
    """

    def __init__(self):
        self.received = []
        self.script_result = "ok"
        self.fail_with = None
        self.prints = []
        # TTS v14.2.2 never sends ID 5; an exec's answer comes back as a marked
        # print (ID 2). Measured against the live game on 2026-09-21 — see
        # ttsd.wrap_script. Set this to emulate a build that does send ID 5.
        self.legacy_return = False
        self.server = socket.socket()
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind(("127.0.0.1", TTS_PORT))
        self.server.listen(8)
        self.server.settimeout(0.25)
        self.stop = threading.Event()
        self.thread = threading.Thread(target=self._loop, daemon=True)
        self.thread.start()

    def _loop(self):
        while not self.stop.is_set():
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
                    chunk = link.recv(65536)
                    if not chunk:
                        break
                    buffer += chunk
            except socket.timeout:
                pass
            finally:
                link.close()
            if buffer:
                try:
                    self._handle(json.loads(buffer.decode("utf-8")))
                except ValueError:
                    pass

    def reply(self, message, delay=0.05):
        """Answer on 39998 — a new connection, as the protocol specifies."""
        def send():
            time.sleep(delay)
            for _ in range(40):
                link = socket.socket()
                link.settimeout(1.0)
                if link.connect_ex(("127.0.0.1", EDITOR_PORT)) == 0:
                    link.sendall(json.dumps(message).encode("utf-8"))
                    link.close()
                    return
                link.close()
                time.sleep(0.05)
        threading.Thread(target=send, daemon=True).start()

    def _handle(self, message):
        self.received.append(message)
        kind = message.get("messageID")
        if kind == 0:
            self.reply({"messageID": 1, "scriptStates": [
                {"name": "Global", "guid": "-1", "script": "-- hi", "ui": "<x/>"},
            ]})
        elif kind == 3:
            for text in self.prints:
                self.reply({"messageID": 2, "message": text}, delay=0.02)
            if self.fail_with:
                self.reply({"messageID": 3, "error": self.fail_with,
                            "guid": "-1"})
            elif self.legacy_return:
                self.reply({"messageID": 5, "returnValue": self.script_result})
            else:
                # Answer the way the real thing does: run the wrapper's print.
                token = re.search(r"@@ttsd:([0-9a-f]+):", message.get("script", ""))
                if token:
                    self.reply({"messageID": 2, "message": "@@ttsd:%s:ok:%s"
                                % (token.group(1), self.script_result)})

    def close(self):
        self.stop.set()
        try:
            self.server.close()
        except OSError:
            pass


def ttsd(*args, **kwargs):
    return subprocess.run([sys.executable, TTSD] + list(args),
                          capture_output=True, text=True, env=ENV,
                          timeout=kwargs.get("timeout", 30))


# ------------------------------------------------------------------- cases


@case
def quoting():
    """Every argument is quoted, because a hex colour is not a number."""
    global current
    current = "call quotes its arguments"
    run = ttsd("call", "tint", "jungle", "2E6B33", "--dry-run")
    eq(run.stdout.strip(), 'return AZ.tint("jungle", "2E6B33")', "a hex colour")

    run = ttsd("call", "tint", "jungle", "006600", "--dry-run")
    eq(run.stdout.strip(), 'return AZ.tint("jungle", "006600")',
       "leading zeros survive")

    run = ttsd("call", "tint", "jungle", "1E5000", "--dry-run")
    eq(run.stdout.strip(), 'return AZ.tint("jungle", "1E5000")',
       "a colour that would float to infinity survives")

    run = ttsd("call", "rings", "4", "--dry-run")
    eq(run.stdout.strip(), 'return AZ.rings("4")',
       "a number is quoted too; every verb calls tonumber")

    run = ttsd("call", "lock", "false", "--dry-run")
    eq(run.stdout.strip(), "return AZ.lock(false)", "false stays a boolean")

    run = ttsd("call", "note", 'a "quoted" word', "--dry-run")
    eq(run.stdout.strip(), 'return AZ.note("a \\"quoted\\" word")',
       "quotes are escaped")


@case
def no_tts():
    """Every verb that needs TTS says so plainly instead of hanging."""
    global current
    current = "a plain message when TTS is not running"
    run = ttsd("status")
    eq(run.returncode, 1, "status exits non-zero")
    check("not listening" in run.stdout, "status says so")

    run = ttsd("exec", "return 1")
    eq(run.returncode, 1, "exec exits non-zero")
    check("nothing is listening" in run.stderr, "exec explains")
    check("build.sh" in run.stderr, "and names the loop that still works")


@case
def exec_round_trip():
    """The whole point: bind 39998, send ID 3, match the ID 5 that answers."""
    global current
    current = "exec round trip"
    fake = FakeTTS()
    try:
        fake.script_result = "seed=1 rings=3 tiles=14"
        run = ttsd("exec", "return AZ.state()")
        eq(run.returncode, 0, "exec succeeded")
        eq(run.stdout.strip(), "seed=1 rings=3 tiles=14", "the return value")
        sent = [m for m in fake.received if m.get("messageID") == 3]
        eq(len(sent), 1, "one ID 3 was sent")
        eq(sent[0]["guid"], "-1", "guid is -1, as ID 3 requires")
        check("return AZ.state()" in sent[0]["script"], "the script went through")
        check("@@ttsd:" in sent[0]["script"],
              "wrapped so the answer comes back as a print, not an ID 5")
        check("pcall" in sent[0]["script"],
              "and wrapped in pcall, so a Lua error answers the same call")

        current = "status sees a listening TTS"
        run = ttsd("status")
        eq(run.returncode, 0, "status exits zero")

        current = "call is sugar over exec"
        fake.received = []
        fake.script_result = 8
        run = ttsd("call", "tint", "jungle", "2E6B33")
        eq(run.stdout.strip(), "8", "the tile count came back")
        check('return AZ.tint("jungle", "2E6B33")' in fake.received[0]["script"],
              "the generated Lua")

        current = "a TTS-side error is reported, not swallowed"
        fake.fail_with = "chunk_0:(1,8): unexpected symbol"
        run = ttsd("exec", "return )(")
        eq(run.returncode, 1, "exec failed")
        check("unexpected symbol" in run.stderr, "the error text is shown")
        fake.fail_with = None

        current = "TTS print() output reaches the terminal"
        fake.prints = ["hello from Lua"]
        run = ttsd("exec", "return 1")
        check("hello from Lua" in run.stderr, "the print was relayed")
        fake.prints = []

        current = "an ID 5 is still honoured if a build sends one"
        fake.legacy_return = True
        fake.script_result = "from an ID 5"
        run = ttsd("exec", "return 1")
        eq(run.stdout.strip(), "from an ID 5",
           "a build that restores ID 5 keeps working")
        fake.legacy_return = False
        fake.script_result = "ok"
    finally:
        fake.close()


@case
def get_and_note():
    global current
    fake = FakeTTS()
    try:
        current = "get lists what TTS holds"
        run = ttsd("get")
        eq(run.returncode, 0, "get succeeded")
        check("Global" in run.stdout, "Global is listed")

        current = "get --out writes the scripts to disk"
        out = tempfile.mkdtemp(prefix="ttsd-get.")
        try:
            run = ttsd("get", "--out", out)
            eq(sorted(os.listdir(out)), ["Global.-1.lua", "Global.-1.xml"],
               "both fields written")
        finally:
            shutil.rmtree(out, ignore_errors=True)

        current = "note sends a table, which is what ID 2 requires"
        fake.received = []
        run = ttsd("note", "moved the cubes")
        eq(run.returncode, 0, "note succeeded")
        eq(fake.received[0]["messageID"], 2, "message ID")
        eq(fake.received[0]["customMessage"], {"note": "moved the cubes"},
           "customMessage is an object, not a string")
    finally:
        fake.close()


@case
def push_sends_both():
    """ID 1 with only `script` deletes the save's UI XML. Never send one."""
    global current
    current = "push sends script and ui together"
    fake = FakeTTS()
    try:
        run = ttsd("push")
        eq(run.returncode, 0, "push succeeded")
        message = fake.received[0]
        eq(message["messageID"], 1, "message ID")
        state = message["scriptStates"][0]
        eq(state["guid"], "-1", "Global")
        eq(state["name"], "Global", "named Global")
        check(len(state["script"]) > 50000, "the whole build went")
        check("ttslib" in state["script"], "the library is in it")
        check("AMAZONIA_ART" in state["script"], "the art catalogue is in it")
        check("AZ.tint" in state["script"], "the command surface is in it")
        check(state.get("ui", "").startswith("<!--"), "the UI XML went with it")
        check("<Panel" in state["ui"], "and it is the panel")

        current = "push builds the same Lua build.sh does"
        lib = os.path.join(ROOT, "reference", "framework", "ttslib")
        proto = os.path.join(ROOT, "proto", "amazonia")
        parts = []
        for name in sorted(os.listdir(lib)):
            if name.endswith(".lua"):
                parts.append(os.path.join(lib, name))
        parts.append(os.path.join(proto, "art", "index.lua"))
        src = os.path.join(proto, "src")
        for name in sorted(os.listdir(src)):
            if name.endswith(".lua"):
                parts.append(os.path.join(src, name))
        expected = "".join(open(p, encoding="utf-8", newline="").read()
                           for p in parts)
        eq(state["script"], expected, "byte-identical to the concatenation")
    finally:
        fake.close()


@case
def daemon_relays_and_journals():
    """serve holds 39998, so a one-shot exec has to go through it."""
    global current
    journal_dir = os.path.join(ROOT, "proto", "amazonia", ".journal")
    journal_md = os.path.join(ROOT, "proto", "amazonia", "JOURNAL.md")
    stash = tempfile.mkdtemp(prefix="ttsd-stash.")
    for path in (journal_dir, journal_md):
        if os.path.exists(path):
            shutil.move(path, os.path.join(stash, os.path.basename(path)))

    fake = FakeTTS()
    daemon = subprocess.Popen([sys.executable, TTSD, "serve"],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              text=True, env=ENV)
    try:
        for _ in range(60):
            if os.path.exists(os.path.join(journal_dir, "ttsd.sock")):
                break
            time.sleep(0.1)

        current = "status sees the daemon"
        run = ttsd("status")
        check("ttsd serve        running" in run.stdout, "status reports it")

        current = "exec relays through the daemon when the port is busy"
        fake.script_result = "relayed"
        run = ttsd("exec", "return AZ.state()")
        eq(run.returncode, 0, "exec still worked with the port held")
        eq(run.stdout.strip(), "relayed", "the value came back through the relay")

        current = "the daemon journals a custom message from Lua"
        fake.reply({"messageID": 4, "customMessage": {"amazonia": {
            "seq": 1, "kind": "move", "what": "Wood", "guid": "4f2a",
            "from": "hex(0,0)", "to": "hex(2,-1)", "who": "White"}}}, delay=0)
        time.sleep(0.6)
        run = ttsd("log", "--since", "all")
        check("move" in run.stdout and "hex(0,0) -> hex(2,-1)" in run.stdout,
              "the move is rendered hex-aware")

        current = "a Game Saved runs the diff and appends to JOURNAL.md"
        fake.reply({"messageID": 6}, delay=0)
        time.sleep(2.5)
        check(os.path.exists(journal_md), "JOURNAL.md was created")
        if os.path.exists(journal_md):
            text = open(journal_md, encoding="utf-8").read()
            check("# Amazonia — observed changelog" in text, "it has a header")
            check("TS_Save_" in text, "it names the save")
            check("hex(0,0) -> hex(2,-1)" in text, "the narrative is in it")
        check(os.path.exists(os.path.join(journal_dir, "snapshot.json")),
              "a snapshot was taken for the next diff")
        check(not os.path.exists(os.path.join(ROOT, "Saves", "snapshot.json")),
              "and it is NOT under Saves/")

        current = "log --since last only shows what is new"
        run = ttsd("log", "--since", "last")
        check("nothing new" in run.stdout, "the cursor advanced past everything")
    finally:
        daemon.terminate()
        try:
            daemon.wait(timeout=5)
        except subprocess.TimeoutExpired:
            daemon.kill()
        fake.close()
        for path in (journal_dir, journal_md):
            if os.path.exists(path):
                shutil.rmtree(path, ignore_errors=True) if os.path.isdir(path) \
                    else os.remove(path)
        for name in os.listdir(stash):
            shutil.move(os.path.join(stash, name),
                        os.path.join(ROOT, "proto", "amazonia", name))
        shutil.rmtree(stash, ignore_errors=True)


def main():
    global current
    print("bridge_spec")
    if socket.socket().connect_ex(("127.0.0.1", TTS_PORT)) == 0:
        print("  SKIP: something is already on port %d." % TTS_PORT)
        print("  These tests need that port to themselves.")
        return 0
    for fn in cases:
        try:
            fn()
        except Exception as exc:  # noqa: BLE001 - a failing case must not stop the run
            global failures
            failures += 1
            print("  ERROR %s: %r" % (current, exc))
    print("%d cases, %d checks, %d failures" % (len(cases), checks, failures))
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
