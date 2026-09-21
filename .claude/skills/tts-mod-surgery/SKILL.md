---
name: tts-mod-surgery
description: Modify a published Tabletop Simulator mod or an existing save — patching someone else's Lua or XML UI, fixing a bug in Arcs/Rurik/RotLA/Politik/Almoravid, changing an object inside a save, or deleting something from one. Use whenever the change lands inside a .json under Saves/ or Mods/Workshop/ that you did not author. Encodes the folder's safety rules as a procedure: check TTS is not running, locate, pre-flight, smallest possible edit, inject to a NEW numbered save, validate, report.
---

# Mod surgery

You are editing **someone else's build artifact**, not writing source. Their Lua
is luabundle output or a 219 KB monolith; their formatting is not yours to fix.
Make the smallest change that works, and never reformat.

There is no git here and no undo. An overwrite is unrecoverable.

## 0. Is TTS running?

```bash
ls -lt "Saves" | head
```

If anything changed in the last minute the game is live and will overwrite your
work on its next autosave. **Say so and stop** — do not race it.

## 1. Locate, without reading the file

Never `Read` a save or mod JSON: they are pretty-printed to 4.4 MB and 106,000
lines, and one will consume the whole context window. Save numbers are
meaningless; the names live in `docs/inventory.md` and `Saves/SaveFileInfos.json`.

```bash
grep -i "arcs" docs/inventory.md                      # which save is it?
python3 scripts/tts.py summary Saves/TS_Save_125.json
python3 scripts/tts.py tree    Saves/TS_Save_125.json --filter Deck --depth 2
python3 scripts/tts.py get     Saves/TS_Save_125.json 'ObjectStates[38]' --no-children
python3 scripts/tts.py lua extract Saves/TS_Save_125.json --list
```

For "how does this mod do X", ask the **tts-reference** agent rather than
grepping megabytes yourself. The extracted corpus is at
`reference/mods/<slug>/`; `docs/mods/<slug>.md` profiles each one.

## 2. Four pre-flight checks

Every one of these has bitten a real mod in this corpus. See
[docs/mods/README.md](../../../docs/mods/README.md#editing-any-of-them).

1. **Is it a shared module?** luabundle inlines dependencies, so one module can
   exist in several slots — 16 of Arcs' do, in 2–4 slots each, byte-identical
   until you edit one. `lua extract` prints a warning; `manifest.json`'s
   `shared_modules` lists them; `validate` reports `duplicated-module` and
   escalates to `drifted-module` once copies disagree. **Apply the edit to every
   copy** (C5).
2. **Is it below a vendored-engine boundary?** RotLA's Global is a paste of
   18Engine v2.96, with `---VERSION 2.96, copy and paste everything below this
   line to update!` at `reference/mods/rotla/global/script.lua:258`. Anything you
   change below that line dies at the next engine upgrade. Change it above, or
   say why it has to go below (C10).
3. **Mod JSON or play-state?** Objects destroyed at game start exist only in
   `Mods/Workshop/<id>.json`. Arcs' `Setup` object `7299d7` is 257 KB of script
   and is **absent** from `Saves/TS_Save_125.json` — you cannot patch it through
   a save. But `Mods/` is read-only (rule 3): to change one, copy the mod JSON
   out, edit the copy, and hand it back as a save, saying plainly what you did.
4. **Who references this?** Before touching or deleting anything:
   ```bash
   python3 scripts/tts.py refs Saves/TS_Save_125.json bb7d21
   grep -rn "bb7d21" reference/mods/arcs/ --include=*.lua
   ```
   `Nickname`, `Description` and `GMNotes` are load-bearing in these mods —
   Arcs branches its whole load path on `reach_board`'s `Description` being
   `"in progress"`, and RotLA stores a bag's GUID in a token's `GMNotes`. A
   "tidy-up" of a name is a functional change.

## 3. Edit

```bash
python3 scripts/tts.py lua extract Saves/TS_Save_125.json -o /tmp/arcs
# edit exactly the lines you must, in /tmp/arcs/<slot>/<module>.lua
python3 scripts/tts.py lua inject  Saves/TS_Save_125.json /tmp/arcs/global -o Saves/TS_Save_127.json
```

`xml extract` / `xml inject` are the same round-trip for `XmlUI`.

- **Pick the next free number.** `ls Saves/TS_Save_*.json | sort -V | tail -3`.
  Never overwrite: `inject` refuses to target its own input, but it will happily
  write over a *different* save you name.
- **Injecting a directory** needs the `_index.json` that `lua extract` wrote —
  that is what re-splices bundled modules losslessly. A plain folder of `.lua`
  files is not a slot; inject a single file instead.
- **Match the local idiom.** Their spacing, their naming, their error handling.
  A diff that touches one line is reviewable; a reformatted file is not.
- **Do not "fix" adjacent bugs** unless asked. Note them in the report instead.

## 4. Validate before anyone loads it

```bash
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

It reports and never rewrites. Compare against the **baseline** for that mod in
[docs/mods/README.md](../../../docs/mods/README.md#what-validate-says-about-them-today) —
these mods ship with findings that are their own bugs (Almoravid 54 warnings,
Arcs' play state 3 errors). What matters is whether *your* edit added one.

A save this tool wrote is byte-compatible with TTS's own writer (`tts.py
selftest` round-trips every file in the folder). Anything else that edits the
JSON will reformat the whole file on TTS's next save.

## 5. Report

- which save you wrote, and that the original is untouched;
- the change, as the smallest possible diff;
- `validate` before and after, with the baseline named;
- anything you found and deliberately left alone.

Then: the only real test is loading it in TTS. Say that, and say what to click.

## Never

- Modify a save in place, or write into `Mods/` (it is TTS's cache; deleting
  from it forces re-downloads and breaks mods offline).
- Build on `TS_AutoSave*.json` — TTS overwrites them on a timer. Copy to a
  numbered save first.
- Hand-edit `LuaScriptState` (runtime state, double-encoded, overwritten on the
  next save) or `SaveFileInfos.json` (TTS regenerates it by scanning the folder).
- Reformat, re-indent or "modernise" a mod's code.
