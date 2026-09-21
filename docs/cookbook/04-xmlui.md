# 04 — XML UI

Two completely different things share one field name.

| | Global `XmlUI` | Object `XmlUI` |
| --- | --- | --- |
| Space | **screen** — 2D, anchored to the viewport | **object-local** — floats with the component |
| Seen by | everyone, always | anyone looking at that object |
| Addressed as | `UI.*` | `self.UI.*` / `obj.UI.*` |
| Good for | menus, dialogs, HUDs, per-player panels | a control surface on a board or token |

In the corpus: Rurik has a 3,702-character global panel; Politik has a
1,614-character object panel on six tokens **and** builds a global one at
runtime. Arcs, RotLA and Almoravid have none — their save-level `XmlUI` is TTS's
81-character default comment stub, which is not UI at all.

**`tts.py` gives you a safe round-trip for this field** — before phase 1 there
was none:

```bash
python3 scripts/tts.py xml extract Mods/Workshop/3663650077.json -o /tmp/rurik-ui
python3 scripts/tts.py xml inject  Saves/TS_Save_125.json /tmp/ui/global -o Saves/TS_Save_127.json
```

---

## Global panels: declare, then show and hide

Rurik's is the model. The panel is declared **inactive** in the save's `XmlUI`
and toggled from Lua — no string building, no rebuild cost.

```xml
<Panel
    id="setupMenu"
    height="951"
    width="989"
    image="Menu"
    rectAlignment="Center"
    allowDragging="true"
    showAnimation="Grow"
    hideAnimation="FadeOut"
    returnToOriginalPositionWhenReleased="false"
    outline="#000000" outlineSize="1 -1"
    active="false"
>
```
— `reference/mods/rurik/global/ui.xml:4`

```lua
        UI.show("setupMenu")
```
— `reference/mods/rurik/global/script.lua:175`

`active="false"` is what keeps it off screen at load. `UI.show(id)` and
`UI.hide(id)` take the element's `id`. Rurik pairs two panels so something is
always on screen:

```lua
    UI.hide("setupMenu")
    UI.show("setupMenuClosed")
```
— `reference/mods/rurik/global/script.lua:1295`

and the inverse at `:1300`. `setupMenuClosed` is a 140×64 button in the upper
right (`rurik/global/ui.xml:113`) that calls `UIShowSetupMenu`.

**Verdict.** Declare the markup once, toggle `active`. Reach for `setXml` only
when the *structure* depends on runtime data.

---

## `setXml` replaces the entire root

This is the trap. `UI.setXml(s)` does not merge — it discards everything and
installs `s`.

Politik builds its camera buttons from the seated players:

```lua
function createCameraButtons()
    local seatedPlayers = getSeatedPlayers()
```
— `reference/mods/politik/global/script.lua:165`

and finishes with:

```lua
    Global.UI.setXml(xmlString)
```
— `reference/mods/politik/global/script.lua:281`

Because that call wipes the root, the function is **forced to re-emit the three
action buttons it did not change** — `firstActionButton`, `secondActionButton`,
`thirdActionButton` — which is most of the 90 lines between the loop and the
`setXml`. Those same three buttons are also declared in the `setXml` at
`politik/global/script.lua:3`, inside `onLoad`. The markup exists twice in one
file, and the two copies must be kept in step by hand.

**Verdict.** If you must build XML at runtime, build **all** of it in one
function and call that function from `onLoad` too, so there is exactly one source
of the markup. Better: declare everything statically and drive it with
`setAttribute`.

---

## `setAttribute` for updates

Changing one property does not need a rebuild:

```lua
        Global.UI.setAttribute("secondActionButton", "color", "#808080")
```
— `reference/mods/politik/global/script.lua:96`

Politik calls `setAttribute` 15 times. Arcs uses the value form for text content:

```lua
    UI.setValue("totalTime", Timer.formatTime(0))
```
— `reference/mods/arcs/global/src__Timer.lua:62`

`setAttribute(id, attr, value)` sets any attribute; `setValue(id, text)` sets an
element's text content. Both need the element to have an `id`.

One reason to resist the rebuild: Politik's own reset path has to restore six
attributes by hand, at `politik/global/script.lua:125`–`:130` — three `color` and
three `textColor` values, wrapped in a `Wait.frames` because the attributes cannot be
set until the frame's UI work has landed.

---

## Object-attached XML: `Defaults` and `class`

Politik's resource token is the best object-XML example in the corpus. The whole
panel is nine elements and two defaults.

```xml
<Defaults>

  <InputField
   class="val"
   color="rgba(0,0,0,0)"
   outline="rgba(255,0,0,255)"
   outlineSize="1 -1"
   width="200"
   height="110"
   fontSize="80"
   horizontalOverflow="Wrap"
   placeholder="#"
   textAlignment="MiddleCenter"
   characterValidation="Integer"
   rotation="0 0 180"
   onEndEdit="updateVal"/>
```
— `reference/mods/politik/objects/1efc34/ui.xml:1`

Everything inside `<Defaults>` is a **template keyed by `class`**, not a rendered
element. The real elements carry only what differs:

```xml
<InputField
 class="val"
 id="val1"
 navigation="Explicit"
 name="Capital"
 position="-40 -180 -11"/>
```
— `reference/mods/politik/objects/1efc34/ui.xml:33`

