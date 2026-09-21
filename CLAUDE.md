# Tabletop Simulator — data folder

This is the **live application data directory** for Tabletop Simulator on macOS
(`~/Library/Tabletop Simulator`; on Windows the equivalent lives under
`~/Documents/My Games/`). It is not a code repository. There is no git, no
build, and no test suite — it is 8.7 GB of game state that TTS reads and writes
while it runs.

Work here is one of three things: **save/mod JSON surgery**, **Lua & XML UI
scripting**, or **prototype design** on the owner's own games.

## Rules

1. **Never modify a save in place.** Read `TS_Save_N.json`, write a *new* file.
   The highest number in use is 126, so new work goes to `Saves/TS_Save_127.json`
   and up. There is no version control here — an overwrite is unrecoverable.
2. **Never `Read` a save file directly.** They are pretty-printed JSON up to
   4.4 MB and 106,000 lines (`TS_Save_112`, `TS_Save_121`); one of them will
   consume an entire context window. Use `scripts/tts.py` — every question you
   have about a save has a subcommand.
3. **Treat `Mods/` as read-only.** TTS owns that cache. Deleting from it forces
   re-downloads, and breaks mods entirely when offline or when the original URL
   has rotted.
4. **Autosaves are volatile.** TTS overwrites `TS_AutoSave.json`,
   `TS_AutoSave_2.json` and `TS_AutoSave_3.json` on a timer. Never build on one
   — copy it to a numbered save first.
5. **Check whether TTS is running** before writing anything under `Saves/`
   (`ls -lt Saves | head`). If files changed in the last minute, the game is
   live and will overwrite your work on its next save. Say so rather than
   racing it.
6. **`SaveFileInfos.json` is TTS-owned.** Don't hand-edit it. TTS regenerates it
   by scanning the folder, so a new `TS_Save_127.json` is picked up on its own.

## Layout

```
Tabletop Simulator/
├── CLAUDE.md, docs/, scripts/   this documentation (not part of TTS)
├── .claude/                     three skills and the tts-reference lookup agent
├── reference/mods/<slug>/       Lua & XML of five scripted mods, as grep-able files
├── reference/api/               the scripting API docs, vendored as 55 markdown files
├── reference/framework/         ttslib: the house framework, its starter scripts,
│                                the Woodcutter demo (TS_Save_126) and the tests
├── proto/amazonia/              the owner's tri-hex prototyping rig (TS_Save_127):
│                                tile spec, generated art, Lua source, tests
├── Graphics.json                render settings; the only loose config file
├── DLC/, Screenshots/           empty
├── Saves/                       139 MB
│   ├── TS_Save_<N>.json         a save; the .png beside it is the thumbnail
│   ├── TS_AutoSave{,_2,_3}.json rotating autosaves — volatile, see rule 4
│   ├── SaveFileInfos.json       TTS index: file path -> "N - SaveName - date"
│   ├── Saved Objects/           reusable single components (StandardCounter, TallVase)
│   ├── ProjStdw/ (17 saves)     the owner's prototype, 2023
│   ├── ProjStdwFinal/ (4)       its finished state
│   ├── Kemet/ (2), PalmaresCoop/ (1)
└── Mods/                        8.7 GB, TTS-managed cache — read-only
    ├── Workshop/                56 subscribed mods as <steamid>.json + .png
    ├── Images/ (2.3 GB)         downloaded textures
    ├── Images Raw/ (5.1 GB)     decoded textures (.rawt) — derived, regenerable
    ├── Models/, Models Raw/     .obj meshes
    ├── PDF/ (783 MB)            rulebooks
    ├── Assetbundles/, Audio/, Text/, Translations/
```

## Finding the right save

**Save numbers are meaningless.** `TS_Save_105.json` is a March game and
`TS_Save_123.json` is Container; nothing in the filename says so. The human name
lives in `Saves/SaveFileInfos.json`, which maps each path to a string like
`"125 - Arcs_19-09-26_setup - 9/19/2026 1:34:05 PM"`.

