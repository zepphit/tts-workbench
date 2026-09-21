# Arcs: Celestial Edition

**Read this mod for:** luabundle module structure, anchor-relative placement, the
async patterns worth stealing, zone-routed scoring, turns and context menus.

**Read it critically.** It is also the source of five of the ten critique items:
duplicated modules (C5), positional button indexes (C3), state in `Description`
(C4), blanket `pcall` (C8) and buried async (C9).

| | |
| --- | --- |
| Corpus | [`reference/mods/arcs/`](../../reference/mods/arcs/) |
| Source | `Mods/Workshop/3683918449.json`, 4.9 MB, TTS v14.2.2, saved 2026-08-30 |
| Play state | `Saves/TS_Save_125.json` — **9 slots, not 10** (see below) |
| Architecture | luabundle 1.6.0, **26 modules** in the Global bundle, 10 script slots |
| Global Lua | 550,845 chars |
| Deduplicated | 38 modules, 18,067 lines |
| Object scripts | 9 slots, 8 of them bundled |
| XML UI | none — no `XmlUI`, no `CustomUIAssets`. All UI is object buttons |
| Objects | 1,823 (310 at table level) |
| `validate` (mod) | 0 errors, 16 warnings — 16 modules in 2–4 slots each |
| `validate` (`TS_Save_125`) | **3 errors**, 11 warnings |

---

## The bundle layout

luabundle output: a ~1 KB runtime preamble, one `__bundle_register(name, fn)` per
module, then `return __bundle_require("Global.-1.lua")`. `tts.py corpus` splits
it back into files and records byte ranges in `_index.json`, so edits can be
spliced back losslessly.

The Global bundle's 26 modules, largest first:

| Module | chars | What |
| --- | --- | --- |
| `src/BaseGame` | 99,330 | base-game setup |
| `src/Global` | 90,097 | the entry module: events, scoring, the `Global.call` surface |
| `src/SheetsSender` | 55,091 | Google Sheets integration |
| `src/SetupControl` | 42,884 | the setup UI — 32 `createButton`, 42 `editButton` |
| `src/AmbitionMarkers` | 41,868 | ambition scoring; the **best placement code** here |
| `assets/leaders_starting_pieces` | 41,404 | pure data |
| `src/Supplies` | 27,902 | |
| `src/ActionCards` | 22,988 | |
| `src/ArcsPlayer` | 21,787 | a per-player class; zone-routed scoring |
| `src/Campaign` | 16,505 | |
| `src/integrations/ErrataFaqService` | 16,454 | |
| `src/Control` | 14,586 | |
| `src/Counters` · `src/GUIDs` · `src/SheetsSenderOverlay` | 8.9 / 7.7 / 7.5 K | |
| `src/Timer` · `src/Camera` · `src/RoundManager` | 5.2 / 5.0 / 4.6 K | |
| `src/events/DropActionEvents` · `src/events/OverlayChatCommands` | 3.8 / 3.5 K | |
| `assets/leaders_pnp2_starting` · `src/InitiativeMarker` · `src/Resource` | 3.3 / 2.5 / 2.5 K | |
| `src/Merchant` · `src/LOG` | 729 / 688 | |
| `Global.-1.lua` | 21 | the root: just requires `src/Global` |

**Entry points.** `Global.-1.lua` → `src/Global`. Its `onLoad(script_state)` is
at `reference/mods/arcs/global/src__Global.lua:2453`, and its single `onSave` at
`:2674` — one save handler for 18,067 lines.

### The ten script slots

| Slot | Nickname | Type | chars | modules |
| --- | --- | --- | --- | --- |
| `global` | — | — | 550,845 | 26 |
| `7299d7` | **Setup** | CardCustom | 256,970 | 13 |
| `6e21fe` | Control | CardCustom | 149,443 | 11 |
| `0289cb` | Zero Marker | Custom_Tile | 127,409 | 8 |
| `af1f85` | Dice Board | Custom_Tile | 16,015 | 2 |
| `069307` / `4798a5` | Dice Counter ×2 | Custom_Tile | 7,197 each | 2 |
| `7a33fa` | Court Discard Zone | ScriptingTrigger | 6,350 | 2 |
| `4fcf71` | Leaders | Deck | 4,385 | 0 |
| `f0362b` | Book of Law | Custom_Model_Bag | 2,089 | 2 |

> **`7299d7` "Setup" exists only in the mod.** It is destroyed at game start, so
> `Saves/TS_Save_125.json` has nine slots, not ten — and 257 KB of setup script is
> unreachable through a play-state save. To edit it you must go to
> `Mods/Workshop/3683918449.json`. This is pre-flight check 3 for mod surgery.

---

## C5, live: 16 modules in 2–4 slots each

luabundle inlines every dependency into every bundle, so a module required by
both Global and an object script is compiled into both.

