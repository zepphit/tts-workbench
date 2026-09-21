-- ttslib/06-layout.lua — placement relative to an anchor, in named spaces.
-- Answers critique C2.  Depends on: 00-log, 01-async, 05-registry.
--
-- Almoravid's Global makes 925 setPosition/setPositionSmooth calls against
-- absolute table coordinates and never once calls positionToWorld: move the
-- board and all 925 are wrong at the same moment, with no transform to adjust
-- (docs/critique.md#c2).  Arcs shows the alternative — its ambition markers get
-- 36 positions out of 12 numbers by composing a column and a row vector in the
-- board's local space and resolving them through reach_board.positionToWorld,
-- which applies the board's position, rotation and scale (it is scaled 6.015x).
--
--   layout.anchor("board")                       -- a role, resolved late
--   layout.spaces({
--     deck  = { -0.42, layout.LAYER.card, 0.10 },
--     score = {  0.31, layout.LAYER.marker, -0.22 },
--   })
--   layout.place(marker, "score", { facing = 180 })
--
-- Positions live in a table you can print, diff and edit — not in statements.
-- Y comes from a named layer, so "just above the board" is written once.
--
-- Use layout.capture(obj) to turn a component you dragged into place in TTS
-- into a row of that table.

ttslib = ttslib or {}

local LOG = assert(ttslib.log, "load ttslib/00-log.lua before 06-layout.lua")
local ASYNC = assert(ttslib.async, "load ttslib/01-async.lua before 06-layout.lua")
local REGISTRY = assert(ttslib.registry, "load ttslib/05-registry.lua before 06-layout.lua")

local L = {}
ttslib.layout = L

-- Stacking layers in the anchor's local space.  Name them once; never write a
-- bare Y again.  Arcs repeats 0.2 by hand in every marker row, and two of them
-- say 0.21 for reasons nobody can now reconstruct.
L.LAYER = {
  table = 0.00,
  board = 0.20,
  marker = 0.30,
  card = 0.40,
  held = 2.00,
}

local anchorRef = nil -- an Object, or a role name resolved through the registry
local spaces = {} -- name -> { x, y, z } in anchor-local space

-- Accepts {1, 2, 3} or {x = 1, y = 2, z = 3}; always returns the second form,
-- which is what every TTS call wants.
local function vec(v)
  if type(v) ~= "table" then return nil end
  if v.x ~= nil then
    return { x = v.x, y = v.y or 0, z = v.z or 0 }
  end
  return { x = v[1] or 0, y = v[2] or 0, z = v[3] or 0 }
end
L.vec = vec

-- add(a, b) — compose local offsets, the way Arcs composes column + row.
function L.add(a, b)
  local va, vb = vec(a), vec(b)
  if not va or not vb then return nil end
  return { x = va.x + vb.x, y = va.y + vb.y, z = va.z + vb.z }
end

-- anchor(objOrRole) — set the anchor everything is measured against.  A role
-- name is resolved through the registry on every use, so it is safe to set
-- before the object exists.
function L.anchor(objOrRole)
  if objOrRole ~= nil then
    anchorRef = objOrRole
  end
  return anchorRef
end

function L.anchorObject(override)
  local ref = override or anchorRef
  if ref == nil then
    LOG.once("layout.noanchor", "error", "layout has no anchor; call layout.anchor(obj or role)")
    return nil
  end
  if type(ref) == "string" then
    return REGISTRY.one(ref)
  end
  return ref
end

-- spaces(table) / space(name, vector) — the named positions of your game, in
-- anchor-local coordinates.
function L.spaces(table_of_spaces)
  LOG.assert(type(table_of_spaces) == "table", "layout.spaces needs a table")
  for name, position in pairs(table_of_spaces) do
    spaces[name] = vec(position)
  end
  return spaces
end

function L.space(name, position)
  if position ~= nil then
    spaces[name] = vec(position)
  end
  return spaces[name]
end

-- local_(where) — the anchor-local vector for a space name or a raw vector.
function L.localOf(where)
  if type(where) == "string" then
    local found = spaces[where]
    if not found then
      LOG.once("layout.space." .. where, "error", "no layout space named '" .. where .. "'")
      return nil
    end
    return { x = found.x, y = found.y, z = found.z }
  end
  return vec(where)
end

-- basis(anchor) — world units per one unit of anchor-local space, per axis.
--
-- **Do not assume this equals the anchor's scale.**  Local space is the
-- *mesh's* space, and a built-in's mesh is not always a unit cube: TTS's
-- `BlockRectangle` measures 1 x 1 x 2, so a plate at scale 20 x 0.2 x 17 has
-- `positionToWorld({0,0,1}).z = 34` and is 34 deep, not 17.  Code that converts
-- a world offset into a local one by dividing by `getScale()` therefore comes
-- out a factor of two wrong on Z alone, which stretches a grid along one axis
-- and is easy to mistake for a spacing choice.  Amazonia's hex map shipped like
-- that on 2026-09-21: every row was twice as far apart as the lattice said and
-- the tiles never interlocked.
--
-- Measuring costs three positionToWorld calls and is true of any mesh, any
-- scale and any rotation — lengths are rotation-invariant, so this needs no
-- special case for a turned anchor.
function L.basis(anchor)
  local object = L.anchorObject(anchor)
  if not object then return nil end
  local origin = object.positionToWorld({ x = 0, y = 0, z = 0 })
  local function span(v)
    local point = object.positionToWorld(v)
    local dx = (point.x or 0) - (origin.x or 0)
    local dy = (point.y or 0) - (origin.y or 0)
    local dz = (point.z or 0) - (origin.z or 0)
    local length = math.sqrt(dx * dx + dy * dy + dz * dz)
    return length > 1e-9 and length or 1
  end
  return {
    x = span({ x = 1, y = 0, z = 0 }),
    y = span({ x = 0, y = 1, z = 0 }),
    z = span({ x = 0, y = 0, z = 1 }),
  }
end

-- localOffset(offset, anchor) — a world-space offset as an anchor-local one.
-- The inverse of multiplying by basis, and the call a grid generator wants:
-- give it the offsets your arithmetic produced and it returns what `spaces`
-- expects, whatever mesh the anchor happens to be.
function L.localOffset(offset, anchor)
  local basis = L.basis(anchor)
  local vector = vec(offset)
  if not basis or not vector then return nil end
  return { x = vector.x / basis.x, y = vector.y / basis.y, z = vector.z / basis.z }
end

-- worldOffset(localVector, anchor) — the other direction, for reading a
-- position back off the table.
function L.worldOffset(localVector, anchor)
  local basis = L.basis(anchor)
  local vector = vec(localVector)
  if not basis or not vector then return nil end
  return { x = vector.x * basis.x, y = vector.y * basis.y, z = vector.z * basis.z }
end

-- world(where, anchor) — the world position of a space.  This is the whole
-- point: one table of local coordinates serves a board at any transform, and
-- serves every player's board from the same rows.
function L.world(where, anchor)
  local object = L.anchorObject(anchor)
  if not object then return nil end
  local position = L.localOf(where)
  if not position then return nil end
  return object.positionToWorld(position)
end

-- place(obj, where, opts) — opts:
--   facing   degrees around Y, relative to the anchor's own rotation
--   layer    a L.LAYER key or a number, overriding the space's Y
--   smooth   default true; false for setup nobody is watching
--   collide  default false; setup should not knock other pieces about
--   fast     default false; passed to setPositionSmooth's third argument
--   anchor   place against a different anchor, e.g. a player's own board
--
-- facing turns the object around Y only.  X and Z are left exactly as the object
-- already holds them, so placing a face-down card with facing keeps it face-down.
function L.place(obj, where, opts)
  opts = opts or {}
  if not LOG.expect(obj, "layout.place: no object", where) then return false end

  local anchor = L.anchorObject(opts.anchor)
  if not anchor then return false end

  local position = L.localOf(where)
  if not position then return false end

  if opts.layer ~= nil then
    position.y = (type(opts.layer) == "number") and opts.layer or (L.LAYER[opts.layer] or position.y)
  end

  local world = anchor.positionToWorld(position)
  if opts.smooth == false then
    obj.setPosition(world)
  else
    -- setPositionSmooth(vector, collide, fast): collide defaults off, because a
    -- piece bouncing off another mid-placement is never what setup wanted.
    obj.setPositionSmooth(world, opts.collide == true, opts.fast == true)
  end

  if opts.facing ~= nil then
    -- Y is the only axis facing controls.  X and Z carry face-up/face-down and
    -- any tilt the piece already has, so zeroing them here quietly turns a
    -- face-down card face-up; keep whatever the object is holding.
    local rotation = anchor.getRotation()
    local current = obj.getRotation() or {}
    local target = {
      x = current.x or 0,
      y = (rotation.y or 0) + opts.facing,
      z = current.z or 0,
    }
    if opts.smooth == false then
      obj.setRotation(target)
    else
      obj.setRotationSmooth(target) -- lowercase s; see cookbook 07 open question 2
    end
  end
  return true
end

-- capture(obj, anchor) — the inverse, for authoring.  Drag a component where
-- you want it in TTS, call this, and paste the result into your spaces table.
function L.capture(obj, anchor)
  local object = L.anchorObject(anchor)
  if not object or not LOG.expect(obj, "layout.capture: no object") then return nil end

  local position = object.positionToLocal(obj.getPosition())
  local function round(n)
    return math.floor(n * 1000 + 0.5) / 1000
  end
  local rounded = { x = round(position.x), y = round(position.y), z = round(position.z) }
  LOG.info(string.format("{ %.3f, %.3f, %.3f }", rounded.x, rounded.y, rounded.z),
    obj.getName and obj.getName())
  return rounded
end

-- takeTo(bag, where, opts) — the bulk-placement idiom, written once instead of
-- 537 times.  takeObject accepts the destination directly and its callback runs
-- once the object has finished spawning, so the take -> Wait.frames -> move
-- dance Almoravid repeats is not needed; what is needed is the guard, because
-- the object can be gone by the time you are called.
--
-- opts, and only these — takeTo is not place(), so do not expect place()'s full
-- set to carry over:
--   anchor   which anchor `where` is relative to, as in place()
--   facing   degrees around Y, relative to the anchor's own rotation
--   smooth   default true
--   guid     take this specific object; exclusive with index
--   index    take the object at this position; exclusive with guid
--   top      take from the top of the container
--   tag      applied on arrival, and the registry invalidated for it
--   onPlaced called with the object once it has spawned
--
-- place()'s layer, collide and fast are NOT read here.  For a layered or
-- non-colliding destination, take the object and place() it from onPlaced.
--
-- Unlike place(), facing sets all three axes: the object does not exist yet, so
-- there is no existing tilt to preserve — this rotation is its spawn rotation.
function L.takeTo(bag, where, opts)
  opts = opts or {}
  if not LOG.expect(bag, "layout.takeTo: no container", where) then return false end

  local world = L.world(where, opts.anchor)
  if not world then return false end

  local rotation = nil
  if opts.facing ~= nil then
    local anchor = L.anchorObject(opts.anchor)
    local anchorRotation = anchor and anchor.getRotation() or { y = 0 }
    rotation = { x = 0, y = (anchorRotation.y or 0) + opts.facing, z = 0 }
  end

  local params = {
    position = world,
    rotation = rotation,
    smooth = opts.smooth ~= false,
    top = opts.top,
    callback_function = function(obj)
      if ASYNC.gone(obj) then return end
      if opts.tag then
        obj.addTag(opts.tag)
        -- TTS fires no event for a tag change, and the spawn that would have
        -- invalidated the cache has already happened by the time this callback
        -- runs — so the new role would be invisible to reg.all until something
        -- unrelated dropped the cache.
        REGISTRY.invalidate(opts.tag)
      end
      if opts.onPlaced then
        LOG.attempt("layout.takeTo onPlaced", opts.onPlaced, obj)
      end
    end,
  }

  -- "Only use index or guid, never both" (reference/api/object.md:1965).
  if opts.guid ~= nil then
    if opts.index ~= nil then
      LOG.warn("layout.takeTo: guid and index are exclusive; using guid", opts.guid)
    end
    params.guid = opts.guid
  elseif opts.index ~= nil then
    params.index = opts.index
  end

  bag.takeObject(params)
  return true
end

-- snaps(anchor, list) — attach snap points from the same local coordinates the
-- spaces table uses.  A snap point is data, not code: it makes a position exist
-- for the player as well as for the script, and a tagged one accepts only the
-- component that belongs there.  The owner's prototypes have none; Politik has
-- 1,562.
--
--   layout.snaps("board", {
--     { at = "deck", tags = { "card" } },
--     { at = { 0.2, layout.LAYER.board, 0.1 }, facing = 180, rotationSnap = true },
--   })
function L.snaps(anchor, list)
  local object = L.anchorObject(anchor)
  if not object then return false end
  LOG.assert(type(list) == "table", "layout.snaps needs a list")

  local points = {}
  for _, entry in ipairs(list) do
    local position = L.localOf(entry.at)
    if position then
      points[#points + 1] = {
        position = position,
        rotation = (entry.facing ~= nil) and { x = 0, y = entry.facing, z = 0 } or nil,
        rotation_snap = entry.rotationSnap == true,
        tags = entry.tags,
      }
    end
  end
  LOG.info("layout.snaps: " .. #points .. " snap points")
  return object.setSnapPoints(points)
end
