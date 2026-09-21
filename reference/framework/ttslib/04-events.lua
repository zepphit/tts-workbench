-- ttslib/04-events.lua — one dispatcher, behaviour registered against a tag.
-- Answers critique C6 and C7.  Depends on: 00-log, 01-async.
--
-- TTS delivers every container event to every script that defines the handler,
-- so RotLA's 51 byte-identical bag scripts each open with `if bag~=self then
-- return end` — 55 scripts, 106 occurrences of a guard that corrupts state
-- silently if you ever forget it (docs/critique.md#c7).  The same 997-character
-- script exists 51 times, so a one-line fix is a 51-site edit (C6).
--
--   events.on("enterContainer", "supply", function(container, object)
--     updateCount(container)
--   end)
--
-- One registration, every bag tagged "supply", no guard to forget.  Objects
-- carry tags; Global carries the code.
--
-- Handlers receive TTS's own arguments, in TTS's own order, so the API docs and
-- the cookbook transfer unchanged.  The tag is matched against the subject of
-- the event — the container, the zone, or the object — which is the first
-- argument for every event below except drop and pickUp, where TTS puts the
-- player colour first.  The table says which.
--
-- Tag matching is obj.hasTag(tag): match the exact casing your objects carry
-- until cookbook open question 1 is settled in TTS.

ttslib = ttslib or {}

local LOG = assert(ttslib.log, "load ttslib/00-log.lua before 04-events.lua")
local ASYNC = assert(ttslib.async, "load ttslib/01-async.lua before 04-events.lua")

local E = {}
ttslib.events = E

-- name -> TTS handler, and which argument carries the tags.
E.EVENTS = {
  spawn          = { tts = "onObjectSpawn",          subject = 1 },
  destroy        = { tts = "onObjectDestroy",        subject = 1 },
  enterContainer = { tts = "onObjectEnterContainer", subject = 1 },
  leaveContainer = { tts = "onObjectLeaveContainer", subject = 1 },
  enterZone      = { tts = "onObjectEnterZone",      subject = 1 },
  leaveZone      = { tts = "onObjectLeaveZone",      subject = 1 },
  drop           = { tts = "onObjectDrop",           subject = 2 },
  pickUp         = { tts = "onObjectPickUp",         subject = 2 },
  randomize      = { tts = "onObjectRandomize",      subject = 1 },
  stateChange    = { tts = "onObjectStateChange",    subject = 1 },
  numberTyped    = { tts = "onObjectNumberTyped",    subject = 1 },
  rotate         = { tts = "onObjectRotate",         subject = 1 },
  peek           = { tts = "onObjectPeek",           subject = 1 },
}

local subscriptions = {} -- name -> { {tag, fn, debounce}, ... }

-- on(name, tag, handler, opts) — opts.debounce is a window in seconds; TTS
-- fires drop and zone events more than once for one physical action, and a
-- debounced subscription drops the repeats (see async.debounce).
-- Returns a handle for off().
function E.on(name, tag, handler, opts)
  local def = LOG.expect(E.EVENTS[name], "events.on: unknown event", name)
  if not def then return nil end
  LOG.assert(type(handler) == "function", "events.on('" .. tostring(name) .. "'): handler must be a function")

  local list = subscriptions[name]
  if not list then
    list = {}
    subscriptions[name] = list
  end

  local sub = { tag = tag or "*", fn = handler, debounce = opts and opts.debounce }
  list[#list + 1] = sub
  LOG.trace("events.on " .. name .. " [" .. tostring(sub.tag) .. "]")
  return sub
end

-- off(name, handle) — pass the handle on() returned.
function E.off(name, handle)
  local list = subscriptions[name]
  if not list then return false end
  for i = 1, #list do
    if list[i] == handle then
      table.remove(list, i)
      return true
    end
  end
  return false
end

function E.offAll(name)
  if name then
    subscriptions[name] = nil
  else
    subscriptions = {}
  end
end

function E.count(name)
  local list = subscriptions[name]
  return list and #list or 0
end

-- has(name, handle) — is this subscription still live?  offAll() is allowed to
-- clear subscriptions another module registered, so a module that depends on
-- its own subscription (the registry's cache invalidation does) checks with
-- this and re-registers rather than trusting a "hooked" flag it set once.
function E.has(name, handle)
  local list = subscriptions[name]
  if not list or handle == nil then return false end
  for i = 1, #list do
    if list[i] == handle then return true end
  end
  return false
end

-- dispatch(name, a, b, c, d, e, f) — route one TTS event to its subscribers.
-- Each handler runs inside LOG.attempt, a named boundary: one broken handler
-- reports itself and the others still run, which is the opposite of a blanket
-- pcall that swallows the error and tells nobody (C8).
--
-- The subscriber list is copied before the loop, because a handler is allowed
-- to call events.off while it runs — unsubscribing itself after the first
-- delivery is the obvious way to write a one-shot.  Iterating the live list
-- would shrink it under a fixed bound and index past the end, and dispatch is
-- not itself inside a boundary, so that error would escape into TTS and skip
-- every later subscriber.  A handler that unsubscribes a *different* one still
-- lets that one run for this event; it is off from the next event on.
function E.dispatch(name, a, b, c, d, e, f)
  local list = subscriptions[name]
  if not list or #list == 0 then return end

  local def = E.EVENTS[name]
  local subject = (def.subject == 2) and b or a
  if subject == nil then return end

  local batch = {}
  for i = 1, #list do batch[i] = list[i] end

  for i = 1, #batch do
    local sub = batch[i]
    if sub.tag == "*" or (subject.hasTag and subject.hasTag(sub.tag)) then
      local suppressed = false
      if sub.debounce then
        local guid = (subject.getGUID and subject.getGUID()) or tostring(subject)
        suppressed = ASYNC.debounce(name .. "|" .. tostring(sub.tag) .. "|" .. tostring(guid), sub.debounce)
      end
      if not suppressed then
        LOG.attempt("events." .. name .. " [" .. tostring(sub.tag) .. "]", sub.fn, a, b, c, d, e, f)
      end
    end
  end
end

-- --------------------------------------------------------- the TTS handlers
--
-- Declared here, once, for the whole script.  Do not declare any of these in
-- your own code: in Lua the second definition silently wins, which is how RotLA
-- ended up with two onPlayerChangeColor bodies and one of them dead
-- (docs/critique.md, live bug 4).  Call events.on instead, and call
-- events.check() from onLoad to be told if something redefined one anyway.

function onObjectSpawn(object) E.dispatch("spawn", object) end
function onObjectDestroy(object) E.dispatch("destroy", object) end
function onObjectEnterContainer(container, object) E.dispatch("enterContainer", container, object) end
function onObjectLeaveContainer(container, object) E.dispatch("leaveContainer", container, object) end
function onObjectEnterZone(zone, object) E.dispatch("enterZone", zone, object) end
function onObjectLeaveZone(zone, object) E.dispatch("leaveZone", zone, object) end
function onObjectDrop(player_color, object) E.dispatch("drop", player_color, object) end
function onObjectPickUp(player_color, object) E.dispatch("pickUp", player_color, object) end
function onObjectRandomize(object, player_color) E.dispatch("randomize", object, player_color) end
function onObjectStateChange(object, old_state_guid) E.dispatch("stateChange", object, old_state_guid) end
function onObjectNumberTyped(object, player_color, number, alt) E.dispatch("numberTyped", object, player_color, number, alt) end
function onObjectRotate(object, spin, flip, player_color, old_spin, old_flip) E.dispatch("rotate", object, spin, flip, player_color, old_spin, old_flip) end
function onObjectPeek(object, player_color) E.dispatch("peek", object, player_color) end

-- Remember what we installed, so check() can tell if it is still ours.
local installed = {}
for name, def in pairs(E.EVENTS) do
  installed[name] = _G[def.tts]
end

-- check() — call from onLoad.  Reports any TTS handler that is no longer the
-- dispatcher, which means something redefined it and those events now bypass
-- every events.on subscription.
function E.check()
  local ok = true
  for name, def in pairs(E.EVENTS) do
    if _G[def.tts] ~= installed[name] then
      ok = false
      LOG.error(
        def.tts .. " has been redefined, so events.on(\"" .. name .. "\", ...) no longer runs",
        "delete that definition and use events.on"
      )
    end
  end
  return ok
end