| Module | Copies | Slots |
| --- | --- | --- |
| `src/ActionCards`, `src/ArcsPlayer`, `src/GUIDs`, `src/LOG`, `src/Resource`, `src/Supplies` | 4 | `global`, `0289cb`, `6e21fe`, `7299d7` |
| `src/AmbitionMarkers` | 3 | `global`, `0289cb`, `6e21fe` |
| `src/InitiativeMarker` | 3 | `global`, `6e21fe`, `7299d7` |
| `src/BaseGame`, `src/Campaign`, `src/Counters`, `src/Merchant`, `src/SetupControl` | 2 | `global`, `7299d7` |
| `src/Control`, `src/RoundManager` | 2 | `global`, `6e21fe` |
| `src/DiceCounter` | 2 | `069307`, `4798a5` |

16 modules in 46 copies, across the six slots that carry a bundle.

All copies are currently byte-identical, recorded with per-copy sha256 in
`manifest.json`'s `shared_modules`. See it in one command:

```bash
python3 scripts/tts.py refs Mods/Workshop/3683918449.json bb7d21
```

`reach_board_GUID = "bb7d21"` comes back four times. **Edit one and three keep
the old value, with no error.** `tts.py validate` reports `duplicated-module`
while they match and escalates to `drifted-module` (ERROR) the moment they do
not.

---

## The `Global.call` bus

Object scripts reach Global through **13 named functions, 60 call sites** across
the deduplicated corpus:

| Function | Calls | | Function | Calls |
| --- | --- | --- | --- | --- |
| `move_and_lock_object` | 14 | | `ambition_refresh_proxy` | 3 |
| `getOrderedPlayers` | 13 | | `set_game_in_progress` | 2 |
| `update_player_scores` | 6 | | `print_ambition_estimates` | 2 |
| `getOrderedPlayersStartingWith` | 6 | | `refresh_player_steam_name_cache_from_seated` | 2 |
| `get_cached_steam_name` | 5 | | `ambition_set_marker_undeclared` | 1 |
| `save_game_starting_players` | 4 | | `on_special_leader_drawn` | 1 |
| | | | `setup_custom_game` | 1 |

This is the right idea — one owner for cross-script logic — with one structural
weakness: `Global.call` takes a **string**, so nothing checks the name exists. A
typo returns nil, silently.

