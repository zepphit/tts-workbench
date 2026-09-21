# The five reference mods

Five complex scripted mods, extracted into `reference/mods/` as 229 grep-able
`.lua` and `.xml` files by `tts.py corpus` (220 excluding the nine
`_bundle.lua`; 243 files in the tree counting each `manifest.json` and
`_index.json`). These profiles tell you **which mod
to open for which question**, and what will break if you edit one.

They are references for their **thoroughness**, not their design. Read
[critique.md](../critique.md) for what they get wrong and
[cookbook/](../cookbook/README.md) for what to do instead.

| Mod | Slug | Architecture | Profile |
| --- | --- | --- | --- |
| Politik | `politik` | logic on objects, object-attached XML UI | [politik.md](politik.md) |
| Railways of the Lost Atlas | `rotla` | logic on objects, vendored 18Engine | [rotla.md](rotla.md) |
| Arcs: Celestial Edition | `arcs` | luabundle, 26 modules across 10 slots | [arcs.md](arcs.md) |
| Rurik: Second Edition | `rurik` | global XML panels, tag-based resolution | [rurik.md](rurik.md) |
| Almoravid | `almoravid` | one 219 KB monolith | [almoravid.md](almoravid.md) |

## Consult *this* mod for *that* question

| Question | Mod | Where |
| --- | --- | --- |
| How do I lay out a luabundle source tree? | Arcs | `arcs/global/_index.json`, 26 modules |
| How do object scripts talk to Global? | Arcs | 13-name `Global.call` bus, 60 sites |
| How do I resolve objects without GUIDs? | **Rurik** | `rurik/global/script.lua:34` `rebuildTagCache` |
| How do I boot a multi-step setup? | **Rurik** | `rurik/global/script.lua:150` coroutine + `waitByTag` |
| How do I build a screen-space menu? | **Rurik** | `rurik/global/ui.xml`, `UI.show`/`UI.hide` |
| How do I attach XML UI to a component? | **Politik** | `politik/objects/1efc34/ui.xml`, `Defaults`+`class` |
| How do I build XML at runtime? | Politik | `politik/global/script.lua:165` → `setXml` at `:281` |
| How do I track what is in a container? | **RotLA** | `rotla/objects/54bdb7/script.lua` (×51) |
| How do I make a bag that returns things? | **RotLA** | `rotla/objects/93c2a0/script.lua` `filterObjectEnter` |
| How do I build buttons in a loop? | RotLA | `rotla/global/script.lua:1462` `setVar` closures |
| How do I place 500 components? | Almoravid | `almoravid/global/script.lua:479` — the shape, not the style |
| How do I place things relative to a board? | **Arcs** | `arcs/global/src__AmbitionMarkers.lua:1037` |
| How do I use snap points and tags together? | **Arcs**, Politik, RotLA | Arcs 245 tagged table snaps; Politik 1,130 tagged object snaps; RotLA 117 of 119, the smallest set to read first |
| How do I drive the turn system? | **Arcs** | `arcs/objects/7299d7/src__BaseGame.lua:1049`, `Turns.*` |
| How do I move a player's camera? | Arcs, Politik | `arcs/global/src__Camera.lua:7` |
| How do I debounce a drop event? | **Arcs** | `arcs/global/src__events__DropActionEvents.lua:11` |
| How do I retry until something spawns? | **Arcs** | `arcs/global/src__Global.lua:864` bounded retry |
| How do I run a repeating timer? | Arcs | `arcs/global/src__Timer.lua:35`, `Wait.stop` at `:49` |
| How do I add a context menu? | Arcs | `arcs/global/src__Global.lua:833`, 27 items |
| What does a game with **no** infrastructure look like? | *the owner's saves* | see the table below |

Bold is the mod to read first.

## Non-Lua infrastructure

The part that is *not* code, and the biggest measurable gap between these mods
and the owner's prototypes. All figures re-derived from the mod JSON on
2026-09-20 by walking `ObjectStates` through both `ContainedObjects` and
`States`.

