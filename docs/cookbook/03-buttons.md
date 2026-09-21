# 03 — Buttons

Object buttons live in **world space**, attached to a component, and scale with
it. For screen-space panels see [04](04-xmlui.md).

Usage across the corpus (deduplicated):

| Mod | `createButton` | `editButton` |
| --- | --- | --- |
| Arcs | 70 | 69 |
| RotLA | 36 | 19 |
| Politik | 24 | 2 |
| Rurik | 14 | 6 |
| Almoravid | 8 | 0 |

---

## Indexes start at 0

Settled, from the primary source — `editButton` in
[`reference/api/object.md`](../../reference/api/object.md):

> *"Indexes start at 0. The first button on any given Object has an index of 0,
> the next button on it has an index of 1, etc. Each Object has its own
> indexes."*

Three mods agree in their own words:

```lua
    --button indexes also start at zero because convention sucks.
```
— `reference/mods/rotla/global/script.lua:1469`

```lua
    self.removeButton(0)  -- Remove the first button (index 0)
```
— `reference/mods/politik/objects/f782d2/script.lua:99`

```lua
        self.editButton({index=0,label = self.getQuantity()})
```
— `reference/mods/rotla/objects/54bdb7/script.lua:34`

**Rurik's `index = 1` is not a counter-example.** 48 call sites across 24
inventory-bag scripts read `self.editButton({ index = 1, label = tostring(val) })`
(`reference/mods/rurik/objects/064e16/script.lua:72` and `:79`). The same script's
`onLoad` creates **two** buttons: an invisible 500×500 click target first
(`:38`), then the counter label (`:49`). Index 1 is the counter label, and the
call is correct. Checked per call site, as
[critique.md](../critique.md#corrections-to-earlier-figures) asked.

---

## The problem with indexes (C3)

Indexes are positional, so inserting a `createButton` renumbers every later
button — silently. Nothing errors; the wrong button gets edited.

Arcs' `src/SetupControl` makes 32 `createButton` and 42 `editButton` calls in one
file and its author left a warning:

```lua
    -- must add buttons in the order of the actual indices !!!!!!!!!! lowest in here must have highest index
```
— `reference/mods/arcs/global/src__SetupControl.lua:743`

RotLA hit the same wall and maintains a counter by hand, because button creation
is conditional:

```lua
            local btnIndex = 0
```
— `reference/mods/rotla/global/script.lua:1465`

```lua
            if company.COMPANIES_CAN_HALF_PAY then
                ...
                halfPayIndex = btnIndex
                btnIndex = btnIndex+1
            end
```
— `reference/mods/rotla/global/script.lua:1471`

with its own explanation one line above the counter:

```lua
            --increment as buttons are created, because createButton doesn't return the button's index for some fucking reason.
```
— `reference/mods/rotla/global/script.lua:1468`

That is the real constraint: **`createButton` returns nothing useful.** You have
to know the index some other way.

### Two workarounds that actually work

**Capture the count before you create.** `#getButtons()` is the index the next
button will get:

```lua
    TOTAL_INDEX = #self.getButtons()
```
— `reference/mods/rurik/objects/8e05ed/script.lua:68`

immediately before the `createButton` at `:71`, and used later at `:116`. Rurik's
Global does the same at `rurik/global/script.lua:1584`. This survives insertions *above* it,
which is most of them.

**Search by `click_function`.** The most robust thing in the corpus:

```lua
local function hasBribeButton()
    local btns = self.getButtons()
    if not btns then return false end
    for _,b in ipairs(btns) do
        if b and b.click_function == "Advisor_onBribePressed" then
            return true
        end
    end
    return false
end
```
— `reference/mods/rurik/objects/7856d0/script.lua:1`

`getButtons()` returns a table of parameter tables, so any field you set at
creation is a lookup key. This is a name→button map with extra steps — which is
precisely `ttslib`'s `ui.button(obj, "name", {...})` / `ui.set("name", {...})`
(C3).

---

## Idempotent rebuild

`onLoad` runs again on every reload. Create unconditionally and you get a second
button stacked on the first.

The whole-object reset — simple, and correct when you own every button:

```lua
    self.clearButtons()
```
— `reference/mods/politik/objects/fb0a83/script.lua:42`

The create-or-edit form, which preserves the button across reloads:

```lua
function setDisplay()
    if self.getButtons() == nil then
        self.createButton({
```
— `reference/mods/rotla/objects/54bdb7/script.lua:19`

```lua
    else
        self.editButton({index=0,label = self.getQuantity()})
    end
```
— `reference/mods/rotla/objects/54bdb7/script.lua:33`

Note `getButtons()` returns **nil**, not an empty table, when there are no
buttons. Arcs guards with `or {}` at
`reference/mods/arcs/global/src__AmbitionMarkers.lua:144`; Rurik guards with
`if not btns then` above. Either, but not neither.

---

## `function_owner`

`click_function` is a **string**, looked up at click time in the environment
named by `function_owner`.

```lua
        click_function = "refreshCameraButtons",
        function_owner = self,
```
— `reference/mods/politik/objects/f782d2/script.lua:15`

- `function_owner = self` → looked up in *this object's* script.
- `function_owner = Global` → looked up in the *Global* script.

Get this wrong and the button is inert, with no error. Rurik's advisor payment
panel does exactly that: it sets

```lua
            function_owner = Global, -- IMPORTANT: functions live on Global environment
```
— `reference/mods/rurik/objects/8e05ed/script.lua:41`

on all four of its buttons, then defines the handlers in its own script
(`:100` onward). `AdvisorPayPanel_cancel` and `AdvisorPayPanel_pay` appear **zero
times** in Rurik's Global. The buttons do nothing; Global builds a separate,
working panel via `AdvisorPay.buildPaymentPanel`
(`reference/mods/rurik/global/script.lua:156`). See [10](10-antipatterns.md).

**Rule.** `function_owner` and the `function` definition go in the same file.
When you need Global's logic from an object button, own the handler locally and
delegate in one line:

```lua
function onBuyClick(obj, color, alt)
  Global.call("buy", { color = color, guid = self.getGUID() })
end
```

That is architectural rule 1 — thin object scripts — and it is what Arcs' 13-name
`Global.call` bus is for ([08](08-players-turns.md)).

---

## The handler signature

```lua
function plus(player, value, id)
```
— `reference/mods/politik/objects/1c1690/script.lua:76`

**Careful — object buttons and XML have different signatures.**

| Source | Signature |
| --- | --- |
| Object `createButton` | `(clicked_object, player_color, alt_click)` |
| XML `onClick` | `(player, value, id)` |

Politik's `plus` above sits on the **XML** side. Its XML declares
`onClick="adjust"` (`objects/1efc34/ui.xml:30`); `adjust` is the real handler and
forwards its three arguments unchanged to `plus` or `minus`
(`objects/1c1690/script.lua:53`). So `(player, value, id)` is right there. An
object button handler gets a *string* colour in the second slot, not a player
object. Arcs is consistent about this:

```lua
function toggle_leaders(obj, color, alt_click)
```
— `reference/mods/arcs/objects/7299d7/src__SetupControl.lua:841`

### Right-click

`alt_click` is the third argument, true on right-click. One button, two actions:

```lua
    local func = function(_, playerColor, alt_click)
        -- alt_click == true means RIGHT click on a TTS button
        if alt_click then
            removeOneToTrash()
        else
            addOneFromSupply()
        end
    end
```
— `reference/mods/rurik/objects/064e16/script.lua:27`

---

## `setVar` closures

`click_function` must be a string naming a global function, which means a plain
closure cannot be a handler. `setVar` installs one under a name:

```lua
    self.setVar(funcName, func)
```
— `reference/mods/rurik/objects/064e16/script.lua:35`

RotLA uses the Global-scoped form to give each company its own handler inside a
loop — and its author left the explanation:

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

The name is derived from the loop key, so each iteration installs a distinct
function that closes over `company`. This is the only way to parameterise a
button handler without encoding the parameter in the button's label or position.

Arcs uses `setVar` 58 times and `getVar` 229 times across its deduplicated
modules — mostly as a cross-script variable bus, which is a different and much
less defensible use.

---

## Text labels: the zero-size button

There is no "label" primitive. A button with `width = 0, height = 0` cannot be
clicked and renders as floating text:

```lua
            label          = self.getQuantity(),
            position       = {-0.8, 2.125, -2},
            rotation       = {0, 180, 0},
            width          = 0,
            height         = 0,
            font_size      = 1000,
```
— `reference/mods/rotla/objects/54bdb7/script.lua:23`

`click_function = "asdfasdfq"` on the line above is deliberate: a zero-size
button is unclickable, so the name never resolves. Rurik is tidier and points it
at a real no-op:

```lua
        click_function = "DoNothing",
```
— `reference/mods/rurik/objects/064e16/script.lua:50`

with `function DoNothing() end` at `:66`. Prefer that — a real empty function
costs nothing and does not look like a typo to the next reader.

`font_size` is in the same units as `width`/`height`, so a zero-size button needs
a large one: 1000 in RotLA, 570 in Rurik.

---

## Scale compensation

Button `position`, `width`, `height` and `scale` are in the **object's local
space**, so a board scaled 6× renders its buttons 6× too big. Divide it out:

```lua
    local bScale = 0.4*board.getScale()

    board.createButton({
        label="Start Game",
        width = 3300,
        height = 699,
        position = {0/bScale.x,0.5,0/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
```
— `reference/mods/rotla/global/script.lua:490`

RotLA repeats `scale = {1/bScale.x,1,1/bScale.z}` at `:497`, `:508`, `:518` and
`:528`. The Y component stays 1 — a button is flat, so only X and Z matter.

Arcs' reach board is scaled 6.015× on X and Z. Any button placed on it needs the
same treatment.

---

## Checklist

- [ ] `onLoad` either `clearButtons()` first, or checks before creating.
- [ ] `getButtons()` guarded for nil.
- [ ] `function_owner` matches the file the handler is defined in.
- [ ] Handler signature matches the source — object `(obj, color, alt)`, XML
      `(player, value, id)`.
- [ ] No index literal you did not capture from `#getButtons()` or verify against
      the creation order in the same file.
- [ ] Buttons on a scaled object divide by that object's scale.

**Next:** [04 — XML UI](04-xmlui.md).
