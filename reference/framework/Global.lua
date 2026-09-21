-- Global.lua — the starter script for a game built on ttslib.
--
-- Build it into a save by concatenating the library and this file, in order,
-- and injecting the result:
--
--   cat reference/framework/ttslib/*.lua reference/framework/Global.lua > /tmp/global.lua
--   python3 scripts/tts.py lua inject Saves/TS_Save_111.json /tmp/global.lua -o Saves/TS_Save_127.json
--   python3 scripts/tts.py validate Saves/TS_Save_127.json
--
-- The files are the source; the save is an artifact (critique C10).  Edit here,
-- rebuild, never edit the Lua inside the JSON.
--
-- Everything below is an example of the shape, not of your game.  Replace the
-- roles, the spaces and the handlers; keep the order of the sections.

-- ---------------------------------------------------------------- shorthands

local LOG = ttslib.log
local ASYNC = ttslib.async
local EVENTS = ttslib.events
local REG = ttslib.registry
local UI_ = ttslib.ui
local LAYOUT = ttslib.layout
local LAYER = ttslib.layout.LAYER

LOG.prefix = "[mygame]"
LOG.level = "debug" -- "warn" before you publish

-- --------------------------------------------------------------------- data
--
-- Roles are component tags you type in TTS (right-click an object > Tags).
-- Nothing here is a GUID: duplicate a component, or take it out of a bag, and
-- its tags come with it while its GUID does not (C1).

local ROLES = {
  board = 1, -- exactly one
  ["supply.wood"] = "+", -- at least one
  wood = "*", -- any number, including none at the start
}

-- Positions in the board's local space, so moving or rescaling the board moves
-- everything with it (C2).  Y always comes from a named layer.

local SPACES = {
  supply = { -0.40, LAYER.board, 0.28 },
  deck = { 0.42, LAYER.card, 0.28 },
  score = { 0.00, LAYER.marker, -0.35 },
}

-- One store per script, with declared defaults and a version.  Only these keys
-- survive a save; anything else in the saved blob is dropped on load (C4).

local game = ttslib.store.new("game", {
  version = 1,
  defaults = {
    round = 1,
    started = false,
  },
  -- migrate = function(saved, fromVersion) return { round = saved.turn or 1 } end,
})

-- ------------------------------------------------------------------ handlers

local function woodCount()
  local bag = REG.one("supply.wood")
  if not bag then return 0 end
  return bag.getQuantity()
end

-- The live badge on the supply bag.  One label, edited by name, so inserting
-- another button above it changes nothing (C3).
local function refreshSupplyBadge()
  local bag = REG.one("supply.wood")
  if not bag then return end
  UI_.label(bag, "count", {
    label = tostring(woodCount()),
    position = { 0, 0.5, -1.2 },
    font_size = 250,
  })
end

local function startRound()
  game.data.round = game.data.round + 1
  game.data.started = true
  LOG.info("round " .. game.data.round)
  broadcastToAll("Round " .. game.data.round, { r = 0.9, g = 0.9, b = 0.9 })
end

-- Buttons are attached by name and rebuilt on every load, because TTS does not
-- save scripted buttons.  Calling this twice edits, it does not duplicate.
local function buildControls()
  local board = REG.one("board")
  if not board then return end

  UI_.button(board, "nextRound", {
    label = "Next round",
    position = { 0, LAYER.board, -0.45 },
    width = 1200,
    height = 400,
    font_size = 180,
    scale = UI_.unscale(board), -- a scaled board renders its buttons scaled too
    onClick = function(_, playerColour, altClick)
      if altClick then
        LOG.info("right-clicked by " .. tostring(playerColour))
        return
      end
      startRound()
    end,
  })
end

-- --------------------------------------------------------------- lifecycle
--
-- Object scripts run their onLoad before this one, so anything they need from
-- here they must ask for a frame later (see ObjectScript.lua).

function onLoad(script_state)
  ttslib.store.restore(script_state)

  REG.declare(ROLES)
  LAYOUT.anchor("board") -- a role, resolved through the registry when used
  LAYOUT.spaces(SPACES)

  -- One dispatcher, subscribed once, routed by tag: no per-object guards, and
  -- nothing to forget in the 51st copy of a script (C6, C7).
  EVENTS.on("enterContainer", "supply.wood", function(container, object)
    ASYNC.keyed("supply.badge", nil, refreshSupplyBadge) -- coalesce a burst
  end)
  EVENTS.on("leaveContainer", "supply.wood", function(container, object)
    ASYNC.keyed("supply.badge", nil, refreshSupplyBadge)
  end)
  EVENTS.on("drop", "wood", function(playerColour, object)
    LOG.debug("wood dropped by " .. tostring(playerColour))
  end, { debounce = 1.25 }) -- TTS fires drop more than once per physical drop

  -- Report everything missing at once, at boot, before setup can half-run.
  if not REG.check() then
    LOG.error("setup stopped: tag the components above and reload")
    return
  end
  EVENTS.check() -- did anything redefine a TTS event handler?

  buildControls()
  refreshSupplyBadge()

  LOG.info("loaded, round " .. tostring(game.data.round))
end

-- The single generated onSave: every store in this script, versioned.
function onSave()
  return ttslib.store.serialize()
end

-- A player who joins later never saw onLoad run, and buttons are not saved.
-- Rebuild idempotently; one second, because their client is still catching up.
function onPlayerConnect(player)
  ASYNC.keyed("rebuild." .. tostring(player and player.color), 1.0, function()
    buildControls()
    refreshSupplyBadge()
  end)
end

-- ------------------------------------------------------------------- the bus
--
-- The one place object scripts are allowed to call into.  Keep it small and
-- named: Arcs' bus is 13 functions and 60 call sites, and that is the upper end
-- of what stays readable.

function componentClicked(params)
  local object = params and params.guid and getObjectFromGUID(params.guid)
  LOG.debug("componentClicked", params and params.guid)
  if object then
    LAYOUT.place(object, "score", { facing = 180 })
  end
end
