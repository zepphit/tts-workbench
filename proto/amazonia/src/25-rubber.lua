-- src/25-rubber.lua — a white cube on every deep forest hexside.
--
-- Rubber comes out of the deep forest, so a DF wall on a tile is a place a
-- cube belongs.  Which hexsides those are is not inferred from the art: it is
-- `edges` in art/index.lua, which scripts/tilegen.py writes from the same
-- `paint` block it draws the diffuse from (tilegen.painted_edges).  One source,
-- so a spec edit moves the pixels and the cubes together and neither can drift.
--
-- **Spawn only** (00-config.lua, RUBBER).  This module is called from
-- Tiles.spawn and from nowhere else automatic: there is no drop handler, no
-- rotate handler, nothing that notices a tile has moved.  Picking a cube up,
-- dragging a tile out from under its cubes, sweeping the lot into a bag — all
-- free, and none of it grows a replacement.  The two verbs that do act on
-- what is already on the table, Rubber.apply and Rubber.clear, are asked for
-- by name through AZ.rubber.
--
-- A reload is not a spawn either.  TTS saves spawned objects, so after a
-- save/reload the cubes come back from the file with the tiles they sit on,
-- and 99-Global.lua's restore path deliberately does not call anything here.
--
-- The one non-obvious coupling is Tiles.reskin, which destroys a tile and
-- respawns it in the same place: its cubes never moved, so it passes
-- `rubber = false` and the ones already there are simply kept.

local LOG = ttslib.log
local ASYNC = ttslib.async
local REG = ttslib.registry

Rubber = {}

-- --------------------------------------------------------------- the hexsides

