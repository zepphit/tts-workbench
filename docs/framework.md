# `ttslib` — the house framework

A small Lua library and an architecture for prototypes built in this folder.
Every module answers a numbered problem from [critique.md](critique.md): these
are not general-purpose abstractions, they are the seven things five shipped mods
get wrong, fixed once.

The library lives in [`reference/framework/ttslib/`](../reference/framework/ttslib/)
as seven files, none of them long — every one is readable in full in a sitting,
and that is the size limit it is held to. For the current figures, run
`wc -l reference/framework/ttslib/*.lua` rather than trusting a number written
here: they move whenever the library is edited.

| Module | Answers | In one line |
| --- | --- | --- |
| [`log`](#log--c8) | C8 | Levels, loud failure, and the only sanctioned `pcall` |
| [`async`](#async--c9) | C9 | Bounded waits: frames, keyed, settle, retry, debounce |
| [`store`](#store--c4) | C4 | Declared state with a version, one generated `onSave` |
| [`ui`](#ui--c3) | C3 | Buttons addressed by name instead of by index |
| [`events`](#events--c6-c7) | C6, C7 | One dispatcher, behaviour registered against a tag |
| [`registry`](#registry--c1) | C1 | Objects resolved by role tag, with a boot-time manifest |
| [`layout`](#layout--c2) | C2 | Anchor-relative placement, named spaces, snap points |

The remaining three critique items are architecture rather than code: C5 and C10
are answered by the build below, C6 also by rule 3.

---

## The five rules

1. **One bundle. Thin object scripts.** `ttslib` lives in the Global script,
   once. An object script delegates to Global in a line or two — see
   [`ObjectScript.lua`](../reference/framework/ObjectScript.lua). Arcs compiles
   16 shared modules into two to four object slots each, byte-identical until
   somebody edits one (C5).
2. **Tags are identity; GUIDs are a cache.** Everything you type is a role name.
   A GUID belongs in a `takeObject` call, never in a lookup table (C1).
3. **Data, not duplicated code.** Component variation lives in tags and a config
   table. RotLA has 51 byte-identical bag scripts; one registration replaces them
   (C6).
4. **Fail loudly at boot, degrade only at boundaries.** `registry.check()` before
   setup, `log.expect` at the top of a function, `log.attempt` where you have
   genuinely decided to continue (C8).
5. **Source lives in files, not in the save.** Author under `src/`, build into a
   *new* numbered save, never edit the Lua inside the JSON (C10).

---

## Getting it into a save

TTS has no `require`: a script is one chunk, so a build is a concatenation in
load order. That is what the numeric prefixes on the filenames are for.

```bash
cat reference/framework/ttslib/*.lua src/*.lua > /tmp/global.lua
python3 scripts/tts.py lua inject Saves/TS_Save_111.json /tmp/global.lua -o Saves/TS_Save_127.json
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

Verified on this machine: the concatenated build injects into a save, `validate`
comes back clean, and `lua extract` gives back the same bytes. Check that TTS is
not running before writing anything under `Saves/` (`ls -lt Saves | head`), and
write to a new number — `lua inject` refuses to target its own input, but it will
happily write over a *different* save you named.

**A worked example of the whole chain** — empty table, components, script, panel,
validate — is
[`reference/framework/demo/build.sh`](../reference/framework/demo/README.md). It
produces `Saves/TS_Save_126.json`, the **Woodcutter** demo: a small loadable save
in which all seven modules are load-bearing. Load that before reading much
further; it is faster than this document at showing what the library is for.

Your own files need the same ordering discipline:

```
src/
├── 00-config.lua       roles, spaces, constants — data only
├── 10-<feature>.lua    one file per feature
└── 99-Global.lua       onLoad, onSave, the bus
```

Start from [`Global.lua`](../reference/framework/Global.lua), which wires all
seven modules together and is the shape every prototype here should have. For
live iteration while TTS is running, see
[`reference/api/externaleditorapi.md`](../reference/api/externaleditorapi.md).

**Load order matters and is checked.** Each file opens with an `assert` naming
the file it needs before it, so a bad concatenation fails at load with a sentence
rather than a nil index somewhere later.

---

## `log` — C8

Arcs has 255 `pcall` call sites, one every 71 lines, and one of them has hidden a
feature that has never worked since release. The inversion: report by default,
and make each swallowed error a named boundary that still reports.

```lua
local LOG = ttslib.log
LOG.prefix = "[mygame]"
LOG.level  = "debug"        -- "warn" before you publish
```

| Call | Does |
| --- | --- |
| `LOG.trace/debug/info/warn/error(message, detail)` | Levelled output; below `LOG.level` is dropped |
| `LOG.once(key, level, message, detail)` | Says it once per session, for per-frame conditions |
| `LOG.expect(value, message, detail)` | Returns the value; reports loudly when it is nil or false |
| `LOG.assert(condition, message, detail)` | Raises. For an invariant, not for a missing component |
| `LOG.attempt(label, fn, a, b, c, d, e, f)` | A `pcall` with a name that still reports the failure. Six arguments, the width of `onObjectRotate` |
| `LOG.sink(level, text)` | Replace to redirect everything |
| `LOG.forget()` | Drops what `once` has already said. For tests, and for a full reset |
| `LOG.level` | The current threshold, a `LEVELS` key. Set it to `"info"` to ship |
| `LOG.LEVELS` | `trace` 1, `debug` 2, `info` 3, `warn` 4, `error` 5, `silent` 6 |
| `LOG.prefix` | `"[ttslib]"` — set it to your game's name |
| `LOG.ERROR_TINT` | The colour `error` broadcasts in |

`trace` and `debug` go to the host System Console (`~`), everything else to
**host chat** — `print` "prints a string into chat that only the host is able to
see" ([api/base.md:86](../reference/api/base.md)), so in multiplayer no one but
the host sees an `info` or a `warn`. `error` is the exception: it also
`broadcastToAll`s on screen, because the failure you most need to see is the one
during setup. If a message is for the table, it has to be an `error` or your own
`broadcastToAll`.

```lua
local bag = LOG.expect(reg.one("supply.wood"), "no wood supply on the table")
if not bag then return end
```

This module is `ttslib.log`; it never defines a global called `log`, so TTS's own
`log()` still works.

---

## `async` — C9

Almoravid hand-writes `takeObject` → `Wait.frames` → `setPositionSmooth` 537
times. Arcs invents a keyed wait registry, a bounded retry and a 1.25-second
duplicate suppressor, each once, inline, reachable from nowhere else. These are
those ideas with names.

| Call | Does |
| --- | --- |
| `async.afterFrames(n, fn)` | `Wait.frames`, default one frame |
| `async.after(seconds, fn)` | `Wait.time`, one shot |
| `async.keyed(key, seconds, fn)` | Cancels whatever that key was already waiting on. `seconds` may be nil for next frame |
| `async.every(key, seconds, fn)` | Repeating timer that cannot stack — the second call replaces the first |
| `async.cancel(key)` / `async.cancelAll()` | Stop a keyed wait |
| `async.whenSettled(obj, fn, timeout)` | Runs `fn(obj)` once `resting` and not smooth-moving; exits if the object goes away; warns on timeout |
| `async.retry(fn, {times, delay, label})` | `fn(attempt)` returns truthy when done; bounded, and loud when it gives up |
| `async.debounce(key, window)` | True when this is a repeat inside the window |
| `async.gone(obj)` | Destroyed, or a handle that has lost its methods |
| `async.now()` | `Time.time`, Unity's clock — with a fallback so this file runs outside TTS |
| `async.forget()` | Clears the `debounce` table. For tests, and for a full reset |
| `async.SETTLE_TIMEOUT` | `10` — seconds `whenSettled` waits before giving up out loud |
| `async.DUPLICATE_WINDOW` | `1.25` — the default `debounce` window; Arcs' figure |
| `async.SEEN_LIMIT` | `256` — entries after which `debounce` prunes, so the table cannot grow forever |

`keyed` is the one to reach for when an event can arrive in a burst:

```lua
events.on("enterContainer", "supply", function(container)
  async.keyed("supply.badge", nil, refreshBadge)   -- one refresh, not twelve
end)
```

Every wait here is bounded. A `Wait.condition` whose condition can never become
true waits forever and says nothing; `whenSettled` exits when its object is
destroyed, and reports if it hits the timeout.

---

## `store` — C4

Politik's tokens still re-save six keys that appear nowhere in their script.
RotLA needed a `USE_SAVES` kill switch because saved state silently overrides an
edited default. A store makes both impossible: you declare the shape, and only
the declared keys survive.

```lua
local game = ttslib.store.new("game", {
  version  = 1,
  defaults = { round = 1, started = false },
  migrate  = function(saved, fromVersion)       -- optional
    return { round = saved.turn or 1 }
  end,
})

function onSave() return ttslib.store.serialize() end
function onLoad(script_state)
  ttslib.store.restore(script_state)
  ...
end
```

| Call | Does |
| --- | --- |
| `store.new(name, spec)` | Declares one slice. `spec = {version, defaults, migrate}` |
| `store.restore(script_state)` | Loads every slice. Call once, first thing in `onLoad` |
| `store.serialize()` | The single generated `onSave` for every slice |
| `st.data` | Your table. Read and write it directly |
| `st:reset()` | Back to defaults |
| `store.get(name)` | The slice declared under that name, or nil |
| `store.clear()` | Forgets every slice. For tests, and the honest way to start a script over |

What it guarantees, each pinned by a test:

- **Undeclared keys are dropped** on load, so a fossil cannot outlive the code
  that wrote it.
- **Values are coerced to the type of their default.** A round that comes back
  from JSON as `"7"` is a number again.
- **A version you did not write a migration for is a reset, reported.** Changing
  a default is safe: bump the version and the stale value is discarded by design.
- **Garbage or an empty `script_state` is defaults, not a crash.**

Persist only what the table cannot tell you. A cube's position on a track *is*
the score — re-read it rather than mirroring it in here. And nothing else
persists state: no flags in `Description`, no payloads in `GMNotes`.

---

## `ui` — C3

Button indexes are positional and 0-based, so inserting one `createButton`
renumbers every later button, silently. Arcs' own source warns about it in
capitals; RotLA maintains a counter by hand. Here every button has a name, the
name becomes its `click_function`, and the index is read back out of
`getButtons()` whenever it is needed — nothing is cached, so nothing goes stale.

```lua
ui.button(board, "nextRound", {
  label = "Next round", position = {0, 0.2, -0.45},
  width = 1200, height = 400, font_size = 180,
  scale = ui.unscale(board),
  onClick = function(clicked, colour, alt) ... end,
})

ui.set(board, "nextRound", { label = "Round 2" })
```

| Call | Does |
| --- | --- |
| `ui.button(obj, name, params)` | Creates it, or edits it if that name already exists |
| `ui.label(obj, name, params)` | A zero-size button: unclickable text, with a real no-op handler |
| `ui.set(obj, name, params)` | Edit by name; an unknown name is an error, not a wrong edit |
| `ui.remove(obj, name)` / `ui.clear(obj)` | Remove one, or all |
| `ui.index(obj, name)` | The current index, for the escape hatch to the raw API |
| `ui.unscale(obj)` | `scale` that cancels out a scaled object; Y stays 1 |
| `ui.xml/attr/attrs/value/show/hide(target, ...)` | XML UI, routed to `obj.UI` or the global `UI` |
| `ui.panel(target)` | The routing itself: `target.UI`, or the global `UI` when target is nil |
| `ui.env()` | `self` in an object script, `Global` in the Global script. Resolved lazily, because `self` is not bound while the chunk is still executing |
| `ui.LABEL_FONT_SIZE` | `300` — the default for `ui.label`, since a zero-size button needs a big one |

`params` are `createButton`'s, minus `click_function` and `function_owner` —
those are generated. `onClick` takes a **function**, which `ui` installs under
the generated name with `setVar` in the same environment it names as
`function_owner`. That is the point: the two can never drift apart, which is
exactly what leaves four of Rurik's advisor buttons inert.

Two things to know:

- **Buttons are not saved.** No save in this folder contains button data, and
  every mod rebuilds them in `onLoad`. So `onLoad` must build them, and
  `onPlayerConnect` must rebuild them — calling `ui.button` again edits rather
  than duplicating, so both are safe.
- **XML handlers have a different signature** — `(player, value, id)`, against a
  button's `(object, colour, alt_click)`.

---

## `events` — C6, C7

TTS delivers every container event to every script that defines the handler, so
RotLA's 51 bag scripts each open with `if bag~=self then return end`: 55 scripts,
106 occurrences, and forgetting it in one corrupts state silently.

```lua
events.on("enterContainer", "supply.wood", function(container, object)
  refreshBadge(container)
end)

events.on("drop", "wood", function(playerColour, object)
  ...
end, { debounce = 1.25 })      -- TTS fires drop more than once per drop
```

| Call | Does |
| --- | --- |
| `events.on(name, tag, handler, opts)` | Subscribe. `tag` may be `"*"`. Returns a handle |
| `events.off(name, handle)` / `events.offAll(name)` | Unsubscribe |
| `events.check()` | Reports any TTS handler something else has redefined |
| `events.count(name)` | How many subscriptions |
| `events.has(name, handle)` | Is this subscription still live? `offAll` may have removed it, so verify rather than remember — this is how `registry` re-arms itself |
| `events.dispatch(name, a…f)` | Route one event to its subscribers. The 13 TTS handlers below call this; call it yourself only to simulate an event |
| `events.EVENTS` | The table below as data: TTS handler name and which argument carries the subject |

Handlers receive **TTS's own arguments in TTS's own order**, so the API docs and
the cookbook transfer unchanged. The tag is matched against the *subject* of the
event — the container, the zone, or the object:

| `name` | TTS handler | Subject |
| --- | --- | --- |
| `spawn`, `destroy` | `onObjectSpawn/Destroy(object)` | the object |
| `enterContainer`, `leaveContainer` | `(container, object)` | the **container** |
| `enterZone`, `leaveZone` | `(zone, object)` | the **zone** |
| `drop`, `pickUp` | `(player_color, object)` | the **object**, argument 2 |
| `randomize`, `stateChange`, `numberTyped`, `rotate`, `peek` | `(object, ...)` | the object |

To react to what *entered* a container rather than to the container, test the
second argument inside the handler.

Two deliberate choices:

- **The module declares the thirteen `onObject*` functions itself.** Do not
  declare them in your own script: in Lua the second definition silently wins,
  which is how RotLA ended up with two `onPlayerChangeColor` bodies and one of
  them dead. `events.check()` in `onLoad` catches it if you do.
- **Each handler runs inside `log.attempt`.** A broken handler reports itself
  with its event and tag, and the others still run. That is a declared boundary,
  not a blanket `pcall` — the difference being that this one tells you.

Tag matching is `obj.hasTag(tag)`. Until
[open question 1](cookbook/10-antipatterns.md#open-questions-test-these-in-tts)
is settled in TTS, match the exact casing your objects carry.

---

## `registry` — C1

Almoravid binds 200 GUID literals in one function with not a single `if obj then`
guard, so one stale GUID leaves the table half set up with nothing naming the
cause. Three of Arcs' `src/GUIDs` literals match no object in the owner's save
today. A GUID is minted per instance; a tag survives duplication.

```lua
reg.declare({
  board           = 1,      -- exactly one
  ["supply.wood"] = "+",    -- at least one
  wood            = "*",    -- any number, including none
})

if not reg.check() then return end      -- everything missing, reported at once

local board = reg.one("board")
for _, bag in ipairs(reg.all("supply.wood")) do ... end
```

| Call | Does |
| --- | --- |
| `reg.declare(roles)` | The manifest. `1` / `"+"` / `"?"` / `"*"` |
| `reg.check()` | Validates the whole manifest in one pass, at boot, loudly |
| `reg.one(role)` | The object, or nil and one report per role per session |
| `reg.all(role)` | Always a table, never nil |
| `reg.waitFor(role, fn, timeout)` | For something still inside a bag; polls one tag, gives up out loud |
| `reg.invalidate(role)` | Drop the cache by hand, if you have changed tags yourself. One role, or every role when called with no argument |
| `reg.roles()` | The declared manifest, as a table |
| `reg.WAIT_TIMEOUT` | `10` — the default `waitFor` timeout, in seconds |

The cache invalidates itself on spawn and destroy, which is the part of Rurik's
tag cache not to copy — its version is rebuilt by hand at six call sites and
never invalidated, and its `waitByTag` sweeps every object on the table once a
frame. When a role is missing and some object carries the same tag in a different
case, the report says so by name.

**One axis per tag.** `coin` + `blue` composes; `bluecoin` has to be parsed.
Dotted names like `supply.wood` are a convention for reading, not a hierarchy —
`reg.all("supply")` does not match them.

---

## `layout` — C2

Almoravid makes 925 positioning calls against absolute coordinates and never
calls `positionToWorld`: move the board and all 925 are wrong at once. Arcs shows
the alternative — 36 marker positions out of 12 numbers, composed in the board's
local space and resolved through a board that happens to be scaled 6.015×.

```lua
layout.anchor("board")                       -- a role, resolved when used
layout.spaces({
  supply = { -0.40, layout.LAYER.board,  0.28 },
  score  = {  0.00, layout.LAYER.marker, -0.35 },
})

layout.place(marker, "score", { facing = 180 })
layout.takeTo(bag, "supply", { tag = "inplay", onPlaced = function(obj) ... end })
```

| Call | Does |
| --- | --- |
| `layout.anchor(objOrRole)` | The object everything is measured against |
| `layout.spaces(table)` / `layout.space(name, vec)` | Named positions in anchor-local space |
| `layout.world(where, anchor)` | Resolve a space to a world position |
| `layout.place(obj, where, opts)` | `opts = {facing, layer, smooth, collide, fast, anchor}`. `facing` turns around Y only — X and Z keep the face-up/face-down the object already has |
| `layout.capture(obj, anchor)` | The inverse — drag a piece into place in TTS, get the row for your table |
| `layout.takeTo(bag, where, opts)` | The bulk-placement idiom, once instead of 537 times. `opts = {anchor, facing, smooth, guid, index, top, tag, onPlaced}` — **not** `place()`'s `layer`, `collide` or `fast`; for those, `place()` from `onPlaced` |
| `layout.snaps(anchor, list)` | Attach snap points from the same coordinates |
| `layout.add(a, b)` | Compose offsets, the way Arcs composes column + row |
| `layout.LAYER` | `table`, `board`, `marker`, `card`, `held` |
| `layout.anchorObject(override)` | Resolves the anchor to a live object — the override, a role, or the declared anchor |
| `layout.localOf(where)` | The anchor-local vector for a space name or a raw vector. Reports once per unknown name |
| `layout.vec(v)` | Normalises `{x,y,z}` or `{1,2,3}` to a full vector, filling missing axes with 0 |

`facing` is degrees around Y **relative to the anchor's own rotation**, so a
board turned 90° turns its contents with it. `layer` overrides a space's Y with a
named layer, so "just above the board surface" is written once rather than in 925
places.

`takeTo` passes the destination straight to `takeObject`, whose callback already
runs after the object has finished spawning — the take → `Wait.frames` → move
dance is not needed. What is needed is the guard, because the object can be gone
by the time you are called; `takeTo` does that for you.

`layout.snaps` is the one to use even in a game with no other scripting: a snap
point makes a position exist for the *player*, and a tagged one accepts only the
component that belongs there. The reference mods have between 11 and 1,562 of
them; the prototypes in this folder have none.

---

## Adding `ttslib` to a prototype that has no scripting

The owner's prototypes carry TTS's 320-character default stub, zero object
scripts, zero snap points and zero tags. This is the order that gets one from
there to scripted without a rewrite. Nothing here needs all seven modules — stop
at any step and the result still works.

1. **Copy the save.** `cp Saves/TS_Save_111.json Saves/TS_Save_127.json`, or work
   from the original and let `lua inject -o` write the new number. Never edit in
   place; there is no undo here.
2. **Tag the components in TTS.** Right-click → Tags. One axis per tag, and one
   role per thing the script will need to find: `board`, `supply.wood`, `wood`.
   This is the whole of C1's fix and it takes minutes.
3. **Write the manifest and boot.** Copy `Global.lua`, replace `ROLES`, build,
   load, and read the chat: `registry.check()` names everything you have not
   tagged yet. Iterate here until it is quiet.
4. **Capture the positions you already like.** The prototype's components are
   already arranged. For each one, `layout.capture(obj)` prints its
   anchor-relative coordinates — paste them into `SPACES`. This converts a hand
   arrangement into a table without measuring anything.
5. **Add snap points** from those same coordinates with `layout.snaps`, tagged so
   only the right component lands there. Players get the benefit immediately,
   with no further scripting.
6. **Add behaviour by tag, not by object.** A supply that counts itself, a token
   that returns home — `events.on` in Global, never a script pasted onto 51 bags.
7. **Persist only what the table cannot tell you** — a round number, a mode, a
   chosen option. Everything else is derived from where the pieces are.

Editing an existing *scripted* mod is the opposite job — there you make the
smallest possible change and never reformat. Read
[docs/mods/README.md](mods/README.md) for what breaks in each of the five, and
run `tts.py refs` before touching anything.

---

## Tests

```bash
luajit reference/framework/test/ttslib_spec.lua   # 45 cases, the modules
luajit reference/framework/test/demo_spec.lua     # 19 cases, the demo booted
```

64 cases, 177 checks, against a stub TTS in
[`test/harness.lua`](../reference/framework/test/harness.lua) — a fake table,
fake objects with TTS's button-index rules, and a manual `Wait` scheduler you
advance by frames.

**What it proves:** the library parses, the modules load in order, and the logic
behaves as documented — name→index survives a shifting index, undeclared keys are
dropped, a debounce window expires, the registry cache invalidates on destroy,
an anchor transform round-trips through `place` and `capture`. The last case
loads `Global.lua` itself, boots it against a tagged table, clicks its button,
moves a token and reloads from its own `onSave` output.

**What it cannot prove:** anything about TTS's own semantics. Whether tags match
case-insensitively, when spawn callbacks really fire, what physics does with a
smooth move, whether an event handler assigned after load is still called — those
need TTS. The harness is Lua 5.1 (LuaJIT) and TTS is 5.2; `ttslib` stays inside
the intersection.

`demo_spec.lua` is the other half: it runs the demo's own `Global.lua` — the file
that goes into `TS_Save_126` — against the same stub, and covers the modules
working *together*. A missing role stops setup; the supply badge follows cubes in
and out through one subscription; ten container events cost one redraw; the round
and drop count survive a reload; the concatenated build parses and boots
identically to the loaded pieces.

Both suites are mutation-checked. Per module: breaking `log.attempt`'s reporting,
`async`'s debounce, `store`'s version check, `ui`'s index lookup, `events`'
subject selection, `registry`'s deferred invalidation or `layout`'s anchor
transform each makes `ttslib_spec` fail. Per integration: dropping the debounce
window, redrawing without coalescing, removing `unscale`, removing the
missing-role guard, freezing the round marker or naming a button
non-deterministically each makes `demo_spec` fail. A green run means something.

Writing them found two real bugs. In this library: `layout.place` was passing
`collide` into `setPositionSmooth`'s `fast` slot. In the harness itself:
`takeObject` put every taken object on the fake table twice and fired
`onObjectSpawn` twice for it, because `H.object` already spawns. Which is the
argument for having tests, and for having tests that count things.

---

## What `ttslib` deliberately does not do

- **No `require`, no bundler.** A concatenation you can read beats a runtime
  module system you cannot (C5, C10).
- **No object-side library.** Object scripts stay thin by design; the library is
  in Global exactly once.
- **No wrapper for the whole API.** `layout.place` exists because absolute
  coordinates are a defect. `obj.setPosition` is fine; call it.
- **No `Global.call` bus.** Keep your own, short and named — Arcs' is 13
  functions and 60 call sites, and that is the upper end of readable.
- **No state anywhere but `store`.** Not in `Description`, not in `GMNotes`, not
  in a component tag.

## Cautions

- **`self or Global`.** `ui` resolves the current environment this way, lazily.
  In an object script that is `self`; in Global, `self` is undefined and reading
  an undefined global is nil in Lua, so it falls through to `Global`.
- **Do not name a local `log`.** The whole build is one chunk, so a top-level
  `local log = ...` would shadow TTS's `log()` for every file after it. `ttslib`
  uses `LOG` for exactly this reason.
- **Three casing questions are still open** — component tags, `onload`, and
  `SetRotationSmooth` — each with a two-minute test in
  [10-antipatterns.md](cookbook/10-antipatterns.md#open-questions-test-these-in-tts).
  `ttslib` writes the conservative form throughout.
- **`validate` before you load.** Every build, every time. It is one command and
  it reports without rewriting.