Three inputs and six buttons, each one four attributes long. Without `Defaults`
this file would be four times the size and every style change would be a
nine-site edit.

See [`reference/api/ui__defaults.md`](../../reference/api/ui__defaults.md) for
the full rules.

### `rotation="0 0 180"`

Object XML is rendered on the object's **local XY plane**. For a flat token lying
face-up on the table, that plane is upside-down relative to the camera, so every
element needs `rotation="0 0 180"` — set once in each `<Defaults>` entry above
(`politik/objects/1efc34/ui.xml:15` and `:29`).

If your object XML renders mirrored or invisible, this is why. `position` is
local too: `-40 -180 -11` in the example, with the Z component lifting the
element clear of the token's surface.

---

## `id`-suffix dispatch

One handler for nine elements, keyed by the id's last character:

```lua
function getValId(id)
  return "val" .. string.sub(id, -1)
end
```
— `reference/mods/politik/objects/1efc34/script.lua:17`

```lua
function adjust(player, value, id)
  if string.sub(id, 0, 5) == "minus" then
    minus(player, value, id)
  else
    plus(player, value, id)
  end
end
```
— `reference/mods/politik/objects/1efc34/script.lua:53`

`plus1`, `minus1` and `val1` all resolve to row 1. It is compact and it works,
and it is also why `plus()` has the bug it has ([10](10-antipatterns.md)) — the
row index is a *string substring*, so nothing type-checks.

**Verdict.** Fine up to ~10 elements. Past that, put the element id in a lookup
table rather than parsing it.

---

## The handler signature

```lua
function updateVal(player, value, id)
```
— `reference/mods/politik/objects/1efc34/script.lua:31`

`(player, value, id)` for every XML event — `onClick`, `onValueChanged`,
`onEndEdit`. `player` is a Player object, `value` is the element's value (empty
for a button), `id` is the element's `id` attribute. This is **not** the object
button signature; see [03](03-buttons.md).

Update the element you were called from with `self.UI` for object XML:

```lua
  self.UI.setAttribute(valId, "text", data[valId])
```
— `reference/mods/politik/objects/1efc34/script.lua:35`

`self.UI.*` for object XML, bare `UI.*` (or `Global.UI.*`) for global XML. Mixing
them is silent — the id simply is not found.

---

## `CustomUIAssets`: images by name

XML `image="..."` refers to a **name** in the save's top-level `CustomUIAssets`
list, never a URL.

```json
{ "Name": "Menu",
  "URL": "https://steamusercontent-a.akamaihd.net/ugc/...",
  "Type": 0 }
```

```xml
    image="Menu"
```
— `reference/mods/rurik/global/ui.xml:8`

Rurik declares six assets — `Button_Main_Blue`, `Button_Square_Blue`,
`Inset_Grey`, `Menu`, `PlayerCount`, `Gamefound` — and its XML references four of
them. `Inset_Grey` and `Gamefound` are declared and unused. Politik, Arcs, RotLA
and Almoravid declare none.

**A name that does not resolve renders a blank box with no error.** That is why
`tts.py validate` checks it:

```bash
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

There is no equivalent for object XML — `CustomUIAssets` is save-level only.

---

## Elements worth knowing

| Element | Use |
| --- | --- |
| `<Panel>` | container; the thing you `show`/`hide` |
| `<VerticalLayout>` / `<HorizontalLayout>` | flow layout with `spacing` and `padding` |
| `<Button onClick="fn">` | click target |
| `<InputField onEndEdit="fn">` | text/number entry; `characterValidation="Integer"` |
| `<Dropdown onValueChanged="fn">` + `<Option>` | select |
| `<Text>` | static label |
| `<Image image="AssetName">` | a `CustomUIAssets` image |

Rurik's setup menu uses `<Dropdown>` for player count
(`reference/mods/rurik/global/ui.xml:70`) and nests
`<VerticalLayout>` inside `<Panel>` inside `<HorizontalLayout>` to get a grid.
Full attribute lists:
[`reference/api/ui__attributes.md`](../../reference/api/ui__attributes.md),
[`reference/api/ui__basicelements.md`](../../reference/api/ui__basicelements.md),
[`reference/api/ui__inputelements.md`](../../reference/api/ui__inputelements.md),
[`reference/api/ui__layoutgrouping.md`](../../reference/api/ui__layoutgrouping.md).

A transparent spacer is `color="#00000000"` — Rurik uses it eight times
(`rurik/global/ui.xml:39` and after), twice as a pure spacer with no children
(`rurik/global/ui.xml:48`, `:90`), to get spacing without a visible box.

---

## Checklist

- [ ] Static markup declared in `XmlUI`; `setXml` only for runtime structure.
- [ ] If you call `setXml`, one function emits the **whole** root, and `onLoad`
      calls that same function.
- [ ] Every element you address from Lua has an `id`.
- [ ] `self.UI` for object XML, `UI`/`Global.UI` for global.
- [ ] Object XML carries `rotation="0 0 180"`.
- [ ] Repeated styling is in `<Defaults>` with a `class`.
- [ ] Every `image=` name exists in `CustomUIAssets` — run `validate`.

**Next:** [05 — State](05-state.md).