| | table snaps | object snaps | *of those, tagged* | objects w/ States | tag labels declared | tags in use | objects tagged | decal palette | decals placed |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Politik | 4 | 1,562 | 1,130 | 0 | 31 | 14 | 1,323 | 0 | 0 |
| RotLA | 0 | 119 | 117 | 0 | 16 | 16 | 469 | 0 | 0 |
| Arcs | 320 | 245 | 234 | 194 | 88 | 72 | 1,668 | 0 | 208 |
| Rurik | 108 | 655 | 28 | 5 | 147 | 61 | 329 | 8 | 2 |
| Almoravid | 0 | 11 | 0 | 2 | 0 | 0 | 0 | 139 | 120 |
| **`TS_Save_111`** *(owner)* | **0** | **0** | **0** | **0** | **0** | **0** | **0** | **0** | **0** |
| **`ProjStdwFinal/TS_Save_22`** | **0** | **0** | **0** | **0** | **0** | **0** | **0** | **0** | **0** |

Reading the columns:

- **table snaps** — top-level `SnapPoints`, world space. **object snaps** —
  `AttachedSnapPoints`, object-local space, so they move with the component.
  Arcs tags 245 of its 320 table snaps and 234 of its 245 object snaps, using the
  same vocabulary its scripts query; a tagged snap point accepts only matching
  components. **RotLA tags 117 of its 119**, from the same vocabulary as its
  component tags — `Token` ×33, `Minor` ×32, `Share` ×24, `Round` ×10,
  `MetroToken` ×10, `Major` ×8 — which makes it the smallest worked example of
  the pattern in the corpus. It places none on the table, so its 0 in the first
  column is a real 0.
- **objects w/ States** — objects carrying an alternate-state dict. The dict
  holds the *other* states, so Arcs' 194 objects have one alternate each, while
  Almoravid's 2 objects have five each (10 alternate states total).
- **tag labels declared** is `ComponentTags.labels` — the palette TTS shows in
  its UI, which drifts ahead of what is actually used. Rurik declares 147 and
  uses 61.
- **decal palette** is `DecalPallet` (declared images); **decals placed** counts
  `AttachedDecals` on objects plus top-level `Decals`. Almoravid is 139 declared
  and 120 placed; Rurik has 8 declared, 0 attached and 2 on the table.

