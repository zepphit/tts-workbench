-- ttslib/01-async.lua — the waiting patterns worth keeping, named once.
-- Answers critique C9.  Depends on: 00-log.
--
-- Almoravid hand-writes the same takeObject -> Wait.frames -> setPositionSmooth
-- block 537 times.  Arcs, at the other extreme, invents a cancellable keyed wait
-- registry, a bounded retry and a 1.25-second duplicate-event suppressor — each
-- written once, inline, unnamed, and reachable from nowhere else
-- (docs/critique.md#c9).  This file is those three ideas with names on them.
--
-- Every wait here is bounded and says something when it gives up.  A
-- Wait.condition whose condition can never become true waits forever, silently.

ttslib = ttslib or {}

local LOG = assert(ttslib.log, "load ttslib/00-log.lua before 01-async.lua")

local A = {}
ttslib.async = A

A.SETTLE_TIMEOUT = 10 -- seconds before whenSettled gives up and says so
A.DUPLICATE_WINDOW = 1.25 -- Arcs' figure, and a good one (src/events/DropActionEvents:5)

-- Time.time is Unity's clock and is what the rest of TTS measures in; the
-- fallback keeps this file runnable outside TTS, in the test harness.
local function now()
  return (Time and Time.time) or os.clock()
end
A.now = now

-- afterFrames(n, fn) — the spawn-callback idiom.  An object taken from a bag is
-- not ready in the same frame; one frame is almost always enough.
function A.afterFrames(frames, fn)
  return Wait.frames(fn, frames or 1)
end

-- after(seconds, fn) — one-shot timer.
function A.after(seconds, fn)
  return Wait.time(fn, seconds)
end

-- ---------------------------------------------------------------- keyed waits

-- Pending waits, by key.  Scheduling a key cancels whatever that key was
-- already waiting on, so dragging a card three times queues one handler, not
-- three (Arcs' best async idea: src/events/DropActionEvents:52).
local pending = {}

function A.cancel(key)
  local id = pending[key]
  if id == nil then return false end
  pending[key] = nil
  Wait.stop(id)
  return true
end

function A.cancelAll()
  for key in pairs(pending) do
    A.cancel(key)
  end
end

-- keyed(key, seconds, fn) — replaces any pending wait under the same key.
-- seconds may be nil for "next frame".
function A.keyed(key, seconds, fn)
  A.cancel(key)
  local id
  local function run()
    pending[key] = nil
    fn()
  end
  if seconds == nil then
    id = Wait.frames(run, 1)
  else
    id = Wait.time(run, seconds)
  end
  pending[key] = id
  return id
end

-- every(key, seconds, fn) — a repeating timer that cannot stack.  A repeating
-- Wait.time(..., -1) with no stored id is the bug Arcs' Timer guards against by
-- hand (src/Timer:29): call the starter twice and you have two timers forever.
function A.every(key, seconds, fn)
  A.cancel(key)
  local id = Wait.time(fn, seconds, -1)
  pending[key] = id
  return id
end

-- ------------------------------------------------------------------- settling

-- gone(obj) — true once an object is destroyed or its handle has expired.
-- Arcs' condition checks getGUID for nil because a destroyed handle loses its
-- methods before it becomes nil (src/events/DropActionEvents:79).
local function gone(obj)
  return obj == nil or obj.getGUID == nil or obj.isDestroyed()
end
A.gone = gone

-- whenSettled(obj, fn, timeout) — run fn(obj) once physics has let go of it.
-- Exits when the object goes away, so it cannot wait forever, and warns if the
-- timeout is reached rather than disappearing.
function A.whenSettled(obj, fn, timeout)
  if gone(obj) then
    LOG.warn("async.whenSettled: object is already gone")
    return nil
  end
  local guid = obj.getGUID()
  timeout = timeout or A.SETTLE_TIMEOUT
  return Wait.condition(
    function()
      if gone(obj) then return end -- settled by leaving the table
      fn(obj)
    end,
    function()
      return gone(obj) or (obj.resting and not obj.isSmoothMoving())
    end,
    timeout,
    function()
      LOG.warn("async.whenSettled timed out after " .. tostring(timeout) .. "s", guid)
    end
  )
end

-- ---------------------------------------------------------------------- retry

-- retry(fn, opts) — fn(attempt) returns truthy when it has succeeded.  Bounded,
-- and loud when it gives up: an unbounded retry is a hang that looks like a
-- physics hang.  opts = { times = 5, delay = 0.5, label = "..." }
-- The label doubles as the cancel key, so a retry loop is cancellable like
-- every other wait here: async.cancel(label) stops it before the next attempt.
function A.retry(fn, opts)
  opts = opts or {}
  local times = opts.times or 5
  local delay = opts.delay or 0.5
  local label = opts.label or "async.retry"
  local attempt = 0
  local function try()
    attempt = attempt + 1
    if fn(attempt) then return end
    if attempt >= times then
      LOG.warn(label .. " gave up after " .. attempt .. " attempts")
      return
    end
    A.keyed(label, delay, try)
  end
  try()
  return label
end

-- ------------------------------------------------------------------- debounce

-- debounce(key, window) — true when this event is a repeat inside the window,
-- so the caller should drop it.  TTS fires drop and zone events more than once
-- for one physical action; Arcs suppresses repeats with a composite key of
-- (object, event kind, player) so that two different actions on one card are
-- not conflated (src/events/DropActionEvents:11).
local seen = {}
local seenCount = 0

-- One entry per (event, tag, object) triple, and objects are minted all game,
-- so this table only ever grew.  Sweep it when it gets big: an entry older than
-- the window can never suppress anything again.
A.SEEN_LIMIT = 256

function A.debounce(key, window)
  window = window or A.DUPLICATE_WINDOW
  local t = now()
  local previous = seen[key]
  if previous == nil then
    seenCount = seenCount + 1
    if seenCount > A.SEEN_LIMIT then
      local cutoff = t - math.max(window, A.DUPLICATE_WINDOW)
      seenCount = 0
      for k, stamp in pairs(seen) do
        if stamp < cutoff then
          seen[k] = nil
        else
          seenCount = seenCount + 1
        end
      end
    end
  end
  seen[key] = t
  return previous ~= nil and (t - previous) < window
end

function A.forget()
  seen = {}
  seenCount = 0
end
