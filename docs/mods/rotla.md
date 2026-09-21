# Railways of the Lost Atlas

**Read this mod for:** container tracking, self-returning supply bags,
`GMNotes` back-pointers, and `setVar` closures for buttons built in a loop.

**Do not read it for:** structure. It is a vendored third-party engine with a
configuration block bolted on top, and 51 copies of one script.

| | |
| --- | --- |
| Corpus | [`reference/mods/rotla/`](../../reference/mods/rotla/) |
| Source | `Mods/Workshop/3026289764.json`, 1.7 MB, TTS v14.2.1, saved 2026-04-25 |
| Architecture | logic on objects, over a vendored **18Engine v2.96** |
| Global Lua | 93,192 chars, 2,453 lines, 72 top-level functions |
| Object scripts | 64 — of which **51 are byte-identical** |
| XML UI | none (the save-level field is TTS's 81-char stub) |
| Objects | 946 (494 at table level) |
| `validate` | 0 errors, 13 warnings (duplicate GUIDs inside containers) |

---

## Shape — three zones in one file

```
  1 –  16   your configuration:  USE_SAVES, gameOptions
 18 – 256   gameEntities:        237 lines, 119 GUID literals
258         ---VERSION 2.96, copy and paste everything below this line to update!
340         -----YOU DO NOT NEED TO EDIT ANYTHING BELOW THIS LINE-----
341 – 2453  the engine
```

```lua
---VERSION 2.96, copy and paste everything below this line to update!
```
— `reference/mods/rotla/global/script.lua:258`

```lua
-----YOU DO NOT NEED TO EDIT ANYTHING BELOW THIS LINE-----
```
— `reference/mods/rotla/global/script.lua:340`

**This is the single most important fact about editing RotLA.** Anything you
change below line 258 is destroyed by the next engine upgrade, and nothing in the
file prevents it. The engine is
[18Engine](https://github.com/goldencow2/18Engine/wiki), cited in the header
comment at `:3`.

**Entry point.** `function onload(saved_data)` at
`reference/mods/rotla/global/script.lua:373` — **lowercase `l`**, and the file
defines no `onLoad` at all. Whether that still works is
[cookbook open question 3](../cookbook/10-antipatterns.md#open-questions-test-these-in-tts);
empirically the mod works, so presumably it does.

---

## The configuration block

Everything the mod author is meant to touch is a literal table:

```lua
gameEntities = {
    OTHER_ACTORS = {
            ['BANK'] = {
                moneyLabelGUID = 'bf2867',
            },
```
— `reference/mods/rotla/global/script.lua:18`

237 lines, **119 GUID literals**. The whole script holds 252 (198 unique). It is
a better shape than scattering them through code — one place to edit — and still
exactly critique item C1: every one of them breaks if the object is duplicated or
re-added.

`gameOptions` above it (`:12`) is the good half of the same idea: three named
booleans and a number, read by name throughout the engine.

---

## Container tracking — the thing to copy, and its cost

51 supply bags carry an identical 997-character script. Read it once:

```lua
--CHILD BAG
function onObjectLeaveContainer(bag, obj)
    if bag~=self then return end
    if not (string.find(obj.getGMNotes(), "Private")) then
        obj.setGMNotes(self.getGUID())
    end
    setDisplay()
end
```
— `reference/mods/rotla/objects/54bdb7/script.lua:1`

Three idioms in eight lines:

1. **The self-filter.** TTS delivers container events to every script that
   defines the handler, so each must discard events about other containers.
   `bag~=self` — **no spaces**; a grep for `bag ~= self` finds nothing. 55 scripts
   carry it, 106 occurrences (enter and leave).
2. **A `GMNotes` back-pointer.** Anything leaving the bag is stamped with the
   bag's own GUID, so it knows where to go home to. 133 objects carry non-empty
   `GMNotes`.
3. **A zero-size button as a count badge**, rebuilt idempotently:

```lua
function setDisplay()
    if self.getButtons() == nil then
```
— `reference/mods/rotla/objects/54bdb7/script.lua:19`

```lua
        self.editButton({index=0,label = self.getQuantity()})
```
— `reference/mods/rotla/objects/54bdb7/script.lua:34`

with `width = 0, height = 0, font_size = 1000` — unclickable, so it renders as
floating text. `index=0` is one of four independent confirmations in this corpus
that button indexes are 0-based.

**The cost (C6, C7).** A one-line fix here is a 51-site edit, and the guard is
load-bearing boilerplate: omit it in one script and that bag reacts to every
other bag's contents, silently. Every container event in the game is dispatched
to all 55 scripts, 54 of which return immediately. The fix is one central
handler routing by tag — [cookbook/06](../cookbook/06-objects-tags-containers.md).

## The sorting bag — 16 lines, complete

The other half of the mechanism, and the best small script in the corpus:

```lua
--SORTING BAG
function filterObjectEnter(obj)
    local returnBag = getObjectFromGUID(obj.getGMNotes())
    if returnBag then
        if obj.getQuantity() > 1 then
            while(obj.getQuantity() > 1) do
                returnBag.putObject(obj.takeObject({}))
            end
        else
            returnBag.putObject(obj)
        end
        return false
    else
        return true
    end
end
```
— `reference/mods/rotla/objects/93c2a0/script.lua:1`

`filterObjectEnter` returning `false` **vetoes** the drop; the bag re-routes the
object to the bag named in its `GMNotes` instead of keeping it. `return true` for
unknown objects, so nothing vanishes. The `getQuantity() > 1` branch handles a
dropped *stack*, one item at a time.

---

## `setVar` closures — buttons built in a loop

`click_function` must be a string naming a global function, so a closure cannot
be a handler directly. RotLA installs one per company:

```lua
            --fucking LUA wizardry
            --Using a locally defined function as the click_function allows us to access the other local variables in this for loop
```
— `reference/mods/rotla/global/script.lua:1462`

```lua
                local payFuncName = k .. 'PayHalf'
                local payFunc = function(object, color, alt) buttonHelper(company, 'PayHalf', color, alt) end
                Global.setVar(payFuncName, payFunc)
                payHalfParams.click_function = payFuncName
```
— `reference/mods/rotla/global/script.lua:1472`

The name is derived from the loop key, so each iteration gets its own handler
closing over `company`. This is the only way to parameterise a button without
encoding the parameter in its label.

Because button creation is conditional, the mod also has to track indexes by
hand — and its author explains exactly why:

```lua
            --increment as buttons are created, because createButton doesn't return the button's index for some fucking reason.
            --button indexes also start at zero because convention sucks.
```
— `reference/mods/rotla/global/script.lua:1468`

That is critique item C3 stated by the person who hit it.

## Scale compensation

Buttons are in the host object's local space, so a scaled board needs the scale
divided out:

```lua
    local bScale = 0.4*board.getScale()
```
— `reference/mods/rotla/global/script.lua:490`

```lua
        scale = {1/bScale.x,1,1/bScale.z},
```
— `reference/mods/rotla/global/script.lua:497`

repeated at `:508`, `:518` and `:528`, with a half-size variant
`{0.5/bScale.x, 0.5, 0.5/bScale.z}` at `:538`. Y stays at the un-divided value —
a button is flat, so only X and Z matter.

---

## State: a kill switch, not a schema

```lua
USE_SAVES = true
--set this to false while editing your mod or treasuries will persist.
```
— `reference/mods/rotla/global/script.lua:6`

The problem is real — saved state silently overrides an edited default — and the
workaround is a global boolean that makes `onSave` return `''`
(`global/script.lua:345`). There is a version constant:

```lua
SAVE_STATE = {
    versionNumber = 2.95
}
```
— `reference/mods/rotla/global/script.lua:341`

`versionNumber` appears exactly once in 2,453 lines. Nothing reads it, and the
engine's own boundary comment at `:258` already says 2.96. A version you branch
on turns the kill switch into a migration —
[cookbook/05](../cookbook/05-state.md).

---

## Conventions

- **Data in three human fields at once.** 133 objects use `GMNotes`, 189 use
  `Description`, 38 have a `Nickname`. All three are read by the engine.
- **16 component tags, all of them used** — the only mod here with no declared-
  but-unused labels. `UnlockMe` ×189, `Share` ×181, `Token` ×126.
- **No snap points on the table**, 119 on objects, **117 of them tagged** —
  `Token` ×33, `Minor` ×32, `Share` ×24, `Round` ×10, `MetroToken` ×10,
  `Major` ×8, drawn from the same 16-label vocabulary as its component tags. Only
  the *table* snaps were skipped. At 119 points over six tags this is the
  smallest complete example of tagged snapping in the corpus — read it before
  Arcs' 245 object snaps or Politik's 1,562.
- **No object States, no decals, no XML UI.**
- `createInput` — the only mod here that uses it: 6 calls, 2 in Global
  (`global/script.lua:1449`, `:1566`) for money entry and 4 in
  `objects/bd69bd/script.lua`.

---

## Known bugs

**`onPlayerChangeColor` is defined twice**, at
`reference/mods/rotla/global/script.lua:560` and again at `:2336`. In Lua the
second assignment wins and the first body is dead code. Note that both are below
the engine boundary, so the duplicate is upstream's, not the mod author's.

---

## What breaks if you edit it

| If you change | Then |
| --- | --- |
| Anything below line 258 | Lost on the next 18Engine upgrade. Configure above it instead |
| One of the 51 bag scripts | The other 50 keep the old behaviour |
| A bag's `GMNotes` | The sorting bag `93c2a0` can no longer route items home |
| An object's `Description` or `Nickname` | 189 and 38 objects respectively; the engine reads them. Grep first |
| A GUID in `gameEntities` | 119 literals in that block alone, 198 unique in the file. `tts.py refs` first |
| `USE_SAVES` | Treasuries persist or do not. Flip it to **false** before changing any `gameOptions`, per the comment at `:9` |

```bash
python3 scripts/tts.py refs Mods/Workshop/3026289764.json bf2867
grep -rn "getGMNotes\|getDescription" reference/mods/rotla/
```

---

## Files

| Path | What |
| --- | --- |
| `global/script.lua` | 93 KB: config (1–256), then 18Engine v2.96 |
| `objects/54bdb7/script.lua` | the 997-char supply bag, ×51 |
| `objects/93c2a0/script.lua` | the sorting bag, 16 lines |
| `objects/bd69bd/script.lua` | "Flex Table Control", 16.3 KB — the one substantial object script |
| `manifest.json` | slot map + sha256 |
