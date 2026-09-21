# 06 — Objects, tags and containers

How to find an object, how to react when one moves, and why 55 scripts in RotLA
start with the same line.

---

## Identifying an object

Four accessors, three of them easy to confuse.

| Expression | Returns | JSON field |
| --- | --- | --- |
| `obj.type` | the object's type — `"Deck"`, `"Card"`, `"Bag"` | `Name` |
| `obj.tag` | same thing, **deprecated** | `Name` |
| `obj.name` | internal resource name; only useful for `spawnObjectData` | `Name` |
| `obj.getName()` | the **nickname** — the label you typed | `Nickname` |

`obj.tag` is marked *deprecated, use `type`* in
[`reference/api/object.md:77`](../../reference/api/object.md). Arcs uses the
deprecated form as its primary check and then falls back twice more:

```lua
      local is_deck = false
      -- prefer the stable tag, fall back to name property/method
      if obj.tag and obj.tag == "Deck" then
        is_deck = true
      elseif obj.getName and obj.getName() == "Deck" then
        is_deck = true
      elseif obj.name == "Deck" then
        is_deck = true
      end
```
— `reference/mods/arcs/global/src__Global.lua:216`

The second branch can never fire: **zero** of Arcs' 53 decks are nicknamed
`"Deck"` (36 have no nickname at all). It is harmless belt-and-braces, but it
tells you the author was not sure which accessor to trust. Use `obj.type`.

`getName()` is genuinely useful when the nickname *is* the data:

```lua
      if object.getName() == "SONG OF FREEDOM" and not object.is_face_down then
```
— `reference/mods/arcs/objects/7a33fa/src__CourtDiscard.lua:21`

