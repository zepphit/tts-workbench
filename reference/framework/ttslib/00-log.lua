-- ttslib/00-log.lua — levelled logging, and loud failure instead of blanket pcall.
-- Answers critique C8.  Load order: first; every other module depends on it.
--
-- Arcs carries 256 pcall sites, one every 71 lines, and one of them has hidden a
-- feature that has never worked since release (docs/critique.md#c8).  The rule
-- here is the inverse: report by default, and make every swallowed error a
-- named, declared boundary that still reports — LOG.attempt("label", fn, ...).
--
-- This module is ttslib.log.  It never defines a global called `log`, so TTS's
-- own log() still works; it is used below as the sink for trace and debug.

ttslib = ttslib or {}

local LOG = {}
ttslib.log = LOG

-- Ordered levels.  Anything below LOG.level is dropped.
LOG.LEVELS = { trace = 1, debug = 2, info = 3, warn = 4, error = 5, silent = 6 }

LOG.level = "debug" -- build-time level; set to "warn" before you publish
LOG.prefix = "[ttslib]" -- set this to your game's name

LOG.ERROR_TINT = { r = 1, g = 0.35, b = 0.35 }

-- The single output point.  Replace it to send everything somewhere else.
function LOG.sink(level, text)
  if level == "trace" or level == "debug" then
    log(text) -- host System Console (~)
  else
    print(text) -- host chat
  end
  if level == "error" then
    broadcastToAll(text, LOG.ERROR_TINT) -- an error nobody can miss
  end
end

local function emit(level, message, detail)
  local threshold = LOG.LEVELS[LOG.level] or LOG.LEVELS.debug
  local text = LOG.prefix .. " " .. string.upper(level) .. ": " .. tostring(message)
  if detail ~= nil then
    text = text .. " (" .. tostring(detail) .. ")"
  end
  if (LOG.LEVELS[level] or 99) >= threshold then
    LOG.sink(level, text)
  end
  return text
end

function LOG.trace(message, detail) return emit("trace", message, detail) end
function LOG.debug(message, detail) return emit("debug", message, detail) end
function LOG.info(message, detail) return emit("info", message, detail) end
function LOG.warn(message, detail) return emit("warn", message, detail) end
function LOG.error(message, detail) return emit("error", message, detail) end

-- Report a recurring condition exactly once per session, by key.  A missing
-- object queried every frame should say so once, not 60 times a second.
local said = {}
function LOG.once(key, level, message, detail)
  if said[key] then return false end
  said[key] = true
  emit(level or "warn", message, detail)
  return true
end

-- Forget what LOG.once has already said (used by tests, and by a full reset).
function LOG.forget()
  said = {}
end

-- expect(value, ...) — returns the value, and reports loudly when it is missing.
-- Use at the top of a function for something that should exist but might not:
--
--   local bag = LOG.expect(reg.one("supply.wood"), "no wood supply on the table")
--   if not bag then return end
--
-- The caller still decides what to do.  What it cannot do is not notice.
function LOG.expect(value, message, detail)
  if value == nil or value == false then
    LOG.error(message, detail)
    return nil
  end
  return value
end

-- assert(cond, ...) — for a programming error that must stop the script now.
-- Reserve it for invariants inside ttslib and your own setup code; a missing
-- component on the table is an expect(), not an assert().
function LOG.assert(condition, message, detail)
  if condition == nil or condition == false then
    error(emit("error", message, detail), 2)
  end
  return condition
end

-- attempt(label, fn, ...) — the only sanctioned pcall in this framework.
--
-- A pcall becomes a deliberate statement about one untrusted call, and the
-- failure is still reported with the label, so it cannot become a silent no-op
-- the way Arcs' draw-bottom patch did.  Handlers dispatched by ttslib.events
-- run inside one of these, so a bad handler cannot take the dispatcher down.
--
-- Up to six arguments are forwarded, which covers every TTS event signature —
-- onObjectRotate is the widest at six (object, spin, flip, player_color,
-- old_spin, old_flip), and forwarding only four silently dropped the two a
-- rotate handler actually wants (reference/api/events.md:89).
function LOG.attempt(label, fn, a, b, c, d, e, f)
  local ok, result = pcall(fn, a, b, c, d, e, f)
  if not ok then
    LOG.error(tostring(label) .. " failed", result)
    return nil
  end
  return result
end