Grep [docs/inventory.md](docs/inventory.md) instead — it lists every save
with name, date, object count and script size, plus all 56 Workshop mods by
title. Regenerate it with `python3 scripts/tts.py inventory` after saving from
TTS.

## The owner's work vs. downloaded mods

This distinction decides how freely you may restructure something.

**Original prototypes** — safe to redesign, this is the owner's own game:

- `Saves/ProjStdw/` and `Saves/ProjStdwFinal/` — 21 saves from 2023, versioned
  by hand (`ProjStdwV1` → `ProjStdwOverhaulV7`). These reference `file:///`
  images from `~/Desktop`, so they are machine-local.
- The 2026 playtest run in the root: `TS_Save_103`/`104` (`pt_1`, `pt_2`),
  `106`–`111` (`pt_3`, `pt_4`, `pt_final_1`, `pt_final_2`, `playtest_final_3`).

**Play states of published mods** — most of the rest (Arcs, Container, Oath,
Food Chain Magnate, Concordia, ROTLA, March of the Ants, ...). Their Lua is the
mod author's luabundle output, often hundreds of KB. Editing it is patching
someone else's build artifact, not writing source: make the smallest possible
change, and never reformat.

## Tooling

`scripts/tts.py` — stdlib Python, no install. Nothing in it modifies an existing
save; every writing subcommand requires an explicit `-o`, `lua inject` /
`xml inject` / `object add` refuse to target their input, and `corpus` refuses to
write anywhere under `Mods/` or `Saves/`.

**Reading:**

```bash
python3 scripts/tts.py summary     Saves/TS_Save_123.json
python3 scripts/tts.py tree        Saves/TS_Save_123.json --filter Deck
python3 scripts/tts.py get         Saves/TS_Save_123.json 'ObjectStates[38]'
python3 scripts/tts.py urls        Saves/TS_Save_123.json --missing-only
python3 scripts/tts.py find-asset  <url | cache-filename>
python3 scripts/tts.py refs        Saves/TS_Save_125.json 8cfcb9      # who references this?
python3 scripts/tts.py validate    Saves/TS_Save_127.json             # before loading it
python3 scripts/tts.py diff        Saves/TS_Save_106.json Saves/TS_Save_107.json --full
python3 scripts/tts.py corpus      Mods/Workshop/3683918449.json -o reference/mods/arcs
python3 scripts/tts.py selftest    # does this tool still write exactly what TTS writes?
python3 scripts/tts.py inventory
```

**Editing an existing save** — always to a new number:

```bash
python3 scripts/tts.py lua extract Saves/TS_Save_125.json -o /tmp/arcs
python3 scripts/tts.py lua inject  Saves/TS_Save_125.json /tmp/arcs/global -o Saves/TS_Save_127.json
python3 scripts/tts.py xml extract Saves/TS_Save_125.json -o /tmp/arcs-ui
python3 scripts/tts.py xml inject  Saves/TS_Save_125.json /tmp/arcs-ui/global -o Saves/TS_Save_127.json
```

**Authoring a new one:**

```bash
python3 scripts/tts.py new         -o Saves/TS_Save_127.json --name "My Game"
python3 scripts/tts.py deck build  --face <url> --back <url> --cols 10 --rows 7 \
                                   --names cards.txt -o parts/deck.json
python3 scripts/tts.py object add  Saves/TS_Save_127.json parts/deck.json \
                                   -o Saves/TS_Save_128.json --at 0,1.5,0
```

`deck build` writes a **Saved Object** — a one-object save, the same thing TTS's
Objects > Saved Objects menu holds — and `object add` puts it on a table with
fresh GUIDs, its tags declared at save level, and its own GUID references
repointed. Both are deterministic: GUIDs are derived from the source, so a
rebuild differs only in the timestamp.

`diff` matches objects by GUID and ignores sub-millimetre physics jitter, so
"change it by hand in TTS, save to a new slot, read the delta" is a practical way
to learn what a field does.