> The brief's version of this table conflated some of these columns — it counted
> `DecalPallet` for one mod and `DecalPallet + AttachedDecals` for another, and
> its tag column was the declared-label count rather than tags in use. The
> figures above are the re-derived ones. See
> [Corrections](#corrections-to-earlier-figures).

## Reading the corpus

```
reference/mods/<slug>/
├── manifest.json          source path, sha256, save date, per-slot file map,
│                          and shared_modules (the C5 duplication report)
├── global/
│   ├── script.lua         an unbundled global script
│   │   ── or ──
│   ├── _bundle.lua        the original bundled field (never grep this)
│   ├── _index.json        byte ranges, for lossless re-splicing
│   └── src__Global.lua    one file per module; `__` encodes `/`
│   └── ui.xml             the global XmlUI, if any
└── objects/<guid>/
    ├── script.lua
    └── ui.xml
```

Two rules when counting anything:

- **Exclude `_bundle.lua`.** Each bundled slot is written out both as individual
  modules and as the original concatenated bundle.
- **Deduplicate module bodies by hash** before counting anything about Arcs — 16
  of its modules are compiled into 2–4 slots each.

See [critique.md § Method](../critique.md#method).

### Is the corpus stale?

Each `manifest.json` records the source's sha256. A Steam update that changes a
mod makes the corpus stale, detectably:

```bash
python3 -c "import json,hashlib;m=json.load(open('reference/mods/arcs/manifest.json'));\
print(m['sha256']==hashlib.sha256(open(m['source'],'rb').read()).hexdigest())"
```

Re-extract with:

```bash
python3 scripts/tts.py corpus Mods/Workshop/3683918449.json -o reference/mods/arcs
```

`corpus` refuses to write anywhere under `Mods/` or `Saves/`.

## What `validate` says about them today

Every finding is the mod's own bug, not something this folder introduced.

| Mod | ERROR | WARN | What |
| --- | --- | --- | --- |
| Politik | 0 | 1 | one GUID twice in one container |
| RotLA | 0 | 13 | duplicate GUIDs within containers |
| Arcs (mod) | 0 | 16 | 16 modules compiled into 2–4 slots each, all identical |
| Arcs (`TS_Save_125`) | **3** | 11 | 3 `getObjectFromGUID` literals in `src/GUIDs` matching no object |
| Rurik | 0 | 2 | duplicate GUIDs within containers |
| Almoravid | 0 | 54 | 54 `getObjectFromGUID` literals resolving only inside containers |
| *owner's `TS_Save_111`* | 0 | 0 | clean |

```bash
python3 scripts/tts.py validate Mods/Workshop/3683918449.json
```

## Editing any of them

The rules in [CLAUDE.md](../../CLAUDE.md) apply — never modify a save in place,
never read one directly, treat `Mods/` as read-only. Four checks before touching
a mod, each expanded in the relevant profile:

1. **Shared module?** If it appears in more than one bundle slot, the edit must
   be applied to **every** copy. `manifest.json`'s `shared_modules` lists them.
2. **Vendored engine?** If the file declares an upstream boundary, changes below
   it are lost on upgrade — RotLA line 258.
3. **Mod JSON or play-state?** Objects destroyed at game start exist only in
   `Mods/Workshop/`. Arcs' `Setup` (`7299d7`) is 257 KB of script that is
   **absent** from `TS_Save_125`.
4. **Who references this?** `tts.py refs`, plus a grep of `Nickname`,
   `Description` and `GMNotes` — all three are load-bearing in at least one of
   these mods.

## Corrections to earlier figures

Re-deriving the numbers for these profiles corrected four, on top of the six
already recorded in [critique.md](../critique.md#corrections-to-earlier-figures).
The [2026-09-21 review](../review-2026-09-21.md) corrected two more — the last
two rows, both of them in this file's own table:

| Claim | Corrected |
| --- | --- |
| A single "tags" column, 31 / 88 / 147 for Politik / Arcs / Rurik | Those are **declared labels** (`ComponentTags.labels`). Tags actually **in use** are **14 / 72 / 61** — a different thing, and the one that matters |
| A single "decals" column: Rurik 8, Almoravid 259, Arcs 208 | Three different measures. Rurik: 8 declared, 0 attached, 2 on the table. Almoravid: 139 declared + 120 attached = 259. Arcs: 0 declared, 208 attached |
| Arcs' `Global.call` bus: 62 sites (brief) / 63 (critique) | **13 distinct names, 60 real call sites.** 62 textual `Global.call(` occurrences, 2 of them inside comments; 63 counts one further comment mention. The brief's "13-function bus" was right all along |
| RotLA absent from the infrastructure table | Added: **0 table snaps, 119 object snaps, 117 of them tagged**, 0 States, 16 labels all in use, 469 objects tagged, no decals |
| RotLA's object snaps: none tagged | **117 of 119 carry `Tags`.** The first pass read only its table snaps, which really are 0. Corrected in the table above, in the routing row, and in [rotla.md](rotla.md) |
| Rurik: 330 objects tagged | **329.** The save-level `"Tags": []` was counted as an object |

The "States" column needed no correction but does need a reading: it counts
objects *carrying* a `States` dict, not states. Almoravid's 2 objects hold 5
alternates each.

The same distinction applies to critique.md's Arcs `pcall` figure: **256**
mentions of the word, **255** actual call sites — the odd one out is a comment at
`reference/mods/arcs/global/src__SheetsSender.lua:330`. Both readings are
defensible; the call-site count is the one to quote.