-- sides(kind) — every outer hexside of a kind painted RUBBER.terrain, as
-- { cell = index, dir = 1..6 } in src/10-hex.lua's numbering (1=E 2=SE 3=SW
-- 4=W 5=NW 6=NE).  A flat kind has no `edges` at all and yields nothing.
--
-- Note this asks the *catalogue*, not the object: two tiles of one kind have
-- the same walls however they are turned, and the turning is applied later,
-- once, by positionToWorld.
function Rubber.sides(name)
  local kind = ART.kinds[name]
  if not kind then return {} end
  local out = {}
  for cell, row in ipairs(kind.edges or {}) do
    for dir = 1, 6 do
      if row[dir] == RUBBER.terrain then
        out[#out + 1] = { cell = cell, dir = dir }
      end
    end
  end
  return out
end

-- offset(shape, cell, dir) — where a cube sits in the tile's own frame, before
-- the tile's rotation: out from that cell's centre, along the normal of the
-- given hexside, RUBBER.inset of the way.
--
-- The normal is taken as the direction of the neighbouring cell centre rather
-- than written out as six angles, so it follows hex.DIRECTIONS by construction
-- and there is no second table of geometry to keep in step.
function Rubber.offset(shape, cell, dir)
  local at = shape.cells[cell]
  local step = hex.DIRECTIONS[dir]
  if not at or not step then return nil end
  local cx, cz = hex.toWorld(at[1], at[2], ART.radius)
  local nx, nz = hex.toWorld(at[1] + step[1], at[2] + step[2], ART.radius)
  local dx, dz = nx - cx, nz - cz
  local length = math.sqrt(dx * dx + dz * dz)
  if length <= 0 then return nil end
  return cx + dx / length * RUBBER.inset, cz + dz / length * RUBBER.inset
end

-- places(obj) — the world positions a tile's cubes go, rotation included.
--
-- Through obj.positionToWorld rather than arithmetic, for the reason the whole
-- rig prefers it (critique C2): the tile's own transform is the authority on
-- where its corners are, so a tile the owner turned by hand needs no special
-- case.  Only X and Z come from it — Y is taken from the tile's centre plus
-- RUBBER.y, because positionToWorld scales Y by the tile's own 0.5 and the
-- height wanted here is a world measurement, not a local one.
function Rubber.places(obj, name)
  local kind = ART.kinds[name]
  local shape = kind and ART.shapes[kind.shape]
  if not shape then return {} end

  local centre = obj.getPosition()
  local out = {}
  for _, side in ipairs(Rubber.sides(name)) do
    local x, z = Rubber.offset(shape, side.cell, side.dir)
    if x then
      local world = obj.positionToWorld({ x = x, y = 0, z = z })
      out[#out + 1] = { x = world.x, y = centre.y + RUBBER.y, z = world.z }
    end
  end
  return out
end

-- ------------------------------------------------------------------ spawning

-- data(position) — the cube, as spawnObjectData wants it.
--
-- The flags are the owner's own sample read back out of the running game on
-- 2026-09-22 (GUID 7bfd32): a BlockSquare at scale 0.25, white, unlocked,
-- Sticky, with Grid and Snap off.  Unlocked is the point — these get moved.
-- Grid and Snap off is belt to Map.unsnap's braces: the spawn event clears
-- use_grid and use_snap_points on anything that is not a tile, and this stops
-- the cube being caught in the frame before that runs.
function Rubber.data(position)
  return {
    Name = RUBBER.block,
    Transform = {
      posX = position.x, posY = position.y, posZ = position.z,
      rotX = 0, rotY = 0, rotZ = 0,
      scaleX = RUBBER.scale, scaleY = RUBBER.scale, scaleZ = RUBBER.scale,
    },
    Nickname = RUBBER.name,
    Description = "",
    GMNotes = RUBBER.tag,
    ColorDiffuse = {
      r = RUBBER.colour[1], g = RUBBER.colour[2], b = RUBBER.colour[3],
    },
    Tags = { RUBBER.tag, RUBBER.mapTag },
    Locked = false,
    Grid = false,
    Snap = false,
    Sticky = true,
    Autoraise = true,
    DragSelectable = true,
    Tooltip = true,
    GridProjection = false,
    HideWhenFaceDown = false,
    Hands = false,
    LuaScript = "",
    LuaScriptState = "",
    XmlUI = "",
  }
end

-- spawn(obj, name) — the cubes for one tile that has just appeared.
--
-- Called from Tiles.spawn's callback, which is the single entry point: if it
-- is not reached from there, no cube is ever created on its own.  Returns the
-- number placed, so 0 is the normal answer for jungle, river and every flat
-- kind — they have no painted walls.
function Rubber.spawn(obj, name)
  if not RUBBER.enabled then return 0 end
  if not obj or ASYNC.gone(obj) then return 0 end
  -- The tray is a palette, not a board (RUBBER.tray). A tile dragged off it
  -- would leave its cubes behind on the empty slot, which reads as litter.
  if not RUBBER.tray and obj.hasTag and obj.hasTag(TRAY.tag) then return 0 end

  local places = Rubber.places(obj, name)
  for _, at in ipairs(places) do
    spawnObjectData({ data = Rubber.data(at) })
  end
  if #places > 0 then REG.invalidate(RUBBER.tag) end
  return #places
end

-- ---------------------------------------------------------------- the supply

-- bag() — the Rubber bag, beside the creek and road bags.
--
-- **Spawned once, then never again.**  It is a supply the owner drags from and
-- refills into, so a boot that replaced it would throw away whatever state he
-- had left it in, and a boot that added a second one would leave him two. It
-- returns the one already there when there is one, which makes it safe to call
-- from onLoad on every single reload.
--
-- Modelled on the creek bag he made by hand (GUID a74776, read out of the
-- running game 2026-09-22): an Infinite_Bag at scale 1, tinted, holding exactly
-- one object. The tint is the cube's own white rather than a colour of its own,
-- because the piece is what names the bag.
--
-- The cube inside carries `rubber` but **not** `rubber.map`: a cube pulled out
-- by hand counts in the total and is not swept away by the next reroll.
function Rubber.bag()
  local found = REG.all(RUBBER.bagTag)
  if #found > 0 then return found[1] end

  local LAYOUT = ttslib.layout
  local anchor = LAYOUT.anchorObject()
  if not anchor then return nil end

  local space = RUBBER.bagTag
  LAYOUT.spaces({ [space] = LAYOUT.localOffset(RUBBER.bag) })
  local world = LAYOUT.world(space)
  if not world then return nil end

  local colour = {
    r = RUBBER.colour[1], g = RUBBER.colour[2], b = RUBBER.colour[3],
  }
  local held = Rubber.data({ x = world.x, y = world.y + 2, z = world.z })
  held.Tags = { RUBBER.tag }

  local bag = spawnObjectData({
    data = {
      Name = "Infinite_Bag",
      Transform = {
        posX = world.x, posY = world.y, posZ = world.z,
        rotX = 0, rotY = 0, rotZ = 0,
        scaleX = 1, scaleY = 1, scaleZ = 1,
      },
      Nickname = RUBBER.name,
      Description =
      "Infinite supply. Drag one out; drop one back in to delete it.",
      GMNotes = "",
      ColorDiffuse = colour,
      Tags = { RUBBER.bagTag },
      Locked = false,
      Grid = false,
      Snap = false,
      Sticky = true,
      Autoraise = true,
      DragSelectable = true,
      Tooltip = true,
      GridProjection = false,
      HideWhenFaceDown = false,
      Hands = false,
      MaterialIndex = -1,
      MeshIndex = -1,
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = "",
      ContainedObjects = { held },
    },
  })
  if bag then
    REG.invalidate(RUBBER.bagTag)
    LOG.info("rubber bag spawned beside the creek and road bags")
  end
  return bag
end

-- ------------------------------------------------------------------ clearing

function Rubber.all()
  return REG.all(RUBBER.tag)
end

function Rubber.count()
  return #Rubber.all()
end

-- clear(tag) — destroy cubes.  Defaults to the map's, which is what Map.clear
-- wants: a reroll destroys every map tile, and cubes left where those tiles
-- were would float over the new ones.
function Rubber.clear(tag)
  local list = REG.all(tag or RUBBER.mapTag)
  for _, obj in ipairs(list) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  if #list > 0 then
    REG.invalidate()
    LOG.info("cleared " .. #list .. " rubber")
  end
  return #list
end

-- clearNear(obj) — the cubes belonging to one tile, by position.
--
-- Map.put replaces whatever tri-hex covers a cell, and that tile's cubes have
-- to go with it.  There is no back-reference to follow: a cube carries no tile
-- GUID, because a GUID changes the moment the tile is picked up or reskinned
-- and a stale one is worse than none.  Position settles it instead — a cube
-- sits RUBBER.inset (0.66) from its own cell's centre, so the nearest cube
-- belonging to a *neighbouring* tile is 1.73 - 0.66 = 1.07 away. One radius
-- claims a tile's own cubes and nothing else's.
function Rubber.clearNear(obj)
  if not obj or ASYNC.gone(obj) then return 0 end
  local name = Tiles.kindOf(obj)
  local kind = name and ART.kinds[name]
  local shape = kind and ART.shapes[kind.shape]
  if not shape then return 0 end

  local centres = {}
  for _, at in ipairs(shape.cells) do
    local x, z = hex.toWorld(at[1], at[2], ART.radius)
    centres[#centres + 1] = obj.positionToWorld({ x = x, y = 0, z = z })
  end

  local reach = ART.radius * ART.radius
  local gone = 0
  for _, cube in ipairs(Rubber.all()) do
    if not ASYNC.gone(cube) then
      local at = cube.getPosition()
      for _, centre in ipairs(centres) do
        local dx, dz = at.x - centre.x, at.z - centre.z
        if dx * dx + dz * dz <= reach then
          destroyObject(cube)
          gone = gone + 1
          break
        end
      end
    end
  end
  if gone > 0 then REG.invalidate() end
  return gone
end

-- ------------------------------------------------------------------ the verbs

-- apply() — put rubber on every map tile that is out now.
--
-- The one call that is not spawn-driven, and it exists because the toggle
-- alone would look broken: switching rubber on changes what the *next* tile
-- does, and the table in front of you does not move. Clears first, so running
-- it twice does not stack two cubes per hexside.
function Rubber.apply()
  local was = Rubber.clear()
  local placed = 0
  local tiles = Tiles.onMap()
  Tiles.bulk = true
  for _, obj in ipairs(tiles) do
    local name = Tiles.kindOf(obj)
    if name then
      -- Past the RUBBER.enabled gate on purpose: this was asked for by name.
      local places = Rubber.places(obj, name)
      for _, at in ipairs(places) do
        spawnObjectData({ data = Rubber.data(at) })
      end
      placed = placed + #places
    end
  end
  ASYNC.keyed("rubber.applied", 0.5, function()
    Tiles.bulk = false
    REG.invalidate()
    Journal.emit("rubber", { placed = placed, removed = was })
    LOG.info("rubber: " .. placed .. " cubes over " .. #tiles .. " map tiles")
  end)
  return placed
end

function Rubber.status()
  return string.format("rubber %s (%s on the table, %s per %s)",
    RUBBER.enabled and "on" or "off", Rubber.count(),
    RUBBER.terrain, "hexside")
end