**Run `validate` on any save before loading it**, and on anything you generate.
It only reports — it never rewrites. Findings on an untouched mod are that mod's
own bugs.

`reference/mods/<slug>/` holds the Lua and XML of five scripted mods as real
files, extracted by `corpus`. Grep there instead of re-parsing megabytes of JSON;
each `manifest.json` records the source's sha256, so a Steam update that stales
the corpus is detectable. [docs/mods/](docs/mods/README.md) says which mod
answers which question. Two rules when counting anything in it: exclude
`_bundle.lua`, and deduplicate Arcs' module bodies by hash first — 16 of its
modules are compiled into 2–4 slots each, so a naive grep inflates every figure.

`reference/api/` is <https://api.tabletopsimulator.com/> vendored as 55 markdown
files. **Don't fetch the web for TTS scripting questions — grep
`reference/api/INDEX.md`.** Its second half lists all 264 documented functions
one per line, so a grep for `createButton` names the one page to open.
Regenerate with `python3 scripts/fetch_api_docs.py` (stdlib only; re-running
leaves unchanged pages alone).

`reference/framework/` is `ttslib`. TTS has no `require`, so a build is a
concatenation in load order, and its tests run outside TTS against a stub:

```bash
cat reference/framework/ttslib/*.lua src/*.lua > /tmp/global.lua
python3 scripts/tts.py lua inject Saves/TS_Save_111.json /tmp/global.lua -o Saves/TS_Save_128.json
luajit reference/framework/test/ttslib_spec.lua     # 53 cases, stub TTS, no TTS needed
luajit reference/framework/test/demo_spec.lua       # 20 more, the demo booted
```

`reference/framework/demo/` is **Woodcutter**, `Saves/TS_Save_126.json`: a small
loadable save where all seven modules are load-bearing, and the only end-to-end
test of the authoring commands — `demo/build.sh` makes it from nothing but
`tts.py`. Start there when you want to see the framework work rather than read
about it. See [demo/README.md](reference/framework/demo/README.md).

`proto/amazonia/` is the owner's tri-hex prototyping rig, `Saves/TS_Save_127.json`
— built to [docs/amazonia-build-plan.md](docs/amazonia-build-plan.md) and the
only thing here with a live channel to a running game. Two new stdlib tools
serve it, and neither writes under `Mods/` or `Saves/`:

```bash
python3 scripts/tilegen.py                        # spec/tiles.json -> art/
python3 scripts/tilegen.py --check                # regenerate, assert unchanged
python3 scripts/luacat.py --lint                  # the build's shadowed-global lint
python3 scripts/ttsd.py status                    # is TTS listening on 39999?
python3 scripts/ttsd.py exec 'return AZ.state()'   # run Lua in the live game
python3 scripts/ttsd.py call tint jungle 2E6B33   # sugar over exec
python3 scripts/ttsd.py serve                     # journal + diff on every save
proto/amazonia/build.sh Saves/TS_Save_128.json    # the whole save, from source
```

`tilegen.py` mints the tri-hex mesh, its collider and its diffuse from
`proto/amazonia/spec/tiles.json`; filenames are content hashes because TTS
caches by mangled URL. `ttsd.py` is the External Editor API (ports 39999 out,
**39998 in** — replies do not come back on the request connection, and
**v14.2.2 never sends message ID 5**, so a return value comes back as a marked
`print`). `luacat.py` is the `cat` that makes a build, plus the one lint a
concatenation needs: **a top-level `local` in an earlier file stays in scope, so
a later file assigning that name overwrites a library module instead of making a
global.** That shipped a broken save on 2026-09-21 — `ttslib/01-async.lua` holds
its module in `local A` — so `build.sh` and `ttsd.py push` both refuse a build
the lint flags. Start at
[proto/amazonia/README.md](proto/amazonia/README.md), which explains the three
iteration loops the rig is arranged around.

