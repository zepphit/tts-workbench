local MIN_VALUE = 0
local MAX_VALUE = 999
local INCREMENT = 1
local NUM_VALS = 3
local COLOR_INVISIBLE = "rgba(0,0,0,0)"
local data
local lastTint = nil

-- Resource names for announcements
local RESOURCE_NAMES = {
  "Capital",
  "Carbon",
  "Food"
}

------------------------------------------------------------
function getValId(id)
  return "val" .. string.sub(id, -1)
end
function getMinusId(id)
  return "minus" .. string.sub(id, -1)
end
function getPlusId(id)
  return "plus" .. string.sub(id, -1)
end
function getResourceName(valId)
  local index = tonumber(string.sub(valId, -1))
  return RESOURCE_NAMES[index] or "Unknown"
end
------------------------------------------------------------
function updateVal(player, value, id)
  local valId = id
  local oldValue = data[valId]
  data[valId] = tonumber(value)
  self.UI.setAttribute(valId, "text", data[valId])
  if data[valId] ~= nil then
    if MIN_VALUE ~= nil and data[valId] < MIN_VALUE then
      data[valId] = MIN_VALUE
      self.UI.setAttribute(valId, "text", data[valId])
    end
    if MAX_VALUE ~= nil and data[valId] > MAX_VALUE then
      data[valId] = MAX_VALUE
      self.UI.setAttribute(valId, "text", data[valId])
    end
  end
  
  -- Announce the change if value actually changed
  -- Note: player parameter here is actually the player object when called from UI input
  if oldValue ~= nil and oldValue ~= data[valId] then
    announceChange(valId, oldValue, data[valId], player)
  end
end
function adjust(player, value, id)
  if string.sub(id, 0, 5) == "minus" then
    minus(player, value, id)
  else
    plus(player, value, id)
  end
end
function minus(player, value, id)
  local valId = getValId(id)
  if data[valId] == nil then return end
  
  local oldValue = data[valId]
  data[valId] = data[valId] - INCREMENT
  if MIN_VALUE ~= nil and data[valId] < MIN_VALUE then
    data[valId] = MIN_VALUE
  end
  self.UI.setAttribute(valId, "text", data[valId])
  
  -- Announce the change
  if oldValue ~= data[valId] then
    announceChange(valId, oldValue, data[valId], player)
  end
end
function plus(player, value, id)
  local valId = getValId(id)
  if data[valId] == nil then return end
  
  local oldValue = data[valId]
  data[valId] = data[valId] + INCREMENT
  if data[maxId] ~= nil then
    data[valId] = math.min(data[valId], data[maxId])
  end
  self.UI.setAttribute(valId, "text", data[valId])
  
  -- Announce the change
  if oldValue ~= data[valId] then
    announceChange(valId, oldValue, data[valId], player)
  end
end
function announceChange(valId, oldValue, newValue, player)
  local resourceName = getResourceName(valId)
  local change = newValue - oldValue
  local changeSymbol = change > 0 and "+" or ""
  
  -- Get player name
  local playerName = "Someone"
  
  -- Check if player is actually a player object (not a string/number from input field)
  if type(player) == "userdata" and player.color ~= nil and Player[player.color] ~= nil then
    playerName = player.steam_name or "Someone"
  end
  
  -- Define colors for each resource (light versions)
  local resourceColors = {
    Capital = Color(1, 1, 0.6),      -- Light yellow
    Carbon = Color(0.8, 0.8, 0.8),   -- Light grey
    Food = Color(0.6, 1, 0.6)        -- Light green
  }
  
  local messageColor = resourceColors[resourceName] or Color.White
  
  -- Format message
  local message = string.format("[%s] %s %s%d (%d → %d)", 
    playerName, resourceName, changeSymbol, change, oldValue, newValue)
  
  -- Print message with resource-specific color
  printToAll(message, messageColor)
end
------------------------------------------------------------
function onLoad(script_state)
  local i
  data = JSON.decode(script_state)
  if data == nil then
    data = {
      name="",
      cardTextColor=Color(0.196, 0.196, 0.196),
      cardTextColorString="#323232FF",
    }
    for i=1,NUM_VALS,1 do
      local id = tostring(i)
      data[getValId(id)] = 0
    end
  end
  for i=1,NUM_VALS,1 do
    local id = tostring(i)
    local valId = getValId(id)
    data[valId] = tonumber(data[valId])
    self.UI.setAttribute(valId, "text", data[valId])
  end
end
function onSave()
  return JSON.encode(data)
end