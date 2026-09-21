# 10 — Antipatterns

Named traps, each with live code from a shipped mod. Every one of these is in a
mod people are playing right now.

For the structural failures — hardcoded GUIDs, absolute coordinates, duplicated
scripts — see [critique.md](../critique.md), C1–C10. This file is the
*small* mistakes: the ones that produce no error, no log line, and no clue.

| # | Trap | Mod | Symptom |
| --- | --- | --- | --- |
| [1](#1-the-swallowed-error) | Blanket `pcall` | Arcs | A feature that has never worked |
| [2](#2-the-nil-key-that-reads-fine) | Undeclared global as a table key | Politik | A limit that never applies |
| [3](#3-the-handler-in-the-wrong-environment) | `function_owner` mismatch | Rurik | Four inert buttons |
| [4](#4-the-handler-defined-twice) | Duplicate function name | RotLA | Half a feature silently dead |
| [5](#5-the-case-typo-lua-really-is-case-sensitive) | `Log.warning` vs `LOG.WARNING` | Arcs | A warning that crashes |
| [6](#6-the-seven-digit-colour) | Malformed hex | Politik | One button renders wrong |
| [7](#7-the-wait-that-does-not-wait) | `Wait.time` used as `sleep` | Politik | A loop that was never paced |
| [8](#8-the-fossil-key) | `onSave` serialising everything | Politik | Dead state re-saved forever |

---

## 1. The swallowed error

```lua
          if not draw_bottom_patched[guid] then
            pcall(function()
              obj.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
            end)
            draw_bottom_patched[guid] = true
          end
```
— `reference/mods/arcs/global/src__Global.lua:231`

`ActionCards` is not in scope at line 233. Its binding,
`local ActionCards = require("src/ActionCards")`, sits at **line 268** — 35 lines
*below* — and the name appears nowhere in lines 1–231. So `ActionCards` is a nil
global, `ActionCards.draw_bottom` raises, the `pcall` swallows it, and **line 235
marks the object patched anyway**. It is never retried. The "Draw bottom card"
menu item has never appeared.

The same call from correct scope works: lines 899 and 2641 call
`ActionCards.draw_bottom` without a `pcall` and succeed.

Arcs has **256** `pcall` mentions (255 real call sites) across 38 deduplicated
modules and 18,067 lines — one every 71 lines.

**Why it survives:** a `pcall` converts an error into a `false` nobody reads.

**Do instead.** A `pcall` is a statement about one specific untrusted call, and
you read its result. Arcs itself gets this right 600 lines later:

```lua
                local ok, err = pcall(function()
```
— `reference/mods/arcs/global/src__Global.lua:832`

```lua
                else
                    print("[DEBUG] Failed to attach menu to marker " .. guid .. ": " .. tostring(err))
                end
```
— `reference/mods/arcs/global/src__Global.lua:839`

Rurik's `safeCall` does the same, with the failure going to chat where a player
will see it (`rurik/global/script.lua:80`).

---

## 2. The nil key that reads fine

```lua
function plus(player, value, id)
  local valId = getValId(id)
  if data[valId] == nil then return end

  local oldValue = data[valId]
  data[valId] = data[valId] + INCREMENT
  if data[maxId] ~= nil then
    data[valId] = math.min(data[valId], data[maxId])
  end
```
— `reference/mods/politik/objects/1c1690/script.lua:76`

`maxId` is never declared. It appears only on lines 82 and 83, so it is a nil
global, and `data[nil]` **reads** as nil rather than raising. The condition is
always false and the cap never applies. The resource counter has no maximum.

**Why it survives:** reading a table with a nil key is legal Lua. Only *writing*
one errors. Had line 82 been an assignment this would have crashed on day one.

Note the contrast three lines up: `if data[valId] == nil then return end` guards
the key that *is* declared. The author knew to guard; the bug is a missing
`local maxId = getMaxId(id)`, the sibling of `getValId` at `:17`, which was
never written.

**Do instead.** In development, fail loudly on a nil you did not expect:

```lua
local maxId = getMaxId(id)
assert(maxId, "no max id for " .. tostring(id))
```

That is `ttslib`'s `log.expect` (C8).

---

## 3. The handler in the wrong environment

```lua
            function_owner = Global, -- IMPORTANT: functions live on Global environment
```
— `reference/mods/rurik/objects/8e05ed/script.lua:41`

on all **4** of the object's `createButton` calls (`:39`, `:55`, `:71`, `:85`),
while the handlers are defined in **its own** script:

```lua
-- Global-owned handlers (since function_owner = Global)
function AdvisorPayPanel_cancel(_, playerColor, alt_click)
```
— `reference/mods/rurik/objects/8e05ed/script.lua:100`

`AdvisorPayPanel_cancel` and `AdvisorPayPanel_pay` appear **zero times** in
Rurik's Global script. `function_owner = Global` tells TTS to look the click
function up in Global's environment, so the buttons are inert. Global builds its
own working panel separately via `AdvisorPay.buildPaymentPanel`
(`reference/mods/rurik/global/script.lua:156`), which is presumably why nobody
noticed.

The comment on the very line that causes it asserts the opposite of what the file
does — a reminder that comments are not evidence.

**Why it survives:** a click function that does not resolve is a no-op, not an
error.

**Do instead.** `function_owner` and the handler in the same file, always. See
[03](03-buttons.md).

---

## 4. The handler defined twice

RotLA declares `onPlayerChangeColor` at `reference/mods/rotla/global/script.lua:560`
**and again** at `:2336`. In Lua, `function f() end` is an assignment — the
second silently wins and the first body is dead code.

**Why it survives:** no warning, no error, and both bodies look reachable.

**Do instead.** Before adding a handler to a large script, grep for it:

```bash
grep -n "function onPlayerChangeColor" reference/mods/rotla/global/script.lua
```

In a 2,453-line file that takes two seconds and is the only thing that catches
it.

---

## 5. The case typo (Lua really *is* case-sensitive)

```lua
            Log.warning("Power bonus zone not found: " .. zone_info.guid)
```
— `reference/mods/arcs/global/src__ArcsPlayer.lua:328`

and again at `:346`. `src/ArcsPlayer` binds `local Log = require("src/LOG")` at
`:2`, and `src/LOG` exports only uppercase names — `LOG.TRACE`
(`arcs/global/src__LOG.lua:5`), `LOG.DEBUG` (`:11`), `LOG.INFO` (`:17`),
`LOG.WARNING` (`:23`), `LOG.ERROR` (`:28`). `Log.warning` is nil, so calling it
raises.

**A missing-zone *warning* becomes a hard error.** The diagnostic is the thing
that breaks.

**Why it survives:** the line only runs when the zone is already missing — a path
nobody tests.

**This one is not open to question.** Unlike the three items below, this is plain
Lua table indexing: `Log.warning` and `LOG.WARNING` are different keys and always
will be. No TTS behaviour can rescue it.

**Do instead.** One naming convention per module, and let the warning path run at
least once in testing.

---

## 6. The seven-digit colour

```lua
        {name = "Blue", color = "#1E87FFF", yOffset = 0, onClick = "onCameraBlueClick", playerColor = "Blue"},
```
— `reference/mods/politik/global/script.lua:179`

`#1E87FFF` is **seven** hex digits. Every sibling entry in the table has six —
`#834A25`, `#E7E52C`, `#00FF00`, `#FF0000`, `#A041DC`.

The value is interpolated straight into XML as `textColor`
(`politik/global/script.lua:200`), so the Blue camera button's text renders with
whatever TTS makes of a malformed colour.

*(An earlier draft of this analysis also claimed `createCameraButtons` is never
called. That was wrong — it is bound to a button at
`reference/mods/politik/objects/f782d2/script.lua:15` via
`click_function = "refreshCameraButtons"`, which calls it at `:105`. The colour
bug is real; the dead-code claim was not.)*

**Do instead.** Colours in a named table, defined once:

```lua
local SEAT_COLOR = { Blue = "#1E87FF", Red = "#FF0000", ... }
```

A repeated literal is a typo waiting to happen; a table is greppable.

---

## 7. The `Wait` that does not wait

```lua
        for _, color in ipairs(seatedPlayers) do
            currentDeck.deal(1, color)
            Wait.time(function() end, 0.1)
        end
```
— `reference/mods/politik/objects/fb0a83/script.lua:35`

`Wait.time` **schedules** a callback. It does not block. The loop finishes in one
frame and then one empty function per player fires 0.1 s later and does nothing.
The intended pacing never existed.

**Why it survives:** the deal works. Only the animation is wrong, and only
slightly.

**Do instead.** A coroutine, where `coroutine.yield(0)` genuinely suspends:

```lua
function dealCoroutine()
  for _, color in ipairs(seatedPlayers) do
    currentDeck.deal(1, color)
    waitAmount(0.1)          -- Rurik's helper, global/script.lua:73
  end
  return 1
end
```

See [02](02-lifecycle.md).

---

## 8. The fossil key

Politik's six resource tokens persist a `LuaScriptState` containing `max1`,
`max2`, `max3`, `statName1`, `statName2` and `statName3` — six keys that appear
**nowhere in the object's script**, not in its defaults
(`objects/1efc34/script.lua:126`) and nowhere else. They are leftovers from an
older version, re-saved forever because:

```lua
function onSave()
  return JSON.encode(data)
end
```
— `reference/mods/politik/objects/1efc34/script.lua:143`

serialises whatever `data` happens to hold.

Trap 2 above is the same bug's other half: the script still *reads* a max, via a
name that no longer exists.

**Do instead.** Serialise a declared shape with a version, and drop unknown keys
on load. See [05](05-state.md).

---

## Open questions: test these in TTS

Four things the corpus cannot settle. The first three it strongly suggests but
cannot prove, because a shipped mod working is evidence, not a specification; the
fourth it is silent on, and two comments in this folder answer it opposite ways.
**Until each is settled, write the conservative form.** Each needs about two
minutes in TTS.

### 1. Are component tags matched case-insensitively?

**Evidence for yes.** Arcs' power scoring queries `getObjectsWithTag("power")`
(`arcs/global/src__Global.lua:666`) and `obj.hasTag("power")`
(`arcs/global/src__ArcsPlayer.lua:332`, `:355`) against nine objects tagged
**`Power`**. The reverse mismatch exists too — `hasTag("Lock")` at
`arcs/global/src__Global.lua:2274` against 376 objects tagged **`lock`**. These
are live scoring paths in a maintained mod. TTS also stores a lowercased
`normalized` form beside every `displayed` label in `ComponentTags.labels`.

**Evidence that nobody knows.** Rurik hedges both ways:

```lua
        if o and (o.hasTag("Deed") or o.hasTag("deed")) then
```
— `reference/mods/rurik/global/script.lua:296`

and again for `Coin`/`coin` (`:816`) and `Character`/`character` (`:910`, `:916`).

**The test.**

```lua
-- tag one object "TestTag" in the TTS UI, then in Global:
function onLoad()
  print(#getObjectsWithTag("testtag"), #getObjectsWithTag("TestTag"))
end
```

**Until then:** match the exact casing the objects carry.

### 2. Are Object members resolved case-insensitively?

**Evidence for yes.** Almoravid calls `.SetRotationSmooth(` — capital S —
**630 times**, and the documented lowercase `setRotationSmooth` 231 times,
interleaved through the same file (capital at `almoravid/global/script.lua:342`
through `:7658`, lowercase at `:974` through `:7637`). The API documents only
`setRotationSmooth`
([`reference/api/object.md:172`](../../reference/api/object.md)). Nothing in the
corpus defines a `SetRotationSmooth` helper, and it is the **only** capitalised
member call in all five mods — Politik, RotLA, Arcs and Rurik use the lowercase
form exclusively.

If TTS were strict here, 630 rotations in a published GMT wargame mod would
silently fail.

**The test.**

```lua
function onLoad()
  local o = getAllObjects()[1]
  print(type(o.setRotationSmooth), type(o.SetRotationSmooth))
end
```

**Until then:** write the documented casing.

### 3. Is `onload` still accepted as an alias for `onLoad`?

**Evidence for yes.** RotLA's Global script defines
`function onload(saved_data)` at `reference/mods/rotla/global/script.lua:373` and
**defines no `onLoad` at all**. If the lowercase form were ignored, RotLA's entire
global boot — including the `SAVE_STATE` restore — would never run.

It is not an isolated typo. **Four of the five mods** contain a lowercase
`onload` declaration:

| Mod | Site |
| --- | --- |
| RotLA | `rotla/global/script.lua:373` *(its only `onLoad`)*, `rotla/objects/bd69bd/script.lua:9` |
| Arcs | `arcs/global/src__Control.lua:118`, `arcs/global/src__SetupControl.lua:683` |
| Rurik | `rurik/objects/8cb299/script.lua:1` |
| Almoravid | `almoravid/objects/ddb88c/script.lua:8` |

Almoravid's Global uses the correct `onLoad` (`almoravid/global/script.lua:270`)
while its
single object script uses `onload` — both in the same mod, by the same author.

The API documents only `onLoad`
([`reference/api/events.md:261`](../../reference/api/events.md)). The lowercase
spelling is plausibly a legacy alias from an older TTS, but nothing in the
vendored docs says so.

**The test.**

```lua
function onload(s) print("lowercase onload ran") end
```

**Until then:** write `onLoad`.

### 4. Is `createButton`'s `position` applied before or after the object's `scale`?

Unlike the first three, this one is not about name resolution — and unlike them,
the corpus offers no evidence either way, because no mod here puts buttons on a
scaled object.

**Why it matters.** `ui.unscale(obj)` returns a `scale` that cancels the object's
own, so a button on a board scaled 6 × 1 × 4 comes out its own shape rather than
six times too wide. What it cannot tell you is whether `position` is measured in
the object's scaled units or its unscaled ones. If `position` is applied *after*
the button's own `scale`, then passing `unscale` shrinks the offsets too, and
every button lands at 1/6 of its intended x and 1/4 of its intended z — clustered
near the board's centre instead of spread across it.

**The two comments in this folder disagree**, and both say so out loud:

- [`ttslib/03-ui.lua:161`](../../reference/framework/ttslib/03-ui.lua) — "Pass
  this as `scale`, and divide positions by the same factors."
- [`demo/Global.lua:173`](../../reference/framework/demo/Global.lua) — "positions
  stay in the same local units the spaces table uses."

They cannot both be right. `reference/api/object.md` documents `position` only as
"relative to the Object's center" and never says relative to *which* units, so
the vendored docs do not settle it either.

**The test.** On an object scaled 6 × 1 × 4:

```lua
function onLoad()
  local s = self.getScale()
  local unscale = { x = 1 / s.x, y = 1, z = 1 / s.z }
  -- same nominal offset, once raw and once unscaled
  self.createButton{ label = "A", click_function = "noop", function_owner = self,
                     position = { 0.4, 0.6, 0 } }
  self.createButton{ label = "B", click_function = "noop", function_owner = self,
                     position = { 0.4, 0.6, 0 }, scale = unscale }
end
function noop() end
```

If A and B sit at the **same** distance from the centre, `position` is
pre-scale and the demo's comment is right. If B sits **closer in** (at 1/6 the
offset), `position` is post-scale and positions must be divided, as `03-ui.lua`
says.

**Until then:** on an unscaled object the question does not arise, so keep
anchors at scale 1 and put the scaling in the `spaces` table. The demo takes the
other path deliberately; if it turns out to be the wrong one, its buttons move
but nothing else in `ttslib` changes.

---

## Settled on the table

### Two snapping systems, and the save file can lie about one (2026-09-21)

**There are two independent magnets in TTS and they are configured in different
places.** Snap points are data on an object or the table, and can carry tags.
The **grid** — Options > Grid > Snapping, `Grid.snapping` in the API — is
global: 1 Off, 2 Lines, 3 Centre, 4 Both, applying to every object with
`use_grid` set, which is TTS's default for a new one. There is no tag on it and
no per-object allow-list.

Amazonia spent an afternoon blaming its 14 snap points for cubes jumping to hex
centres. The points were tagged `tile` and innocent. The grid was at Centre on a
hex lattice.

**And the file disagreed with the game.** `TS_Save_127.json` carried
`"Grid": { "Snapping": false }`; the running game loaded from it reported
`Grid.snapping = 3`. Whatever the mapping between the save's booleans and the
API's enum is, it is not "read the file and you know". `print(Grid.snapping)`
against the live game is the only reliable answer, and it costs one line.

The lesson is general: **the save file is where TTS last wrote state, not what
the game is doing now.** For anything the Options menus can change under you,
read it through the API.

What remains open is whether a *tagged* snap point spares an object carrying no
tags at all. Every piece in every mod here is tagged, so the corpus cannot say.
The form that does not depend on it: clear `use_grid` and `use_snap_points` on
the objects that must not snap.

```lua
-- only tiles snap; everything else opts out of both systems as it spawns
Grid.snapping = 1
events.on("spawn", "*", function(obj)
  if not obj.hasTag("tile") then
    obj.use_grid, obj.use_snap_points = false, false
  end
end)
```

---

## Why the first three are one family

All three are questions about **TTS's own name resolution at the C#/Lua
boundary** — tag strings, member lookup, callback dispatch. They are separate
mechanisms and could easily have different answers; nothing here should be
generalised from one to another. Question 4 is not one of them: it is about
coordinate spaces, and shares only the property of being unanswerable from here.

What is *not* in question is Lua itself. Trap 5 above is a plain table lookup and
is case-sensitive beyond argument. When in doubt about which kind you are looking
at: if the name is being resolved by a table you can see in the source, it is
Lua and it is strict.

---

**Back to** [README](README.md) · **the structural critique** is
[critique.md](../critique.md).
