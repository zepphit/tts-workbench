# 02 — Lifecycle

When your code runs, and why the object you asked for is not there yet.

Almost every "it works the second time" bug in TTS is a timing bug. This recipe
covers the order things happen in and the five primitives you have to work with.

---

## The order

1. TTS instantiates every object in `ObjectStates`.
2. Each object's `LuaScript` is compiled, and its `onLoad(script_state)` runs.
3. The global `LuaScript` is compiled, and its `onLoad(script_state)` runs.
4. Everything else is an event.

**Object `onLoad` runs before Global `onLoad`.** An object script that calls into
Global at load time is calling into a script that has not finished setting up.
Delegate on the *next frame*, not immediately.

**Objects inside containers do not exist.** A card in a deck, a token in a bag —
these have no Object, no script and no GUID lookup until something takes them
out. `getObjectFromGUID` returns nil for all of them. This is not a race you can
wait out; it is the state of the table.

That distinction is exactly what `tts.py validate` separates. On Almoravid it
reports **54** `getObjectFromGUID` literals that resolve only inside containers —
warnings, not errors, because the mod may intend to bind them after setup. On
Arcs' `TS_Save_125` it reports **3** that match nothing at all — errors.

```bash
python3 scripts/tts.py validate Mods/Workshop/2804149704.json
```

---

## `onLoad(script_state)`

```lua
function onLoad(script_state)
  data = JSON.decode(script_state)
  if data == nil then
    data = { ... defaults ... }
  end
  ...
end
```
— `reference/mods/politik/objects/1efc34/script.lua:122`

`script_state` is whatever the matching `onSave` returned last time, as a string.
On a fresh load it is `""`, and `JSON.decode("")` returns nil — so the
`if data == nil` branch is your defaults. See [05](05-state.md) for why this
particular example also carries six keys nothing reads.

Rurik's variant guards on length instead, which is equivalent and marginally
clearer about intent:

```lua
function onLoad(saveinf)
    if saveinf and #saveinf > 0 then
        local t = JSON.decode(saveinf)
```
— `reference/mods/rurik/objects/064e16/script.lua:17`