## Reference

**Skills and agent** (`.claude/`, loaded automatically when they apply):

- **tts-mod-surgery** — editing a published mod or an existing save. The safety
  rules as a procedure, plus the four pre-flight checks.
- **tts-prototype** — the owner's own games, on `ttslib` by default.
- **tts-scripting** — writing Lua and XML UI; a router to the cookbook, the
  vendored API and the framework.
- **tts-reference** *(agent)* — read-only lookup over the corpus and the API
  docs, answering with `file:line` citations. Ask it "how does Arcs handle
  turn order?" instead of grepping 11 MB of JSON into your own context.

**Scripting:**

- [docs/framework.md](docs/framework.md) — **`ttslib`, the house framework, and
  the architecture to write new prototypes in.** Seven modules in
  [reference/framework/](reference/framework/README.md), each answering one
  numbered defect from the critique: roles instead of GUIDs, anchor-relative
  placement, named buttons, versioned state, one tag-routed event dispatcher,
  bounded waits, loud failure. Includes the step-by-step for adding it to a
  prototype that has no scripting at all.
- [docs/cookbook/](docs/cookbook/README.md) — ten task-keyed recipes with
  decision tables: architecture, lifecycle, buttons, XML UI, state, containers
  and tags, placement, players and turns, decks, antipatterns. Every recipe cites
  a real exemplar by mod, GUID and file:line. **Start at its README's decision
  tables.**
- [docs/mods/](docs/mods/README.md) — which of the five reference mods to open
  for which question, one profile each, and what breaks if you edit one. Includes
  the non-Lua infrastructure table (snap points, states, tags, decals) — the
  measurable gap between those mods and the owner's prototypes.
- [docs/critique.md](docs/critique.md) — C1–C10, what those mods get wrong and
  why, with quoted evidence. Its *Corrections to earlier figures* section
  supersedes any figure that disagrees with it.
- [docs/review-2026-09-21.md](docs/review-2026-09-21.md) — **the audit of all of
  the above, and the open work order.** Six runtime bugs in `ttslib`, two
  missing guards in `tts.py`, and a set of documentation figures to correct. Its
  *Canonical figures* table is the current authority on every count in this
  folder; its *Already verified* table says what has been checked so you need
  not check it again. Read it before editing `reference/framework/` or any
  number in `docs/`.
- [docs/amazonia-build-plan.md](docs/amazonia-build-plan.md) — **built, awaiting
  the two in-game gates.** The build brief for Amazonia, the owner's tri-hex
  prototyping rig: a `Custom_Model` tile generator, a bridge to TTS's External
  Editor API on port 39999, and an observed changelog. It carries the measured
  tri-hex mesh geometry, the `Grid.Type` enum and the protocol, so nothing needs
  re-deriving. The rig is [proto/amazonia/](proto/amazonia/README.md) and
  `Saves/TS_Save_127.json`; the plan's *Implementation record* says what was
  built, what changed from the brief, and what only loading it in TTS can prove.

Three questions the corpus cannot settle — whether TTS matches component tags,
Object members and the `onload` callback name case-insensitively — are collected
in [cookbook/10-antipatterns.md](docs/cookbook/10-antipatterns.md#open-questions-test-these-in-tts),
each with a two-minute test to run in TTS. Until then, write the conservative
form.

**Format:**

- [docs/save-format.md](docs/save-format.md) — the JSON schema: `ObjectStates`
  recursion, object types, which fields are load-bearing, the deck `CardID`
  rule, and the Lua extract/inject round-trip.
- [docs/asset-cache.md](docs/asset-cache.md) — how `Mods/` caching works, the
  URL→filename rule, the `.rawt` container, and the local-asset prototype
  pipeline.
- [docs/inventory.md](docs/inventory.md) — generated catalog of every save and
  mod.
- TTS scripting API: <https://api.tabletopsimulator.com/> — but grep
  `reference/api/INDEX.md` instead of fetching it.
