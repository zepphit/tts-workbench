-- src/40-journal.lua — the narrative half of the changelog.
--
-- The build plan asks for a changelog the owner does not have to dictate, in
-- two layers (section 5):
--
--   ground truth  `tts.py diff` between save N and save N+1. Catches every
--                 change, scripted or not, and is already built — ttsd.py runs
--                 it on message ID 6 and nothing in Lua duplicates it.
--   narrative     this file. Ordering and intent that a diff cannot recover:
--                 who picked a cube up, which hex they dropped it on, that the
--                 map was rerolled between the two saves.
--
-- Everything goes out through `sendExternalMessage`, which reaches the daemon
-- as message ID 4.  With no editor attached the call is a no-op, so a save
-- loaded without ttsd.py running behaves exactly the same, only quieter.
--
-- Records are hex-aware: an object's float position is put back through
-- hex.fromWorld so an entry reads `hex(1,-1) -> hex(0,2)` rather than three
-- decimals that nobody can compare by eye.

local LOG = ttslib.log
local ASYNC = ttslib.async
local EVENTS = ttslib.events
local LAYOUT = ttslib.layout

Journal = {}

Journal.enabled = true
Journal.echo = false -- also print every record to the in-game log

local sequence = 0
local held = {} -- guid -> the hex an object was picked up from

-- where(obj) — an object's position as a hex on the map lattice, measured in
-- the anchor's frame so it keeps meaning after the plate has been dragged.
function Journal.where(obj)
  if not obj or ASYNC.gone(obj) then return nil end
  local anchor = LAYOUT.anchorObject()
  if not anchor then return nil end
  local scale = anchor.getScale()
  local localPos = anchor.positionToLocal(obj.getPosition())
  local q, r = hex.fromWorld(localPos.x * scale.x, localPos.z * scale.z,
    ART.radius)
  return { q = q, r = r, text = "hex(" .. q .. "," .. r .. ")" }
end

local function describe(obj)
  if not obj or ASYNC.gone(obj) then return "?" end
  local name = obj.getName and obj.getName() or ""
  if name == "" then name = obj.getGMNotes and obj.getGMNotes() or "" end
  if name == "" then name = obj.type or "object" end
  return name
end

-- emit(kind, fields) — one record.  Called from everywhere, including from
-- 20-tiles.lua, so it has to tolerate being called before attach().
function Journal.emit(kind, fields)
  if not Journal.enabled then return false end
  sequence = sequence + 1

  local record = { seq = sequence, kind = tostring(kind), t = os.time() }
  for key, value in pairs(fields or {}) do
    -- A hex from where() goes over the wire as its own little table; anything
    -- else is flattened to a string, because the far end writes JSON lines and
    -- a Lua Object in there would serialise to nothing useful.
    if type(value) == "table" and value.text then
      record[key] = value.text
    elseif type(value) == "table" then
      record[key] = value
    elseif value ~= nil then
      record[key] = value
    end
  end

  if Journal.echo then
    LOG.debug("journal " .. record.kind, JSON.encode(record))
  end
  -- Returns false with no editor attached, which is fine and expected.
  return sendExternalMessage({ amazonia = record })
end

-- ------------------------------------------------------------------- taps

-- attach() — one subscription per event, routed by tag, in Global. Not a
-- script on every component (critique C6, C7).
--
-- The "*" tag means every object, which is what the changelog wants: the owner
-- moves cubes and pieces that this prototype has never heard of, and those are
-- exactly the moves worth recording.
function Journal.attach()
  EVENTS.on("pickUp", "*", function(playerColour, obj)
    if Tiles.bulk then return end
    local at = Journal.where(obj)
    if obj and not ASYNC.gone(obj) then held[obj.getGUID()] = at end
    Journal.emit("pickUp", {
      what = describe(obj), guid = obj and obj.getGUID(),
      who = playerColour, from = at,
    })
  end)

  -- TTS fires drop more than once for one physical drop; 1.25s is the window
  -- Arcs uses and the one ttslib's demo settled on.
  EVENTS.on("drop", "*", function(playerColour, obj)
    if Tiles.bulk then return end
    local guid = obj and not ASYNC.gone(obj) and obj.getGUID() or nil
    local from = guid and held[guid] or nil
    if guid then held[guid] = nil end
    -- A drop is reported once the object has stopped moving: reading its hex
    -- mid-flight would record where it was thrown from, not where it landed.
    ASYNC.whenSettled(obj, function(settled)
      Journal.emit("move", {
        what = describe(settled), guid = guid, who = playerColour,
        from = from, to = Journal.where(settled),
      })
    end)
  end, { debounce = 1.25 })

  EVENTS.on("spawn", "*", function(obj)
    if Tiles.bulk then return end
    Journal.emit("spawn", { what = describe(obj),
      guid = obj and obj.getGUID(), at = Journal.where(obj) })
  end)

  EVENTS.on("destroy", "*", function(obj)
    if Tiles.bulk then return end
    Journal.emit("destroy", { what = describe(obj),
      guid = obj and obj.getGUID(), at = Journal.where(obj) })
  end)

  LOG.info("journal attached")
  return true
end

-- A message from ttsd.py, arriving as external message ID 2.  The daemon uses
-- it for a heartbeat and for marking a session boundary in the log.
function onExternalMessage(data)
  if type(data) ~= "table" then return end
  if data.ping then
    Journal.emit("pong", { ping = tostring(data.ping), tiles = Map.count() })
  end
  if data.note then
    Journal.emit("note", { text = tostring(data.note) })
    LOG.info("note: " .. tostring(data.note))
  end
end
