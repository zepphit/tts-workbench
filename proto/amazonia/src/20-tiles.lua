-- src/20-tiles.lua — one tile: spawn it, tint it, reskin it, label its hubs.
--
-- A tile is a Custom_Model carrying three assets that must agree — mesh,
-- collider and diffuse — so nothing here writes a URL by hand; they all come
-- out of ART, which tilegen.py generated from the spec.
--
-- The costs are deliberately uneven, and that asymmetry is the whole reason the
-- build plan has three loop tiers:
--
--   tint    setColorTint, instant, no respawn        L1, ~100 tokens
--   reskin  a new diffuse, so a new object           L2, ~2 seconds
--
-- reskin respawns rather than calling reload().  Arcs' exemplar
-- (src__SetupControl.lua:1112) does getCustomObject -> setCustomObject ->
-- reload(), and that works — but reload() destroys and respawns the object, the
-- docs say nothing about what happens to its buttons, and these tiles carry
-- hub buttons.  spawnObjectData writes the whole block in one call with no
-- reload at all, and we have to re-place the buttons either way.

local LOG = ttslib.log
local ASYNC = ttslib.async
local REG = ttslib.registry
local UI_ = ttslib.ui

Tiles = {}

-- Set while the map is being rebuilt, so 40-journal.lua can report "built 24
-- tiles" instead of 24 separate spawn lines.
Tiles.bulk = false

-- --------------------------------------------------------------- the catalog

