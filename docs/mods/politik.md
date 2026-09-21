# Politik

**Read this mod for:** object-attached XML UI, and building global XML at
runtime from the seated players.

| | |
| --- | --- |
| Corpus | [`reference/mods/politik/`](../../reference/mods/politik/) |
| Source | `Mods/Workshop/3460664356.json`, 3.2 MB, TTS v14.2.2, saved 2026-09-19 |
| Architecture | logic on objects; a thin 9.8 KB Global |
| Global Lua | 9,857 chars, 13 functions, no modules |
| Object scripts | 23, total ~103 KB — 6 of them byte-identical |
| XML UI | 6 objects × 1,614 chars, byte-identical; Global builds its own at runtime |
| Objects | 1,772 (903 at table level) |
| `validate` | 0 errors, 1 warning (one GUID twice in one container) |

---

## Shape

The Global script is nothing but **UI and cameras**:

```
onLoad()                      -> Global.UI.setXml(...) with 3 action buttons
onFirstActionClick  :74       -> announce + grey out the button
onSecondActionClick :87
onThirdActionClick  :100
onPowerGrabClick    :113      -> announce + reset all three buttons
onCameraBoardClick  :136      -> Player[player.color].lookAt{...}
onCameraBrownClick  :140         ... one per seat colour, 7 total
createCameraButtons :165      -> rebuild the whole root XML from seated players
```

