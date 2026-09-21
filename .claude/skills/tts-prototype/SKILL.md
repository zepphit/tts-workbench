---
name: tts-prototype
description: Work on the owner's own Tabletop Simulator games — starting a new prototype, extending an existing one (ProjStdw, ProjStdwFinal, the pt_/playtest saves), adding scripting to a prototype that has none, building decks from art sheets, adding snap points and component tags, or scaffolding a new save. Use for the owner's original designs, where redesign is allowed; use tts-mod-surgery instead when patching a published mod.
---

# Prototyping the owner's own games

These are the owner's designs: **redesign is allowed here.** You are not
patching someone else's build artifact, so structure, naming and architecture are
open. What is not open are the folder's safety rules — no git, no undo.

## Which saves are the owner's

| Where | What |
| --- | --- |
| `Saves/ProjStdw/` (17), `ProjStdwFinal/` (4) | the 2023 prototype, hand-versioned `ProjStdwV1` → `ProjStdwOverhaulV7` |
| `Saves/TS_Save_103`, `104`, `106`–`111` | the 2026 playtest run: `pt_1`…`playtest_final_3` |
| everything else in `Saves/` | play states of **published** mods — that is mod surgery, not this |

`grep -i <name> docs/inventory.md` maps names to numbers; save numbers carry no
meaning. Note the ProjStdw saves reference `file:///` images under `~/Desktop`,
so they are machine-local — an asset that has moved will not load.

## Default: build it on `ttslib`

The house framework exists because the owner's prototypes measurably lack what
five shipped mods all use: `TS_Save_111` and `ProjStdwFinal/TS_Save_22` carry
TTS's 320-character default stub, **zero** object scripts, snap points, tags and
States. Read [docs/framework.md](../../../docs/framework.md) — especially
*Adding `ttslib` to a prototype that has no scripting*, which is the seven-step
ladder. You can stop at any rung and the result still works:

1. **Copy the save** to a new number — never edit in place. Starting from
   nothing instead? `tts.py new -o Saves/TS_Save_<next>.json --name "..."`
   writes an empty table in TTS's own format, and `tts.py object add` puts
   Saved Objects on it with fresh GUIDs and their tags declared.
2. **Tag the components in TTS** (right-click → Tags). One axis per tag:
   `coin` + `blue`, never `bluecoin`. This alone is the fix for addressing
   objects by GUID (C1).
3. **Write the manifest and boot.** Copy `reference/framework/Global.lua`,
   replace `ROLES`, build, load, read the chat: `registry.check()` names
   everything not yet tagged.
4. **Capture the positions you already like** — `layout.capture(obj)` prints a
   component's anchor-relative coordinates; paste them into `SPACES`. This turns
   a hand arrangement into a table without measuring anything.
5. **Add snap points** from those same coordinates, tagged so only the right
   component lands there. Players feel this immediately, with no more scripting.
6. **Add behaviour by tag, not by object** — `events.on` in Global, never a
   script pasted onto 51 bags (C6, C7).
7. **Persist only what the table cannot tell you** — a round number, a mode. A
   cube's position on a track *is* the score; derive it (C4).

## The loop

```bash
ls -lt Saves | head                      # TTS running? if so, stop and say so
cat reference/framework/ttslib/*.lua src/*.lua > /tmp/global.lua
python3 scripts/tts.py lua inject Saves/TS_Save_111.json /tmp/global.lua -o Saves/TS_Save_127.json
python3 scripts/tts.py validate Saves/TS_Save_127.json
luajit reference/framework/test/ttslib_spec.lua    # library logic, no TTS needed
```

TTS has no `require`, so a build is a concatenation in load order — hence the
`00-`…`06-` prefixes. Pick the next free save number with
`ls Saves/TS_Save_*.json | sort -V | tail -3`. For live iteration while the game
is running, read `reference/api/externaleditorapi.md` rather than assuming the
protocol.

`reference/framework/demo/build.sh` is this loop written out end to end, from an
empty table to a loadable save; `Saves/TS_Save_126.json` is what it produces.
Copy its shape rather than inventing one.

To find out what a TTS setting or field actually does, change it by hand in TTS,
save to a new number, and run `tts.py diff <before> <after>` — it matches objects
by GUID and ignores physics jitter, so the delta is a page rather than a diff of
100,000 lines.

## Components

**Snap points** are the biggest single gap — data, not code, and they make a
position exist for the *player*. Politik has 1,562, the owner's prototypes have
0. `layout.snaps(anchor, {...})` writes them from the same local coordinates the
layout table uses; tag them and only matching components will snap there. See
[docs/cookbook/07-placement.md](../../../docs/cookbook/07-placement.md).

**Decks** are the card-heavy part of these saves. The invariant, from
[docs/save-format.md](../../../docs/save-format.md#decks-and-card-ids):

```
CardID = <CustomDeck sheet key> * 100 + <zero-based index on that sheet>
```

`DeckIDs` must list the same IDs as `ContainedObjects`, in the same order and
length. A card *inside* a deck also keeps a stale `CustomDeck` key of its own —
only the deck's is authoritative, so do not "fix" the card's. `validate` checks
both invariants; run it before loading anything you generated.

Do not write those ids by hand. `tts.py deck build` takes a sheet URL and a
grid, honours the rule, and writes a Saved Object that `object add` drops onto a
table — see
[docs/cookbook/09-decks-cards.md](../../../docs/cookbook/09-decks-cards.md#building-decks).

**Anything a script places** goes through `positionToWorld` on an anchor;
anything a player places by hand gets a snap point. No world-space coordinate
literals — that is the defect that makes Almoravid's 925 placements
un-editable (C2).

## Before handing back

- `validate` is clean, or every finding is explained.
- TTS was not running when you wrote (`ls -lt Saves | head`).
- You wrote a **new** numbered save and said which.
- The library's tests pass, if you changed anything under
  `reference/framework/`.
- You said what to click in TTS to see it work. Loading it is the only real
  test of generated JSON; do not claim it works until someone has.
