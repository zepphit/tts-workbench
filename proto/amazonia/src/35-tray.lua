-- src/35-tray.lua — the palette: one of every tray kind, beside the map.
--
-- The frontier tiles (a shoreline, a walled clearing) are not drawn at random.
-- A coast only means something next to the right neighbour, so they are placed
-- by hand — and something placed by hand needs somewhere to be picked up from.
-- Every one of them sits at weight 0 in spec/tiles.json and carries `tray`
-- there; this file turns that flag into objects on the table.
--
-- Three things make it a tray rather than just more tiles:
--
--   the tag       TRAY.tag, which is what Tiles.onMap() subtracts, so a reroll
--                 rebuilds the map and leaves the palette alone
--   unlocked      the map ships locked; a palette you cannot pick up is furniture
--   anchor-local  the grid is registered as layout spaces like every other
--                 position here, so dragging the plate takes the tray with it
--
-- It is not a bag. A bag would hide the art, and seeing all sixteen silhouettes
-- at once is the entire point of having them.
--
-- **The tray no longer brings its own plate.**  It used to: two plates butted
-- together, sized to match, kept flush so a tile dragged across the seam did
-- not step.  One plate is now big enough for both (MAP.plate, 60 x 40.8), which
-- removes the seam, the flushness problem and a second thing to keep seated
-- under the palette.  Tray.clear still destroys anything carrying the old
-- plate's tag, so a save made before 2026-09-21 cleans itself up on load.

local LOG = ttslib.log
local ASYNC = ttslib.async
local REG = ttslib.registry
local LAYOUT = ttslib.layout

Tray = {}

