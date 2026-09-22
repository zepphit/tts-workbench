-- test/boot_spec.lua — the whole rig, booted against the stub TTS.
--
--   luajit proto/amazonia/test/boot_spec.lua
--
-- hex_spec.lua proves the arithmetic. This proves the thing build.sh actually
-- ships: that the concatenation ttslib + art/index.lua + src/*.lua loads, that
-- onLoad runs, that the map builds on the lattice the arithmetic predicted, and
-- that tint, reskin, clear and a save/reload round trip behave. It runs the same
-- files build.sh concatenates, so a change that breaks the rig fails here
-- instead of in TTS.
--
-- What it cannot prove is TTS's own semantics — that a Custom_Model with these
-- three URLs renders, that the diffuse lands square on the top face, that a
-- snap point at this local coordinate catches a dragged tile. Those are the
-- step-3 gate in docs/amazonia-build-plan.md, and loading the save is the only
-- test of them.
--
-- The stub is reference/framework/test/harness.lua plus the handful of globals
-- Amazonia uses and Woodcutter did not: spawnObjectData, destroyObject,
-- sendExternalMessage, and the object members a Custom_Model needs.

local HERE = arg[0]:match("^(.*)/[^/]+$") or "."
local H = dofile(HERE .. "/../../../reference/framework/test/harness.lua")
local LIB = HERE .. "/../../../reference/framework/ttslib"
local ART_FILE = HERE .. "/../art/index.lua"
local SRC = HERE .. "/../src"

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

-- ------------------------------------------------- the rest of the stub TTS

local sent -- every sendExternalMessage payload, newest last

-- The harness's fake object knows nothing about custom models, locking or
-- tinting. Everything Amazonia calls that Woodcutter did not is added here,
-- with the same modest ambition: enough to run the logic, no claim about TTS.
local function augment(obj, data)
  data = data or {}
  obj.gmNotes = data.GMNotes or ""
  obj.colorDiffuse = data.ColorDiffuse or { r = 1, g = 1, b = 1 }
  obj.locked = data.Locked == true
  obj.custom = data.CustomMesh
  obj.type = data.Name or "Generic"

  function obj.getGMNotes() return obj.gmNotes end
  function obj.setGMNotes(v) obj.gmNotes = v; return true end
  function obj.getLock() return obj.locked end
  function obj.setLock(v) obj.locked = (v == true); return true end
  function obj.setColorTint(c) obj.colorDiffuse = c; return true end
  function obj.getColorTint() return obj.colorDiffuse end
  function obj.getCustomObject() return obj.custom end
  function obj.setCustomObject(c) obj.custom = c; return true end
  return obj
end

local function install()
  H.install()
  sent = {}

  _G.spawnObjectData = function(params)
    local data = params.data or {}
    local transform = data.Transform or {}
    local position = params.position or
        { x = transform.posX or 0, y = transform.posY or 0, z = transform.posZ or 0 }
    local rotation = params.rotation or
        { x = transform.rotX or 0, y = transform.rotY or 0, z = transform.rotZ or 0 }
    local tags = {}
    for i, tag in ipairs(data.Tags or {}) do tags[i] = tag end

    local obj = H.object({
      spawn = false, tags = tags, name = data.Nickname or "",
      position = position, rotation = rotation,
      scale = { x = transform.scaleX or 1, y = transform.scaleY or 1,
        z = transform.scaleZ or 1 },
      -- Same measured mesh as the anchor: anything the rig spawns as a
      -- BlockRectangle is twice as deep as its Z scale says.
      mesh = (data.Name == "BlockRectangle") and { x = 1, y = 1, z = 2 } or nil,
    })
    augment(obj, data)
    H.spawn(obj)
    if params.callback_function then
      H.schedule(1, function() params.callback_function(obj) end)
    end
    return obj
  end

  _G.destroyObject = function(obj)
    if obj then H.destroy(obj) end
    return true
  end

  _G.sendExternalMessage = function(payload)
    sent[#sent + 1] = payload
    return true
  end

  -- TTS's grid, the global one. 1 = Off, 3 = Centre. It starts at Centre
  -- because that is what the running game was found at on 2026-09-21 while its
  -- save file claimed otherwise — so the rig has to set it, not assume it.
  _G.Grid = { type = 3, snapping = 3, show_lines = false, size_x = 2, size_y = 2 }

  _G.getObjectFromGUID = _G.getObjectFromGUID
end

local function readFile(path)
  local handle = assert(io.open(path, "rb"), "cannot read " .. path)
  local text = handle:read("*a")
  handle:close()
  return text
end

-- loadRig() — load what build.sh ships: ONE chunk, not fifteen.
--
-- This used to call loadfile() per file, which is wrong in a way that matters.
-- TTS has no `require`, so a build is a concatenation, and in a concatenation a
-- file's top-level `local` stays in scope for every file after it. Loading the
-- files separately gives each `local` its own chunk scope and hides that
-- entirely — which is how `AZ = {}` (then `A = {}`) silently overwrote
-- ttslib/01-async.lua's `local A` and shipped to TTS on 2026-09-21, passing all
-- 30 cases here on the way out. The lint in scripts/luacat.py catches it
-- statically now; this catches it dynamically, which is the stronger of the two.
--
-- The two directories are *listed*, not spelled out, for the same reason: a
-- hardcoded file list is a build that silently stops covering a new module the
-- day someone adds one, and scripts/luacat.py takes whatever is in the
-- directory in filename order. This has to take the same thing.
local function luaFiles(directory)
  local pipe = io.popen("ls " .. directory .. "/*.lua 2>/dev/null")
  if not pipe then error("cannot list " .. directory) end
  local found = {}
  for line in pipe:lines() do found[#found + 1] = line end
  pipe:close()
  table.sort(found)
  if #found == 0 then error("no .lua files in " .. directory) end
  return found
end

local function loadRig()
  _G.ttslib = nil
  local parts = {}
  for _, path in ipairs(luaFiles(LIB)) do
    parts[#parts + 1] = readFile(path)
  end
  parts[#parts + 1] = readFile(ART_FILE)
  for _, path in ipairs(luaFiles(SRC)) do
    parts[#parts + 1] = readFile(path)
  end

  local loader = loadstring or load -- LuaJIT is 5.1; TTS is 5.2
  local chunk, err = loader(table.concat(parts), "=Global")
  if not chunk then error("the concatenated build does not parse: " .. tostring(err)) end
  chunk()
  ttslib.log.level = "error" -- after the build: 99-Global.lua sets it to info
end

-- A table with the anchor build.sh inserts: a BlockRectangle scaled
-- 20 x 0.2 x 17, locked, tagged map.anchor.
--
-- **`mesh` is the point of this function.** A BlockRectangle's mesh is
-- 1 x 1 x 2, measured in the running game: `positionToWorld({0,0,1}).z` on this
-- plate is 34, not 17, and the plate is 34 deep. The stub used to multiply by
-- `scale` alone, which is how a map stretched by exactly two along Z passed
-- every case here and shipped (2026-09-21). Anything that turns a world offset
-- into an anchor-local one has to go through layout.basis, and this is what
-- makes a test that skips it fail.
local function anchor(spec)
  spec = spec or {}
  return augment(H.object({
    tags = { "map.anchor" },
    position = spec.position or { x = 0, y = 1, z = 0 },
    rotation = spec.rotation or { x = 0, y = 0, z = 0 },
    scale = spec.scale or { x = 20, y = 0.2, z = 17 },
    mesh = spec.mesh or { x = 1, y = 1, z = 2 },
    name = "Amazonia Anchor",
  }), { Locked = true })
end

-- boot(saved, spec) — install the stub, load the rig, run onLoad, and let the
-- spawn callbacks and the coalesced HUD refresh land.
--
-- `spec.carry` is the reload case: TTS saves the objects a script spawned, so a
-- reload comes back with its tiles already on the table. Putting them back
-- *before* onLoad is what makes the "do not build over them" branch reachable.
local function boot(saved, spec)
  spec = spec or {}
  for _, name in ipairs({ "onObjectSpawn", "onObjectDestroy", "onObjectDrop",
    "onObjectPickUp", "onObjectEnterContainer", "onObjectLeaveContainer",
    "onLoad", "onSave" }) do
    _G[name] = nil
  end
  install()
  loadRig()
  local plate = anchor(spec)
  for _, obj in ipairs(spec.carry or {}) do H.spawn(obj) end
  onLoad(saved)
  H.tick(80) -- spawn callbacks, then the 0.5s bulk flush and 0.75s HUD pass
  return plate
end

-- ------------------------------------------------------------------- cases

case("the build loads and onLoad runs on an empty table", function()
  boot(nil)
  check(Map.count() > 0, "a map was built (got " .. Map.count() .. " tiles)")
  eq(MAP.seed, 1, "default seed")
  eq(MAP.rings, 3, "default rings")
end)

case("one tile per packed slot, and no two on the same hex", function()
  boot(nil)
  eq(Map.count(), #Map.slots(), "tiles == slots")
  local seen = {}
  for key in pairs(Map.cells()) do
    check(not seen[key], "hex " .. key .. " covered twice")
    seen[key] = true
  end
  local covered = 0
  for _ in pairs(seen) do covered = covered + 1 end
  eq(covered, Map.count() * 3, "each tri-hex covers three hexes")
end)

case("tiles carry both tags and their kind in GMNotes", function()
  boot(nil)
  for _, obj in ipairs(Tiles.onMap()) do
    check(obj.hasTag("tile"), "tile tag")
    local kind = Tiles.kindOf(obj)
    check(kind ~= nil, "GMNotes names a known kind")
    check(obj.hasTag("tile." .. tostring(kind)), "tile." .. tostring(kind) .. " tag")
  end
end)

case("tiles land exactly where the arithmetic says, through the anchor", function()
  -- The anchor is at the origin, scaled 20 x 0.2 x 17, and every slot was
  -- registered as world-offset-over-scale. positionToWorld multiplies it back,
  -- so a tile must sit on hex.toWorld to the millimetre. This is the whole of
  -- critique C2 in one assertion.
  boot(nil)
  local byHex = {}
  for _, slot in ipairs(Map.slots()) do
    local x, z = hex.toWorld(slot.q, slot.r, ART.radius)
    byHex[hex.key(slot.q, slot.r)] = { x = x, z = z, rot = slot.rot }
  end
  local matched = 0
  for _, obj in ipairs(Tiles.onMap()) do
    local q, r = hex.fromWorld(obj.getPosition().x, obj.getPosition().z, ART.radius)
    local want = byHex[hex.key(q, r)]
    if check(want ~= nil, "a tile sits on a slot hex, got " .. hex.key(q, r)) then
      near(obj.getPosition().x, want.x, "tile x")
      near(obj.getPosition().z, want.z, "tile z")
      near(obj.getRotation().y, want.rot * 60, "tile rotY")
      matched = matched + 1
    end
  end
  eq(matched, Map.count(), "every tile matched a slot")
end)

case("moving the anchor moves the whole map with it", function()
  local plate = boot(nil)
  local before = Map.count()
  plate.position = { x = 8, y = 1, z = -5 }
  Map.invalidate()
  Map.build()
  H.tick(80)
  eq(Map.count(), before, "same tile count after the plate moved")
  local anySeen = false
  for _, obj in ipairs(Tiles.onMap()) do
    local slot = Map.slots()[1]
    local x, z = hex.toWorld(slot.q, slot.r, ART.radius)
    if math.abs(obj.getPosition().x - (8 + x)) < 0.001
        and math.abs(obj.getPosition().z - (-5 + z)) < 0.001 then
      anySeen = true
    end
  end
  check(anySeen, "the first slot landed at the plate's new position")
end)

case("only tiles snap: the lattice is on and TTS's grid is off", function()
  -- Two separate systems, set opposite ways. The lattice interlocks tri-hexes;
  -- TTS's grid is global and was the thing pulling cubes to hex centres.
  local plate = boot(nil)
  eq(MAP.snap, true, "the lattice ships on")
  eq(MAP.gridSnap, false, "TTS's grid snapping ships off")
  eq(Grid.snapping, 1, "and the rig set it off rather than trusting the save")

  local points = plate.getSnapPoints()
  eq(#points, #Map.lattice(), "one snap point per lattice position")
  for _, point in ipairs(points) do
    eq(point.tags[1], "tile", "snap point is tagged for tiles")
    check(point.rotation ~= nil, "snap point carries a rotation, so tiles land interlocked")
  end

  -- The field is much larger than the map, and that is the point: with one
  -- point per map slot and every slot filled, the only snappable positions on
  -- the table were underneath tiles, so a tile dragged off the tray had nowhere
  -- to land. Reported at the table on 2026-09-21 as "it doesn't magnet".
  check(#points > #Map.slots() * 4,
    "the snap field reaches well past the map (" .. #points .. " vs " ..
    #Map.slots() .. " slots)")

  -- and every map slot is still one of them, or the tiles already down stop
  -- interlocking with anything dropped beside them.
  local field = {}
  for _, at in ipairs(Map.lattice()) do
    field[at.q .. "," .. at.r .. "," .. at.rot] = true
  end
  for _, slot in ipairs(Map.slots()) do
    check(field[slot.q .. "," .. slot.r .. "," .. slot.rot],
      "map slot " .. slot.q .. "," .. slot.r .. " is in the snap field")
  end

  for _, obj in ipairs(Tiles.onMap()) do
    eq(obj.use_snap_points ~= false, true, "a tile still uses the lattice")
  end

  AZ.snap(false)
  eq(#plate.getSnapPoints(), 0, "off clears the plate rather than just not writing")
  AZ.snap(true)
  eq(#plate.getSnapPoints(), #Map.lattice(), "and on writes it again")
end)

case("the snap field covers the plate and stops at its rim", function()
  local plate = boot(nil)
  local basis = ttslib.layout.basis()
  local halfX, halfZ = basis.x / 2, basis.z / 2

  -- Nothing hangs off: the table is Table_None and this plate is the floor, so
  -- a snap point past the rim would pull a tile out of the world.
  for _, at in ipairs(Map.lattice()) do
    for _, cell in ipairs(hex.footprint(ART.shapes[MAP.shape].cells,
      at.q, at.r, at.rot)) do
      local x, z = hex.toWorld(cell[1], cell[2], ART.radius)
      check(math.abs(x) <= halfX and math.abs(z) <= halfZ,
        string.format("cell %.2f,%.2f is on the plate", x, z))
    end
  end

  -- and it reaches: a lattice that only covered the middle would pass the test
  -- above trivially.
  local far = 0
  for _, at in ipairs(Map.lattice()) do
    local x = hex.toWorld(at.q, at.r, ART.radius)
    if math.abs(x) > far then far = math.abs(x) end
  end
  check(far > halfX * 0.7,
    string.format("the field reaches %.1f of the plate's %.1f half-width",
      far, halfX))
  eq(#plate.getSnapPoints(), #Map.lattice(), "all of it is written to the plate")
end)

case("anything that is not a tile is taken out of both snapping systems", function()
  boot(nil)
  -- A cube, the way the owner makes one: no tags, TTS's defaults.
  local cube = H.object({ name = "Block", position = { x = 1, y = 3, z = 1 } })
  cube.use_grid, cube.use_snap_points = true, true
  onObjectSpawn(cube)
  H.tick(5)
  eq(cube.use_grid, false, "the cube ignores the table grid")
  eq(cube.use_snap_points, false, "and the lattice")

  -- And a tile is left alone, because it is the one thing that should snap.
  local tile = Tiles.onMap()[1]
  tile.use_snap_points = true
  onObjectSpawn(tile)
  H.tick(5)
  eq(tile.use_snap_points, true, "a tile keeps its snapping")

  eq(AZ.gridsnap(true), true, "the grid can be turned back on")
  eq(Grid.snapping, 3, "which is Centre")
  AZ.gridsnap(false)
  eq(Grid.snapping, 1, "and off again")
end)

-- withLabels() — the stripes, plus a kind that has something to say.
--
-- Labels ship off and no kind in spec/tiles.json claims a hub any more, so
-- every test below has to turn both back on. What they prove is still worth
-- proving: the counter-rotation and the 180 baseline are measured facts about
-- TTS, and the code that knows them is one AZ.labels(true) away from live.
local function withLabels()
  AZ.labels(true)
  Tiles.hub("jungle", 1, "rubber")
  Tiles.hub("deep_jungle", 1, "timber")
  Tiles.hub("deep_jungle", 2, "cacao")
end

case("labels off: no tile on the table carries a button", function()
  boot(nil)
  eq(HUB.enabled, false, "stripes ship off")
  local buttons = 0
  for _, obj in ipairs(Tiles.all()) do
    buttons = buttons + #(obj.getButtons() or {})
  end
  eq(buttons, 0, "the whole table is plain")

  -- And turning them off again *removes* what is there, rather than declining
  -- to draw: a stripe already on a tile has to go.
  withLabels()
  local drawn = 0
  for _, obj in ipairs(Tiles.onMap()) do
    drawn = drawn + #(obj.getButtons() or {})
  end
  check(drawn > 0, "labels on: stripes appear (" .. drawn .. ")")
  AZ.labels(false)
  local left = 0
  for _, obj in ipairs(Tiles.onMap()) do
    left = left + #(obj.getButtons() or {})
  end
  eq(left, 0, "labels off again: they are cleared from the tiles")
end)

case("hub buttons exist, are named, and do not stack on a redraw", function()
  boot(nil)
  withLabels()
  local withHubs = 0
  for _, obj in ipairs(Tiles.onMap()) do
    local kind = ART.kinds[Tiles.kindOf(obj)]
    local wanted = #kind.hubs
    local buttons = obj.getButtons() or {}
    eq(#buttons, wanted, "button count for " .. Tiles.kindOf(obj))
    if wanted > 0 then withHubs = withHubs + 1 end
    Tiles.hubs(obj)
    Tiles.hubs(obj)
    eq(#(obj.getButtons() or {}), wanted, "redrawing edits rather than stacks")
  end
  check(withHubs > 0, "at least one kind on the table has hubs")
end)

case("a hub button sits over its own cell centre", function()
  boot(nil)
  withLabels()
  for _, obj in ipairs(Tiles.onMap()) do
    local kind = ART.kinds[Tiles.kindOf(obj)]
    local shape = ART.shapes[kind.shape]
    for index, _ in ipairs(kind.hubs) do
      local button = (obj.getButtons() or {})[index]
      if check(button ~= nil, "button " .. index .. " exists") then
        local x, z = hex.toWorld(shape.cells[index][1], shape.cells[index][2],
          ART.radius)
        near(button.position[1], x, "hub x")
        near(button.position[3], z, "hub z")
        check(button.position[2] > 0.1, "hub floats above the tile's top face")
      end
    end
  end
end)

case("a hub stripe cancels its tile's rotation so the text reads one way", function()
  -- position turns with the tile, because the cell it points at moves.
  -- rotation does not, because the text should read the same on every tile.
  -- Both are relative to the object, so the check is that world rotation
  -- (tile + button) comes out at zero whatever the tile is doing.
  boot(nil)
  withLabels()
  local turned = 0
  for _, obj in ipairs(Tiles.onMap()) do
    local tileY = obj.getRotation().y
    for _, button in ipairs(obj.getButtons() or {}) do
      check(button.rotation ~= nil, "the stripe carries a rotation")
      if button.rotation then
        -- HUB.facing, not 0: TTS lays button text out along the object's -Z,
        -- so a stripe at world rotation 0 reads upside down. Every stripe must
        -- land on the same baseline, whatever its tile is doing.
        near((tileY + button.rotation[2]) % 360, HUB.facing % 360,
          "stripe reads the same way on a " .. tileY .. "-degree tile")
      end
    end
    if tileY % 360 ~= 0 then turned = turned + 1 end
  end
  check(turned > 0, "the map really does use rotated tiles (" .. turned .. ")")
end)

case("turning a tile by hand re-pins its stripes", function()
  boot(nil)
  withLabels()
  local tile, button = nil, nil
  for _, obj in ipairs(Tiles.onMap()) do
    if #(obj.getButtons() or {}) > 0 then tile = obj break end
  end
  check(tile ~= nil, "a tile with a hub")
  local stripes = #(tile.getButtons() or {}) -- deep_jungle has two

  tile.rotation = { x = 0, y = 240, z = 0 }
  onObjectRotate(tile, 240, 0, "White", 0, 0)
  H.tick(40) -- the keyed redraw waits for the spin to settle
  button = (tile.getButtons() or {})[1]
  if check(button ~= nil, "the stripe survived") then
    near((240 + button.rotation[2]) % 360, HUB.facing % 360,
      "re-pinned to the same baseline after the turn")
  end
  eq(#(tile.getButtons() or {}), stripes, "re-pinning edits rather than stacks")
end)

case("AZ.hubstyle changes the stripe live, without respawning", function()
  boot(nil)
  withLabels()
  local before = Map.count()
  AZ.hubstyle(1200, 90, 111)
  eq(HUB.width, 1200, "width set")
  eq(HUB.height, 90, "height set")
  eq(HUB.fontSize, 111, "font set")
  eq(Map.count(), before, "nothing respawned")
  for _, obj in ipairs(Tiles.onMap()) do
    for _, button in ipairs(obj.getButtons() or {}) do
      eq(button.width, 1200, "the stripe got wider")
      eq(button.height, 90, "and thinner")
      eq(button.font_size, 111, "and the font changed")
    end
  end
  AZ.hubstyle(nil, 200)
  eq(HUB.width, 1200, "an omitted argument keeps its value")
  eq(HUB.height, 200, "the given one changes")
end)

case("AZ.hubface changes the baseline every stripe reads to", function()
  boot(nil)
  withLabels()
  eq(HUB.facing, 180, "TTS lays button text along the object's -Z, so 180")
  AZ.hubface(90)
  eq(HUB.facing, 90, "the baseline moved")
  for _, obj in ipairs(Tiles.onMap()) do
    local tileY = obj.getRotation().y
    for _, button in ipairs(obj.getButtons() or {}) do
      near((tileY + button.rotation[2]) % 360, 90, "every stripe followed")
    end
  end
  AZ.hubface(180)
  eq(HUB.facing, 180, "and back")
end)

case("the stripe is wider than it is tall — it is a stripe, not a box", function()
  boot(nil)
  check(HUB.width > HUB.height * 3,
    "HUB defaults to a stripe (" .. HUB.width .. " x " .. HUB.height .. ")")
end)

case("AZ.tint recolours one kind, instantly, without respawning", function()
  boot(nil)
  local kind = nil
  for _, name in ipairs(Tiles.kinds()) do
    if #Tiles.ofKind(name) > 0 then kind = name break end
  end
  check(kind ~= nil, "some kind is on the table")
  local guids, before = {}, Map.count()
  for _, obj in ipairs(Tiles.ofKind(kind)) do guids[#guids + 1] = obj.getGUID() end

  local touched = AZ.tint(kind, "14351F")
  eq(touched, #guids, "tinted every tile of the kind")
  eq(Map.count(), before, "nothing respawned")
  for _, obj in ipairs(Tiles.ofKind(kind)) do
    near(obj.getColorTint().r, 0x14 / 255, "tint r")
    near(obj.getColorTint().g, 0x35 / 255, "tint g")
    near(obj.getColorTint().b, 0x1F / 255, "tint b")
  end
  -- Other kinds are untouched: the tag routes the change, not a sweep.
  for _, name in ipairs(Tiles.kinds()) do
    if name ~= kind then
      for _, obj in ipairs(Tiles.ofKind(name)) do
        check(math.abs(obj.getColorTint().r - 0x14 / 255) > 0.001,
          "kind " .. name .. " was left alone")
      end
    end
  end
end)

case("AZ.tint rejects a colour that is not six hex digits", function()
  boot(nil)
  eq(AZ.tint("jungle", "green"), false, "a word is refused")
  eq(AZ.tint("jungle", "12345"), false, "five digits are refused")
  eq(AZ.tint("no_such_kind", "112233"), false, "an unknown kind is refused")
end)

case("AZ.reskin respawns in place and puts the hubs back", function()
  boot(nil)
  withLabels()
  local kind = nil
  for _, name in ipairs(Tiles.kinds()) do
    if #Tiles.ofKind(name) > 0 and #ART.kinds[name].hubs > 0 then
      kind = name
      break
    end
  end
  check(kind ~= nil, "some kind with hubs is on the table")

  local before, total = {}, Map.count()
  for _, obj in ipairs(Tiles.ofKind(kind)) do
    before[#before + 1] = { obj.getPosition(), obj.getRotation().y, obj.getGUID() }
  end

  local n = Tiles.reskin(kind, "file:///tmp/new-diffuse.png")
  H.tick(10)
  eq(n, #before, "reskinned every tile of the kind")
  eq(Map.count(), total, "the map is the same size afterwards")

  local after = Tiles.ofKind(kind)
  eq(#after, #before, "same number of tiles")
  for _, obj in ipairs(after) do
    eq(obj.getCustomObject().DiffuseURL, "file:///tmp/new-diffuse.png",
      "the new diffuse is on the object")
    eq(#(obj.getButtons() or {}), #ART.kinds[kind].hubs, "hubs are back")
  end
  -- Positions survived, even though the objects did not.
  for _, old in ipairs(before) do
    local found = false
    for _, obj in ipairs(after) do
      if math.abs(obj.getPosition().x - old[1].x) < 0.001
          and math.abs(obj.getPosition().z - old[1].z) < 0.001 then
        found = true
      end
    end
    check(found, "a tile came back at " .. string.format("%.2f,%.2f", old[1].x, old[1].z))
  end
end)

case("AZ.hub sets, clears and cycles a resource", function()
  boot(nil)
  withLabels()
  local kind = "jungle"
  eq(AZ.hub(kind, 1, "gold"), true, "set a hub")
  eq(ART.kinds[kind].hubs[1], "gold", "the catalogue was updated")
  eq(AZ.hub(kind, 2, "fish", 3), true, "set a counted hub")
  eq(ART.kinds[kind].hubs[2], "fish 3", "count is part of the label")
  eq(AZ.hub(kind, 1, ""), true, "clear a hub")
  eq(ART.kinds[kind].hubs[1], nil, "the hub is gone")
  eq(AZ.hub(kind, 9, "gold"), false, "a cell that does not exist is refused")
  for _, obj in ipairs(Tiles.ofKind(kind)) do
    eq(#(obj.getButtons() or {}), 1, "one button left on the table")
  end
end)

case("AZ.clear empties the table and AZ.n counts it", function()
  boot(nil)
  check(AZ.n() > 0, "tiles to start with")
  local removed = AZ.clear()
  H.tick(30)
  eq(AZ.n(), 0, "nothing left")
  check(removed > 0, "clear reported what it removed")
end)

case("a reroll changes the terrain and not the lattice", function()
  boot(nil)
  local before = {}
  for key, cell in pairs(Map.cells()) do before[key] = cell.kind end

  Map.reroll()
  H.tick(80)
  eq(MAP.seed, 2, "the seed stepped")
  eq(Map.count(), #Map.slots(), "the same number of tiles")

  local after, moved, changed = Map.cells(), 0, 0
  for key in pairs(before) do
    if after[key] == nil then moved = moved + 1
    elseif after[key].kind ~= before[key] then changed = changed + 1 end
  end
  eq(moved, 0, "every hex the old map covered is still covered")
  check(changed > 0, "at least one hex changed kind")
end)

case("the same seed rebuilds the same map", function()
  boot(nil)
  local first = {}
  for key, cell in pairs(Map.cells()) do first[key] = cell.kind end
  Map.build(7)
  H.tick(80)
  local seven = {}
  for key, cell in pairs(Map.cells()) do seven[key] = cell.kind end
  Map.build(1)
  H.tick(80)
  for key, kind in pairs(first) do
    eq(Map.cells()[key] and Map.cells()[key].kind, kind, "hex " .. key .. " redrawn")
  end
  local differs = false
  for key, kind in pairs(seven) do
    if first[key] ~= kind then differs = true end
  end
  check(differs, "a different seed gives a different map")
end)

case("building twice does not double the map", function()
  boot(nil)
  local first = Map.count()
  Map.build()
  H.tick(80)
  eq(Map.count(), first, "the second build cleared before it spawned")
end)

case("onSave / onLoad keeps the seed and does not rebuild over the tiles", function()
  boot(nil)
  Map.reroll(41)
  H.tick(80)
  local seed, tiles = MAP.seed, Map.count()
  AZ.rings(2)
  H.tick(80)
  local rings, ringTiles = MAP.rings, Map.count()

  local saved = onSave()
  check(type(saved) == "string" and #saved > 2, "onSave returned a blob")

  -- The reload: same table, same objects, the script started again.
  local carried = {}
  for _, obj in ipairs(Tiles.all()) do carried[#carried + 1] = obj end
  local plate = boot(saved, { carry = carried })

  eq(MAP.seed, seed, "the seed came back")
  eq(MAP.rings, rings, "the ring count came back")
  eq(Map.count(), ringTiles, "the tiles came back once, not twice")
  check(plate ~= nil, "the anchor is still there")
  eq(seed, 41, "the seed under test really was the rerolled one")
  check(tiles > 0, "there were tiles before the resize")
end)

case("a reload redraws the hub buttons TTS did not save", function()
  boot(nil)
  withLabels()
  local carried = {}
  for _, obj in ipairs(Tiles.all()) do
    obj.clearButtons() -- TTS saves no scripted buttons
    carried[#carried + 1] = obj
  end
  local saved = onSave()
  boot(saved, { carry = carried })

  -- A reload re-reads the spec, so labels come back off and no kind claims a
  -- hub: a live AZ.labels(true) is no more persistent than a live tint.
  local drawn = 0
  for _, obj in ipairs(Tiles.all()) do
    drawn = drawn + #(obj.getButtons() or {})
  end
  eq(drawn, 0, "nothing is drawn while labels are off")

  -- Turning them on draws on the tiles that came back *with the save* rather
  -- than from a build, which is the path onLoad has to cover: TTS restores the
  -- objects and drops their scripted buttons.
  withLabels()
  for _, obj in ipairs(Tiles.onMap()) do
    drawn = drawn + #(obj.getButtons() or {})
  end
  check(drawn > 0, "hubs were redrawn on the carried tiles (got " .. drawn .. ")")
end)

case("setup stops loudly when the anchor is missing", function()
  install()
  loadRig()
  ttslib.log.level = "info"
  H.printed = {}
  onLoad(nil)
  H.tick(20)
  check(H.logged("map.anchor") ~= nil, "the missing role is named")
  eq(Map.count(), 0, "nothing was built on a table with no anchor")
end)

-- ------------------------------------------------------------------ journal

case("a drop is recorded hex-aware, with where it came from", function()
  boot(nil)
  local cube = H.object({ tags = { "cube" }, name = "Wood",
    position = { x = 0, y = 1.4, z = 0 } })
  augment(cube, {})
  H.tick(2)

  local mark = #sent
  onObjectPickUp("White", cube)
  cube.position = { x = hex.toWorld(2, -1, ART.radius) }
  local x, z = hex.toWorld(2, -1, ART.radius)
  cube.position = { x = x, y = 1.4, z = z }
  onObjectDrop("White", cube)
  H.tick(10)

  local move = nil
  for i = mark + 1, #sent do
    local record = sent[i].amazonia
    if record and record.kind == "move" then move = record end
  end
  if check(move ~= nil, "a move record was sent") then
    eq(move.who, "White", "who dropped it")
    eq(move.from, "hex(0,0)", "picked up from the origin hex")
    eq(move.to, "hex(2,-1)", "dropped on the hex it landed on")
    eq(move.what, "Wood", "what was moved")
  end
end)

case("the journal stays quiet while the map is rebuilt", function()
  boot(nil)
  local mark = #sent
  Map.reroll()
  H.tick(80)
  local spawns = 0
  for i = mark + 1, #sent do
    local record = sent[i].amazonia
    if record and (record.kind == "spawn" or record.kind == "destroy") then
      spawns = spawns + 1
    end
  end
  eq(spawns, 0, "a rebuild is one record, not one per tile")
  local built = false
  for i = mark + 1, #sent do
    if sent[i].amazonia and sent[i].amazonia.kind == "build" then built = true end
  end
  check(built, "the rebuild itself was recorded")
end)

case("an external ping is answered and a note is recorded", function()
  boot(nil)
  local mark = #sent
  onExternalMessage({ ping = "hello" })
  onExternalMessage({ note = "moved the cubes by hand" })
  H.tick(2)
  local pong, note = nil, nil
  for i = mark + 1, #sent do
    local record = sent[i].amazonia
    if record and record.kind == "pong" then pong = record end
    if record and record.kind == "note" then note = record end
  end
  if check(pong ~= nil, "ping answered") then
    eq(pong.tiles, Map.count(), "the pong carries the tile count")
  end
  if check(note ~= nil, "note recorded") then
    eq(note.text, "moved the cubes by hand", "the note text survived")
  end
  onExternalMessage("not a table") -- must not throw
end)

-- --------------------------------------------------------------- the surface

case("AZ.state and AZ.kinds return one printable line each", function()
  boot(nil)
  local state = AZ.state()
  check(type(state) == "string", "state is a string")
  check(state:find("seed=", 1, true) ~= nil, "state names the seed")
  check(state:find("tiles=", 1, true) ~= nil, "state names the tile count")
  check(not state:find("\n", 1, true), "state is one line")
  check(AZ.kinds():find("jungle", 1, true) ~= nil, "kinds names a kind")
  check(AZ.help():find("AZ.tint", 1, true) ~= nil, "help names a verb")
end)

case("AZ.lock takes a string from a command line", function()
  boot(nil)
  AZ.lock("false")
  for _, obj in ipairs(Tiles.onMap()) do
    eq(obj.getLock(), false, "'false' unlocked them")
  end
  AZ.lock("true")
  for _, obj in ipairs(Tiles.onMap()) do
    eq(obj.getLock(), true, "'true' locked them again")
  end
end)

case("AZ.rings resizes the map and rewrites the snap points", function()
  local plate = boot(nil)
  local before = Map.count()
  AZ.rings(1)
  H.tick(80)
  check(Map.count() < before, "a smaller map has fewer tiles")
  eq(Map.count(), #Map.slots(), "tiles still match slots")
  eq(#plate.getSnapPoints(), #Map.lattice(), "the snap points followed the resize")

  AZ.snap(false)
  AZ.rings(2)
  H.tick(80)
  eq(#plate.getSnapPoints(), 0, "with the lattice off, resizing writes none")
  AZ.snap(true)
  eq(AZ.rings(99), false, "an absurd ring count is refused")
end)

case("AZ.weight retires a kind from the draw without deleting it", function()
  boot(nil)
  AZ.weight("river", 0)
  AZ.weight("deep_jungle", 0)
  AZ.weight("clearing", 0)
  Map.build(3)
  H.tick(80)
  for _, obj in ipairs(Tiles.onMap()) do
    eq(Tiles.kindOf(obj), "jungle", "only the weighted kind was drawn")
  end
  check(ART.kinds["river"] ~= nil, "the retired kind is still in the catalogue")
end)

case("the draw is filtered to the map's own shape", function()
  -- The lattice is packed for one shape. A kind with a different footprint
  -- would leave bare hexes inside its own slot, so it must not be drawn — even
  -- though it stays in the catalogue for AZ.shape() to use.
  boot(nil)
  eq(MAP.shape, "trihex", "the default map is tri-hexes")
  for _, obj in ipairs(Tiles.onMap()) do
    eq(ART.kinds[Tiles.kindOf(obj)].shape, "trihex",
      "every drawn kind has the map's shape")
  end
  local pool = {}
  for _, entry in ipairs(Tiles.pool("trihex")) do pool[entry[2]] = true end
  check(pool["clearing"] == nil, "a hex1 kind is out of a trihex draw")
  check(pool["jungle"] ~= nil, "a trihex kind is in it")
  check(Tiles.pool("hex1")[1] ~= nil, "the hex1 kind is still in the catalogue")
end)

case("AZ.shape relays the whole map in another shape", function()
  boot(nil)
  local before = Map.count()
  eq(AZ.shape("nonesuch"), false, "an unknown shape is refused")
  AZ.shape("hex1")
  H.tick(80)
  eq(MAP.shape, "hex1", "the map's shape changed")
  eq(Map.count(), #Map.slots(), "tiles match the new lattice")
  check(Map.count() ~= before, "a one-hex lattice is not the tri-hex one")
  for _, obj in ipairs(Tiles.onMap()) do
    eq(Tiles.kindOf(obj), "clearing", "only hex1 kinds were drawn")
  end
  -- Every hex of the disc is covered exactly once by a one-cell tile.
  local covered = 0
  for _ in pairs(Map.cells()) do covered = covered + 1 end
  eq(covered, Map.count(), "one hex per tile")
end)

case("AZ.at names the kind covering a hex, or 'empty'", function()
  boot(nil)
  local key, kind = nil, nil
  for k, cell in pairs(Map.cells()) do key, kind = k, cell.kind break end
  local q, r = key:match("(-?%d+),(-?%d+)")
  eq(AZ.at(tonumber(q), tonumber(r)), kind, "a covered hex names its kind")
  eq(AZ.at(40, 40), "empty", "a hex off the map is empty")
end)

case("AZ.capture prints a table that names every tile", function()
  boot(nil)
  local text = AZ.capture()
  check(type(text) == "string", "capture returns text")
  local rows = select(2, text:gsub("\n", "\n")) - 1
  eq(rows, Map.count(), "one row per tile")
end)

-- --------------------------------------------------------------------- tray

case("the tray lays out one of every tray kind, unlocked, beside the plate", function()
  boot(nil)
  local wanted = Tray.kinds()
  check(#wanted > 0, "the spec declares tray kinds (" .. #wanted .. ")")
  eq(Tray.count(), #wanted, "one tile per tray kind")

  local seen = {}
  for _, obj in ipairs(Tiles.inTray()) do
    local kind = Tiles.kindOf(obj)
    check(kind ~= nil, "a tray tile knows its kind")
    check(seen[kind] == nil, "one of each: " .. tostring(kind))
    seen[kind] = true
    check(obj.hasTag("tile"), "a tray tile is still a tile")
    check(obj.hasTag(TRAY.tag), "and carries the tray tag")
    eq(obj.getLock(), false, "unlocked — the point is to pick it up")
    check(obj.getPosition().x > 10, "it sits east of the 20-wide plate")
  end
  for _, name in ipairs(wanted) do
    check(seen[name], name .. " is in the tray")
  end
end)

case("one plate carries the map and the tray both", function()
  -- The table is Table_None in a fresh build, so a plate is the only floor
  -- there is: anything off it falls out of the world. It used to be two plates
  -- butted together, which meant a seam to keep closed and two tops to keep
  -- level; it is one now, sized from MAP.plate.
  local plate = boot(nil)
  eq(#getObjectsWithTag(TRAY.plateTag), 0, "the tray brings no plate of its own")

  local basis = ttslib.layout.basis()
  near(basis.x, MAP.plate.x, "the plate is as wide as the rig says")
  near(basis.z, MAP.plate.z, "and as deep")

  -- Half-extents are scale TIMES MESH: this is a BlockRectangle, so its Z
  -- scale is half its depth — the trap that stretched the map on 2026-09-21.
  local halfX = plate.getScale().x * plate.mesh.x / 2
  local halfZ = plate.getScale().z * plate.mesh.z / 2
  near(halfX * 2, MAP.plate.x, "scale times mesh is the width")

  local origin = plate.getPosition()
  for _, obj in ipairs(Tiles.all()) do
    local p = obj.getPosition()
    check(math.abs(p.x - origin.x) < halfX,
      "tile " .. tostring(obj.getGMNotes()) .. " is over the plate in x")
    check(math.abs(p.z - origin.z) < halfZ,
      "tile " .. tostring(obj.getGMNotes()) .. " is over the plate in z")
  end
end)

case("a save made when the tray had its own plate cleans itself up", function()
  boot(nil)
  -- Stand in for the legacy object: tagged, locked, sitting proud of the big
  -- plate. Tray.sync is what is expected to notice it.
  local legacy = H.object({
    spawn = false, tags = { TRAY.plateTag }, name = "Amazonia Tray",
    position = { x = 18.2, y = 1, z = 0 },
  })
  H.spawn(legacy)
  ttslib.registry.invalidate()
  eq(#getObjectsWithTag(TRAY.plateTag), 1, "the legacy plate is on the table")

  Tray.sync()
  H.tick(30)
  eq(#getObjectsWithTag(TRAY.plateTag), 0, "and sync destroyed it")
end)

case("tray sync spawns what is missing and leaves the rest where it is", function()
  boot(nil)
  local before = Tray.count()
  check(before > 0, "the palette is out")

  -- The owner curates this by hand: he deletes the kinds he is not using and
  -- drags the rest into rows. A push reloads the save, so boot must converge on
  -- the spec without relaying the grid — sync, not build.
  local victim, moved
  for _, obj in ipairs(Tiles.inTray()) do
    if not victim then
      victim = Tiles.kindOf(obj)
      destroyObject(obj)
    elseif not moved then
      moved = obj
      obj.setPosition({ x = -20, y = 1.15, z = 8 })
    end
  end
  H.tick(30)
  eq(Tray.count(), before - 1, "one gone")

  local added, orphans = Tray.sync()
  H.tick(30)
  eq(added, 1, "sync spawned exactly the missing one")
  eq(orphans, 0, "and destroyed nothing")
  eq(Tray.count(), before, "the palette is whole again")

  local back = false
  for _, obj in ipairs(Tiles.inTray()) do
    if Tiles.kindOf(obj) == victim then back = true end
  end
  check(back, "the missing kind is the one that came back")

  local p = moved.getPosition()
  near(p.x, -20, "a tile the owner moved stayed where he put it")
  near(p.z, 8, "in z too")
end)

case("tray sync destroys a tile whose kind the spec no longer has", function()
  boot(nil)
  local before = Tray.count()
  local ghost = Tiles.inTray()[1]
  ghost.setGMNotes("a_kind_that_was_deleted")
  ttslib.registry.invalidate()

  -- Left alone this poisons the next load: Tiles.hubs walks every tile on a
  -- reload and used to index ART.kinds[name] straight into nil, stopping onLoad
  -- after the tiles were restored but before the tray and the HUD.
  eq(Tiles.hubs(ghost), false, "hubs declines an unknown kind rather than throwing")

  local added, orphans = Tray.sync()
  H.tick(30)
  eq(orphans, 1, "sync destroyed the orphan")
  eq(added, 1, "and put the real kind back")
  eq(Tray.count(), before, "the palette is the size the spec says")
end)

case("the tray is not the map: a reroll leaves it alone", function()
  boot(nil)
  local trayed, mapped = Tray.count(), Map.count()
  check(trayed > 0 and mapped > 0, "both are on the table")

  eq(#Tiles.all(), trayed + mapped, "the table holds both sets")
  AZ.reroll()
  H.tick(80)
  eq(Tray.count(), trayed, "the palette survived a reroll")
  eq(Map.count(), mapped, "and the map was rebuilt to the same size")

  AZ.clear()
  H.tick(30)
  eq(Map.count(), 0, "clear emptied the map")
  eq(Tray.count(), trayed, "and still left the palette")
end)

case("a frontier kind is painted, out of the draw, and tinted white", function()
  boot(nil)
  local painted = 0
  for _, name in ipairs(Tray.kinds()) do
    local kind = ART.kinds[name]
    eq(kind.weight, 0, name .. " is out of the random draw")
    -- Its colour is baked into the diffuse, so ColorDiffuse must not tint it a
    -- second time. tilegen refuses `paint` plus `tint`; this is the far end of
    -- that guarantee, in the table the game actually reads.
    near(kind.tint[1], 1, name .. " tint r")
    near(kind.tint[2], 1, name .. " tint g")
    near(kind.tint[3], 1, name .. " tint b")
    painted = painted + 1
  end
  -- 16 since 2026-09-21: the owner retired six from the palette (tray:false
  -- in spec/tiles.json) rather than deleting the kinds, so they stay
  -- available to AZ.put and out of the tray.
  eq(painted, 16, "the whole frontier set is there")

  for _, entry in ipairs(Tiles.pool(MAP.shape)) do
    check(not ART.kinds[entry[2]].tray,
      "no tray kind turns up in the draw: " .. entry[2])
  end
end)

case("AZ.tray syncs, clears, and rebuilds only when asked", function()
  boot(nil)
  local n = Tray.count()
  eq(AZ.tray(false), n, "clearing reports what it removed")
  H.tick(30)
  eq(Tray.count(), 0, "the palette is gone")

  -- No argument is a sync, which on an empty table spawns the lot.
  AZ.tray()
  H.tick(30)
  eq(Tray.count(), n, "one of each again")

  -- "rebuild" is the destructive one, and has to be asked for by name so that a
  -- bare AZ.tray() can never throw away a hand arrangement.
  local mover = Tiles.inTray()[1]
  mover.setPosition({ x = -22, y = 1.15, z = -6 })
  AZ.tray()
  H.tick(30)
  near(mover.getPosition().x, -22, "a sync leaves a moved tile alone")

  AZ.tray("rebuild")
  H.tick(80)
  eq(Tray.count(), n, "a rebuild still lays out one of each")
end)

case("a reskin keeps a tray tile in the tray", function()
  -- reskin respawns, and a respawn that forgot the tray tag would quietly move
  -- the palette onto the map, where the next reroll would destroy it.
  boot(nil)
  local name = Tray.kinds()[1]
  local before = Tray.count()
  Tiles.reskin(name, "file:///tmp/other.png")
  H.tick(20)
  eq(Tray.count(), before, "still in the tray after a reskin")
  for _, obj in ipairs(Tiles.ofKind(name)) do
    check(obj.hasTag(TRAY.tag), "the tag came through the respawn")
  end
end)

case("AZ.put drops a named tile on a cell, replacing what covered it", function()
  boot(nil)
  local before = Map.count()
  local was = AZ.at(0, 0)
  check(was ~= "empty", "something covers the origin to start with")

  local said = AZ.put("coast_f_n", 0, 0, 2)
  H.tick(20)
  check(type(said) == "string" and said:find("coast_f_n", 1, true) ~= nil,
    "put reports what it did: " .. tostring(said))
  eq(AZ.at(0, 0), "coast_f_n", "the named kind is on the cell now")
  eq(Map.count(), before, "one tile replaced one tile")

  -- ofKind covers the tray copy too, which is the one sitting out at x = 27.7.
  local placed = Tiles.onMap(Tiles.ofKind("coast_f_n"))
  check(#placed > 0, "the tile exists")
  local x, z = hex.toWorld(0, 0, ART.radius)
  near(placed[1].getPosition().x, x, "put x")
  near(placed[1].getPosition().z, z, "put z")
  near(placed[1].getRotation().y, 120, "put rot (2 steps of 60)")
  check(not placed[1].hasTag(TRAY.tag), "a placed tile is map, not tray")
  eq(AZ.put("nonesuch", 0, 0), false, "an unknown kind is refused")
end)

local function dividers()
  return ttslib.registry.all(TRAY.divider.tag)
end

case("a line on the floor separates the map from the palette", function()
  local plate = boot(nil)
  local bar = dividers()
  eq(#bar, 1, "exactly one divider")

  -- In the clear gap: east of everything the map can reach, west of the
  -- palette's first column. Both ends are measured, not assumed.
  local at = bar[1].getPosition()
  local eastmost = 0
  for _, obj in ipairs(Tiles.onMap()) do
    eastmost = math.max(eastmost, obj.getPosition().x + ART.radius * 0.8661)
  end
  check(at.x > eastmost,
    string.format("clear of the map (%.2f > %.2f)", at.x, eastmost))
  check(at.x < TRAY.origin.x - ART.radius * math.sqrt(3),
    "clear of the palette's west column")

  -- Under a tile's top face, so a tile laid over it hides it rather than
  -- being pierced by it.
  -- A tile is ART.thickness * 2 tall in the mesh and scaled TILES.scaleY, so
  -- its top face is half of that above the height it floats at.
  local plateTop = plate.getPosition().y + 0.1
  local tileTop = plate.getPosition().y + MAP.tileY + ART.thickness * TILES.scaleY
  check(at.y + TRAY.divider.height / 2 <= tileTop,
    string.format("under a tile's top face (%.3f <= %.3f)",
      at.y + TRAY.divider.height / 2, tileTop))
  check(at.y - TRAY.divider.height / 2 >= plateTop - 0.001,
    "and not sunk into the plate")

  check(bar[1].getLock(), "locked: it is furniture")

  -- Live, like every other L1 tweak.
  AZ.divider(8.0)
  H.tick(20)
  bar = dividers()
  eq(#bar, 1, "moving it does not leave the old one behind")
  near(bar[1].getPosition().x, 8.0, "moved to where it was asked for")

  AZ.divider(false)
  H.tick(20)
  eq(#dividers(), 0, "and it can be turned off")
  TRAY.divider.enabled = true
end)

-- --------------------------------------------------------------------- rubber

-- The owner's own cube, read out of the running game on 2026-09-22 (GUID
-- 7bfd32) and the only thing tying RUBBER.inset to the table rather than to
-- arithmetic: a white BlockSquare he put on the NE hexside of the top-right
-- cell of a glade_mix_a sitting at (5.9422, 1.1833, -4.3721) with rotY 0.
local SAMPLE = { dx = 1.2679, dy = 0.1720, dz = 2.0279, cell = 3, dir = 6 }

-- distance from a cube to the nearest of its tile's three cell centres.
local function toNearestCell(obj, cube)
  local kind = ART.kinds[Tiles.kindOf(obj)]
  local shape = ART.shapes[kind.shape]
  local at, best = cube.getPosition(), 1e9
  for _, cell in ipairs(shape.cells) do
    local x, z = hex.toWorld(cell[1], cell[2], ART.radius)
    local centre = obj.positionToWorld({ x = x, y = 0, z = z })
    local dx, dz = at.x - centre.x, at.z - centre.z
    best = math.min(best, math.sqrt(dx * dx + dz * dz))
  end
  return best
end

case("deep forest hexsides come from the catalogue, not from the art", function()
  boot(nil)
  -- The owner counted these by eye: "the Glades 2/3/4 triplet would have 9 DF
  -- hexsides". tilegen writes them into art/index.lua from the same `paint`
  -- block it draws the diffuse from, so the cubes and the pixels cannot drift.
  local sides = Rubber.sides("glade_mix_a")
  eq(#sides, 9, "glade_mix_a has nine deep forest hexsides")

  local perCell = { 0, 0, 0 }
  for _, side in ipairs(sides) do
    perCell[side.cell] = perCell[side.cell] + 1
  end
  eq(perCell[1], 2, "pivot: two walls")
  eq(perCell[2], 3, "top-left: three")
  eq(perCell[3], 4, "top-right: four — 2/3/4, which is what the kind is called")

  eq(#Rubber.sides("glade_4"), 12, "the sealed glade is walled all round")
  eq(#Rubber.sides("coast_df_n"), 4, "a deep forest coast walls two cells")

  -- The narrow rule the owner chose: a *painted* deep forest edge, not every
  -- hexside whose terrain happens to be deep forest. A plain deep_jungle
  -- triplet is deep forest all over and still earns nothing.
  eq(#Rubber.sides("deep_jungle"), 0, "a plain deep forest triplet: none")
  eq(#Rubber.sides("jungle"), 0, "a plain forest triplet: none")
  eq(#Rubber.sides("river_run_df"), 0, "deep forest cells, but no painted edge")
  eq(#Rubber.sides("nonesuch"), 0, "an unknown kind does not throw")
end)

case("a cube sits in the middle of the deep forest band, not on the edge", function()
  boot(nil)
  local shape = ART.shapes.trihex
  local x, z = Rubber.offset(shape, SAMPLE.cell, SAMPLE.dir)

  -- Against the owner's sample. He placed it by hand, so this is a tolerance
  -- rather than an equality — the point is that 0.66 is his 0.66 and not a
  -- number someone liked the look of.
  check(math.sqrt((x - SAMPLE.dx) ^ 2 + (z - SAMPLE.dz) ^ 2) < 0.1,
    string.format("within a hand's width of the sample (got %.3f,%.3f, "
      .. "want %.3f,%.3f)", x, z, SAMPLE.dx, SAMPLE.dz))
  check(math.abs(RUBBER.y - SAMPLE.dy) < 0.05,
    string.format("cube height matches the sample (%.3f vs %.3f)",
      RUBBER.y, SAMPLE.dy))

  -- And the geometry it is meant to express: inset along the edge normal,
  -- inside the cell rather than on its rim.
  local cx, cz = hex.toWorld(shape.cells[SAMPLE.cell][1],
    shape.cells[SAMPLE.cell][2], ART.radius)
  near(math.sqrt((x - cx) ^ 2 + (z - cz) ^ 2), RUBBER.inset,
    "inset from the cell centre")
  local apothem = ART.radius * math.sqrt(3) / 2
  check(RUBBER.inset < apothem, "inside the cell, not on the hexside")
  check(RUBBER.inset > apothem - 0.44, "inside the deep forest band, which "
    .. "reaches 0.44 in from the rim")
end)

case("a plain map brings no rubber; placing a glade brings nine", function()
  boot(nil)
  -- jungle, deep_jungle and river are the only kinds with a weight, and none
  -- of them paints a wall. A fresh table is clean.
  eq(Rubber.count(), 0, "nothing on a plain map")

  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 9, "the glade brought its nine")

  -- Every cube belongs to a hexside of the tile that spawned it.
  local tile = Tiles.onMap(Tiles.ofKind("glade_mix_a"))[1]
  check(tile ~= nil, "the glade is on the map")
  for _, cube in ipairs(Rubber.all()) do
    eq(cube.getName(), RUBBER.name, "called Rubber")
    check(cube.hasTag(RUBBER.tag), "tagged rubber")
    check(not cube.getLock(), "unlocked — these get moved")
    near(toNearestCell(tile, cube), RUBBER.inset, "inset from its own cell")
  end
end)

case("rubber turns with the tile", function()
  boot(nil)
  -- Two steps of 60 degrees. positionToWorld carries the rotation, so the
  -- invariant is the same at any angle: every cube is one inset from a cell
  -- centre of the tile it belongs to.
  AZ.put("glade_mix_a", 0, 0, 2)
  H.tick(30)
  local tile = Tiles.onMap(Tiles.ofKind("glade_mix_a"))[1]
  near(tile.getRotation().y, 120, "the tile really is turned")
  eq(Rubber.count(), 9, "nine cubes at 120 degrees too")
  for _, cube in ipairs(Rubber.all()) do
    near(toNearestCell(tile, cube), RUBBER.inset, "inset survives the rotation")
  end
end)

case("spawn only: moving a tile grows nothing back", function()
  boot(nil)
  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  local before = Rubber.count()
  local tile = Tiles.onMap(Tiles.ofKind("glade_mix_a"))[1]

  -- The whole point of the feature being spawn-only: the owner rearranges the
  -- table by hand and nothing is watching.
  tile.setPosition({ x = -8, y = 1.15, z = 6 })
  tile.setRotation({ x = 0, y = 240, z = 0 })
  H.tick(40)
  eq(Rubber.count(), before, "no cubes appeared under the moved tile")

  local cube = Rubber.all()[1]
  cube.setPosition({ x = 14, y = 1.4, z = 14 })
  H.tick(40)
  eq(Rubber.count(), before, "moving a cube does not replace it")

  destroyObject(cube)
  H.tick(40)
  eq(Rubber.count(), before - 1, "a cube taken off the table stays off")
end)

case("a reload does not respawn rubber the save already carries", function()
  boot(nil)
  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 9, "nine before the reload")

  -- TTS saves spawned objects, so a real reload comes back with tiles *and*
  -- cubes. Carrying only the tiles is the harsher test: if onLoad spawned
  -- rubber for what it restored, this would come back with nine.
  local carried = {}
  for _, obj in ipairs(Tiles.all()) do carried[#carried + 1] = obj end
  boot(onSave(), { carry = carried })
  eq(Rubber.count(), 0, "the restore path spawns none of its own")
  check(Map.count() > 0, "the tiles did come back")
end)

case("a reskin does not double the cubes", function()
  boot(nil)
  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  local before = Rubber.count()

  -- reskin destroys and respawns the tile in place. Its cubes never moved, so
  -- a second set would sit exactly on top of the first and nothing would look
  -- wrong until you picked one up.
  Tiles.reskin("glade_mix_a", "file:///tmp/other.png")
  H.tick(40)
  eq(Rubber.count(), before, "still nine after a reskin")
end)

case("clearing and rerolling the map take its rubber with them", function()
  boot(nil)
  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  check(Rubber.count() > 0, "there is rubber to lose")

  Map.reroll(7)
  H.tick(80)
  eq(Rubber.count(), 0, "a reroll does not leave cubes floating over the new map")

  AZ.put("glade_4", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 12, "the sealed glade brought twelve")
  AZ.clear()
  H.tick(40)
  eq(Rubber.count(), 0, "clear takes them too")
end)

case("putting a tile over another takes the replaced tile's rubber", function()
  boot(nil)
  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 9, "nine on the glade")

  -- Rubber.clearNear finds them by position — a cube carries no tile GUID,
  -- because a GUID changes the moment the tile is picked up.
  AZ.put("jungle", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 0, "the glade's cubes went with the glade")

  -- And it claims only its own: a glade next door keeps all nine.
  AZ.put("glade_mix_a", 3, 0)
  H.tick(30)
  eq(Rubber.count(), 9, "the neighbour is untouched")
  AZ.put("jungle", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 9, "replacing a tile 1.7 away took none of them")
end)

-- drag(obj, x, z) — the owner picking a tile up and putting it down somewhere.
-- The debounce on the drop tap is 1.25s, so the ticks have to cover it.
local function drag(obj, x, z)
  onObjectPickUp("White", obj)
  H.tick(5)
  local at = obj.getPosition()
  obj.setPosition({ x = x, y = at.y, z = z })
  onObjectDrop("White", obj)
  H.tick(80)
end

case("a tile dragged across the line brings its rubber", function()
  boot(nil)
  eq(Rubber.count(), 0, "a plain map starts clean")

  -- The owner's actual workflow: a glade sitting in the palette, dragged onto
  -- the map by hand. Nothing spawns it, so only the drop can notice.
  local glade = Tiles.ofKind("glade_mix_a")[1]
  check(glade ~= nil, "the palette holds a glade")
  check(not Rubber.onMapSide(glade), "and it starts east of the line")
  eq(Rubber.count(), 0, "with no cubes")

  drag(glade, -4, 6)
  check(Rubber.onMapSide(glade), "it is west of the line now")
  eq(Rubber.count(), 9, "nine cubes appeared on the drop")
  for _, cube in ipairs(Rubber.all()) do
    near(toNearestCell(glade, cube), RUBBER.inset, "placed on its hexsides")
  end

  -- Back to the palette: the cubes come off rather than staying behind on the
  -- hex it vacated.
  drag(glade, TRAY.origin.x, TRAY.origin.z)
  check(not Rubber.onMapSide(glade), "east of the line again")
  eq(Rubber.count(), 0, "and the cubes went with it")
end)

case("moving a tile inside the map carries its cubes, without doubling", function()
  boot(nil)
  local glade = Tiles.ofKind("glade_4")[1]
  drag(glade, -4, 6)
  eq(Rubber.count(), 12, "the sealed glade brought twelve")

  -- Twice more, well inside the map. Each move has to take the old set off and
  -- put one new set on: leaving them behind litters the vacated hex, and not
  -- clearing first doubles the count every drag.
  drag(glade, 0, -6)
  eq(Rubber.count(), 12, "still twelve after moving it")
  drag(glade, 3, 3)
  eq(Rubber.count(), 12, "and after moving it again")
  for _, cube in ipairs(Rubber.all()) do
    near(toNearestCell(glade, cube), RUBBER.inset, "all of them came along")
  end
end)

case("a pasted copy gets rubber on the drop it never was picked up for", function()
  boot(nil)
  -- ctrl+c / ctrl+v: the copy appears already held, so TTS fires a drop with
  -- no pickUp in front of it. Rubber.land clears before it spawns for exactly
  -- this case — otherwise a paste onto the map could end up double-stacked.
  local original = Tiles.ofKind("glade_mix_a")[1]
  local copy = H.object({
    tags = { "tile", "tile.glade_mix_a", TRAY.tag },
    name = "Glades — 2/3/4", position = { x = -6, y = 1.15, z = -3 },
    rotation = { x = 0, y = 0, z = 0 },
  })
  augment(copy, { GMNotes = "glade_mix_a" })
  ttslib.registry.invalidate()
  H.tick(5)

  onObjectDrop("White", copy)
  H.tick(80)
  eq(Rubber.count(), 9, "the copy got its nine")
  check(original ~= nil, "the original is still in the palette")
  for _, cube in ipairs(Rubber.all()) do
    near(toNearestCell(copy, cube), RUBBER.inset, "on the copy's hexsides")
  end
end)

case("a cube moved by hand is never replaced", function()
  boot(nil)
  local glade = Tiles.ofKind("glade_mix_a")[1]
  drag(glade, -4, 6)
  eq(Rubber.count(), 9, "nine to start")

  -- The owner's original condition, and it still holds: the taps are on the
  -- *tile*. Picking a cube up, dropping it elsewhere or deleting it is his
  -- business and nothing grows back.
  local cube = Rubber.all()[1]
  onObjectPickUp("White", cube)
  H.tick(5)
  cube.setPosition({ x = 12, y = 1.4, z = 12 })
  onObjectDrop("White", cube)
  H.tick(80)
  eq(Rubber.count(), 9, "moving a cube spawns nothing")

  destroyObject(cube)
  H.tick(40)
  eq(Rubber.count(), 8, "and one taken off the table stays off")
end)

case("with the toggle off, dragging a tile changes nothing", function()
  boot(nil)
  local glade = Tiles.ofKind("glade_mix_a")[1]
  drag(glade, -4, 6)
  eq(Rubber.count(), 9, "nine while it is on")

  AZ.rubber(false)
  drag(glade, 0, -6)
  eq(Rubber.count(), 9, "the cubes are left exactly where they were")

  AZ.rubber(true)
  TRAY.divider.enabled = true
end)

case("the rubber bag is spawned once and survives a reload", function()
  boot(nil)
  local bags = ttslib.registry.all(RUBBER.bagTag)
  eq(#bags, 1, "one supply bag")
  eq(bags[1].getName(), RUBBER.name, "called Rubber")

  -- Beside the creek and road bags, which sit at x = 1.6 and 3.6 on z = 10.6.
  local at = bags[1].getPosition()
  near(at.x, RUBBER.bag.x, "on the free side of the creek bag")
  near(at.z, RUBBER.bag.z, "on the same row")

  -- The bag is not itself rubber: clearing the map's cubes must not destroy
  -- the supply they would be replaced from.
  check(not bags[1].hasTag(RUBBER.tag), "the bag is not tagged rubber")
  check(not bags[1].hasTag(RUBBER.mapTag), "nor rubber.map")
  Rubber.clear()
  H.tick(20)
  eq(#ttslib.registry.all(RUBBER.bagTag), 1, "still there after a clear")

  -- A reload finds it by tag rather than spawning a second one, which is what
  -- makes it safe to call from onLoad every time.
  local carried = { bags[1] }
  for _, obj in ipairs(Tiles.all()) do carried[#carried + 1] = obj end
  boot(onSave(), { carry = carried })
  eq(#ttslib.registry.all(RUBBER.bagTag), 1, "one bag after a reload, not two")
end)

case("the tray is a palette and gets no rubber", function()
  boot(nil)
  -- The tray holds glades — glade_mix_a among them — and they paint the same
  -- walls. RUBBER.tray is off because a tile dragged off the tray would leave
  -- its cubes sitting on the empty slot.
  local glades = 0
  for _, name in ipairs(Tray.kinds()) do
    if #Rubber.sides(name) > 0 then glades = glades + 1 end
  end
  check(glades > 0, "the tray does hold walled kinds (" .. glades .. ")")
  eq(Rubber.count(), 0, "and none of them carries a cube")
end)

case("the toggle governs the next tile; apply covers the ones already out", function()
  boot(nil)
  AZ.rubber(false)
  eq(RUBBER.enabled, false, "off")
  AZ.put("glade_mix_a", 0, 0)
  H.tick(30)
  eq(Rubber.count(), 0, "a tile spawned while it is off brings nothing")

  -- Switching it back on is spawn-only too, so the table does not change.
  AZ.rubber(true)
  eq(RUBBER.enabled, true, "on")
  eq(Rubber.count(), 0, "the toggle alone changes nothing already on the table")

  -- Which is what apply is for, and it has to be idempotent: run twice, nine.
  AZ.rubber("apply")
  H.tick(80)
  eq(Rubber.count(), 9, "apply covered the glade that was already out")
  AZ.rubber("apply")
  H.tick(80)
  eq(Rubber.count(), 9, "apply again does not stack a second set")

  AZ.rubber("clear")
  H.tick(40)
  eq(Rubber.count(), 0, "clear empties it")
  check(AZ.rubber():find("rubber on", 1, true) ~= nil,
    "no argument reports: " .. tostring(AZ.rubber()))
end)

-- ------------------------------------------------------------------- runner

out("boot_spec")
for _, entry in ipairs(cases) do
  currentCase = entry.name
  local ok, err = pcall(entry.fn)
  if not ok then
    failures = failures + 1
    out(string.format("  ERROR %s: %s", entry.name, tostring(err)))
  end
end
out(string.format("%d cases, %d checks, %d failures", #cases, checks, failures))
os.exit(failures == 0 and 0 or 1)