All game logic lives on the 23 object scripts. The biggest are `d34970` (16.4 KB,
a card-tray `BlockSquare` that computes tray colour from the cards' backs) and
`4817be` (11.8 KB).

**Entry points.** `global/script.lua:1` (`onLoad`), plus every object's own
`onLoad`. There is no setup routine and no coroutine — the mod assumes the table
is already laid out, which is why it has 1,562 object snap points and only four
table ones.

---

## Object-attached XML UI — the thing to copy

Six `Custom_Token` objects nicknamed `[E9E2B6]Resources` — `1efc34`, `5cfd6c`,
`f0237c`, `1c1690`, `241e2d`, `2b84d7` — each carry a byte-identical
1,614-character panel and a byte-identical 4,304-character script. It is a
three-row resource counter: an `InputField` and a `+`/`−` pair per row.

```xml
<Defaults>

  <InputField
   class="val"
   ...
   rotation="0 0 180"
   onEndEdit="updateVal"/>
```
— `reference/mods/politik/objects/1efc34/ui.xml:1`

Four things this file teaches, in 105 lines:

- **`<Defaults>` + `class`** — the styling lives once; the nine real elements
  carry four attributes each.
- **`rotation="0 0 180"`** — object XML renders on the object's local XY plane,
  which is upside-down for a flat token.
- **`position="-40 -180 -11"`** — object-local coordinates, with Z lifting the
  element clear of the surface.
- **id-suffix dispatch** — `val1`/`plus1`/`minus1` all mean row 1, resolved by
  `string.sub(id, -1)` at `script.lua:17`.

The Lua side updates through `self.UI`, not the global `UI`:

```lua
  self.UI.setAttribute(valId, "text", data[valId])
```
— `reference/mods/politik/objects/1efc34/script.lua:35`

Full walkthrough: [cookbook/04-xmlui.md](../cookbook/04-xmlui.md).

---

## Runtime XML from the seated players

`createCameraButtons` is the mod's other good idea: only emit a jump-to-seat
button for a colour that someone is sitting in.

```lua
function createCameraButtons()
    local seatedPlayers = getSeatedPlayers()
    local seatedColors = {}
```
— `reference/mods/politik/global/script.lua:165`

```lua
        if btn.alwaysShow or seatedColors[btn.playerColor] then
```
— `reference/mods/politik/global/script.lua:189`

**And its cost, which is the lesson.** `Global.UI.setXml` replaces the *entire*
root (`script.lua:281`), so the function must also re-emit the three action
buttons it did not change. Those buttons are therefore declared twice in one
file — once in `onLoad`'s `setXml` at `:3`, once inside `createCameraButtons`.
Change one and you must change the other.

It is reached from a physical button on object `f782d2`:

```lua
        click_function = "refreshCameraButtons",
```
— `reference/mods/politik/objects/f782d2/script.lua:15`

which calls `Global.call("createCameraButtons")` at `:105`.

---

## Conventions

- **Nicknames carry colour markup.** `[E9E2B6]Resources`, `[E9E2B6]Clash Helper`.
  TTS's `[rrggbb]` inline codes work in `Nickname`, and 1,128 objects have one.
- **State is per-object `onSave`** — 13 object scripts define one, 8 distinct
  (six of the thirteen are the identical resource script). All of the form
  `return JSON.encode(data)`.
- **No `GMNotes` at all** — zero objects use it, and only 3 have a
  `Description`. Politik is the one mod here that keeps human fields human.
- **Tags are a vocabulary, not a mechanism.** 1,323 objects carry one of 14 tags
  (`politik card` ×458, `nation token` ×423, `leader` ×216), and the scripts
  touch the tag API exactly twice — `hasTag("activated card")` at
  `objects/a4a0b5/script.lua:68` and `getTags()` at `objects/5a5dd1/script.lua:78`.
  The tags exist for the *snap points*: **1,130 of the 1,562** object snap points
  are tagged, so components only drop where they belong.
- **Buttons are rebuilt with `clearButtons()`**, not edited — 8 sites across 5
  object scripts. Only 2 `editButton` calls in the whole mod.

---

## Known bugs

Two, both live, both used as teaching material in
[cookbook/10-antipatterns.md](../cookbook/10-antipatterns.md).

**A seven-digit hex colour.**

```lua
        {name = "Blue", color = "#1E87FFF", yOffset = 0, onClick = "onCameraBlueClick", playerColor = "Blue"},
```
— `reference/mods/politik/global/script.lua:179`

Every sibling entry has six digits. The value is interpolated into the XML as
`textColor` at `:200`.

**A cap that never applies.**

```lua
  if data[maxId] ~= nil then
    data[valId] = math.min(data[valId], data[maxId])
  end
```
— `reference/mods/politik/objects/1c1690/script.lua:82`

`maxId` is never declared — it appears only on these two lines. `data[nil]`
*reads* as nil rather than raising, so the condition is always false and the
resource counters have no maximum. The `getValId` helper at `:17` has no
`getMaxId` sibling; it was never written.

**And the fossil that goes with it.** The persisted `LuaScriptState` of these six
objects still contains `max1`, `max2`, `max3`, `statName1`, `statName2` and
`statName3` — six keys that appear nowhere in the script, re-saved forever
because `onSave` serialises whatever `data` holds (`script.lua:143`).

*(An earlier analysis claimed `createCameraButtons` is dead code. It is not —
see above. That correction is recorded in
[critique.md](../critique.md#corrections-to-earlier-figures).)*

---

## What breaks if you edit it

| If you change | Then |
| --- | --- |
| One of the six `[E9E2B6]Resources` objects | The other five keep the old behaviour. All six are byte-identical; change all six or none |
| The XML on one of them | Same — 1,614 chars, six copies |
| `createCameraButtons`' emitted XML | You must mirror the change in `onLoad`'s `setXml` at `:3`, or the action buttons diverge |
| Any element `id` in the object XML | `getValId`/`getPlusId`/`getMinusId` parse the **last character** of the id. Renaming `val1` to `capital` breaks dispatch silently |
| An object's `Nickname` | Safe — nothing in Politik reads nicknames. Rare among these mods |
| A GUID | 73 unique GUID literals across the object scripts. Run `tts.py refs` first |

```bash
python3 scripts/tts.py refs Mods/Workshop/3460664356.json 1efc34
python3 scripts/tts.py xml extract Mods/Workshop/3460664356.json --object 1efc34 -o /tmp/politik-ui
```

---

## Files

| Path | What |
| --- | --- |
| `global/script.lua` | 9.8 KB — UI, cameras, nothing else |
| `objects/1efc34/{script.lua,ui.xml}` | the resource counter, ×6 |
| `objects/d34970/script.lua` | 16.4 KB card tray, the largest script |
| `objects/f782d2/script.lua` | the utility board: refresh cameras, delete vacant player areas |
| `objects/5a5dd1/script.lua` | `[E9E2B6]Clash Helper`, 6.8 KB |
| `manifest.json` | slot map + sha256 |
