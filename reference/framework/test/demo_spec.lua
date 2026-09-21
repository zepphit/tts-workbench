-- test/demo_spec.lua — the Woodcutter demo, booted against the stub TTS.
--
--   luajit reference/framework/test/demo_spec.lua
--
-- ttslib_spec.lua proves each module in isolation. This proves the thing the
-- brief actually asks for: that a save built on the library boots, that every
-- module is load-bearing in it, and that its state survives a reload. It runs
-- demo/Global.lua — the same file build.sh concatenates into TS_Save_126 — so a
-- change that breaks the demo fails here rather than in TTS.
--
-- What it cannot prove is TTS's own semantics: whether a BlockRectangle is
-- where we think it is, whether the XML renders. See harness.lua.

local HERE = arg[0]:match("^(.*)/[^/]+$") or "."
local H = dofile(HERE .. "/harness.lua")
local LIB = HERE .. "/../ttslib"
local DEMO = HERE .. "/../demo/Global.lua"

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
  return check(got == want,
    string.format("%s (got %s, want %s)", label, tostring(got), tostring(want)))
end

local function near(got, want, label)
  return check(math.abs((got or 0) - want) < 0.001,
    string.format("%s (got %s, want %s)", label, tostring(got), tostring(want)))
end

local cases = {}
local function case(name, fn)
  cases[#cases + 1] = { name = name, fn = fn }
end

-- The table build.sh lays out: a board scaled 6 x 1 x 4, a supply of six, a
-- round marker, and four loose cubes.
local function table_()
  local t = {}
  t.board = H.object({
    tags = { "board" },
    position = { x = 0, y = 1.1, z = 0 },
    scale = { x = 6, y = 1, z = 4 },
  })
  t.supply = H.object({
    tags = { "supply.wood" }, contents = 6, childTags = { "wood" },
    position = { x = -2, y = 1.6, z = 1 },
  })
  t.marker = H.object({ tags = { "marker" }, position = { x = 0, y = 1.4, z = -3.2 } })
  t.wood = {}
  for i = 1, 4 do
    t.wood[i] = H.object({ tags = { "wood" } })
  end
  return t
end

local function boot(saved)
  local chunk, err = loadfile(DEMO)
  if not chunk then
    error("demo/Global.lua does not parse: " .. tostring(err))
  end
  chunk()
  onLoad(saved or "")
  H.tick(2) -- the coalesced first redraw
end

-- ------------------------------------------------------------------- the boot

case("the demo boots with every declared role present", function()
  H.reset(LIB)
  table_()
  boot()
  check(H.logged("all 4 declared roles present") ~= nil, "the manifest checked out")
  check(H.logged("ready — round 1, 6 wood") ~= nil, "and it said so")
  eq(H.logged("ERROR"), nil, "nothing failed on the way up")
end)

case("a missing role stops setup instead of half-running it", function()
  H.reset(LIB)
  H.object({ tags = { "board" } }) -- no supply, no marker
  boot()
  check(H.logged("role 'supply.wood': expected 1, found 0") ~= nil,
    "the missing supply is named")
  check(H.logged("role 'marker': expected 1, found 0") ~= nil,
    "and so is the marker, in the same pass")
  check(H.logged("setup stopped") ~= nil, "setup stopped rather than continuing")
end)

case("a tag typed in the wrong case is diagnosed, not just missed", function()
  H.reset(LIB)
  H.object({ tags = { "Board" } })
  H.object({ tags = { "supply.wood" }, contents = 1 })
  H.object({ tags = { "marker" } })
  boot()
  check(H.logged("tag case must match") ~= nil, "the near miss is reported")
end)

-- -------------------------------------------------------------------- layout

case("the supply and the marker are placed relative to the board", function()
  H.reset(LIB)
  local t = table_()
  boot()
  -- supply is board-local (-0.34, 0.20, 0.22); the board is at (0, 1.1, 0)
  -- scaled 6 x 1 x 4, so world = local * scale + board position.
  near(t.supply.position.x, -0.34 * 6, "the supply moved to its space in X")
  near(t.supply.position.y, 1.1 + 0.20, "the stacking layer is not scaled away")
  near(t.supply.position.z, 0.22 * 4, "and in Z")
  near(t.marker.position.x, -0.34 * 6, "the marker starts at round 1 on the track")
end)

case("moving the board moves the whole layout with it", function()
  H.reset(LIB)
  local t = table_()
  t.board.position = { x = 20, y = 1.1, z = -7 }
  boot()
  near(t.supply.position.x, 20 + (-0.34 * 6), "the supply followed the board")
  near(t.supply.position.z, -7 + (0.22 * 4), "on both axes")
  check(H.logged("ERROR") == nil, "and nothing had to be re-authored")
end)

case("the snap row is built from the same coordinates as the spaces", function()
  H.reset(LIB)
  local t = table_()
  boot()
  check(t.board.snapPoints ~= nil, "the board got snap points")
  eq(#t.board.snapPoints, 6, "one per clearing slot, and one per cube in the supply")
  eq(t.board.snapPoints[1].tags[1], "wood", "tagged, so only wood snaps there")
  near(t.board.snapPoints[2].position.x, 0.04 + 0.10, "the second slot is one step over")
end)

-- ------------------------------------------------------------------ buttons

case("the board's buttons are named, and rebuilt without duplicating", function()
  H.reset(LIB)
  local t = table_()
  boot()
  eq(#t.board.buttons, 2, "two controls")
  onPlayerConnect({ color = "Blue" })
  H.tick(70) -- the 1s rebuild, plus the redraw
  eq(#t.board.buttons, 2, "a late joiner's rebuild edits rather than stacks")
end)

case("a scaled board does not render scaled buttons", function()
  H.reset(LIB)
  local t = table_()
  boot()
  near(t.board.buttons[1].scale.x, 1 / 6, "X is undistorted")
  near(t.board.buttons[1].scale.z, 1 / 4, "and so is Z")
end)

case("next round advances the marker; right-click resets", function()
  H.reset(LIB)
  local t = table_()
  boot()
  local click = Global.getVar(t.board.buttons[2].click_function)
  click(t.board, "Blue", false)
  check(H.logged("Round 2") ~= nil, "the round advanced")
  near(t.marker.position.x, -0.34 * 6 + 0.09 * 6, "and the marker stepped along the track")

  click(t.board, "Blue", true) -- alt_click
  H.tick(2)
  check(H.logged("Woodcutter reset") ~= nil, "the same button reset the game")
  near(t.marker.position.x, -0.34 * 6, "and the marker went back to round 1")
end)

case("take wood moves one cube from the supply to a clearing slot", function()
  H.reset(LIB)
  local t = table_()
  boot()
  Global.getVar(t.board.buttons[1].click_function)(t.board, "Blue", false)
  H.tick(2)
  eq(#H.objects, 8, "a cube was taken out of the bag")
  check(H.logged("ERROR") == nil, "with no error on the way")
end)

case("draining the supply gives every cube its own slot", function()
  H.reset(LIB)
  local t = table_()
  boot()

  -- The bag holds six (objects/supply.json), and the clearing row is built from
  -- the same constant.  Clicking it empty used to land the sixth cube exactly on
  -- top of the first (review 2026-09-21, A6).
  local seen, taken = {}, 0
  for _ = 1, t.supply.quantity do
    local before = #H.objects
    Global.getVar(t.board.buttons[1].click_function)(t.board, "Blue", false)
    H.tick(3)
    if #H.objects > before then
      taken = taken + 1
      local cube = H.objects[#H.objects]
      local key = string.format("%.3f", cube.position.x)
      check(seen[key] == nil, "cube " .. taken .. " landed on a free slot (x=" .. key .. ")")
      seen[key] = true
    end
  end

  eq(taken, 6, "all six cubes came out")
  check(H.logged("ERROR") == nil, "and nothing errored draining it")
end)

case("taking from an empty supply says so instead of failing", function()
  H.reset(LIB)
  local t = table_()
  t.supply.quantity = 0
  boot()
  Global.getVar(t.board.buttons[1].click_function)(t.board, "Blue", false)
  check(H.logged("supply is empty") ~= nil, "the player is told")
  eq(H.logged("ERROR"), nil, "and it is not treated as a bug")
end)

-- ------------------------------------------------------------------- events

case("one subscription keeps the badge right, with no per-object script", function()
  H.reset(LIB)
  local t = table_()
  boot()
  eq(t.supply.buttons[1].label, "6", "the badge starts at the bag's own count")

  t.supply.quantity = 5
  onObjectLeaveContainer(t.supply, H.object({ tags = { "wood" } }))
  H.tick(2)
  eq(t.supply.buttons[1].label, "5", "and follows a cube leaving")

  t.supply.quantity = 6
  onObjectEnterContainer(t.supply, H.object({ tags = { "wood" } }))
  H.tick(2)
  eq(t.supply.buttons[1].label, "6", "and a cube returning")
end)

case("a burst of container events costs one redraw, not one each", function()
  H.reset(LIB)
  local t = table_()
  boot()
  local before = H.pendingWaits()
  for _ = 1, 10 do
    onObjectLeaveContainer(t.supply, H.object({ tags = { "wood" } }))
  end
  eq(H.pendingWaits() - before, 1, "ten events, one pending redraw")
  t.supply.quantity = 0
  H.tick(2)
  eq(t.supply.buttons[1].label, "0", "and it still lands on the right number")
end)

case("events for other containers are not delivered here", function()
  H.reset(LIB)
  local t = table_()
  boot()
  local other = H.object({ tags = { "junk" }, contents = 3 })
  t.supply.quantity = 99
  onObjectLeaveContainer(other, H.object({}))
  H.tick(2)
  eq(t.supply.buttons[1].label, "6", "the untagged container's event changed nothing")
end)

case("a dropped cube is counted once, not once per duplicate event", function()
  H.reset(LIB)
  local t = table_()
  boot()
  local cube = t.wood[1]
  onObjectDrop("Blue", cube)
  onObjectDrop("Blue", cube) -- TTS fires drop more than once per physical drop
  onObjectDrop("Blue", cube)
  H.tick(2)
  eq(onSave():match('"dropped":(%d+)'), "1", "the repeats inside the window were dropped")

  H.tick(100) -- past the 1.25s window
  onObjectDrop("Blue", cube)
  H.tick(2)
  eq(onSave():match('"dropped":(%d+)'), "2", "a later drop counts again")
end)

-- -------------------------------------------------------------------- store

case("round and dropped survive a save and reload", function()
  H.reset(LIB)
  local t = table_()
  boot()
  Global.getVar(t.board.buttons[2].click_function)(t.board, "Blue", false)
  onObjectDrop("Blue", t.wood[1])
  H.tick(2)
  local saved = onSave()

  H.reset(LIB)
  local t2 = table_()
  boot(saved)
  check(H.logged("ready — round 2") ~= nil, "the round came back")
  eq(onSave():match('"dropped":(%d+)'), "1", "and so did the drop count")
  near(t2.marker.position.x, -0.34 * 6 + 0.09 * 6,
    "the marker was replaced at the restored round")
end)

case("a save from another schema version is dropped, loudly", function()
  H.reset(LIB)
  table_()
  boot('{"game":{"v":99,"d":{"round":5,"dropped":40}}}')
  check(H.logged("saved at version 99") ~= nil, "the mismatch is reported")
  check(H.logged("ready — round 1") ~= nil, "and the defaults are used")
end)

case("junk in the saved blob cannot crash the boot", function()
  H.reset(LIB)
  table_()
  boot("not json at all")
  check(H.logged("ready — round 1") ~= nil, "it booted on defaults")
end)

-- ------------------------------------------------------------- the build path

case("the built script is the library plus the demo, and it parses", function()
  local pieces = {}
  for _, file in ipairs({
    "00-log.lua", "01-async.lua", "02-store.lua", "03-ui.lua",
    "04-events.lua", "05-registry.lua", "06-layout.lua",
  }) do
    local fh = assert(io.open(LIB .. "/" .. file, "r"))
    pieces[#pieces + 1] = fh:read("*a")
    fh:close()
  end
  local fh = assert(io.open(DEMO, "r"))
  pieces[#pieces + 1] = fh:read("*a")
  fh:close()

  local source = table.concat(pieces)
  local chunk, err = loadstring(source, "built")
  check(chunk ~= nil, "the concatenation parses: " .. tostring(err))

  H.reset(LIB)
  table_()
  if chunk then
    chunk()
    onLoad("")
    H.tick(2)
    check(H.logged("ready — round 1") ~= nil, "and boots exactly as the pieces do")
  end
end)

-- ------------------------------------------------------------------ runner

out("woodcutter demo spec")
for _, c in ipairs(cases) do
  currentCase = c.name
  local ok, err = pcall(c.fn)
  if not ok then
    failures = failures + 1
    out(string.format("  ERROR %s: %s", c.name, tostring(err)))
  end
end

out(string.format("\n%d cases, %d checks, %d failures", #cases, checks, failures))
os.exit(failures == 0 and 0 or 1)
