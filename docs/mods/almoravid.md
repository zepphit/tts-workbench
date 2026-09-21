# Almoravid

**Read this mod for:** the bulk-placement idiom — `takeObject` → `Wait.frames` →
`setPositionSmooth` — and nothing else.

Almoravid is the cautionary example. It is 7,697 lines with ten top-level
functions, 200 GUIDs bound to globals with no guards, 925 absolute coordinates
and zero component tags. Every structural mistake in
[critique.md](../critique.md) that can be made in a single file is made here.

| | |
| --- | --- |
| Corpus | [`reference/mods/almoravid/`](../../reference/mods/almoravid/) |
| Source | `Mods/Workshop/2804149704.json`, 1.2 MB, TTS **v13.2.2**, saved 2023-03-16 |
| Architecture | one 219 KB monolith |
| Global Lua | 219,055 chars, 7,697 lines, **10 top-level functions** |
| Object scripts | **1** — a 838-char d6 roller |
| XML UI | none |
| Objects | 411 (224 at table level) |
| `validate` | 0 errors, **54 warnings** — GUID literals that resolve only inside containers |

Note the TTS version: v13.2.2, March 2023. This is the oldest mod in the corpus
by three years, and some of what it does may predate better options.

---

## Shape

Ten functions, 7,697 lines:

```
   1  getObjects()             205 getObjectFromGUID calls, 200 distinct GUIDs
 244  DrawSpecificCard(deckGUID, CardName, pos1, pos2)
 270  onLoad()                 calls getObjects(), then creates 8 scenario buttons
 340  scenarioA()              ~1,000 lines of placement
1364  scenarioAQ()             ~1,070 lines
2436  scenarioB()              ~750
3185  scenarioC()              ~1,030
4219  scenarioD()              ~1,520
5742  scenarioE()              ~1,075
6817  scenarioF()              ~920
```

Six scenarios plus a quickstart, each an independent straight line of placement
statements. There is no shared setup routine: the scenarios do not call each
other, and a change to how a piece is placed must be made in up to seven
functions.

**Entry point.** `function onLoad()` at
`reference/mods/almoravid/global/script.lua:270` — correctly cased here, unlike
its one object script.

---

## C1 at its purest

```lua
function getObjects()
	caowdeck = getObjectFromGUID("607a04")
	maowdeck = getObjectFromGUID("98eca0")
	    aowc1 = getObjectFromGUID("3c89b8")
```
— `reference/mods/almoravid/global/script.lua:1`

Lines 1–241 do nothing but bind GUIDs to globals: **205 calls, 200 distinct
GUIDs.** The file contains **zero** `if <name> then` guards — nothing checks
whether any of them resolved.

`tts.py validate` reports **54** of those literals resolving only to objects
*inside containers*, where `getObjectFromGUID` returns nil until something takes
them out. Because nothing is guarded, the first nil in a scenario function kills
the rest of that function, leaving the table half-placed with no error naming the
cause.

```bash
python3 scripts/tts.py validate Mods/Workshop/2804149704.json
```

---

## C2 at its purest

**925 `setPosition`/`setPositionSmooth` calls. Zero `positionToWorld` calls.**

Every destination is an absolute table-space coordinate anchored to a board that
happens to sit at a fixed transform. Move the board, rescale it or rebuild the
table and all 925 are wrong simultaneously — there is no transform to adjust.

Every other mod in the corpus uses `positionToWorld` at least once (Arcs 21,
Rurik 4, Politik 1, RotLA 1). Almoravid is the only zero.

---

## The bulk-placement idiom — the one thing to take

The shape is right even though its expression is not:

```lua
bagSiegeC.takeObject({
    callback_function = function(obj)
        Wait.frames(function()
            if not obj.isDestroyed() then
                obj.setPositionSmooth({3.74,6.66,3.66}, false, false)
				obj.SetRotationSmooth({0,180,0}) 
            end
        end)
    end, 
})
```
— `reference/mods/almoravid/global/script.lua:479`

