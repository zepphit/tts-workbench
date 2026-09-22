-- test/harness.lua — a stub Tabletop Simulator, enough to run ttslib outside it.
--
-- Critique C10 is "no source tree, no build, no tests".  A framework that
-- answers it cannot ship untested, and the only real test of TTS code is TTS
-- itself — so this harness is deliberately modest about what it proves:
--
--   it does prove   the library parses, its modules load in order, and its
--                   logic (name -> index, tag routing, coercion, debounce
--                   windows, cache invalidation, anchor transforms) behaves
--                   the way the documentation says
--   it cannot prove anything about TTS's own semantics — whether tags match
--                   case-insensitively, when spawn callbacks really fire, or
--                   what the physics engine does with a smooth move
--
-- Run it with luajit (Lua 5.1; TTS is 5.2, and ttslib avoids the differences):
--
--   luajit reference/framework/test/ttslib_spec.lua
--
-- The scheduler here is manual: nothing happens until you call H.tick(n).

local H = {}

H.frame = 0
H.printed = {} -- everything the log module emitted, newest last

-- --------------------------------------------------------------- minimal JSON

local function encode(value)
  local kind = type(value)
  if kind == "nil" then
    return "null"
  elseif kind == "boolean" or kind == "number" then
    return tostring(value)
  elseif kind == "string" then
    return '"' .. value:gsub('[%c"\\]', function(c)
      if c == '"' then return '\\"' end
      if c == "\\" then return "\\\\" end
      if c == "\n" then return "\\n" end
      return string.format("\\u%04x", c:byte())
    end) .. '"'
  elseif kind == "table" then
    local isArray, n = true, 0
    for k in pairs(value) do
      n = n + 1
      if type(k) ~= "number" then isArray = false end
    end
    local parts = {}
    if isArray and n == #value then
      for _, v in ipairs(value) do
        parts[#parts + 1] = encode(v)
      end
      return "[" .. table.concat(parts, ",") .. "]"
    end
    for k, v in pairs(value) do
      parts[#parts + 1] = encode(tostring(k)) .. ":" .. encode(v)
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  error("cannot encode " .. kind)
end

local function decode(text)
  local pos = 1
  local parseValue

  local function skip()
    while pos <= #text and text:sub(pos, pos):match("%s") do
      pos = pos + 1
    end
  end

  local function parseString()
    pos = pos + 1 -- opening quote
    local out = {}
    while pos <= #text do
      local c = text:sub(pos, pos)
      if c == '"' then
        pos = pos + 1
        return table.concat(out)
      elseif c == "\\" then
        local escaped = text:sub(pos + 1, pos + 1)
        if escaped == "n" then
          out[#out + 1] = "\n"
        elseif escaped == "u" then
          out[#out + 1] = string.char(tonumber(text:sub(pos + 2, pos + 5), 16) % 256)
          pos = pos + 4
        else
          out[#out + 1] = escaped
        end
        pos = pos + 2
      else
        out[#out + 1] = c
        pos = pos + 1
      end
    end
    error("unterminated string")
  end

  parseValue = function()
    skip()
    local c = text:sub(pos, pos)
    if c == "{" then
      pos = pos + 1
      local out = {}
      skip()
      if text:sub(pos, pos) == "}" then
        pos = pos + 1
        return out
      end
      while true do
        skip()
        local key = parseString()
        skip()
        pos = pos + 1 -- colon
        out[key] = parseValue()
        skip()
        local sep = text:sub(pos, pos)
        pos = pos + 1
        if sep == "}" then return out end
      end
    elseif c == "[" then
      pos = pos + 1
      local out = {}
      skip()
      if text:sub(pos, pos) == "]" then
        pos = pos + 1
        return out
      end
      while true do
        out[#out + 1] = parseValue()
        skip()
        local sep = text:sub(pos, pos)
        pos = pos + 1
        if sep == "]" then return out end
      end
    elseif c == '"' then
      return parseString()
    else
      local literal = text:match("^[%w%.%+%-eE]+", pos)
      if not literal then error("bad JSON at " .. pos) end
      pos = pos + #literal
      if literal == "true" then return true end
      if literal == "false" then return false end
      if literal == "null" then return nil end
      return tonumber(literal)
    end
  end

  local ok, result = pcall(parseValue)
  if not ok then return nil end
  return result
end

-- -------------------------------------------------------------- fake objects

local nextGuid = 0

-- H.object{ tags = {...}, position = {...}, scale = {...}, contents = n }
function H.object(spec)
  spec = spec or {}
  nextGuid = nextGuid + 1

  local obj
  obj = {
    guid = spec.guid or string.format("%06x", nextGuid),
    tags = spec.tags or {},
    buttons = {},
    menuItems = {}, -- right-click items; like buttons, TTS never saves these
    vars = {},
    snapPoints = nil,
    destroyed = false,
    quantity = spec.contents or 0,
    name = spec.name or "",
    position = spec.position or { x = 0, y = 0, z = 0 },
    rotation = spec.rotation or { x = 0, y = 0, z = 0 },
    scale = spec.scale or { x = 1, y = 1, z = 1 },
    resting = (spec.resting ~= false),
    smoothMoving = false,
  }

  function obj.getGUID() return obj.guid end
  function obj.getName() return obj.name end
  function obj.isDestroyed() return obj.destroyed end
  function obj.isSmoothMoving() return obj.smoothMoving end
  function obj.getQuantity() return obj.quantity end

  function obj.getTags()
    local copy = {}
    for i, t in ipairs(obj.tags) do copy[i] = t end
    return copy
  end

  function obj.hasTag(tag)
    for _, t in ipairs(obj.tags) do
      if t == tag then return true end -- TTS's own case behaviour is unknown
    end
    return false
  end

  function obj.addTag(tag)
    if not obj.hasTag(tag) then obj.tags[#obj.tags + 1] = tag end
    return true
  end

  function obj.removeTag(tag)
    for i, t in ipairs(obj.tags) do
      if t == tag then
        table.remove(obj.tags, i)
        return true
      end
    end
    return false
  end

  -- Buttons, with TTS's indexing rules: 0-based, and removing one shifts every
  -- higher index down by one.  getButtons returns nil when there are none.
  function obj.getButtons()
    if #obj.buttons == 0 then return nil end
    local out = {}
    for i, b in ipairs(obj.buttons) do
      local copy = {}
      for k, v in pairs(b) do copy[k] = v end
      copy.index = i - 1
      out[i] = copy
    end
    return out
  end

  function obj.createButton(params)
    local copy = {}
    for k, v in pairs(params) do copy[k] = v end
    obj.buttons[#obj.buttons + 1] = copy
    return true
  end

  function obj.editButton(params)
    local button = obj.buttons[(params.index or 0) + 1]
    if not button then return false end
    for k, v in pairs(params) do
      if k ~= "index" then button[k] = v end
    end
    return true
  end

  function obj.removeButton(index)
    if not obj.buttons[index + 1] then return false end
    table.remove(obj.buttons, index + 1)
    return true
  end

  function obj.clearButtons()
    obj.buttons = {}
    return true
  end

  -- The right-click menu.  Recorded rather than rendered, and `fire` is the
  -- test's way in: a menu item is a callback with no other handle on it.
  function obj.addContextMenuItem(label, callback, keepOpen)
    obj.menuItems[#obj.menuItems + 1] =
      { label = label, callback = callback, keep_open = keepOpen == true }
    return true
  end

  function obj.clearContextMenu()
    obj.menuItems = {}
    return true
  end

  function obj.fireContextMenuItem(label, playerColour)
    for _, item in ipairs(obj.menuItems) do
      if item.label == label then
        item.callback(playerColour or "White", obj.position, obj)
        return true
      end
    end
    return false
  end

  function obj.setVar(name, value)
    obj.vars[name] = value
    return true
  end

  function obj.getVar(name) return obj.vars[name] end

  function obj.call(name, params)
    local fn = obj.vars[name]
    if fn then return fn(params) end
  end

  function obj.getPosition() return obj.position end
  function obj.getRotation() return obj.rotation end
  function obj.getScale() return obj.scale end

  function obj.setPosition(v) obj.position = v; return true end
  function obj.setRotation(v) obj.rotation = v; return true end

  -- Rescaling matters to layout: basis() is scale times mesh, so an object that
  -- is resized changes what every local coordinate measured against it means.
  -- The stub keeps `mesh` fixed and moves `scale`, which is what TTS does.
  function obj.setScale(v) obj.scale = v; return true end

  function obj.setPositionSmooth(v, collide, fast)
    obj.position = v
    obj.lastMove = { collide = collide, fast = fast } -- argument order matters
    obj.smoothMoving = false -- the harness settles instantly; TTS does not
    return true
  end

  function obj.setRotationSmooth(v) obj.rotation = v; return true end

  -- Position/rotation/scale applied, like the real thing: this is what makes
  -- anchor-relative coordinates follow a board that has been moved or scaled.
  --
  -- **`mesh` is not decoration.**  Local space is the *mesh's* space, and a
  -- built-in's mesh is not always a unit cube — TTS's `BlockRectangle` measures
  -- 1 x 1 x 2, so a plate at scale 20 x 0.2 x 17 is 34 deep and its
  -- `positionToWorld({0,0,1}).z` is 34.  A stub that multiplied by `scale`
  -- alone said otherwise, and let Amazonia ship a hex map stretched by exactly
  -- that factor along one axis (2026-09-21).  Default it to a unit cube, and
  -- pass `mesh = { x = 1, y = 1, z = 2 }` to model a BlockRectangle.
  local mesh = spec.mesh or { x = 1, y = 1, z = 1 }
  obj.mesh = { x = mesh.x or 1, y = mesh.y or 1, z = mesh.z or 1 }

  function obj.positionToWorld(v)
    local rad = math.rad(obj.rotation.y or 0)
    local x = (v.x or 0) * obj.scale.x * obj.mesh.x
    local z = (v.z or 0) * obj.scale.z * obj.mesh.z
    return {
      x = obj.position.x + x * math.cos(rad) + z * math.sin(rad),
      y = obj.position.y + (v.y or 0) * obj.scale.y * obj.mesh.y,
      z = obj.position.z - x * math.sin(rad) + z * math.cos(rad),
    }
  end

  function obj.positionToLocal(v)
    local rad = math.rad(obj.rotation.y or 0)
    local dx = (v.x or 0) - obj.position.x
    local dz = (v.z or 0) - obj.position.z
    return {
      x = (dx * math.cos(rad) - dz * math.sin(rad)) / (obj.scale.x * obj.mesh.x),
      y = ((v.y or 0) - obj.position.y) / (obj.scale.y * obj.mesh.y),
      z = (dx * math.sin(rad) + dz * math.cos(rad)) / (obj.scale.z * obj.mesh.z),
    }
  end

  function obj.setSnapPoints(points) obj.snapPoints = points; return true end
  function obj.getSnapPoints() return obj.snapPoints or {} end

  -- takeObject spawns on a later frame, and its callback runs then.
  function obj.takeObject(params)
    params = params or {}
    if obj.quantity > 0 then obj.quantity = obj.quantity - 1 end
    -- spawn = false, then H.spawn: H.object spawns by default, and taking the
    -- default here put every taken object on the table twice and fired
    -- onObjectSpawn twice for it.
    local taken = H.object({
      tags = spec.childTags, position = params.position, spawn = false,
    })
    taken.rotation = params.rotation or taken.rotation
    H.spawn(taken)
    if params.callback_function then
      H.schedule(2, function() params.callback_function(taken) end)
    end
    return taken
  end

  if spec.spawn ~= false then H.spawn(obj) end
  return obj
end

-- ------------------------------------------------------------- the TTS table

H.objects = {}

function H.spawn(obj)
  H.objects[#H.objects + 1] = obj
  if _G.onObjectSpawn then _G.onObjectSpawn(obj) end
  return obj
end

function H.destroy(obj)
  if _G.onObjectDestroy then _G.onObjectDestroy(obj) end -- fires before removal
  obj.destroyed = true
  for i, o in ipairs(H.objects) do
    if o == obj then
      table.remove(H.objects, i)
      break
    end
  end
end

-- ----------------------------------------------------------- Wait, by hand

local scheduled = {}
local nextWaitId = 0

function H.schedule(frames, fn)
  nextWaitId = nextWaitId + 1
  scheduled[nextWaitId] = { kind = "frames", due = H.frame + (frames or 1), fn = fn }
  return nextWaitId
end

-- tick(n) — advance n frames, running whatever comes due.  One frame is 1/60 s
-- of Time.time, which is what the debounce window is measured against.
function H.tick(frames)
  for _ = 1, (frames or 1) do
    H.frame = H.frame + 1
    Time.time = Time.time + 1 / 60
    local due = {}
    for id, task in pairs(scheduled) do
      if task.kind == "frames" and H.frame >= task.due then
        due[#due + 1] = id
      elseif task.kind == "time" and Time.time >= task.due then
        due[#due + 1] = id
      elseif task.kind == "condition" then
        if task.cond() then
          due[#due + 1] = id
        elseif task.deadline and Time.time >= task.deadline then
          scheduled[id] = nil
          if task.timeoutFn then task.timeoutFn() end
        end
      end
    end
    table.sort(due)
    for _, id in ipairs(due) do
      local task = scheduled[id]
      if task then
        if task.kind == "time" and task.repetitions == -1 then
          task.due = Time.time + task.seconds
        else
          scheduled[id] = nil
        end
        task.fn()
      end
    end
  end
end

function H.pendingWaits()
  local n = 0
  for _ in pairs(scheduled) do n = n + 1 end
  return n
end

-- --------------------------------------------------------------- the globals

function H.install()
  H.frame = 0
  H.objects = {}
  H.printed = {}
  scheduled = {}

  _G.Time = { time = 0, delta_time = 1 / 60 }

  _G.JSON = { encode = encode, decode = decode }

  _G.Wait = {
    frames = function(fn, frames)
      nextWaitId = nextWaitId + 1
      scheduled[nextWaitId] = { kind = "frames", due = H.frame + (frames or 1), fn = fn }
      return nextWaitId
    end,
    time = function(fn, seconds, repetitions)
      nextWaitId = nextWaitId + 1
      scheduled[nextWaitId] = {
        kind = "time",
        due = Time.time + seconds,
        seconds = seconds,
        repetitions = repetitions,
        fn = fn,
      }
      return nextWaitId
    end,
    condition = function(fn, cond, timeout, timeoutFn)
      nextWaitId = nextWaitId + 1
      scheduled[nextWaitId] = {
        kind = "condition",
        fn = fn,
        cond = cond,
        deadline = timeout and (Time.time + timeout) or nil,
        timeoutFn = timeoutFn,
      }
      return nextWaitId
    end,
    stop = function(id)
      local had = scheduled[id] ~= nil
      scheduled[id] = nil
      return had
    end,
    stopAll = function() scheduled = {} end,
  }

  local function record(text)
    H.printed[#H.printed + 1] = tostring(text)
  end
  _G.print = record
  _G.log = record
  _G.broadcastToAll = function(text) record("BROADCAST " .. tostring(text)) end
  _G.broadcastToColor = function(text) record("BROADCAST " .. tostring(text)) end

  _G.getObjects = function()
    local out = {}
    for i, o in ipairs(H.objects) do out[i] = o end
    return out
  end

  _G.getObjectsWithTag = function(tag)
    local out = {}
    for _, o in ipairs(H.objects) do
      if o.hasTag(tag) then out[#out + 1] = o end
    end
    return out
  end

  _G.getObjectFromGUID = function(guid)
    for _, o in ipairs(H.objects) do
      if o.guid == guid then return o end
    end
    return nil
  end

  -- The Global script's own environment object.  In an object script this
  -- would be `self`; ttslib.ui resolves `self or Global`.
  _G.Global = H.object({ spawn = false, guid = "global" })
  _G.UI = {
    setXml = function() return true end,
    setAttribute = function() return true end,
    setAttributes = function() return true end,
    setValue = function() return true end,
    show = function() return true end,
    hide = function() return true end,
  }
end

-- Load the library the same way a build does: in filename order.
function H.loadLibrary(directory)
  _G.ttslib = nil
  local files = {
    "00-log.lua", "01-async.lua", "02-store.lua", "03-ui.lua",
    "04-events.lua", "05-registry.lua", "06-layout.lua",
  }
  for _, file in ipairs(files) do
    local chunk, err = loadfile(directory .. "/" .. file)
    if not chunk then error(err) end
    chunk()
  end
  ttslib.log.level = "info" -- keep the test output readable
  return ttslib
end

-- Everything a test wants reset between cases.
function H.reset(directory)
  for _, name in ipairs({
    "onObjectSpawn", "onObjectDestroy", "onObjectEnterContainer",
    "onObjectLeaveContainer", "onObjectEnterZone", "onObjectLeaveZone",
    "onObjectDrop", "onObjectPickUp", "onObjectRandomize",
    "onObjectStateChange", "onObjectNumberTyped", "onObjectRotate",
    "onObjectPeek",
  }) do
    _G[name] = nil
  end
  H.install()
  return H.loadLibrary(directory)
end

function H.logged(pattern)
  for _, line in ipairs(H.printed) do
    if line:find(pattern, 1, true) then return line end
  end
  return nil
end

return H