*(Figures: 62 textual `Global.call(` occurrences, 2 of them inside comments →
60 real calls. The brief said 62 and critique.md said 63; both were counting
text. The brief's "13-function bus" was right.)*

---

## The best code here

### Anchor-relative placement — `src/AmbitionMarkers`

```lua
        local target_pos = reach_board.positionToWorld(high_marker.column_pos + this_ambition.row_pos)
```
— `reference/mods/arcs/global/src__AmbitionMarkers.lua:1037`

Six column vectors × six row vectors = 36 positions from 12 numbers, composed
with `Vector` addition and resolved through the board. The board is scaled
6.015×, so world coordinates would have been unmaintainable. Full treatment:
[cookbook/07](../cookbook/07-placement.md).

### Cancellable keyed waits — `src/events/DropActionEvents`

```lua
    local wait_id = object.getGUID()
    if deps.zone_waits[wait_id] then
      Wait.stop(deps.zone_waits[wait_id])
      deps.zone_waits[wait_id] = nil
    end
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:52`

then `Wait.condition` on `object.resting` (`:57`, condition at `:79`). Drag a
card three times and you get one handler, not three.

### A 1.25-second duplicate suppressor

```lua
local function should_suppress_duplicate(guid, event_kind, player_color)
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:11`

Composite key of object, event kind and player — so a seize and a play of the
same card are not conflated.

### A bounded retry

```lua
        if markers_found < (#ambition_marker_GUIDs + 1) and attempt < 5 then
```
— `reference/mods/arcs/global/src__Global.lua:864`

Five attempts, half a second apart, then it stops.

### A stoppable repeating timer

```lua
    Timer.timer_id = Wait.time(function() Timer.update(active_players) end, 1, -1)
```
— `reference/mods/arcs/global/src__Timer.lua:35`

with `Wait.stop` at `:49` and a defensive stop-before-start at `:29`.

**All five are written once, inline, unnamed and unreusable** (C9). Extracting
them is the whole point of `ttslib`'s `async` module.

---

## Conventions

- **`src/GUIDs` is a flat namespace of globals** — 314 lines holding 75
  `…_GUID`-suffixed names assigned at module scope, plus a few tables of them. It
  works because luabundle modules share the script's globals; it also means three
  of those names currently resolve to nothing.
- **Nickname is data.** 1,538 objects have one, and scripts match on it —
  `getName() == "SONG OF FREEDOM"`, `== "Action Card"`, `== "Zero Marker"`.
- **Description is data too**, on 310 objects, including the save/restore flag
  (below) and per-object payloads read by the scoring code.
- **Zero `GMNotes`.** The one human field Arcs leaves alone.
- **72 component tags on 1,668 objects**, composed two at a time:
  `hasTag("power") and hasTag(color_tag)` where `color_tag = self.color .. "Piece"`.
- **Snap points are tagged and match the script vocabulary** — 245 of 320 table
  snaps, 234 of 245 object snaps, using `Agent`, `Power`, `Resource`, `Court`,
  `Edict`, `Law`, `Doctrine`.
- **194 objects carry an alternate state**; 208 decals are attached to objects.
- **`getVar`/`setVar` as a cross-script variable bus** — 229 and 58 sites. This
  is not a pattern to copy; it is untyped global state by another name.

---

## Known bugs

**1. A feature that has never worked** (C8).

```lua
              obj.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
```
— `reference/mods/arcs/global/src__Global.lua:233`

`ActionCards` is bound at `:268`, **35 lines below**, and appears nowhere in
lines 1–231. So it is a nil global here, the call raises, the wrapping `pcall`
swallows it, and `:235` marks the object patched anyway. The same call from
correct scope works at `:899` and `:2641`.

**2. A warning that crashes.**

```lua
            Log.warning("Power bonus zone not found: " .. zone_info.guid)
```
— `reference/mods/arcs/global/src__ArcsPlayer.lua:328`

and `:346`. `src/LOG` exports only `LOG.TRACE`, `LOG.DEBUG`, `LOG.INFO`,
`LOG.WARNING`, `LOG.ERROR` (`src__LOG.lua:5`–`:28`). `Log.warning` is nil, so the
diagnostic is the thing that breaks. **This one is plain Lua indexing and is not
in question** — unlike the tag-casing issue below.

**3. Three dead GUIDs**, in the play-state save:

```lua
artifact_deck_GUID = "9c97c9"
reach_feature_deck_GUID = "a5e8a7"
windfall_deck_Guid = "8cfcb9"
```
— `reference/mods/arcs/global/src__GUIDs.lua:11`

All three match no object in `Saves/TS_Save_125.json`. `tts.py validate` reports
them as errors — critique C1, live.

**4. State in a human field** (C4).

```lua
    reach_board.setDescription("in progress")
```
— `reference/mods/arcs/global/src__Global.lua:2411`

read back at `:2521` to branch the entire load path. Clear that description in
the TTS UI and Arcs forgets a game is running.

**5. Statement order is load-bearing** (C3). `src/SetupControl` addresses 30+
buttons by creation index, and its author left the warning:

```lua
    -- must add buttons in the order of the actual indices !!!!!!!!!! lowest in here must have highest index
```
— `reference/mods/arcs/global/src__SetupControl.lua:743`

**6. Tag casing that may or may not be a bug.** Arcs queries
`getObjectsWithTag("power")` (`src__Global.lua:666`) and `hasTag("power")`
(`src__ArcsPlayer.lua:332`, `:355`) against nine objects tagged **`Power`**, and
`hasTag("Lock")` (`src__Global.lua:2274`) against 376 tagged **`lock`**. These
are live scoring paths. Either TTS matches case-insensitively or Arcs' power
scoring is broken — see
[open question 1](../cookbook/10-antipatterns.md#open-questions-test-these-in-tts).

---

## What breaks if you edit it

| If you change | Then |
| --- | --- |
| A shared module in one slot | The other 1–3 copies keep the old code. Check `manifest.json`'s `shared_modules` and apply the edit to **every** slot |
| `7299d7` "Setup" | Only editable in `Mods/Workshop/`; it does not exist in a play-state save |
| `src/GUIDs` | Four copies. And it is already wrong in three places |
| A `createButton` order in `src/SetupControl` | Every later `editButton({index=…})` shifts. 42 of them |
| `reach_board`'s Description | The save/restore branch stops working |
| Any object's Nickname | Scripts match on nicknames. Grep before editing |
| An object's tags | Both the scripts **and** the tagged snap points depend on them |

```bash
python3 scripts/tts.py lua extract Saves/TS_Save_125.json -o /tmp/arcs
# edit /tmp/arcs/global/src__Global.lua
python3 scripts/tts.py lua inject Saves/TS_Save_125.json /tmp/arcs/global -o Saves/TS_Save_127.json
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

An unmodified round-trip is byte-identical — verified against this 550 KB bundle.

---

## Files

| Path | What |
| --- | --- |
| `global/_bundle.lua` | the original 550 KB field — **never grep this** |
| `global/_index.json` | byte ranges for lossless re-splicing |
| `global/src__Global.lua` | the entry module, 90 KB |
| `global/src__AmbitionMarkers.lua` | the placement code worth copying |
| `global/src__events__DropActionEvents.lua` | the async patterns worth copying |
| `global/src__LOG.lua` | 688 chars, 5 functions — and the casing bug's other half |
| `objects/7299d7/` | Setup, 13 modules, mod-only |
| `manifest.json` | slot map, sha256, `shared_modules` |