That is legitimate — and it is also why `Nickname` is no longer listed as safe to
edit freely in [`save-format.md`](../save-format.md#common-object-fields).

---

## Component tags

Tags are the only identity that survives duplication. They live in two places:

- **`ComponentTags.labels`** at save level — the palette TTS offers in its UI,
  each entry `{"displayed": "politik card", "normalized": "politik_card"}`.
- **`Tags`** on each object — a plain list of `displayed` strings.

Declared vs actually used, across the corpus:

| Mod | labels declared | tags used | objects tagged |
| --- | --- | --- | --- |
| Rurik | 147 | 61 | 329 |
| Arcs | 88 | 72 | 1,668 |
| Politik | 31 | 14 | 1,323 |
| RotLA | 16 | 16 | 469 |
| Almoravid | 0 | 0 | 0 |
| *owner's prototypes* | **0** | **0** | **0** |

The palette drifts ahead of use — Rurik declares 147 labels and uses 61. Nothing
breaks; it is just clutter. The last row is the gap this cookbook exists to
close.

### The API

| Call | Does |
| --- | --- |
| `getObjectsWithTag(tag)` | every object on the table with that tag |
| `obj.hasTag(tag)` | one object |
| `obj.getTags()` | its list |
| `obj.addTag(tag)` / `obj.removeTag(tag)` | mutate at runtime |
| `obj.hasMatchingTag(other)` | do two objects share any tag |

Grep [`reference/api/INDEX.md`](../../reference/api/INDEX.md) for the page.

### Tag caching

`getObjectsWithTag` walks the table. Rurik caches, and you can copy the shape but
not the invalidation:

```lua
local function rebuildTagCache()
    TAG_MULTI = {}
    for _, o in ipairs(getAllObjects()) do
        local tags = o.getTags()
```
— `reference/mods/rurik/global/script.lua:34`

```lua
function getByTag(tag)
    local list = TAG_MULTI and TAG_MULTI[tag] or nil
    if not list or #list == 0 then return nil end
    return list[1]
end
```
— `reference/mods/rurik/global/script.lua:47`

The cache is rebuilt by hand at six call sites and is **never invalidated on
spawn or destroy**. Take an object out of a bag and the cache is stale until
something happens to call `rebuildTagCache` again. `ttslib`'s `registry`
invalidates on spawn/destroy instead (C1).

### Multi-tag queries

Tags compose, which is what makes them better than a naming convention. Arcs
finds one player's power cubes by intersecting two tags:

```lua
                if obj.hasTag("power") and obj.hasTag(color_tag) then
```
— `reference/mods/arcs/global/src__ArcsPlayer.lua:332`

with `color_tag` built as `self.color .. "Piece"` — so `RedPiece`, `WhitePiece`.
Rurik does the same for coin bags:

```lua
        if o and o.type=="Bag" and o.hasTag and o.hasTag("Coin") and o.hasTag(playerColor) then
```
— `reference/mods/rurik/global/script.lua:1364`

**One axis per tag.** `Coin` + `Blue` beats `BlueCoin`, because the first
composes and the second has to be parsed.

### Tagged snap points

A snap point can carry tags too, and then only matching components snap to it:

```json
{ "Position": {...}, "Rotation": {...}, "Tags": ["City", "Starport"] }
```

Arcs uses this heavily — **245 of its 320** table snap points carry tags, plus
234 of its 245 object-attached ones, and the tag names are the same ones the
scripts query (`Agent` ×89, `Power` ×55, `Resource` ×27, `Court` ×11). Politik
tags 1,130 of its 1,562 object snap points. See [07](07-placement.md).

---

## ⚠ Tag case is unsettled

**Arcs' power scoring queries a tag that no object carries, in that casing.**

Nine objects carry the tag `Power` — five `BlockSquare` cubes (`4c96ac`,
`e1edd4`, `38ef71`, `40f97a`, `d25054`) and four `Custom_Model` objective
markers (`3c2ffc`, `c5bc19`, `59d36b`, `8d76b7`). Every query
is lowercase:

```lua
  local power_cubes = getObjectsWithTag("power") or {}
```
— `reference/mods/arcs/global/src__Global.lua:666`

and at `arcs/global/src__ArcsPlayer.lua:332` and `:355`. The reverse mismatch
exists too: 376 objects carry `lock`, and `arcs/global/src__Global.lua:2274` asks
`hasTag("Lock")`.

These are not dead paths — `ArcsPlayer`'s are the power-bonus-zone scoring and
the negative-power check. If matching were case-sensitive, scoring in a popular,
actively maintained mod would be broken.

Rurik's author clearly did not know either, and hedged:

```lua
        if o and (o.hasTag("Deed") or o.hasTag("deed")) then
```
— `reference/mods/rurik/global/script.lua:296`

```lua
    if o.hasTag and (o.hasTag("Coin") or o.hasTag("coin")) then return true end
```
— `reference/mods/rurik/global/script.lua:816`

and again for `Character`/`character` at `:910` and `:916`.

A third piece of evidence: TTS itself stores a `normalized` (lowercased,
underscored) form beside every `displayed` label in `ComponentTags.labels`,
which is at least suggestive that it normalises for matching.

**This is still not proof, and the API docs say nothing.** Until someone runs the
test in TTS — tag one object `TestTag`, then `print(#getObjectsWithTag("testtag"))`
— **match the exact casing the object carries.** Tracked as
[open question 1](10-antipatterns.md#open-questions-test-these-in-tts).

---

## Container events

TTS delivers `onObjectEnterContainer` and `onObjectLeaveContainer` to **every**
script that defines them — Global and every object. So every object script must
discard events that are not about itself:

```lua
function onObjectLeaveContainer(bag, obj)
    if bag~=self then return end
```
— `reference/mods/rotla/objects/54bdb7/script.lua:2`

**Note the spacing: `bag~=self`, no spaces.** A grep for `bag ~= self` finds
nothing in RotLA.

**55 scripts** in RotLA carry that guard, **106 occurrences** — one for enter, one
for leave. Every container event in the game is dispatched to all 55, and 54
return immediately (C7). Worse, the guard is load-bearing boilerplate: omit it in
one script and that script reacts to every other bag's contents.

Rurik writes it with spaces, in its 24 inventory bags:

```lua
function onObjectEnterContainer(container, obj)
    if container ~= self then return end
```
— `reference/mods/rurik/objects/064e16/script.lua:69`

**Fix.** Subscribe **once**, in Global, and route by tag:

```lua
function onObjectEnterContainer(container, obj)
  if container.hasTag("supply") then supplyChanged(container) end
end
```

One registration replaces 51 copies. That is `ttslib`'s `events` module
(C6, C7).

---

## `filterObjectEnter` — the veto

A container can refuse an object. Return `false` and the drop is rejected. RotLA's
sorting bag uses it to re-route rather than accept:

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

The whole script. Drop anything on this bag and it goes home instead — a
one-object "return to supply" tray. `return true` when there is no home, so
unknown objects still land somewhere rather than vanishing.

Note `obj.getQuantity() > 1`: a dropped *stack* has to be taken apart one at a
time, because `putObject` moves the whole stack.

---

## `GMNotes` back-pointers

The other half of that mechanism. When something leaves a supply bag, the bag
stamps its own GUID onto the object:

```lua
    if not (string.find(obj.getGMNotes(), "Private")) then
        obj.setGMNotes(self.getGUID())
    end
```
— `reference/mods/rotla/objects/54bdb7/script.lua:4`

So every token in play knows where it came from, and the sorting bag above can
read it. 133 objects in RotLA carry non-empty `GMNotes`.

**It works, and it is still the wrong channel** (C4). `GMNotes` is a
human-visible field; anyone who edits it in the TTS UI breaks the return path
silently, and the `string.find(..., "Private")` special case shows the field was
already overloaded for two purposes. A component tag naming the supply role does
the same job, survives duplication, and cannot be typed over by accident.

Rurik reads a number out of `GMNotes` the same way:

```lua
local function gmNumberFromObject(obj, defaultVal)
    if not obj then return defaultVal end
    local n = tonumber(string.match(obj.getGMNotes() or "", "%d+"))
    return n or defaultVal
end
```
— `reference/mods/rurik/global/script.lua:67`

and its boot sequence branches the whole game on it — that is the round counter,
stored in a notes field.

---

## Taking and putting

```lua
    self.takeObject({
        position = self.getPosition() + Vector(0,2,0),
        smooth = false,
        callback_function = function(obj)
            if obj and not obj.isDestroyed() then
                trash.putObject(obj)
            end
        end,
        callback_owner = self
    })
```
— `reference/mods/rurik/objects/064e16/script.lua:97`

- `takeObject` is **asynchronous**. The object does not exist until the callback.
- `callback_function` may be a real closure here (unlike `click_function`), with
  `callback_owner` naming its environment.
- Guard with `isDestroyed()` — Almoravid does the same at
  `almoravid/global/script.lua:482`.
- Lift the spawn position clear of the bag (`+ Vector(0,2,0)`) or it can drop
  straight back in.
- `putObject(obj)` is synchronous and takes the whole stack.

See [09](09-decks-cards.md) for decks specifically.

---

## Context menus

For actions that do not deserve screen space:

```lua
                    marker.addContextMenuItem("Show Ambition Scores", show_ambition_scores_menu)
```
— `reference/mods/arcs/global/src__Global.lua:833`

The handler is a **function value**, not a name string — the opposite of
`click_function`. Arcs registers 27 context menu items. They survive reloads only
if you re-register in `onLoad`, which is why Arcs wraps the whole thing in the
bounded retry at `arcs/global/src__Global.lua:864` ([02](02-lifecycle.md)).

---

## Checklist

- [ ] Objects addressed by tag, not GUID literal.
- [ ] `obj.type`, not `obj.tag` or `obj.name`.
- [ ] One tag per axis; compose with `hasTag` twice.
- [ ] Tag queries match the exact casing the objects carry (until question 1 is
      settled).
- [ ] Container events subscribed **once** in Global and routed by tag.
- [ ] Nothing important stored in `GMNotes`.
- [ ] Every `takeObject` result used only inside its callback, guarded by
      `isDestroyed()`.

**Next:** [07 — Placement](07-placement.md).