- `takeObject` is asynchronous — the object exists only in the callback.
- One `Wait.frames` before positioning: a freshly spawned object is not ready in
  the same frame.
- `isDestroyed()` guarded.
- `collide = false` on the smooth move, so pieces do not knock each other about
  during setup.

**And then it is written out 537 times.** 538 lines mention `takeObject`. Written
as data instead — a table of `{role, position, facing}` iterated once — the same
setup is twenty lines. See
[cookbook/07](../cookbook/07-placement.md#the-bulk-placement-idiom).

### ⚠ `SetRotationSmooth` with a capital S

Note the second line of that block. Almoravid calls `.SetRotationSmooth(`
**630 times** and the documented `.setRotationSmooth(` **231 times**, interleaved
through the same file (capital from `:342` to `:7658`, lowercase from `:974` to
`:7637`). The API documents only the lowercase form
([`reference/api/object.md:172`](../../reference/api/object.md)), nothing in the
corpus defines a helper of that name, and this is the **only** capitalised member
call in all five mods.

Either TTS resolves Object members case-insensitively or 630 rotations in a
published GMT wargame mod silently fail. Tracked as
[open question 2](../cookbook/10-antipatterns.md#open-questions-test-these-in-tts).
**Write the documented casing.**

---

## Conventions

There are not many.

- **No component tags at all.** `ComponentTags.labels` is `[]` and no object
  carries a `Tags` entry. Almoravid and the owner's prototypes are the only saves
  in this folder with zero.
- **No snap points on the table**, 11 on objects, none tagged.
- **No `onSave`.** The mod persists nothing; reloading re-runs a scenario from
  scratch.
- **Decals instead of markers** — 139 in `DecalPallet`, 120 attached to objects.
  This is the mod's one distinctive piece of non-Lua infrastructure, and it is how
  a hex-and-counter wargame marks a map.
- **2 objects carry alternate states**, five each.
- **Almost nothing in human fields**: 1 `Description`, 0 `GMNotes`, 111
  `Nickname`s.
- **Tabs, not spaces**, and inconsistent indentation inside the placement blocks.

---

## The one object script

`ddb88c`, 838 chars — a d6 roller:

```lua
function onload()
    self.createButton(
        {click_function='rolldice',
```
— `reference/mods/almoravid/objects/ddb88c/script.lua:8`

**Lowercase `onload`** here, while the Global script uses `onLoad`. Same mod,
same author, both spellings. See
[open question 3](../cookbook/10-antipatterns.md#open-questions-test-these-in-tts).

It also calls `math.randomseed(os.time())` at module scope (`:2`) and then throws
away three `math.random(1,6)` results at `:4`–`:6` — the old superstition about
warming up a PRNG. Harmless, and not something to copy.

---

## What breaks if you edit it

| If you change | Then |
| --- | --- |
| Any object's GUID | One of 200 bindings goes nil, unguarded, and the scenario that uses it dies part-way through. Run `tts.py refs` first |
| The board's position or scale | All 925 coordinates are wrong. There is no single place to fix this |
| Placement in one scenario | The other six scenarios still place it the old way |
| A card's `Nickname` | `DrawSpecificCard` (`:244`) finds cards by matching `object.name` in a deck's `getObjects()` listing (`:251`) — grep before editing |
| Anything at all | There is no `onSave`, so nothing persists. That at least makes testing cheap: reload and re-run |

```bash
python3 scripts/tts.py refs Mods/Workshop/2804149704.json 607a04
python3 scripts/tts.py lua extract Mods/Workshop/2804149704.json -o /tmp/almoravid
```

---

## Files

| Path | What |
| --- | --- |
| `global/script.lua` | 219 KB, 7,697 lines, 10 functions |
| `objects/ddb88c/script.lua` | the d6 roller, 838 chars |
| `manifest.json` | slot map + sha256 |