-- kinds() — what belongs in the tray, in catalogue order so the grid is stable
-- between builds and a tile is always in the same place.
function Tray.kinds()
  local out = {}
  for _, name in ipairs(Tiles.kinds()) do
    if ART.kinds[name].tray then out[#out + 1] = name end
  end
  return out
end

function Tray.rows()
  return math.ceil(#Tray.kinds() / TRAY.columns)
end

-- spaces() — the grid, in the anchor's local coordinates, through
-- layout.localOffset for the same reason Map.slots uses it: local space is the
-- mesh's space, and the anchor plate's mesh is twice as deep as it is wide.
function Tray.spaces()
  local anchor = LAYOUT.anchorObject()
  if not anchor then return {} end
  local names = Tray.kinds()
  local spaces = {}
  local slots = {}
  for index, name in ipairs(names) do
    local column = (index - 1) % TRAY.columns
    local row = math.floor((index - 1) / TRAY.columns)
    local x = TRAY.origin.x + column * TRAY.spacing.x
    local z = TRAY.origin.z + row * TRAY.spacing.z
    local space = "tray" .. index
    spaces[space] = LAYOUT.localOffset({ x = x, y = MAP.tileY, z = z })
    slots[index] = { kind = name, space = space }
  end

  LAYOUT.spaces(spaces)
  return slots
end

-- ------------------------------------------------------------------ the line

-- divider() — the mark between the map and the palette.
--
-- One plate carries both, which removed the seam that used to show where one
-- ended and the other began.  This is that boundary as a line on the floor: a
-- locked bar in the clear gap east of the map, spanning the plate's depth.
--
-- Rebuilt rather than moved, because it is one object and a rebuild re-derives
-- its length from MAP.plate — so resizing the plate does not leave a bar that
-- is the old plate's length.
--
-- **A BlockRectangle's mesh is 1 x 1 x 2**, which is the measurement that cost
-- a shipped save on 2026-09-21 (the map stretched by exactly two along Z). The
-- anchor plate is the same block, and Map.plate divides by the measured basis
-- for precisely this reason. Nothing to measure here — the object does not
-- exist yet — so the constant is written down and named.
local BLOCK_MESH_Z = 2

function Tray.divider()
  local spec = TRAY.divider or {}
  for _, obj in ipairs(REG.all(spec.tag or "tray.divider")) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  if not spec.enabled then return nil end

  local anchor = LAYOUT.anchorObject()
  if not anchor then return nil end

  local depth = math.max(MAP.plate.z - (spec.margin or 0) * 2, 1)
  local space = "tray.divider"
  LAYOUT.spaces({
    [space] = LAYOUT.localOffset({ x = spec.x, y = spec.y, z = 0 }),
  })
  local world = LAYOUT.world(space)
  if not world then return nil end

  return spawnObjectData({
    data = {
      Name = "BlockRectangle",
      Transform = {
        posX = world.x, posY = world.y, posZ = world.z,
        rotX = 0, rotY = (anchor.getRotation() or {}).y or 0, rotZ = 0,
        scaleX = spec.width, scaleY = spec.height,
        scaleZ = depth / BLOCK_MESH_Z,
      },
      Nickname = "",
      Description = "",
      GMNotes = spec.tag,
      ColorDiffuse = {
        r = spec.colour[1], g = spec.colour[2], b = spec.colour[3],
      },
      Tags = { spec.tag },
      -- Locked, and out of both snapping systems: this is furniture. Unlocked
      -- it would be shoved aside by the first tile dropped against it, and a
      -- 60-unit bar is not something you want to have to put back.
      Locked = true,
      Grid = false,
      Snap = false,
      Sticky = false,
      Autoraise = false,
      DragSelectable = false,
      Tooltip = false,
      GridProjection = false,
      HideWhenFaceDown = false,
      Hands = false,
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = "",
    },
  })
end

-- sync() — make the table hold one of every tray kind, without disturbing the
-- ones already out.
--
-- **This is what boot calls, not build().**  The owner curates this palette by
-- hand: on 2026-09-21 he deleted six of the twenty-two and regrouped the rest
-- into rows by family.  build() would have thrown that away — it clears and
-- relays the whole catalogue on the generated grid — and every `ttsd.py push`
-- reloads the save, so "rebuild if empty" meant his arrangement survived only
-- until the next code change.  sync() converges on the spec instead:
--
--   orphans   a tile whose kind the catalogue no longer has is destroyed. It
--             has no art, no shape and no label, and Tiles.hubs dereferences
--             ART.kinds[name] unguarded, so leaving one poisons the next load.
--   missing   a kind with `tray` set and no tile on the table is spawned, at
--             its own grid position.
--   the rest  left exactly where they are, duplicates included: two of a kind
--             side by side is something he did on purpose.
--
-- A kind that loses its `tray` flag keeps whatever tile is already out — the
-- flag governs what gets laid out, not what is allowed to exist.
function Tray.sync()
  -- The palette's own plate is gone — there is one plate now. A save made
  -- before that still carries it, sitting proud of the big plate's surface, so
  -- it is cleared here rather than left as furniture nobody owns.
  for _, obj in ipairs(REG.all(TRAY.plateTag)) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end

  local present = {}
  local orphans = 0
  for _, obj in ipairs(Tiles.inTray()) do
    if not ASYNC.gone(obj) then
      local name = Tiles.kindOf(obj)
      if not name or not ART.kinds[name] then
        destroyObject(obj)
        orphans = orphans + 1
      else
        present[name] = true
      end
    end
  end

  -- Rebuilt on every sync, which is every boot: it is one locked object and
  -- re-deriving it is what keeps its length honest after a plate resize.
  Tray.divider()

  local slots = Tray.spaces()
  local anchor = LAYOUT.anchorObject()
  local facing = (anchor and (anchor.getRotation() or {}).y or 0)
  local added = 0
  for _, slot in ipairs(slots) do
    if not present[slot.kind] then
      local world = LAYOUT.world(slot.space)
      if world and Tiles.spawn(slot.kind, world, facing, {
            locked = TRAY.locked,
            tags = { "tile", "tile." .. slot.kind, TRAY.tag },
          }) then
        added = added + 1
      end
    end
  end

  if orphans > 0 or added > 0 then
    REG.invalidate()
    LOG.info("tray sync: +" .. added .. " spawned, -" .. orphans .. " orphaned")
  end
  return added, orphans
end

-- build() — clear whatever is there and lay the palette out again.
function Tray.build()
  Tray.clear()
  ASYNC.cancel("tray.cleared")
  Tray.divider()

  local slots = Tray.spaces()
  local anchor = LAYOUT.anchorObject()
  local facing = (anchor and (anchor.getRotation() or {}).y or 0)
  local placed = 0

  Tiles.bulk = true
  for _, slot in ipairs(slots) do
    local world = LAYOUT.world(slot.space)
    if world then
      local spawned = Tiles.spawn(slot.kind, world, facing, {
        locked = TRAY.locked,
        tags = { "tile", "tile." .. slot.kind, TRAY.tag },
      })
      if spawned then placed = placed + 1 end
    end
  end

  ASYNC.keyed("tray.built", 0.5, function()
    Tiles.bulk = false
    REG.invalidate()
    Journal.emit("tray", { tiles = placed })
    LOG.info("tray: " .. placed .. " tiles in " .. TRAY.columns .. " columns")
  end)
  return placed
end

function Tray.clear()
  local tiles = Tiles.inTray()
  Tiles.bulk = true
  for _, obj in ipairs(tiles) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  for _, obj in ipairs(REG.all(TRAY.plateTag)) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  -- The line marks where the palette is; with no palette it marks nothing.
  for _, obj in ipairs(REG.all((TRAY.divider or {}).tag or "tray.divider")) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  REG.invalidate()
  ASYNC.keyed("tray.cleared", 0.25, function() Tiles.bulk = false end)
  if #tiles > 0 then LOG.info("cleared " .. #tiles .. " tray tiles") end
  return #tiles
end

function Tray.count()
  return #Tiles.inTray()
end
