-- ttslib/05-registry.lua — objects resolved by role tag, not by GUID.
-- Answers critique C1.  Depends on: 00-log, 01-async, 04-events.
--
-- Almoravid binds 200 GUID literals in one getObjects() function with not a
-- single `if obj then` guard, so one stale GUID leaves the table half set up
-- with no error naming the cause; RotLA embeds 119 more in a literal table;
-- three of Arcs' src/GUIDs literals match no object in the owner's save today
-- (docs/critique.md#c1).  A GUID is minted per instance: duplicate a component,
-- or take it out of a bag, and every reference to it is silently wrong.
--
-- A role is a component tag you typed, so it survives duplication:
--
--   reg.declare({ board = 1, ["supply.wood"] = "+", card = "*" })
--   ...
--   local board = reg.one("board")
--   for _, bag in ipairs(reg.all("supply.wood")) do ... end
--
-- declare() is the manifest, check() reports everything missing at once, at
-- boot, loudly — instead of a nil dereference in the middle of setup.
--
-- Rurik is the mod that committed to tags, and its cache is the part not to
-- copy: it is rebuilt by hand at six call sites, never invalidated on spawn or
-- destroy, and waitByTag sweeps every object on the table once a frame.  This
-- cache invalidates itself on spawn and destroy, and waitFor polls one tag.
--
-- One axis per tag: "coin" + "blue" composes, "bluecoin" has to be parsed.

ttslib = ttslib or {}

local LOG = assert(ttslib.log, "load ttslib/00-log.lua before 05-registry.lua")
local ASYNC = assert(ttslib.async, "load ttslib/01-async.lua before 05-registry.lua")
local EVENTS = assert(ttslib.events, "load ttslib/04-events.lua before 05-registry.lua")

local R = {}
ttslib.registry = R

R.WAIT_TIMEOUT = 10 -- seconds waitFor spends before giving up, loudly

local manifest = {} -- role -> expectation: a number, "+", "?" or "*"
local cache = {} -- role -> array of objects
local spawnHandle, destroyHandle = nil, nil

-- invalidate(role) — drop one role's cache, or all of them when given nothing.
-- A spawn invalidates everything, because a new object can carry any tag; a
-- poll that is watching one role drops only that one, so waiting for a bag to
-- open does not turn the cache off for the whole game.
function R.invalidate(role)
  if role ~= nil then
    cache[role] = nil
  else
    cache = {}
  end
end

-- The cache is only correct while these two subscriptions exist, and
-- events.offAll() will happily remove them — so verify rather than remember.
-- hook() runs on every all(), so the registry re-arms itself on the next query
-- instead of returning a frozen cache forever with no warning.
local function hook()
  if not EVENTS.has("spawn", spawnHandle) then
    spawnHandle = EVENTS.on("spawn", "*", function() R.invalidate() end)
    R.invalidate() -- whatever spawned while we were not listening
  end
  if not EVENTS.has("destroy", destroyHandle) then
    destroyHandle = EVENTS.on("destroy", "*", function()
      -- onObjectDestroy fires while the object is still on the table, so drop the
      -- cache now and again next frame, once it has actually gone.  Both calls go
      -- through a closure: invalidate takes an optional role, and a scheduler or
      -- dispatcher that passes its own argument would drop only that one.
      R.invalidate()
      ASYNC.afterFrames(1, function() R.invalidate() end)
    end)
    R.invalidate()
  end
end

-- declare(roles) — roles = { role = expectation }, where expectation is
--   a number   exactly that many
--   "+"        one or more
--   "?"        none or one
--   "*"        any number, including none
-- Declaring a role is optional for querying it, and is what makes check() able
-- to report it missing before anything asks.
function R.declare(roles)
  LOG.assert(type(roles) == "table", "registry.declare needs a table of roles")
  hook()
  for role, expectation in pairs(roles) do
    manifest[role] = expectation
  end
  R.invalidate()
  return manifest
end

function R.roles()
  return manifest
end

-- all(role) — every object carrying the tag, cached until something spawns or
-- is destroyed.  Always a table, never nil.
function R.all(role)
  hook()
  local hit = cache[role]
  if hit then return hit end

  local found = getObjectsWithTag(role) or {}
  local live = {}
  for _, obj in ipairs(found) do
    if not ASYNC.gone(obj) then
      live[#live + 1] = obj
    end
  end
  cache[role] = live
  return live
end

-- A role queried in the wrong case is the most likely reason for an empty
-- result, so say so when it happens.  Only runs on the failure path.
local function suggest(role)
  local wanted = string.lower(role)
  for _, obj in ipairs(getObjects() or {}) do
    if obj.getTags then
      for _, tag in ipairs(obj.getTags() or {}) do
        if tag ~= role and string.lower(tag) == wanted then return tag end
      end
    end
  end
  return nil
end

-- one(role) — the object for a role there should be exactly one of.  Reports a
-- miss once per role per session, not once per frame.
function R.one(role)
  local list = R.all(role)
  if #list == 0 then
    local other = suggest(role)
    LOG.once("registry.missing." .. role, "error",
      "no object tagged '" .. tostring(role) .. "'",
      other and ("an object is tagged '" .. other .. "' — tag case must match") or nil)
    return nil
  end
  if #list > 1 then
    LOG.once("registry.many." .. role, "warn",
      "registry.one('" .. tostring(role) .. "') found " .. #list .. " objects; using the first")
  end
  return list[1]
end

-- check() — validate the whole manifest in one pass and report every problem
-- together.  Call it from onLoad, before setup runs.  Returns true when the
-- table matches what the game declared it needs.
function R.check()
  local ok = true
  local roles = {}
  for role in pairs(manifest) do
    roles[#roles + 1] = role
  end
  table.sort(roles)

  for _, role in ipairs(roles) do
    local expectation = manifest[role]
    local found = #R.all(role)
    local bad = nil

    if type(expectation) == "number" then
      if found ~= expectation then bad = "expected " .. expectation end
    elseif expectation == "+" then
      if found < 1 then bad = "expected at least one" end
    elseif expectation == "?" then
      if found > 1 then bad = "expected none or one" end
    elseif expectation ~= "*" then
      bad = "unknown expectation " .. tostring(expectation)
    end

    if bad then
      ok = false
      local other = (found == 0) and suggest(role) or nil
      LOG.error("role '" .. role .. "': " .. bad .. ", found " .. found,
        other and ("an object is tagged '" .. other .. "' — tag case must match") or nil)
    end
  end

  if ok then
    LOG.info("registry: all " .. #roles .. " declared roles present")
  end
  return ok
end

-- waitFor(role, fn, timeout) — for something that is not on the table yet,
-- typically because it is still inside a bag.  Polls one tag, not every object,
-- and says so when it gives up rather than waiting forever.
function R.waitFor(role, fn, timeout)
  timeout = timeout or R.WAIT_TIMEOUT
  local deadline = ASYNC.now() + timeout
  local function poll()
    R.invalidate(role) -- only the role being waited on, not every role in the game
    local list = R.all(role)
    if #list > 0 then
      fn(list[1], list)
      return
    end
    if ASYNC.now() >= deadline then
      LOG.error("waited " .. tostring(timeout) .. "s for a '" .. tostring(role) .. "', nothing appeared")
      return
    end
    ASYNC.afterFrames(1, poll)
  end
  poll()
end
