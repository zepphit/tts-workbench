-- src/30-map.lua — lay the tiles out, clear them, capture them.
--
-- The lattice and the draw are separate on purpose:
--
--   the lattice  hex.pack over a disc, deterministic. Rerolling does not move
--                it, so the table keeps its shape and only the terrain changes.
--   the draw     hex.rng(seed) over the weighted pool. This is the re-rollable
--                half, and it is one number.
--
-- Positions go through ttslib.layout, not arithmetic: every slot is registered
-- as a named space in the anchor's local coordinates, so dragging or rescaling
-- the anchor plate in TTS moves the whole map with it and a rebuild lands where
-- the anchor now is (critique C2).  The division by the anchor's scale is the
-- only place world units and anchor-local units meet.

local LOG = ttslib.log
local ASYNC = ttslib.async
local REG = ttslib.registry
local LAYOUT = ttslib.layout

Map = {}

local slots = nil -- { { q, r, rot, space } }, rebuilt when rings change
local slotRings = nil
local lattice = nil -- { { q, r, rot } } — the bigger snap field, see Map.lattice
local latticeKey = nil

-- ------------------------------------------------------------------- lattice

-- slots() — the packed lattice, as named layout spaces.  Cached until the ring
-- count changes, because packing rings=6 is a few hundred table lookups and
-- this is called on every build.
function Map.slots()
  if slots and slotRings == MAP.rings then return slots end

  local shape = ART.shapes[MAP.shape]
  if not shape then
    LOG.error("MAP.shape is '" .. tostring(MAP.shape) ..
      "', which art/index.lua does not define")
    return {}
  end

  local anchor = LAYOUT.anchorObject()
  if not anchor then return {} end

  local placements, holes = hex.pack(shape.cells, MAP.rings,
    { overflow = MAP.overflow })

  slots = {}
  local spaces = {}
  for index, placement in ipairs(placements) do
    local q, r, rot = placement[1], placement[2], placement[3]
    local x, z = hex.toWorld(q, r, ART.radius)
    local space = "slot" .. index
    -- World offsets in anchor-local units: layout multiplies them back through
    -- positionToWorld, so this survives the plate being moved or resized.
    --
    -- Through layout.localOffset, **not** by dividing by getScale().  Local
    -- space is the mesh's space and BlockRectangle's mesh is 1 x 1 x 2, so the
    -- anchor plate is 34 deep at scaleZ 17 and a division by the scale comes
    -- out half what it should on Z alone. That shipped: until 2026-09-21 every
    -- row of this map was twice as far apart as hex.toWorld says and no two
    -- tri-hexes ever met along an edge.
    spaces[space] = LAYOUT.localOffset({ x = x, y = MAP.tileY, z = z })
    slots[index] = { q = q, r = r, rot = rot, space = space }
  end
  LAYOUT.spaces(spaces)
  slotRings = MAP.rings

  LOG.info("lattice: " .. #slots .. " tile slots over " .. MAP.rings ..
    " rings" .. (#holes > 0 and (", " .. #holes .. " uncovered cells") or ""))
  return slots
end

function Map.invalidate()
  slots, slotRings = nil, nil
  lattice, latticeKey = nil, nil
end

-- ------------------------------------------------------------- the snap field
--
-- latticeRings() — how far the snap field has to reach to cover the plate.
--
-- Derived from the anchor's *measured* size rather than a constant, so
-- resizing the plate re-derives it and there is no number here to go stale.
-- hex.toWorld steps sqrt(3) in x and 1.5 in z per ring, so a half-extent
-- divided by those is the ring count that reaches it; +1 covers the corner.
local function latticeRings()
  if (MAP.snapRings or 0) > 0 then
    return math.min(MAP.snapRings, MAP.snapMaxRings)
  end
  local basis = LAYOUT.basis()
  if not basis then return MAP.rings end
  local byX = (basis.x / 2) / (ART.radius * 1.7321)
  local byZ = (basis.z / 2) / (ART.radius * 1.5)
  return math.max(MAP.rings,
    math.min(MAP.snapMaxRings, math.ceil(math.max(byX, byZ)) + 1))
end

-- lattice() — every position on the plate a tri-hex can be dropped into.
--
-- This is the *snap* field, and it is deliberately much larger than
-- Map.slots(), which is only the disc the random map is drawn over.  They were
-- the same set until 2026-09-21, and that is the whole of the bug the owner
-- reported: with one snap point per map slot and every slot already filled, the
-- only snappable positions on the table were underneath tiles, so a tile
-- dragged off the tray had nowhere to land and looked like it was ignoring the
-- lattice.  A drop probe measured it — a tile let go 0.00 from a point snapped,
-- one let go 4.77 away did not.
--
-- **The map's own slots must come out as an exact prefix of this**, or every
-- tile already on the table stops interlocking.  hex.pack is greedy, so the
-- walk order *is* the tiling: hex.disc sorts by r then q, which puts disc(18)'s
-- first cell in a different corner from disc(3)'s and yields a tiling offset
-- from it.  Walking the map's own disc first, in its own order, and only then
-- the rest of the big one, makes the small packing a prefix by construction.
-- test/hex_spec.lua asserts it.
function Map.lattice()
  local rings = latticeRings()
  local key = MAP.shape .. "|" .. MAP.rings .. "|" .. rings
  if lattice and latticeKey == key then return lattice end

  local shape = ART.shapes[MAP.shape]
  if not shape then return {} end
  local basis = LAYOUT.basis()
  if not basis then return {} end

  local order, seen = {}, {}
  for _, cell in ipairs(hex.disc(MAP.rings)) do
    order[#order + 1] = cell
    seen[hex.key(cell[1], cell[2])] = true
  end
  for _, cell in ipairs(hex.disc(rings)) do
    if not seen[hex.key(cell[1], cell[2])] then order[#order + 1] = cell end
  end

  local placements = hex.pack(shape.cells, rings,
    { overflow = MAP.overflow, order = order })

  -- Keep the placements that sit wholly on the plate.  A pointy-top hex is
  -- sqrt(3)R across the flats and 2R corner to corner, so a cell centre needs
  -- 0.866R of x and 1R of z to spare.  Snap points past the rim would pull a
  -- tile off the edge of the world — the table is Table_None and this plate is
  -- the floor.
  local halfX, halfZ = basis.x / 2, basis.z / 2
  local apothem, radius = ART.radius * 0.8661, ART.radius

  lattice = {}
  for _, placement in ipairs(placements) do
    local fits = true
    for _, cell in ipairs(hex.footprint(shape.cells,
      placement[1], placement[2], placement[3])) do
      local x, z = hex.toWorld(cell[1], cell[2], ART.radius)
      if math.abs(x) + apothem > halfX or math.abs(z) + radius > halfZ then
        fits = false
        break
      end
    end
    if fits then
      lattice[#lattice + 1] =
        { q = placement[1], r = placement[2], rot = placement[3] }
    end
  end
  latticeKey = key

  LOG.info("snap field: " .. #lattice .. " positions over " .. rings ..
    " rings, on a " .. string.format("%.1f x %.1f", basis.x, basis.z) .. " plate")
  return lattice
end

-- snaps() — one tagged snap point per lattice position, so a tile dropped by
-- hand lands interlocked anywhere on the plate.  This is Clash of Cultures'
-- pattern (build plan section 2.5) and it is data, not code: it works with the
-- script switched off.
--
-- **This is the snapping we want** (MAP.snap): a tri-hex dropped near a
-- position lands interlocked with its neighbours, at that position's own
-- rotation.  What was catching cubes was the other system, TTS's grid — see
-- Map.grid below.
--
-- The points go in as raw local offsets rather than named layout spaces: there
-- are a couple of hundred of them, they are never addressed by name, and
-- registering that many spaces would bloat every lookup that walks the table.
--
-- Note what the disabled branch does — it writes an **empty list** rather than
-- returning early.  A save made while snapping was on carries those points on
-- the anchor plate, and they have to be cleared, not merely not re-added.
function Map.snaps()
  if not MAP.snap then
    LAYOUT.snaps(nil, {})
    return 0
  end
  local list = {}
  for _, at in ipairs(Map.lattice()) do
    local x, z = hex.toWorld(at.q, at.r, ART.radius)
    list[#list + 1] = {
      at = LAYOUT.localOffset({ x = x, y = MAP.tileY, z = z }),
      facing = at.rot * 60,
      rotationSnap = true,
      tags = { "tile" },
    }
  end
  LAYOUT.snaps(nil, list)
  return #list
end

-- plate(width, depth) — resize the one plate the map and the tray both sit on.
--
-- **The scale is not the size.**  This is the same 1 x 1 x 2 BlockRectangle the
-- tray plate used to be, so the mesh factor is measured off the object rather
-- than written as 2: layout.basis reports world units per local unit, and
-- dividing that by the object's own scale leaves the mesh.
--
-- Resizing changes basis, which every layout space is expressed against, so the
-- lattice is invalidated and the snap field re-derived. Tiles do not move: they
-- are separate objects and the plate scales about its centre.
function Map.plate(width, depth)
  local anchor = LAYOUT.anchorObject()
  if not anchor then return false end
  local scale = anchor.getScale()
  local basis = LAYOUT.basis() or { x = scale.x, y = scale.y, z = scale.z }
  local meshX = (scale.x ~= 0) and (basis.x / scale.x) or 1
  local meshZ = (scale.z ~= 0) and (basis.z / scale.z) or 1

  width = tonumber(width) or basis.x
  depth = tonumber(depth) or basis.z
  if width <= 0 or depth <= 0 then
    LOG.error("Map.plate wants positive world dimensions")
    return false
  end

  anchor.setScale({ x = width / meshX, y = scale.y, z = depth / meshZ })
  MAP.plate = { x = width, z = depth }
  Map.invalidate()
  Map.slots()
  Map.snaps()
  LOG.info(string.format("plate %.1f x %.1f", width, depth))
  return true
end

-- snap(on) — the lattice, live.  It is a rewrite of the anchor's snap points
-- either way, so it costs one call and no respawn.
function Map.snap(on)
  MAP.snap = on ~= false
  local n = Map.snaps()
  LOG.info("snap lattice " .. (MAP.snap and ("on — " .. n .. " points")
    or "off — cleared"))
  return n
end

-- ------------------------------------------------------------ the other grid
--
-- TTS's own grid (Options > Grid) is a second, completely separate snapping
-- system, and it is the one that was catching cubes: `Grid.snapping = 3`
-- (Center) on a hex grid pulls **every** object to the nearest cell centre.  It
-- is global — not per object, not per tag — so there is no version of it that
-- applies to tiles alone.
--
-- Worth knowing for next time: the save file's `Grid.Snapping: false` and the
-- running game's `Grid.snapping = 3` disagreed. Read the live value through the
-- API before believing the file.

-- grid(on) — TTS's grid snapping. Off is the default and is enforced at boot.
function Map.grid(on)
  MAP.gridSnap = on == true
  if Grid then
    Grid.snapping = MAP.gridSnap and 3 or 1 -- 1 = Off, 3 = Center
  end
  LOG.info("table grid snapping " .. (MAP.gridSnap and "on (centre)" or "off"))
  return MAP.gridSnap
end

-- unsnap(obj) — take one object that is not a tile out of both systems.
--
-- The lattice's points are tagged `tile`, which should mean only a tile can use
-- them; whether TTS honours that for an object carrying no tags at all is not
-- settled here (cookbook open questions). Clearing the object's own
-- `use_snap_points` does not depend on the answer.
function Map.unsnap(obj)
  if not obj or ASYNC.gone(obj) then return false end
  if obj.hasTag and obj.hasTag("tile") then return false end
  obj.use_grid = false
  obj.use_snap_points = false
  return true
end

-- unsnapAll() — every object on the table that is not a tile. Run at boot,
-- because the objects already there never fired a spawn event.
function Map.unsnapAll()
  local n = 0
  -- getObjects(), not getAllObjects(): the latter is deprecated and skips hand
  -- zones (reference/api/base.md:36).
  for _, obj in ipairs(getObjects() or {}) do
    if Map.unsnap(obj) then n = n + 1 end
  end
  LOG.info("unsnapped " .. n .. " non-tile objects")
  return n
end

-- --------------------------------------------------------------------- build

-- draw(seed) — which kind goes in which slot.  Pure given the seed, so the same
-- seed rebuilds the same map, and the plan's "random draw from a pool,
-- re-rollable" is one integer.
function Map.draw(seed)
  local rng = hex.rng(seed or MAP.seed)
  -- Only kinds of the map's own shape: the lattice was packed for that shape,
  -- and a tile with a different footprint leaves bare hexes in its slot.
  local pool = Tiles.pool(MAP.shape)
  if #pool == 0 then
    LOG.error("no '" .. tostring(MAP.shape) ..
      "' tile kind has a weight above zero — nothing to draw from",
      "kinds: " .. table.concat(Tiles.kinds(), ", "))
    return {}
  end
  local out = {}
  for index = 1, #Map.slots() do
    out[index] = rng.pick(pool)
  end
  return out
end

-- build(seed) — clear, then spawn one tile per slot.
--
-- Clearing first is not optional: TTS saves spawned objects, so a build that
-- did not clear would double the map on the first save-and-reload.
function Map.build(seed)
  if seed ~= nil then MAP.seed = tonumber(seed) or MAP.seed end

  Map.clear()
  -- clear() schedules its own bulk flush a quarter-second out. Left alone it
  -- would fire in the middle of this build and let the journal report a handful
  -- of individual tile spawns; the build's own flush below supersedes it.
  ASYNC.cancel("map.cleared")

  local list = Map.slots()
  local drawn = Map.draw(MAP.seed)
  local placed = 0

  Tiles.bulk = true
  for index, slot in ipairs(list) do
    local world = LAYOUT.world(slot.space)
    if world then
      local anchor = LAYOUT.anchorObject()
      local facing = ((anchor and anchor.getRotation() or {}).y or 0)
          + slot.rot * 60
      if Tiles.spawn(drawn[index], world, facing) then placed = placed + 1 end
    end
  end

  -- Spawning is asynchronous; let the callbacks land before the registry is
  -- believed again or the journal starts reporting individual spawns.
  ASYNC.keyed("map.built", 0.5, function()
    Tiles.bulk = false
    REG.invalidate()
    Journal.emit("build", { seed = MAP.seed, tiles = placed,
      rings = MAP.rings })
    LOG.info("map built: " .. placed .. " tiles, seed " .. MAP.seed)
  end)

  return placed
end

-- put(kind, q, r, steps) — one named tile on one lattice cell, replacing
-- whatever tri-hex is covering that cell.
--
-- This is the counterpart of the tray: the tray is for placing by hand, this is
-- for placing in one line from the command line, which is how a transition gets
-- modelled without a dozen drags.  The cell is the *pivot* — a tri-hex covers
-- (q,r) plus two more, which is why the tile already there is removed whole.
function Map.put(name, q, r, steps)
  if not Tiles.kind(name) then return nil end
  local anchor = LAYOUT.anchorObject()
  if not anchor then return nil end

  q, r, steps = tonumber(q) or 0, tonumber(r) or 0, tonumber(steps) or 0
  local occupant = Map.at(q, r)
  if occupant and occupant.obj and not ASYNC.gone(occupant.obj) then
    destroyObject(occupant.obj)
    REG.invalidate()
  end

  local x, z = hex.toWorld(q, r, ART.radius)
  local space = "put." .. hex.key(q, r)
  LAYOUT.spaces({
    [space] = LAYOUT.localOffset({ x = x, y = MAP.tileY, z = z }),
  })
  local world = LAYOUT.world(space)
  if not world then return nil end

  local facing = ((anchor.getRotation() or {}).y or 0) + steps * 60
  local obj = Tiles.spawn(name, world, facing)
  if not obj then return nil end
  Journal.emit("put", { kind = name, cell = hex.key(q, r), rot = steps % 6 })
  LOG.info("put " .. name .. " at hex(" .. q .. "," .. r .. ") rot " ..
    (steps % 6))
  return name .. " at hex(" .. q .. "," .. r .. ")" ..
      (occupant and " (replaced " .. tostring(occupant.kind) .. ")" or "")
end

function Map.reroll(seed)
  if seed == nil then
    -- No seed given: step to the next one rather than drawing a random number,
    -- so "reroll again" is repeatable and the changelog can say which map it is.
    seed = MAP.seed + 1
  end
  return Map.build(seed)
end

-- clear() — destroy by role, never by GUID.  Anything the owner tagged "tile"
-- goes, including tiles placed by hand — but not the tray, which is a palette
-- to draw from and would be maddening to lose on every reroll.
function Map.clear()
  local tiles = Tiles.onMap()
  Tiles.bulk = true
  for _, obj in ipairs(tiles) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  REG.invalidate()
  ASYNC.keyed("map.cleared", 0.25, function() Tiles.bulk = false end)
  if #tiles > 0 then LOG.info("cleared " .. #tiles .. " tiles") end
  return #tiles
end

function Map.count()
  return #Tiles.onMap()
end

-- ------------------------------------------------------------------ querying

-- cells() — every hex the map currently covers, as key -> { kind, obj }.
-- Built from where the tiles actually are, not from the plan, so a tile the
-- owner dragged somewhere else is reported where it now is.
function Map.cells()
  local anchor = LAYOUT.anchorObject()
  local out = {}
  for _, obj in ipairs(Tiles.onMap()) do
    if not ASYNC.gone(obj) then
      local name = Tiles.kindOf(obj)
      local kind = name and ART.kinds[name]
      local shape = kind and ART.shapes[kind.shape]
      if shape and anchor then
        local offset = LAYOUT.worldOffset(
          anchor.positionToLocal(obj.getPosition()))
        local q, r = hex.fromWorld(offset.x, offset.z, ART.radius)
        local steps = math.floor((((obj.getRotation() or {}).y or 0)
          - ((anchor.getRotation() or {}).y or 0)) / 60 + 0.5) % 6
        for _, cell in ipairs(hex.footprint(shape.cells, q, r, steps)) do
          out[hex.key(cell[1], cell[2])] = { kind = name, obj = obj }
        end
      end
    end
  end
  return out
end

function Map.at(q, r)
  return Map.cells()[hex.key(q, r)]
end

-- capture() — print the map as a table you could paste into a spec.  The
-- authoring counterpart of layout.capture: arrange tiles by hand, call this,
-- and the arrangement stops being something only the save remembers.
function Map.capture()
  local anchor = LAYOUT.anchorObject()
  if not anchor then return nil end
  local rows = {}
  for _, obj in ipairs(Tiles.onMap()) do
    if not ASYNC.gone(obj) then
      local offset = LAYOUT.worldOffset(
        anchor.positionToLocal(obj.getPosition()))
      local q, r = hex.fromWorld(offset.x, offset.z, ART.radius)
      local steps = math.floor((((obj.getRotation() or {}).y or 0)
        - ((anchor.getRotation() or {}).y or 0)) / 60 + 0.5) % 6
      rows[#rows + 1] = string.format('  { "%s", %d, %d, %d },',
        tostring(Tiles.kindOf(obj)), q, r, steps)
    end
  end
  table.sort(rows)
  local text = "{\n" .. table.concat(rows, "\n") .. "\n}"
  LOG.info("Map.capture — " .. #rows .. " tiles")
  print(text)
  return text
end