**Casing.** The API documents `onLoad`
([`reference/api/events.md:261`](../../reference/api/events.md)). RotLA's Global
script defines only `function onload(saved_data)` — lowercase `l` — at
`reference/mods/rotla/global/script.lua:373`, and defines no `onLoad` anywhere;
its 55 *object* scripts all use `onLoad`. Four of the five mods contain a
lowercase `onload` somewhere. Whether TTS still accepts it as a legacy alias is
[open question 3](10-antipatterns.md#open-questions-test-these-in-tts). **Write
`onLoad`.**

---

## Coroutine boot — the good pattern

For setup that must proceed in steps, and must wait for things to spawn, a
coroutine beats a chain of nested `Wait` callbacks. Rurik does this well:

```lua
function onLoad()
    rebuildTagCache()
    startLuaCoroutine(Global, "bootCoroutine")
```
— `reference/mods/rurik/global/script.lua:150`

```lua
function bootCoroutine()
    rebuildTagCache()

    local coinsBag = waitByTag("bag_coins", 10)
    if not coinsBag then
        broadcastToAll("ERROR: Missing tag bag_coins on coins bag.", {r=1,g=0.2,b=0.2})
        return 1
    end
```
— `reference/mods/rurik/global/script.lua:163`

Three things to copy:

- **`startLuaCoroutine(owner, "functionName")`** takes a *name*, and the function
  must be a global on that owner.
- **A coroutine must `return 1`.** Returning nothing, or 0, is an error in TTS.
  Every exit path needs it — note the early `return 1` in the failure branch
  above.
- **The wait is bounded and the failure is loud.** `waitByTag(tag, 10)` gives up
  after ten seconds and says so in chat with a red colour. Compare Arcs'
  `pcall`-and-continue, which says nothing at all (C8).

Yielding is `coroutine.yield(0)` — one frame:

```lua
function waitAmount(seconds)
    local start = Time.time
    while (Time.time - start) < (seconds or 0) do
        coroutine.yield(0)
    end
end
```
— `reference/mods/rurik/global/script.lua:73`

One caveat on Rurik's own `waitByTag`: it calls `rebuildTagCache()` — a full
`getAllObjects()` sweep — on **every frame** of the loop
(`reference/mods/rurik/global/script.lua:56`). Poll the one thing you are waiting
for, not the whole table.

---

## The `Wait` family

| Call | Runs | Cancel |
| --- | --- | --- |
| `Wait.frames(fn)` | next frame | `Wait.stop(id)` |
| `Wait.frames(fn, n)` | in n frames | ” |
| `Wait.time(fn, s)` | in s seconds | ” |
| `Wait.time(fn, s, -1)` | every s seconds, forever | ” — and you **must** |
| `Wait.condition(fn, cond)` | when `cond()` is true | ” |

### The spawn-callback idiom

The thing you just took out of a bag is not ready in the same frame. Almoravid
writes this 537 times:

```lua
bagSiegeC.takeObject({
    callback_function = function(obj)
        Wait.frames(function()
            if not obj.isDestroyed() then
                obj.setPositionSmooth({3.74,6.66,3.66}, false, false)
```
— `reference/mods/almoravid/global/script.lua:479`

The shape is right — `takeObject` callback, then one frame, then position, with
an `isDestroyed()` guard. What is wrong is that it is written out 537 times with
the coordinates inline (C2, C9). Extract it once:

```lua
local function placeFrom(bag, pos, rot)
  bag.takeObject({ callback_function = function(obj)
    Wait.frames(function()
      if obj.isDestroyed() then return end
      obj.setPositionSmooth(pos, false, false)
      if rot then obj.setRotationSmooth(rot) end
    end)
  end })
end
```

### Waiting for an object to settle

`Wait.condition` with `obj.resting` is the right way to react after a drop:

```lua
    deps.zone_waits[wait_id] = Wait.condition(function()
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:57`

with the condition:

```lua
    end, function()
      return object == nil or object.getGUID == nil or object.resting
    end)
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:79`

Note the condition returns true when the object has *gone away* as well as when
it is at rest. A `Wait.condition` whose condition can never become true waits
forever, silently. Always give it an exit.

The related guard is `obj.isSmoothMoving()`, documented at
[`reference/api/object.md:163`](../../reference/api/object.md) — smooth moves are
what `setPositionSmooth` and `setRotationSmooth` start.

### Cancellable keyed waits

Arcs' best async idea, buried in one function. Key each pending wait by the
object's GUID and cancel the previous one before starting a new one:

```lua
    local wait_id = object.getGUID()
    if deps.zone_waits[wait_id] then
      Wait.stop(deps.zone_waits[wait_id])
      deps.zone_waits[wait_id] = nil
    end
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:52`

Without this, dragging a card three times queues three handlers. This is
`ttslib`'s `async.keyed` (C9).

### Debouncing duplicate events

TTS fires drop and zone events more than once for a single physical action. Arcs
suppresses repeats inside a window:

```lua
local DUPLICATE_WINDOW_SECONDS = 1.25
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:5`

```lua
local function should_suppress_duplicate(guid, event_kind, player_color)
  local now = os.clock()
  local key = tostring(guid or "") .. "|" .. tostring(event_kind or "") .. "|" .. tostring(player_color or "")
  local prev = recent_announcements[key]
  recent_announcements[key] = now
  return prev and (now - prev) < DUPLICATE_WINDOW_SECONDS
end
```
— `reference/mods/arcs/global/src__events__DropActionEvents.lua:11`

A composite key of (object, event kind, player) rather than the object alone —
so a seize and a play of the same card are not conflated. This is
`ttslib`'s `async.debounce`.

### Bounded retry

When something may not have spawned yet, retry — but count:

```lua
        if markers_found < (#ambition_marker_GUIDs + 1) and attempt < 5 then
            Wait.time(function()
                try_attach(attempt + 1)
            end, 0.5)
        end
```
— `reference/mods/arcs/global/src__Global.lua:864`

Five attempts, half a second apart, then it stops. Unbounded retries are a hang
that looks like a hang in the physics engine.

### Repeating timers must be stopped

```lua
    Timer.timer_id = Wait.time(function() Timer.update(active_players) end, 1, -1)
```
— `reference/mods/arcs/global/src__Timer.lua:35`

`-1` means forever. Keep the id and stop it, or you get a second timer every time
the function runs:

```lua
    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
        Timer.timer_id = nil
    end
```
— `reference/mods/arcs/global/src__Timer.lua:49`

Arcs' `Timer.start` also stops any existing timer before starting a new one
(`arcs/global/src__Timer.lua:29`) — the defensive version of the same rule.

---

## Late joiners

A player who connects after `onLoad` never saw your setup run. Global XML panels
are per-table and survive, but anything you *built* — buttons, per-colour UI —
does not exist for them unless you rebuild it.

```lua
function onPlayerConnect(player)
    -- Ensure late joiners get the panel buttons
    Wait.time(function()
        if AdvisorPay and AdvisorPay.buildPaymentPanel then
            AdvisorPay._panelBuilt = false
            AdvisorPay.buildPaymentPanel(true)
        end
    end, 1.0)
end
```
— `reference/mods/rurik/global/script.lua:183`

Two things to note: the one-second delay (the player's client is still catching
up), and `_panelBuilt = false` — forcing an idempotent rebuild rather than
appending a second panel. That idempotency is the subject of
[03](03-buttons.md).

Arcs handles the same event at `arcs/global/src__Global.lua:168`, and also
implements `onPlayerChangeColor` (`:178`), `onPlayerAction` (`:879`) and
`onPlayerTurn` (`:906`).

**Careful:** RotLA defines `onPlayerChangeColor` **twice**, at
`reference/mods/rotla/global/script.lua:560` and again at `:2336`. In Lua the
second assignment wins and the first body is dead. Nothing warns you. See
[10](10-antipatterns.md).

---

## Checklist

- [ ] Object `onLoad` does not call Global directly — it waits a frame.
- [ ] Every coroutine `return 1`s on **every** path.
- [ ] Every wait for a spawn is bounded, and says something when it gives up.
- [ ] Every `Wait.condition` can become true, or go away.
- [ ] Every repeating `Wait.time(..., -1)` has its id stored and stopped.
- [ ] `onPlayerConnect` rebuilds anything you built, idempotently.
- [ ] No handler name is defined twice in the same script.

**Next:** [03 — Buttons](03-buttons.md).
