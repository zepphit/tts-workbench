-- test/ttslib_spec.lua — what ttslib promises, checked against a stub TTS.
--
--   luajit reference/framework/test/ttslib_spec.lua
--
-- See harness.lua for what this can and cannot prove.  Every case below maps to
-- a claim in docs/framework.md; if you change a module's behaviour, change the
-- case that pins it.

local HERE = arg[0]:match("^(.*)/[^/]+$") or "."
local H = dofile(HERE .. "/harness.lua")
local LIB = HERE .. "/../ttslib"

-- The harness redirects print() into its log, so keep the real one for results.
local out = print

local checks, failures, currentCase = 0, 0, "?"

local function check(ok, label)
  checks = checks + 1
  if not ok then
    failures = failures + 1
    out(string.format("  FAIL  %s: %s", currentCase, label))
  end
  return ok
end

local function eq(got, want, label)
  return check(got == want, string.format("%s (got %s, want %s)", label, tostring(got), tostring(want)))
end

local function near(got, want, label)
  return check(math.abs((got or 0) - want) < 0.001,
    string.format("%s (got %s, want %s)", label, tostring(got), tostring(want)))
end

local cases = {}
local function case(name, fn)
  cases[#cases + 1] = { name = name, fn = fn }
end

-- ------------------------------------------------------------------- 00-log

case("log respects its level, and errors are impossible to miss", function()
  local L = H.reset(LIB)
  L.log.level = "warn"
  L.log.debug("quiet one")
  L.log.error("loud one")
  eq(H.logged("quiet one"), nil, "debug is dropped below the level")
  check(H.logged("loud one") ~= nil, "error is printed")
  check(H.logged("BROADCAST") ~= nil, "error is also broadcast on screen")
end)

case("expect returns the value and reports a miss", function()
  local L = H.reset(LIB)
  eq(L.log.expect(42, "should not fire"), 42, "expect passes a value through")
  eq(L.log.expect(nil, "no supply bag"), nil, "expect returns nil on a miss")
  check(H.logged("no supply bag") ~= nil, "the miss was reported")
end)

case("once says it once", function()
  local L = H.reset(LIB)
  for _ = 1, 5 do
    L.log.once("k", "warn", "repeated condition")
  end
  local seen = 0
  for _, line in ipairs(H.printed) do
    if line:find("repeated condition", 1, true) then seen = seen + 1 end
  end
  eq(seen, 1, "five calls, one line")
end)

case("attempt is a named boundary, not a silent one", function()
  local L = H.reset(LIB)
  local result = L.log.attempt("risky thing", function() error("kaboom") end)
  eq(result, nil, "a failed attempt returns nil")
  check(H.logged("risky thing failed") ~= nil, "the label is in the report")
  check(H.logged("kaboom") ~= nil, "so is the error")
  eq(L.log.attempt("fine", function(a, b) return a + b end, 2, 3), 5, "arguments are forwarded")
end)

-- ----------------------------------------------------------------- 01-async

case("afterFrames waits exactly that many frames", function()
  local L = H.reset(LIB)
  local ran = false
  L.async.afterFrames(3, function() ran = true end)
  H.tick(2)
  eq(ran, false, "not yet")
  H.tick(1)
  eq(ran, true, "now")
end)

case("keyed waits replace each other instead of stacking", function()
  local L = H.reset(LIB)
  local runs = 0
  for _ = 1, 3 do
    L.async.keyed("badge", 0.5, function() runs = runs + 1 end)
  end
  H.tick(60)
  eq(runs, 1, "three schedules, one run")
  eq(L.async.cancel("badge"), false, "nothing left pending")
end)

case("every repeats until cancelled", function()
  local L = H.reset(LIB)
  local runs = 0
  L.async.every("tick", 0.1, function() runs = runs + 1 end)
  H.tick(60) -- one second
  check(runs >= 8, "repeating timer fired about ten times, got " .. runs)
  L.async.cancel("tick")
  local before = runs
  H.tick(60)
  eq(runs, before, "cancelled means cancelled")
end)

case("whenSettled waits for rest, and gives up out loud", function()
  local L = H.reset(LIB)
  local moving = H.object({ resting = false })
  local settled = false
  L.async.whenSettled(moving, function() settled = true end, 5)
  H.tick(10)
  eq(settled, false, "still moving")
  moving.resting = true
  H.tick(1)
  eq(settled, true, "settled")

  local stuck = H.object({ resting = false })
  L.async.whenSettled(stuck, function() end, 0.2)
  H.tick(60)
  check(H.logged("whenSettled timed out") ~= nil, "a timeout says so")
end)

case("whenSettled exits when the object goes away", function()
  local L = H.reset(LIB)
  local obj = H.object({ resting = false })
  local ran = false
  L.async.whenSettled(obj, function() ran = true end, 5)
  H.destroy(obj)
  H.tick(2)
  eq(ran, false, "the callback does not run for a destroyed object")
  eq(H.pendingWaits(), 0, "and nothing is left waiting forever")
end)

case("retry is bounded and says when it gives up", function()
  local L = H.reset(LIB)
  local attempts = 0
  L.async.retry(function()
    attempts = attempts + 1
    return false
  end, { times = 3, delay = 0.1, label = "find the marker" })
  H.tick(60)
  eq(attempts, 3, "three attempts, not more")
  check(H.logged("find the marker gave up") ~= nil, "and it said so")
end)

case("debounce suppresses a repeat inside the window only", function()
  local L = H.reset(LIB)
  eq(L.async.debounce("a|drop|Blue", 1.25), false, "first is not a repeat")
  eq(L.async.debounce("a|drop|Blue", 1.25), true, "second, immediately, is")
  eq(L.async.debounce("b|drop|Blue", 1.25), false, "a different key is not")
  H.tick(120) -- two seconds
  eq(L.async.debounce("a|drop|Blue", 1.25), false, "past the window it is allowed again")
end)

-- ----------------------------------------------------------------- 02-store

case("only declared keys survive, with their declared types", function()
  local L = H.reset(LIB)
  local st = L.store.new("game", { version = 1, defaults = { round = 1, mode = "solo", flag = false } })
  L.store.restore('{"game":{"v":1,"d":{"round":"7","mode":"duel","junk":"fossil","flag":true}}}')
  eq(st.data.round, 7, "a string round comes back a number")
  eq(st.data.mode, "duel", "a declared string is kept")
  eq(st.data.flag, true, "a declared boolean is kept")
  eq(st.data.junk, nil, "an undeclared key is dropped, not re-saved forever")
end)

case("a missing key falls back to its default", function()
  local L = H.reset(LIB)
  local st = L.store.new("game", { version = 1, defaults = { round = 3, names = { "a" } } })
  L.store.restore('{"game":{"v":1,"d":{}}}')
  eq(st.data.round, 3, "default applied")
  eq(type(st.data.names), "table", "table default copied")
end)

case("a version change without a migration resets, loudly", function()
  local L = H.reset(LIB)
  local st = L.store.new("game", { version = 2, defaults = { round = 1 } })
  L.store.restore('{"game":{"v":1,"d":{"round":9}}}')
  eq(st.data.round, 1, "the stale value is dropped by design")
  check(H.logged("saved at version 1") ~= nil, "and the reset is reported")
end)

case("a migration runs and is reported", function()
  local L = H.reset(LIB)
  local st = L.store.new("game", {
    version = 2,
    defaults = { round = 1 },
    migrate = function(saved) return { round = (saved.turn or 0) + 1 } end,
  })
  L.store.restore('{"game":{"v":1,"d":{"turn":4}}}')
  eq(st.data.round, 5, "migrated forward")
  check(H.logged("migrated from version 1") ~= nil, "and said so")
end)

case("serialize round-trips through one onSave", function()
  local L = H.reset(LIB)
  local a = L.store.new("game", { version = 1, defaults = { round = 1 } })
  local b = L.store.new("ui", { version = 1, defaults = { panel = "closed" } })
  a.data.round = 4
  b.data.panel = "open"
  local blob = L.store.serialize()

  local L2 = H.reset(LIB)
  local a2 = L2.store.new("game", { version = 1, defaults = { round = 1 } })
  local b2 = L2.store.new("ui", { version = 1, defaults = { panel = "closed" } })
  L2.store.restore(blob)
  eq(a2.data.round, 4, "first store restored")
  eq(b2.data.panel, "open", "second store restored from the same string")
end)

case("garbage in script_state is defaults, not a crash", function()
  local L = H.reset(LIB)
  local st = L.store.new("game", { version = 1, defaults = { round = 1 } })
  L.store.restore("")
  eq(st.data.round, 1, "empty state")
  L.store.restore("{not json")
  eq(st.data.round, 1, "broken state")
end)

-- -------------------------------------------------------------------- 03-ui

case("a named button is created once and edited after that", function()
  local L = H.reset(LIB)
  local board = H.object({ tags = { "board" } })
  L.ui.button(board, "next", { label = "Next round" })
  L.ui.button(board, "next", { label = "Next round" })
  eq(#board.buttons, 1, "no duplicate on a second call")
  L.ui.set(board, "next", { label = "Round 2" })
  eq(board.buttons[1].label, "Round 2", "edited by name")
end)

case("a name survives the indexes moving underneath it", function()
  local L = H.reset(LIB)
  local board = H.object({})
  L.ui.button(board, "first", { label = "1" })
  L.ui.button(board, "second", { label = "2" })
  eq(L.ui.index(board, "second"), 1, "second button is index 1")
  board.removeButton(0) -- something else removes the first button
  eq(L.ui.index(board, "second"), 0, "indexes shifted, the name did not")
  L.ui.set(board, "second", { label = "still me" })
  eq(board.buttons[1].label, "still me", "the right button was edited")
end)

case("an unknown name is an error, not a wrong edit", function()
  local L = H.reset(LIB)
  local board = H.object({})
  L.ui.button(board, "real", { label = "1" })
  eq(L.ui.set(board, "imaginary", { label = "x" }), false, "set refuses")
  check(H.logged("no button named 'imaginary'") ~= nil, "and says which name")
  eq(board.buttons[1].label, "1", "the real button is untouched")
end)

case("the handler is installed where function_owner points", function()
  local L = H.reset(LIB)
  local board = H.object({})
  local clicked = nil
  L.ui.button(board, "go", {
    label = "Go",
    onClick = function(_, colour, alt) clicked = { colour = colour, alt = alt } end,
  })
  local fname = board.buttons[1].click_function
  eq(board.buttons[1].function_owner, Global, "owned by the script that registered it")
  check(Global.getVar(fname) ~= nil, "and the function lives in that same environment")
  Global.getVar(fname)(board, "Blue", true)
  eq(clicked.colour, "Blue", "colour forwarded")
  eq(clicked.alt, true, "alt_click forwarded")
end)

case("a label is a zero-size button with a real no-op", function()
  local L = H.reset(LIB)
  local bag = H.object({})
  L.ui.label(bag, "count", { label = "3" })
  local button = bag.buttons[1]
  eq(button.width, 0, "width 0")
  eq(button.height, 0, "height 0")
  check(button.font_size >= 300, "and a font size big enough to read")
  check(type(Global.getVar(button.click_function)) == "function", "clicking it does nothing, safely")
end)

case("unscale cancels a scaled object out of its buttons", function()
  local L = H.reset(LIB)
  local board = H.object({ scale = { x = 6, y = 1, z = 6 } })
  local s = L.ui.unscale(board)
  near(s.x, 1 / 6, "x divided out")
  eq(s.y, 1, "y left alone: a button is flat")
  near(s.z, 1 / 6, "z divided out")
end)

case("remove drops the named button and nothing else", function()
  local L = H.reset(LIB)
  local board = H.object({})
  L.ui.button(board, "a", { label = "a" })
  L.ui.button(board, "b", { label = "b" })
  eq(L.ui.remove(board, "a"), true, "removed")
  eq(#board.buttons, 1, "one left")
  eq(L.ui.index(board, "b"), 0, "and it is still addressable by name")
end)

-- ---------------------------------------------------------------- 04-events

case("one registration serves every object with the tag", function()
  local L = H.reset(LIB)
  local seen = {}
  L.events.on("enterContainer", "supply", function(container, object)
    seen[#seen + 1] = container.getGUID()
  end)
  local supplyA = H.object({ tags = { "supply" } })
  local supplyB = H.object({ tags = { "supply" } })
  local other = H.object({ tags = { "scenery" } })
  local token = H.object({})

  onObjectEnterContainer(supplyA, token)
  onObjectEnterContainer(supplyB, token)
  onObjectEnterContainer(other, token)

  eq(#seen, 2, "both supplies, and not the scenery")
  eq(seen[1], supplyA.getGUID(), "first container")
end)

case("drop and pickUp are routed on their second argument", function()
  local L = H.reset(LIB)
  local got = nil
  L.events.on("drop", "wood", function(colour, object) got = colour end)
  local token = H.object({ tags = { "wood" } })
  onObjectDrop("Blue", token)
  eq(got, "Blue", "the handler sees TTS's own argument order")

  local elsewhere = H.object({ tags = { "stone" } })
  got = nil
  onObjectDrop("Red", elsewhere)
  eq(got, nil, "a different tag is not delivered")
end)

case('"*" subscribes to everything', function()
  local L = H.reset(LIB)
  local count = 0
  L.events.on("spawn", "*", function() count = count + 1 end)
  H.object({})
  H.object({ tags = { "anything" } })
  eq(count, 2, "both spawns")
end)

case("a debounced subscription drops TTS's duplicate events", function()
  local L = H.reset(LIB)
  local count = 0
  L.events.on("drop", "wood", function() count = count + 1 end, { debounce = 1.25 })
  local token = H.object({ tags = { "wood" } })
  onObjectDrop("Blue", token)
  onObjectDrop("Blue", token)
  eq(count, 1, "the repeat inside the window is dropped")
  H.tick(120)
  onObjectDrop("Blue", token)
  eq(count, 2, "a later drop is a real one")
end)

case("a broken handler reports itself and the others still run", function()
  local L = H.reset(LIB)
  local ran = false
  L.events.on("spawn", "*", function() error("bad handler") end)
  L.events.on("spawn", "*", function() ran = true end)
  H.object({})
  eq(ran, true, "the second handler ran")
  check(H.logged("bad handler") ~= nil, "and the first one was reported")
end)

case("off removes one subscription", function()
  local L = H.reset(LIB)
  local count = 0
  local handle = L.events.on("spawn", "*", function() count = count + 1 end)
  H.object({})
  eq(L.events.off("spawn", handle), true, "removed")
  H.object({})
  eq(count, 1, "only the first spawn counted")
end)

case("check() catches a redefined TTS handler", function()
  local L = H.reset(LIB)
  eq(L.events.check(), true, "clean to start with")
  onObjectDrop = function() end -- the RotLA mistake, made on purpose
  eq(L.events.check(), false, "and caught")
  check(H.logged("onObjectDrop has been redefined") ~= nil, "by name")
end)

-- -------------------------------------------------------------- 05-registry

case("roles resolve to objects, and one() is loud when it cannot", function()
  local L = H.reset(LIB)
  local board = H.object({ tags = { "board" } })
  H.object({ tags = { "supply.wood" } })
  H.object({ tags = { "supply.wood" } })
  L.registry.declare({ board = 1, ["supply.wood"] = "+" })

  eq(L.registry.one("board"), board, "one() resolves")
  eq(#L.registry.all("supply.wood"), 2, "all() returns every one")
  eq(L.registry.one("nothing"), nil, "a missing role is nil")
  check(H.logged("no object tagged 'nothing'") ~= nil, "and is reported")
  eq(#L.registry.all("nothing"), 0, "all() of nothing is an empty table, never nil")
end)

case("the cache invalidates itself on spawn and destroy", function()
  local L = H.reset(LIB)
  L.registry.declare({ token = "*" })
  eq(#L.registry.all("token"), 0, "nothing yet — and now it is cached")

  local token = H.object({ tags = { "token" } })
  eq(#L.registry.all("token"), 1, "a spawn invalidated the cache")

  H.destroy(token)
  H.tick(2)
  eq(#L.registry.all("token"), 0, "and so did the destroy")
end)

case("a query during a destroy event does not leave the cache stale", function()
  local L = H.reset(LIB)
  L.registry.declare({ token = "*" })
  local token = H.object({ tags = { "token" } })
  eq(#L.registry.all("token"), 1, "on the table")

  -- onObjectDestroy fires while the object is still there, so anything that
  -- queries from inside the event re-caches the dying object.
  L.events.on("destroy", "*", function() L.registry.all("token") end)
  H.destroy(token)
  H.tick(2)
  eq(#L.registry.all("token"), 0, "the frame-later invalidation cleared it")
end)

case("check() reports every missing role at once", function()
  local L = H.reset(LIB)
  H.object({ tags = { "board" } })
  H.object({ tags = { "board" } })
  L.registry.declare({ board = 1, ["supply.wood"] = "+", scenery = "*" })
  eq(L.registry.check(), false, "the manifest does not match the table")
  check(H.logged("role 'board': expected 1, found 2") ~= nil, "too many")
  check(H.logged("role 'supply.wood': expected at least one, found 0") ~= nil, "too few")
  eq(H.logged("role 'scenery'"), nil, "'*' accepts none")
end)

case("a role that differs only in case is named in the report", function()
  local L = H.reset(LIB)
  H.object({ tags = { "Board" } })
  L.registry.declare({ board = 1 })
  L.registry.check()
  check(H.logged("an object is tagged 'Board'") ~= nil, "the likely cause is spelled out")
end)

case("waitFor polls one tag and gives up out loud", function()
  local L = H.reset(LIB)
  local found = nil
  L.registry.waitFor("late", function(obj) found = obj end, 5)
  H.tick(3)
  eq(found, nil, "not there yet")
  local late = H.object({ tags = { "late" } })
  H.tick(2)
  eq(found, late, "found once it spawned")

  L.registry.waitFor("never", function() end, 0.2)
  H.tick(60)
  check(H.logged("nothing appeared") ~= nil, "a give-up is reported")
  eq(H.pendingWaits(), 0, "and nothing polls forever")
end)

-- ---------------------------------------------------------------- 06-layout

case("a space is resolved through the anchor's transform", function()
  local L = H.reset(LIB)
  local board = H.object({
    tags = { "board" },
    position = { x = 10, y = 1, z = -5 },
    scale = { x = 6, y = 1, z = 6 },
  })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  L.layout.spaces({ slot = { 0.5, L.layout.LAYER.board, 0.25 } })

  local world = L.layout.world("slot")
  near(world.x, 10 + 0.5 * 6, "x scaled and translated")
  near(world.y, 1 + 0.2, "y is the named layer")
  near(world.z, -5 + 0.25 * 6, "z scaled and translated")
end)

case("basis measures the mesh, not the scale", function()
  -- TTS's BlockRectangle has a 1 x 1 x 2 mesh, so a plate at scaleZ 17 is 34
  -- deep and positionToWorld({0,0,1}).z is 34. Code that turns a world offset
  -- into a local one by dividing by getScale() is then out by a factor of two
  -- on Z alone — which is exactly how Amazonia shipped a hex map with every
  -- row twice as far apart as its arithmetic said (2026-09-21).
  local L = H.reset(LIB)
  H.object({
    tags = { "board" },
    position = { x = 0, y = 1, z = 0 },
    scale = { x = 20, y = 0.2, z = 17 },
    mesh = { x = 1, y = 1, z = 2 },
  })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")

  local basis = L.layout.basis()
  near(basis.x, 20, "one local x unit is 20 world units")
  near(basis.y, 0.2, "and one local y unit is 0.2")
  near(basis.z, 34, "and one local z unit is 34 — the scale is 17")

  -- The round trip is what callers actually use: a world offset in, the same
  -- world offset back out of the anchor's transform.
  local offset = L.layout.localOffset({ x = 4.33, y = 0.15, z = -4.5 })
  L.layout.spaces({ probe = offset })
  local world = L.layout.world("probe")
  near(world.x, 4.33, "x survives the round trip")
  near(world.y, 1 + 0.15, "y is an offset from the anchor's own height")
  near(world.z, -4.5, "z survives it too, which dividing by scale would not")

  local back = L.layout.worldOffset(offset)
  near(back.z, -4.5, "worldOffset is the inverse")
end)

case("basis is rotation-invariant", function()
  local L = H.reset(LIB)
  H.object({
    tags = { "board" },
    position = { x = 3, y = 0, z = -2 },
    rotation = { x = 0, y = 37, z = 0 },
    scale = { x = 6, y = 1, z = 6 },
    mesh = { x = 1, y = 1, z = 2 },
  })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  local basis = L.layout.basis()
  near(basis.x, 6, "x is a length, so turning the board does not change it")
  near(basis.z, 12, "nor z")

  -- And a space built from an offset still lands the offset's distance away,
  -- turned with the board rather than stretched by it.
  L.layout.spaces({ probe = L.layout.localOffset({ x = 3, y = 0, z = 0 }) })
  local world = L.layout.world("probe")
  local dx, dz = world.x - 3, world.z + 2
  near(math.sqrt(dx * dx + dz * dz), 3, "three units from the anchor")
  check(math.abs(dx - 3) > 0.01, "and turned, not axis-aligned")
end)

case("moving the board moves every space with it", function()
  local L = H.reset(LIB)
  local board = H.object({ tags = { "board" }, position = { x = 0, y = 0, z = 0 } })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  L.layout.spaces({ slot = { 1, 0.2, 1 } })
  local before = L.layout.world("slot")
  board.setPosition({ x = 20, y = 0, z = 20 })
  local after = L.layout.world("slot")
  near(after.x - before.x, 20, "the space followed the board on x")
  near(after.z - before.z, 20, "and on z")
end)

case("place puts an object in a space, facing relative to the anchor", function()
  local L = H.reset(LIB)
  local board = H.object({ tags = { "board" }, position = { x = 0, y = 0, z = 0 },
    rotation = { x = 0, y = 90, z = 0 } })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  L.layout.spaces({ score = { 0, 0.3, 1 } })

  local marker = H.object({})
  eq(L.layout.place(marker, "score", { facing = 180 }), true, "placed")
  local world = L.layout.world("score")
  near(marker.position.x, world.x, "x")
  near(marker.position.z, world.z, "z")
  eq(marker.rotation.y, 270, "facing is added to the anchor's own rotation")

  -- setPositionSmooth(vector, collide, fast) — in that order.
  eq(marker.lastMove.collide, false, "setup does not collide by default")
  L.layout.place(marker, "score", { collide = true, fast = true })
  eq(marker.lastMove.collide, true, "collide reaches the collide slot")
  eq(marker.lastMove.fast, true, "and fast reaches the fast slot")
end)

case("capture is the inverse of place", function()
  local L = H.reset(LIB)
  local board = H.object({ tags = { "board" }, position = { x = 3, y = 0, z = 7 },
    rotation = { x = 0, y = 45, z = 0 }, scale = { x = 2, y = 1, z = 2 } })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  L.layout.spaces({ slot = { -0.4, 0.2, 0.9 } })

  local piece = H.object({})
  L.layout.place(piece, "slot")
  local captured = L.layout.capture(piece)
  near(captured.x, -0.4, "x round-trips")
  near(captured.y, 0.2, "y round-trips")
  near(captured.z, 0.9, "z round-trips")
end)

case("an unknown space is reported, not silently placed at the origin", function()
  local L = H.reset(LIB)
  H.object({ tags = { "board" } })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  local piece = H.object({})
  eq(L.layout.place(piece, "nowhere"), false, "refused")
  check(H.logged("no layout space named 'nowhere'") ~= nil, "and named")
end)

case("takeTo takes one component to a space", function()
  local L = H.reset(LIB)
  H.object({ tags = { "board" } })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  L.layout.spaces({ slot = { 1, 0.2, 0 } })

  local bag = H.object({ tags = { "supply" }, contents = 3, childTags = { "wood" } })
  local placed = nil
  L.layout.takeTo(bag, "slot", { facing = 180, tag = "inplay", onPlaced = function(obj) placed = obj end })
  H.tick(3)

  check(placed ~= nil, "the callback ran")
  eq(bag.getQuantity(), 2, "one came out of the bag")
  near(placed.position.x, L.layout.world("slot").x, "and landed in the space")
  eq(placed.hasTag("inplay"), true, "with the tag it was given on arrival")
end)

case("snaps are built from the same local coordinates", function()
  local L = H.reset(LIB)
  local board = H.object({ tags = { "board" } })
  L.registry.declare({ board = 1 })
  L.layout.anchor("board")
  L.layout.spaces({ deck = { 0.5, 0.2, 0.5 } })
  L.layout.snaps("board", {
    { at = "deck", tags = { "card" } },
    { at = { -0.5, 0.2, 0.5 }, facing = 180, rotationSnap = true },
  })
  local points = board.getSnapPoints()
  eq(#points, 2, "two snap points")
  near(points[1].position.x, 0.5, "the first is where the space is")
  eq(points[1].tags[1], "card", "and carries its tag")
  eq(points[2].rotation.y, 180, "the second is rotated")
  eq(points[2].rotation_snap, true, "and is a rotation snap")
end)

-- ---------------------------------------------------------- the whole thing

case("the starter Global.lua loads and boots against a tagged table", function()
  local L = H.reset(LIB)
  H.object({ tags = { "board" }, position = { x = 0, y = 1, z = 0 } })
  H.object({ tags = { "supply.wood" }, contents = 12, childTags = { "wood" } })

  local chunk, err = loadfile(HERE .. "/../Global.lua")
  check(chunk ~= nil, "Global.lua parses: " .. tostring(err))
  if not chunk then return end
  chunk()

  onLoad("")
  check(H.logged("all 3 declared roles present") ~= nil, "the manifest checked out")
  check(H.logged("loaded, round 1") ~= nil, "and it booted")

  local board = L.registry.one("board")
  local bag = L.registry.one("supply.wood")
  eq(#board.buttons, 1, "the control button was built")
  eq(bag.buttons[1].label, "12", "the supply badge shows the count")

  -- Click it the way TTS would, by name, in the owner's environment.
  Global.getVar(board.buttons[1].click_function)(board, "Blue", false)
  check(H.logged("round 2") ~= nil, "the button advanced the round")

  -- A token leaves the bag: one subscription updates the badge.
  bag.quantity = 11
  onObjectLeaveContainer(bag, H.object({ tags = { "wood" } }))
  H.tick(2)
  eq(bag.buttons[1].label, "11", "the badge followed, with no per-object script")

  -- And the round survives a save/load.
  local saved = onSave()
  local L2 = H.reset(LIB)
  H.object({ tags = { "board" } })
  H.object({ tags = { "supply.wood" }, contents = 11 })
  loadfile(HERE .. "/../Global.lua")()
  onLoad(saved)
  check(H.logged("loaded, round 2") ~= nil, "state survived the round-trip")
end)

-- --------------------------------------------- regressions (review 2026-09-21)
--
-- One case per bug found in docs/review-2026-09-21.md.  Each fails against the
-- code as it stood before that review.

case("a handler may unsubscribe itself while it is being dispatched", function()
  local L = H.reset(LIB)
  local ran, later = 0, false
  local handle
  handle = L.events.on("drop", "*", function()
    ran = ran + 1
    L.events.off("drop", handle)
  end)
  L.events.on("drop", "*", function() later = true end)

  local ok = pcall(function() L.events.dispatch("drop", "Blue", H.object({ tags = { "x" } })) end)
  check(ok, "dispatch survived the handler removing itself")
  check(later, "the subscriber after it still ran")
  eq(ran, 1, "the one-shot ran once")
  eq(L.events.count("drop"), 1, "and it is gone from the list")
end)

case("events.offAll does not leave the registry cache frozen", function()
  local L = H.reset(LIB)
  H.object({ tags = { "wood" } })
  eq(#L.registry.all("wood"), 1, "cache warm")

  L.events.offAll() -- takes the registry's own subscriptions with it
  H.object({ tags = { "wood" } })
  eq(#L.registry.all("wood"), 2, "the registry re-armed itself and saw the spawn")
end)

case("waitFor drops only the role it is waiting on", function()
  local L = H.reset(LIB)
  H.object({ tags = { "settled" } })
  eq(#L.registry.all("settled"), 1, "cache warm for an unrelated role")

  local scans = 0
  local real = _G.getObjectsWithTag
  _G.getObjectsWithTag = function(tag) scans = scans + 1 return real(tag) end

  L.registry.waitFor("late", function() end)
  H.tick(3)
  local before = scans
  eq(#L.registry.all("settled"), 1, "the unrelated role still resolves")
  eq(scans, before, "and answered from cache: polling did not invalidate everything")

  _G.getObjectsWithTag = real
end)

case("rotate hands the handler old_spin and old_flip", function()
  local L = H.reset(LIB)
  local got = {}
  L.events.on("rotate", "*", function(_, spin, flip, colour, oldSpin, oldFlip)
    got = { spin = spin, flip = flip, colour = colour, oldSpin = oldSpin, oldFlip = oldFlip }
  end)
  onObjectRotate(H.object({ tags = { "t" } }), 90, 0, "Blue", 270, 180)
  eq(got.spin, 90, "spin")
  eq(got.colour, "Blue", "player colour")
  eq(got.oldSpin, 270, "old_spin, the one a delta handler wants")
  eq(got.oldFlip, 180, "old_flip")
end)

case("place with a facing leaves a face-down piece face down", function()
  local L = H.reset(LIB)
  H.object({ tags = { "board" }, position = { x = 0, y = 1, z = 0 } })
  local card = H.object({ tags = { "card" }, rotation = { x = 0, y = 0, z = 180 } })
  L.layout.anchor("board")
  L.layout.spaces({ slot = { 0, 0, 0 } })

  L.layout.place(card, "slot", { facing = 0 })
  local r = card.getRotation()
  eq(r.z, 180, "z is the card's own, not zeroed")
  eq(r.y, 0, "y is the one facing sets")
end)

case("takeTo's tag is visible through the registry at once", function()
  local L = H.reset(LIB)
  H.object({ tags = { "board" }, position = { x = 0, y = 1, z = 0 } })
  local bag = H.object({ tags = { "bag" }, quantity = 3 })
  L.layout.anchor("board")
  L.layout.spaces({ slot = { 0, 0, 0 } })
  eq(#L.registry.all("inplay"), 0, "nothing in play yet, and the miss is cached")

  L.layout.takeTo(bag, "slot", { tag = "inplay" })
  H.tick(4)
  eq(#L.registry.all("inplay"), 1, "the tag applied on arrival invalidated the role")
end)

case("a migration that throws reports the loss instead of claiming success", function()
  local L = H.reset(LIB)
  local st = L.store.new("game", {
    version = 2,
    defaults = { round = 1 },
    migrate = function() error("boom") end,
  })
  st:fromTable({ v = 1, d = { round = 9 } })

  eq(st.data.round, 1, "fell back to the declared default")
  check(H.logged("failed") ~= nil, "the failure was reported")
  check(H.logged("using defaults") ~= nil, "and what it cost was said out loud")
  check(H.logged("migrated from version") == nil, "no success line over the top of it")
end)

case("ui.set and ui.label leave the caller's params table alone", function()
  local L = H.reset(LIB)
  local a, b = H.object({}), H.object({})
  L.ui.button(a, "total", { label = "a" })
  L.ui.button(b, "spacer", {})
  L.ui.button(b, "total", { label = "b" })

  local shared = { label = "shared" }
  L.ui.set(a, "total", shared)
  eq(shared.index, nil, "no index left behind on the caller's table")

  L.ui.set(b, "total", shared)
  eq(b.getButtons()[2].label, "shared", "so the next object edits its own button, not index 0")

  local spec = { font_size = 120 }
  L.ui.label(a, "note", spec)
  eq(spec.width, nil, "label did not stamp width onto the caller's table")
end)

-- ------------------------------------------------------------------ runner

out("ttslib spec")
for _, c in ipairs(cases) do
  currentCase = c.name
  local ok, err = pcall(c.fn)
  if not ok then
    failures = failures + 1
    -- `out`, not print: the harness rebinds print into its own log, so a
    -- thrown case used to bump the failure count and say nothing.
    out(string.format("  ERROR %s: %s", c.name, tostring(err)))
  end
end

out(string.format("\n%d cases, %d checks, %d failures", #cases, checks, failures))
os.exit(failures == 0 and 0 or 1)