function Tiles.kinds()
  local names = {}
  for name in pairs(ART.kinds) do names[#names + 1] = name end
  table.sort(names)
  return names
end

function Tiles.kind(name)
  local kind = ART.kinds[name]
  if not kind then
    LOG.error("no tile kind '" .. tostring(name) .. "'",
      "known: " .. table.concat(Tiles.kinds(), ", "))
  end
  return kind
end

function Tiles.shape(name)
  local kind = Tiles.kind(name)
  return kind and ART.shapes[kind.shape] or nil
end

-- pool(shape) — the kinds with a positive weight, as rng.pick wants them.
--
-- The shape filter is load-bearing, not tidiness.  A map's lattice is packed
-- for one shape (30-map.lua), so dropping a one-hex `clearing` into a slot cut
-- for a tri-hex leaves two hexes bare and a hole in the map.  Kinds of other
-- shapes stay in the catalogue — AZ.shape() relays the whole map in one of them —
-- they just do not turn up in this map's draw.  A kind at weight 0 (the UV
-- probe) is in the catalogue and out of every draw.
function Tiles.pool(shape)
  local out = {}
  for _, name in ipairs(Tiles.kinds()) do
    local kind = ART.kinds[name]
    local weight = tonumber(kind.weight) or 0
    if weight > 0 and (shape == nil or kind.shape == shape) then
      out[#out + 1] = { weight, name }
    end
  end
  return out
end

-- colour("2E6B33") or colour({r,g,b}) -> a TTS colour table.
function Tiles.colour(value)
  if type(value) == "table" then
    return { r = value.r or value[1] or 1, g = value.g or value[2] or 1,
      b = value.b or value[3] or 1 }
  end
  local text = tostring(value):gsub("^#", "")
  if #text ~= 6 or text:match("%X") then
    LOG.error("'" .. tostring(value) .. "' is not a six-digit hex colour")
    return nil
  end
  return {
    r = tonumber(text:sub(1, 2), 16) / 255,
    g = tonumber(text:sub(3, 4), 16) / 255,
    b = tonumber(text:sub(5, 6), 16) / 255,
  }
end

-- ------------------------------------------------------------------- spawning

-- data(name, opts) — the object table spawnObjectData wants.
--
-- The flags are RotLA's, read off Saves/TS_Save_122 ObjectStates[330]: Locked,
-- Grid, Snap and Sticky true, scaleY 0.5, Convex true, MaterialIndex 3 (
-- Cardboard), TypeIndex 0 (Generic).  GMNotes carries the kind, which is what
-- lets a tile that has been through a save/reload still say what it is.
function Tiles.data(name, opts)
  opts = opts or {}
  local kind = Tiles.kind(name)
  if not kind then return nil end
  local shape = ART.shapes[kind.shape]
  if not shape then
    LOG.error("kind '" .. name .. "' names shape '" .. tostring(kind.shape) ..
      "', which art/index.lua does not define")
    return nil
  end

  local position = opts.position or { x = 0, y = 2, z = 0 }
  local tint = opts.tint and Tiles.colour(opts.tint) or {
    r = kind.tint[1], g = kind.tint[2], b = kind.tint[3],
  }

  -- Not `(opts.locked ~= nil) and opts.locked or TILES.locked`: that idiom
  -- cannot express false. `true and false or true` is true, so an explicit
  -- `locked = false` came out locked — which silently re-locked an unlocked
  -- tile on every reskin and gave the tray a palette nobody could pick up.
  local locked = TILES.locked
  if opts.locked ~= nil then locked = opts.locked == true end

  return {
    Name = "Custom_Model",
    Transform = {
      posX = position.x, posY = position.y, posZ = position.z,
      rotX = 0, rotY = opts.rotY or 0, rotZ = 0,
      scaleX = 1, scaleY = TILES.scaleY, scaleZ = 1,
    },
    Nickname = kind.label,
    Description = "",
    GMNotes = name,
    ColorDiffuse = tint,
    Tags = opts.tags or { "tile", "tile." .. name },
    Locked = locked,
    -- Grid and Snap are RotLA's defaults and both are off here: a tile that
    -- obeys the table grid or the snap lattice drags everything near it into
    -- line, and this prototype is at the stage of pushing terrain around by
    -- hand. AZ.snap(true) restores the lattice; these two follow TILES.
    Grid = TILES.grid,
    Snap = TILES.snap,
    Sticky = true,
    Autoraise = true,
    DragSelectable = true,
    Tooltip = true,
    GridProjection = false,
    HideWhenFaceDown = false,
    Hands = false,
    CustomMesh = {
      MeshURL = shape.mesh,
      DiffuseURL = opts.diffuse or kind.diffuse,
      ColliderURL = shape.collider,
      Convex = TILES.convex,
      MaterialIndex = TILES.material,
      TypeIndex = 0,
      CastShadows = true,
    },
    LuaScript = "",
    LuaScriptState = "",
    XmlUI = "",
  }
end

-- spawn(name, position, rotY, opts) — one tile, with its hub buttons applied
-- once it exists.  opts.onSpawned is called with the object.
function Tiles.spawn(name, position, rotY, opts)
  opts = opts or {}
  local tags = opts.tags or { "tile", "tile." .. name }
  local data = Tiles.data(name, {
    position = position, rotY = rotY, tint = opts.tint, diffuse = opts.diffuse,
    locked = opts.locked, tags = tags,
  })
  if not data then return nil end

  return spawnObjectData({
    data = data,
    callback_function = function(obj)
      if ASYNC.gone(obj) then return end
      -- Tags are in the data table already; re-asserting is cheap insurance,
      -- and the registry has no event for a tag change so it is told directly.
      for _, tag in ipairs(tags) do
        obj.addTag(tag)
        REG.invalidate(tag)
      end
      Tiles.hubs(obj)
      if opts.onSpawned then
        LOG.attempt("Tiles.spawn onSpawned", opts.onSpawned, obj)
      end
    end,
  })
end

-- kindOf(obj) — a tile's kind, from GMNotes, which survives a save and reload.
function Tiles.kindOf(obj)
  if not obj or ASYNC.gone(obj) then return nil end
  local notes = obj.getGMNotes and obj.getGMNotes() or nil
  if notes and ART.kinds[notes] then return notes end
  return nil
end

function Tiles.all()
  return REG.all("tile")
end

function Tiles.ofKind(name)
  return REG.all("tile." .. name)
end

-- onMap(list) — the tiles that are part of the map, which is every tile that is
-- not sitting in the tray.  The split is a tag, not a second registry: tint,
-- reskin and lock want *every* tile of a kind including the palette, while
-- build, clear and the tile count want only what is laid out.  Passing a list
-- filters that list instead of querying.
function Tiles.onMap(list)
  local out = {}
  for _, obj in ipairs(list or Tiles.all()) do
    if not ASYNC.gone(obj) and not obj.hasTag(TRAY.tag) then
      out[#out + 1] = obj
    end
  end
  return out
end

function Tiles.inTray()
  return REG.all(TRAY.tag)
end

-- ----------------------------------------------------------------- hub buttons

-- hubs(obj) — draw the tile's hub stripes, one per cell that has a resource.
--
-- Buttons are by name through ttslib.ui, so calling this again after a reskin
-- edits them rather than stacking a second set; TTS does not save scripted
-- buttons, so it also has to run on every load.
--
-- **The counter-rotation is the point of this function's `rotation`.**  A
-- button's `position` and `rotation` are both relative to the object, so a tile
-- spawned at rotY 120 renders its labels turned 120 degrees too — on a map
-- whose tiles use all six rotations to interlock, that means text lying on its
-- side or upside down, which is what the first build looked like.  `position`
-- *should* turn with the tile, because the cell it points at moves; the text
-- should not.  Cancelling the tile's own Y rotation pins every label to one
-- direction across the whole map, whatever the tile underneath is doing.
--
-- It reads the tile's rotation at draw time rather than the slot's, so a tile
-- the owner turned by hand is handled the same way — and 99-Global.lua calls
-- this again on the rotate event so it does not drift.
function Tiles.hubs(obj)
  if not obj or ASYNC.gone(obj) then return false end
  local name = Tiles.kindOf(obj)
  if not name then return false end
  -- A tile whose kind has been deleted from the spec outlives it on the table,
  -- and this used to dereference ART.kinds[name] straight into a nil index —
  -- one retired kind and the whole of onLoad stopped, after the tiles were
  -- restored but before the tray and the HUD. Tray.sync destroys them; this is
  -- the guard that keeps one from taking the boot down before it gets there.
  local kind = ART.kinds[name]
  if not kind then
    LOG.once("tile.kind." .. name, "error",
      "tile " .. tostring(obj.getGUID()) .. " is kind '" .. name ..
      "', which the catalogue no longer has")
    return false
  end
  local shape = ART.shapes[kind.shape]
  if not shape then return false end

  -- Labels off: clear any stripe this tile is carrying and stop.  It has to
  -- *remove* rather than just decline to draw, so that AZ.labels(false) takes
  -- effect on tiles that are already on the table.
  if not HUB.enabled then
    for index = 1, #shape.cells do
      UI_.remove(obj, "hub" .. index)
    end
    return false
  end

  -- Cancel the tile's own spin, then add the baseline: HUB.facing is 180
  -- because a button at rotation 0 on an upright object reads upside down.
  local facing = (HUB.facing or 0) - ((obj.getRotation() or {}).y or 0)

  for index = 1, #shape.cells do
    local resource = kind.hubs[index]
    local label = "hub" .. index
    if resource then
      local cell = shape.cells[index]
      local x, z = hex.toWorld(cell[1], cell[2], ART.radius)
      UI_.button(obj, label, {
        label = resource,
        position = { x, HUB.y, z },
        rotation = { 0, facing, 0 },
        width = HUB.width,
        height = HUB.height,
        font_size = HUB.fontSize,
        color = HUB.colour,
        font_color = HUB.fontColour,
        tooltip = kind.label .. " — harvests " .. resource ..
            " (right-click to change)",
        onClick = function(clicked, playerColour, altClick)
          if altClick then
            Tiles.cycleHub(name, index, playerColour)
          else
            Journal.emit("harvest", {
              kind = name, cell = index, resource = resource,
              who = playerColour, at = Journal.where(clicked),
            })
            broadcastToColor(kind.label .. " cell " .. index .. ": " .. resource,
              playerColour, { 0.85, 0.82, 0.76 })
          end
        end,
      })
    else
      UI_.remove(obj, label)
    end
  end
  return true
end

-- hub(kind, cell, resource, n) — set or clear a hub and redraw every tile of
-- that kind.  `resource` may be nil or "" to remove it; `n` is an optional
-- count shown after the name.  This edits ART in memory, which is the live
-- half of spec/tiles.json — persist it by writing the spec and regenerating.
function Tiles.hub(name, cell, resource, n)
  local kind = Tiles.kind(name)
  if not kind then return false end
  cell = tonumber(cell) or 1
  local shape = ART.shapes[kind.shape]
  if not shape or cell < 1 or cell > #shape.cells then
    LOG.error("kind '" .. name .. "' has no cell " .. tostring(cell),
      "it has " .. (shape and #shape.cells or 0))
    return false
  end

  if resource == nil or resource == "" then
    kind.hubs[cell] = nil
  else
    kind.hubs[cell] = n and (tostring(resource) .. " " .. tostring(n))
        or tostring(resource)
  end
  for _, obj in ipairs(Tiles.ofKind(name)) do
    Tiles.hubs(obj)
  end
  LOG.info("hub " .. name .. "[" .. cell .. "] = " ..
    tostring(kind.hubs[cell] or "none"))
  return true
end

function Tiles.cycleHub(name, cell, playerColour)
  local kind = Tiles.kind(name)
  if not kind then return false end
  local current = kind.hubs[cell]
  local index = 0
  for i, resource in ipairs(RESOURCES) do
    if current and current:find(resource, 1, true) then index = i end
  end
  local nextResource = RESOURCES[(index % #RESOURCES) + 1]
  Tiles.hub(name, cell, nextResource)
  Journal.emit("hub", { kind = name, cell = cell, resource = nextResource,
    who = playerColour })
  return true
end

-- ----------------------------------------------------------- live appearance

-- tint(kind, colour) — L1.  Multiplicative over the greyscale diffuse, so it
-- darkens and shifts but never brightens past the source pixel; that is why
-- the generated art is light grey rather than mid grey.
function Tiles.tint(name, colour)
  local kind = Tiles.kind(name)
  if not kind then return false end
  local rgb = Tiles.colour(colour)
  if not rgb then return false end

  kind.tint = { rgb.r, rgb.g, rgb.b }
  local tiles = Tiles.ofKind(name)
  for _, obj in ipairs(tiles) do
    if not ASYNC.gone(obj) then obj.setColorTint(rgb) end
  end
  LOG.info("tint " .. name .. " -> " .. tostring(colour) ..
    " (" .. #tiles .. " tiles)")
  Journal.emit("tint", { kind = name, colour = tostring(colour), n = #tiles })
  return #tiles
end

-- reskin(kind, url) — L2.  Respawn every tile of a kind with a new diffuse,
-- keeping its transform, its lock state and its hubs.
--
-- `url` defaults to whatever art/index.lua now holds for the kind, which is the
-- normal case: edit spec/tiles.json, run tilegen.py, and the new content hash
-- makes a new URL that TTS has never cached.  Passing one explicitly is for
-- trying an asset that is not in the spec yet.
function Tiles.reskin(name, url)
  local kind = Tiles.kind(name)
  if not kind then return false end
  if url and url ~= "" then kind.diffuse = tostring(url) end

  local old = Tiles.ofKind(name)
  local plan = {}
  for _, obj in ipairs(old) do
    if not ASYNC.gone(obj) then
      plan[#plan + 1] = {
        position = obj.getPosition(),
        rotY = (obj.getRotation() or {}).y or 0,
        locked = obj.getLock(),
        -- Tags travel with the tile, or a reskin would quietly move every tray
        -- tile onto the map: the tray is a tag and nothing else.
        tags = obj.getTags(),
      }
    end
  end
  for _, obj in ipairs(old) do
    if not ASYNC.gone(obj) then destroyObject(obj) end
  end
  REG.invalidate()

  for _, entry in ipairs(plan) do
    Tiles.spawn(name, entry.position, entry.rotY,
      { locked = entry.locked, tags = entry.tags })
  end
  LOG.info("reskin " .. name .. " -> " .. tostring(kind.diffuse),
    #plan .. " tiles")
  Journal.emit("reskin", { kind = name, n = #plan, url = kind.diffuse })
  return #plan
end

-- repin(obj) — redraw one tile's stripes after it has been turned.
--
-- onObjectRotate fires while the rotation is still animating, so reading
-- getRotation() in the handler gives the angle it is leaving, not the one it is
-- arriving at.  A keyed wait per object coalesces a spin into one redraw once
-- it has settled, which is also what stops a flick through several faces from
-- costing one redraw per face.
function Tiles.repin(obj)
  if not obj or ASYNC.gone(obj) then return false end
  ASYNC.keyed("hub.repin." .. tostring(obj.getGUID()), 0.4, function()
    if not ASYNC.gone(obj) then Tiles.hubs(obj) end
  end)
  return true
end

-- restyle(width, height, fontSize) — HUB's three numbers, live.
--
-- Stripe proportions are the kind of thing that can only be judged on the
-- table, and rebuilding a save to try a font size is the opposite of what this
-- rig is for.  Any argument left nil keeps its current value.  Copy what you
-- settle on back into 00-config.lua, which is the source of truth.
-- face(degrees) — the baseline every stripe is turned to, live.
--
-- Separate from restyle because it answers a different question: not "how big",
-- but "which way is up for text on this table". 180 is TTS's own convention,
-- 0 / 90 / 270 are the other quarter turns if a different camera wants them.
function Tiles.face(degrees)
  HUB.facing = (tonumber(degrees) or HUB.facing) % 360
  local tiles = Tiles.all()
  for _, obj in ipairs(tiles) do
    Tiles.hubs(obj)
  end
  LOG.info("hub facing: " .. HUB.facing .. " (" .. #tiles .. " tiles)")
  return HUB.facing
end

-- labels(on) — the resource stripes as a whole, live.  Off by default: the
-- tiles are meant to read as plain terrain while the terrain is what is being
-- designed.  Turning them on only shows a stripe where spec/tiles.json gives a
-- kind `hubs`, which nothing does at the moment.
function Tiles.labels(on)
  HUB.enabled = on ~= false
  local tiles = Tiles.all()
  for _, obj in ipairs(tiles) do
    Tiles.hubs(obj)
  end
  local labelled = 0
  for _, name in ipairs(Tiles.kinds()) do
    if #(ART.kinds[name].hubs or {}) > 0 then labelled = labelled + 1 end
  end
  LOG.info("labels " .. (HUB.enabled and "on" or "off") ..
    " (" .. #tiles .. " tiles, " .. labelled .. " kinds carry any)")
  return HUB.enabled
end

-- reskinAll() — every kind, after an edit that moved more than one of them.
-- A terrain colour is baked into every painted tile that touches that terrain,
-- so changing `terrains` in the spec is not a tint but a regenerate: run
-- tilegen.py, then this.
function Tiles.reskinAll()
  local total = 0
  for _, name in ipairs(Tiles.kinds()) do
    local n = Tiles.reskin(name)
    if type(n) == "number" then total = total + n end
  end
  LOG.info("reskinned " .. total .. " tiles across " .. #Tiles.kinds() .. " kinds")
  return total
end

function Tiles.restyle(width, height, fontSize)
  HUB.width = tonumber(width) or HUB.width
  HUB.height = tonumber(height) or HUB.height
  HUB.fontSize = tonumber(fontSize) or HUB.fontSize
  local tiles = Tiles.all()
  for _, obj in ipairs(tiles) do
    Tiles.hubs(obj)
  end
  LOG.info(string.format("hub style: width=%s height=%s font=%s (%d tiles)",
    HUB.width, HUB.height, HUB.fontSize, #tiles))
  return string.format("width=%s height=%s font=%s",
    HUB.width, HUB.height, HUB.fontSize)
end

-- lock(on, kind) — tiles ship locked, because an unlocked map drifts under the
-- first dropped cube.  Unlock to rearrange by hand; the changelog still sees it.
function Tiles.lock(on, name)
  local list = name and Tiles.ofKind(name) or Tiles.all()
  for _, obj in ipairs(list) do
    if not ASYNC.gone(obj) then obj.setLock(on ~= false) end
  end
  LOG.info((on ~= false and "locked " or "unlocked ") .. #list .. " tiles")
  return #list
end
