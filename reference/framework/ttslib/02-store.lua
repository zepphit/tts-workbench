-- ttslib/02-store.lua — declared state, one onSave, migrations by version.
-- Answers critique C4.  Depends on: 00-log.
--
-- Politik's resource tokens still re-save max1/max2/max3 and statName1..3, keys
-- that appear nowhere in their script, because onSave blindly encodes whatever
-- `data` happens to hold.  RotLA needed a documented USE_SAVES kill switch
-- because saved state silently overrides an edited default, and carries a
-- versionNumber that nothing ever reads (docs/critique.md#c4).
--
-- A store fixes both: you declare the shape, only declared keys survive a
-- round-trip, every value is coerced back to the type of its default, and a
-- version change is a migration — or, if you did not write one, a loud reset.
--
-- Declare one per script (or one per feature module) and serialise them all
-- through the pair below:
--
--   local game = ttslib.store.new("game", { version = 1, defaults = { round = 1 } })
--
--   function onSave() return ttslib.store.serialize() end
--   function onLoad(script_state)
--     ttslib.store.restore(script_state)
--     ...
--   end
--
-- Persist only what the table cannot tell you.  A cube's position on a track is
-- the score; re-read it from the board instead of mirroring it in here.

ttslib = ttslib or {}

local LOG = assert(ttslib.log, "load ttslib/00-log.lua before 02-store.lua")

local S = {}
ttslib.store = S

local VERSION_KEY = "v" -- reserved inside a slice; "d" holds the declared fields

local stores, order = {}, {}

local function copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do
    out[k] = copy(v)
  end
  return out
end

-- Never trust a decoded value's type: JSON round-trips hand back strings where
-- numbers went in.  Coerce at the boundary, against the default's own type.
local function coerce(value, default)
  local want = type(default)
  if value == nil then return copy(default) end
  if want == "number" then
    return tonumber(value) or default
  elseif want == "string" then
    local got = type(value)
    if got == "string" then return value end
    if got == "number" then return tostring(value) end
    return default
  elseif want == "boolean" then
    return value == true or value == "true"
  elseif want == "table" then
    if type(value) == "table" then return value end -- contents are not schema-checked
    return copy(default)
  end
  return copy(default)
end

local Store = {}
Store.__index = Store

-- fromTable(slice) — apply one decoded slice, dropping everything undeclared.
function Store:fromTable(slice)
  self.data = copy(self.defaults)
  if type(slice) ~= "table" then return self end

  local saved = slice.d
  if type(saved) ~= "table" then saved = {} end

  local from = tonumber(slice[VERSION_KEY])
  if from ~= self.version then
    if type(self.migrate) == "function" then
      local migrated = LOG.attempt("store '" .. self.name .. "' migrate", self.migrate, saved, from)
      if type(migrated) == "table" then
        saved = migrated
        LOG.info("store '" .. self.name .. "' migrated from version " .. tostring(from))
      else
        -- attempt() has already reported why.  Say what it cost, rather than
        -- logging a successful migration over the top of a failed one and
        -- leaving the player wondering where their state went.
        saved = {}
        LOG.warn("store '" .. self.name .. "' migration from version " ..
          tostring(from) .. " failed; using defaults")
      end
    else
      -- No migration for this version: the saved slice is from another schema,
      -- so drop it by design rather than by remembering to flip a kill switch.
      LOG.warn(
        "store '" .. self.name .. "' saved at version " .. tostring(from) ..
        ", now version " .. tostring(self.version) .. "; using defaults"
      )
      return self
    end
  end

  for key, default in pairs(self.defaults) do
    self.data[key] = coerce(saved[key], default)
  end
  return self
end

-- toTable() — the declared shape and nothing else.
function Store:toTable()
  local out = {}
  for key in pairs(self.defaults) do
    out[key] = self.data[key]
  end
  return { [VERSION_KEY] = self.version, d = out }
end

-- reset() — back to declared defaults, without touching what is on disk until
-- the next save.
function Store:reset()
  self.data = copy(self.defaults)
  return self.data
end

-- new(name, spec) — spec = { version = 1, defaults = {...}, migrate = fn }
--
-- migrate(saved, fromVersion) receives the raw decoded fields of the older slice
-- and returns a table in the current shape.  Anything it leaves out falls back
-- to that key's default.
function S.new(name, spec)
  spec = spec or {}
  LOG.assert(type(name) == "string" and name ~= "", "store.new needs a name")
  LOG.assert(type(spec.defaults) == "table", "store '" .. tostring(name) .. "' needs defaults")

  if stores[name] then
    LOG.warn("store '" .. name .. "' declared twice; the later one wins")
  else
    order[#order + 1] = name
  end

  local store = setmetatable({
    name = name,
    version = tonumber(spec.version) or 1,
    defaults = copy(spec.defaults),
    migrate = spec.migrate,
    data = copy(spec.defaults),
  }, Store)

  stores[name] = store
  return store
end

function S.get(name)
  return stores[name]
end

-- restore(script_state) — call once, from onLoad, before anything reads state.
function S.restore(script_state)
  local blob
  if type(script_state) == "string" and script_state ~= "" then
    blob = LOG.attempt("store.restore decode", JSON.decode, script_state)
  end
  if type(blob) ~= "table" then blob = {} end
  for _, name in ipairs(order) do
    stores[name]:fromTable(blob[name])
  end
  return blob
end

-- serialize() — the single generated onSave for every store in this script.
function S.serialize()
  local out = {}
  for _, name in ipairs(order) do
    out[name] = stores[name]:toTable()
  end
  return JSON.encode(out)
end

-- Used by the test harness; also the honest way to start a script over.
function S.clear()
  stores, order = {}, {}
end
