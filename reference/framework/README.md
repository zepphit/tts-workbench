# `ttslib` — source

The house framework for prototypes built in this folder. **The guide is
[docs/framework.md](../../docs/framework.md)**; this file is just the map.

```
ttslib/          the library, seven files, concatenated in filename order
  00-log.lua       levels, loud failure, the only sanctioned pcall   (C8)
  01-async.lua     bounded waits: frames, keyed, settle, retry, debounce (C9)
  02-store.lua     declared state, versioned, one generated onSave    (C4)
  03-ui.lua        buttons by name, not by index; XML wrappers        (C3)
  04-events.lua    one dispatcher, routed by component tag        (C6, C7)
  05-registry.lua  objects by role tag, with a boot manifest          (C1)
  06-layout.lua    anchor-relative placement, spaces, snap points     (C2)
Global.lua       the starter Global script — copy this and edit it
ObjectScript.lua the thin object-script template (architectural rule 1)
demo/            Woodcutter: a runnable save built on all seven  (Saves/TS_Save_126)
test/            a stub TTS, and the specs that run against it
```

The C-numbers are the defects in [docs/critique.md](../../docs/critique.md) that
each module exists to answer.

## Build

TTS has no `require`, so a build is a concatenation in load order — which is what
the numeric prefixes are for.

```bash
cat reference/framework/ttslib/*.lua src/*.lua > /tmp/global.lua
python3 scripts/tts.py lua inject Saves/TS_Save_111.json /tmp/global.lua -o Saves/TS_Save_127.json
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

Check TTS is not running before writing under `Saves/`, and write to a new
number: nothing here is under version control.

## Demo

[demo/](demo/README.md) is the library's real test: a small loadable save where
every one of the seven modules is load-bearing, built end to end by
`tts.py new` / `object add` / `lua inject` / `xml inject`.

```bash
reference/framework/demo/build.sh     # -> Saves/TS_Save_126.json
```

## Test

```bash
luajit reference/framework/test/ttslib_spec.lua   # 45 cases, the modules
luajit reference/framework/test/demo_spec.lua     # 19 cases, the demo booted
```

64 cases against a stub TTS. They prove the library's own logic, not TTS's
semantics — [harness.lua](test/harness.lua) says exactly where that line is.
