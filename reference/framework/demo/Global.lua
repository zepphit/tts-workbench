-- Global.lua — "Woodcutter", the demo that has to work before ttslib ships.
--
-- Not a game. One table, one supply, one counter, chosen so that every module
-- in the library is load-bearing: if any of the seven is broken, something here
-- visibly stops working.
--
--   registry  every object is found by tag; there is not one GUID in this file
--   layout    the supply, the marker and the snap row are placed relative to
--             the board, so dragging the board moves all of them on reload
--   ui        buttons and the count badge are addressed by name
--   store     round and dropped survive a save and reload, versioned
--   events    one enterContainer subscription serves the supply, not 51 scripts
--   async     the badge coalesces a burst of container events into one redraw
--   log       every failure path says which role or which handler
--
-- Build it with demo/build.sh; the save is the artifact, this file is the
-- source (critique C10).

-- ---------------------------------------------------------------- shorthands

local LOG = ttslib.log
local ASYNC = ttslib.async
local EVENTS = ttslib.events
local REG = ttslib.registry
local UI_ = ttslib.ui
local LAYOUT = ttslib.layout
local LAYER = ttslib.layout.LAYER

LOG.prefix = "[woodcutter]"
LOG.level = "info" -- "debug" also narrates to the host console (~)

-- --------------------------------------------------------------------- data
--
-- Roles are component tags. Right-click any piece in TTS > Tags to see them;
-- duplicate a wood cube and the copy is wood too, which a GUID would not be.

local ROLES = {
  board = 1, -- the anchor everything is measured from
  ["supply.wood"] = 1,
  marker = 1,
  wood = "*", -- any number: cubes come and go
}

-- Positions in the board's local space. The board is scaled 6 x 1 x 4, so
-- these small numbers land metres apart on the table — and if the board is
-- moved, rotated or resized, every one of them follows it (C2).
local SPACES = {
  supply = { -0.34, LAYER.board, 0.22 },
  clearing = { 0.04, LAYER.board, 0.22 },
  track = { -0.34, LAYER.marker, -0.30 },
}

local SLOT_STEP = 0.10 -- one clearing slot, in board-local X
local SLOTS = 6 -- one per cube in objects/supply.json: fewer and two would stack
local TRACK_STEP = 0.09 -- one round along the track
local ROUNDS = 8

-- The only state worth persisting. The number of cubes in the supply is not
-- here: the bag already knows, and a second copy would only go stale (C4).
local game = ttslib.store.new("game", {
  version = 1,
  defaults = {
    round = 1,
    dropped = 0,
  },
})

-- ---------------------------------------------------------------- the table

local function supplyBag()
  return REG.one("supply.wood")
end

local function woodInSupply()
  local bag = supplyBag()
  return bag and bag.getQuantity() or 0
end

local function slot(index)
  return LAYOUT.add(SPACES.clearing, { (index % SLOTS) * SLOT_STEP, 0, 0 })
end

-- ------------------------------------------------------------------ display

-- The live badge on the supply bag: one named label, edited in place. Adding a
-- button above it later changes nothing, because nothing here knows an index.
local function refreshBadge()
  local bag = supplyBag()
  if not bag then return end
  UI_.label(bag, "count", {
    label = tostring(woodInSupply()),
    position = { 0, 0.85, 0 },
    font_size = 500,
    font_color = { 0.96, 0.93, 0.86 },
  })
end

-- The screen panel. Its markup lives in the save's XmlUI, so there is no
-- setXml here — only the three values that change.
local function refreshHud()
  UI_.value(nil, "hudRound", "Round " .. game.data.round .. " of " .. ROUNDS)
  UI_.value(nil, "hudSupply", "In supply: " .. woodInSupply())
  UI_.value(nil, "hudDropped", "Wood dropped: " .. game.data.dropped)
end

-- Container events arrive in bursts — emptying a bag fires one per object — so
-- the redraw is keyed and coalesced into a single pass on the next frame (C9).
local function refresh()
  ASYNC.keyed("woodcutter.refresh", nil, function()
    refreshBadge()
    refreshHud()
  end)
end

-- ------------------------------------------------------------------- moves

local function placeMarker()
  local marker = REG.one("marker")
  if not marker then return end
  LAYOUT.place(marker, LAYOUT.add(SPACES.track, {
    (game.data.round - 1) * TRACK_STEP, 0, 0,
  }))
end

local function takeWood(playerColour)
  local bag = supplyBag()
  if not LOG.expect(bag, "no wood supply on the table") then return end
  if woodInSupply() == 0 then
    broadcastToColor("The supply is empty.", playerColour, { 0.93, 0.66, 0.35 })
    return
  end
  -- takeObject places the object itself and calls back once it exists; the
  -- take -> Wait.frames -> move dance Almoravid writes 537 times is not needed.
  --
  -- Index by cubes already taken, not cubes left, so the row fills left to
  -- right: the bag still holds this one at the moment we choose its slot.
  LAYOUT.takeTo(bag, slot(SLOTS - woodInSupply()), {
    onPlaced = function(obj)
      LOG.debug("wood placed", obj.getGUID())
    end,
  })
end

local function nextRound(playerColour)
  if game.data.round >= ROUNDS then
    broadcastToColor("That was the last round.", playerColour, { 0.93, 0.66, 0.35 })
    return
  end
  game.data.round = game.data.round + 1
  placeMarker()
  refreshHud()
  broadcastToAll("Round " .. game.data.round, { 0.85, 0.82, 0.76 })
end

local function resetGame()
  game:reset()
  placeMarker()
  refresh()
  broadcastToAll("Woodcutter reset.", { 0.85, 0.82, 0.76 })
end

-- ------------------------------------------------------------------ buttons
--
-- Rebuilt on every load, because TTS does not save scripted buttons: no save or
-- mod JSON in this folder contains button data. Calling this twice edits the
-- buttons that are there rather than stacking a second set on top.

local function buildControls()
  local board = REG.one("board")
  if not board then return end

  -- The board is scaled 6 x 1 x 4, which would render its buttons 6x wide and
  -- 4x deep. unscale cancels exactly that, so the button comes out its own shape.
  --
  -- The positions below are NOT divided by those factors, on the reading that
  -- `position` is measured pre-scale. That is cookbook open question 4 and it is
  -- genuinely unsettled — the API never says which units `position` is in, and
  -- ttslib/03-ui.lua's own comment reads it the other way. If loading this save
  -- shows the two buttons bunched near the middle of the board instead of spread
  -- across it, the other reading is right: divide x by 6 and z by 4 here, and
  -- correct the note in 03-ui.lua.
  local undistort = UI_.unscale(board)

  UI_.button(board, "take", {
    label = "Take wood",
    position = { -0.22, LAYER.board, -0.36 },
    width = 1500, height = 420, font_size = 200,
    color = { 0.29, 0.23, 0.15 },
    font_color = { 0.94, 0.90, 0.82 },
    tooltip = "Move one wood from the supply to the clearing",
    scale = undistort,
    onClick = function(_, playerColour)
      takeWood(playerColour)
    end,
  })

  UI_.button(board, "nextRound", {
    label = "Next round",
    position = { 0.22, LAYER.board, -0.36 },
    width = 1500, height = 420, font_size = 200,
    color = { 0.22, 0.28, 0.20 },
    font_color = { 0.94, 0.90, 0.82 },
    tooltip = "Advance the round marker. Right-click to reset the game.",
    scale = undistort,
    onClick = function(_, playerColour, altClick)
      -- One button, two actions: alt_click is true on right-click.
      if altClick then
        resetGame()
      else
        nextRound(playerColour)
      end
    end,
  })
end

-- --------------------------------------------------------------- XML panel
--
-- Screen-space handlers take (player, value, id), not the button signature.
-- These are global on purpose: the markup names them.

function hudNextRound(player)
  nextRound(player and player.color)
end

function hudReset()
  resetGame()
end

-- --------------------------------------------------------------- lifecycle

function onLoad(script_state)
  ttslib.store.restore(script_state)

  REG.declare(ROLES)
  LAYOUT.anchor("board") -- a role, resolved through the registry on every use
  LAYOUT.spaces(SPACES)

  -- One subscription per event, routed by tag. There is no per-object guard to
  -- forget here, because there is no per-object script (C6, C7).
  EVENTS.on("enterContainer", "supply.wood", function()
    refresh()
  end)
  EVENTS.on("leaveContainer", "supply.wood", function()
    refresh()
  end)
  -- TTS fires drop more than once for one physical drop; 1.25s is Arcs' window.
  EVENTS.on("drop", "wood", function(playerColour)
    game.data.dropped = game.data.dropped + 1
    LOG.debug("wood dropped by " .. tostring(playerColour), game.data.dropped)
    refreshHud()
  end, { debounce = 1.25 })

  -- Everything missing, reported at once, before setup can half-run (C1, C8).
  if not REG.check() then
    LOG.error("setup stopped: tag the components listed above and reload")
    return
  end
  EVENTS.check() -- has anything redefined a TTS event handler?

  -- Anchor-relative setup. Drag the board anywhere, save, reload: the bag, the
  -- marker and the snap row are all where they were, relative to the board.
  LAYOUT.place(supplyBag(), "supply", { smooth = false })
  placeMarker()

  local row = {}
  for i = 0, SLOTS - 1 do
    row[#row + 1] = { at = slot(i), tags = { "wood" } }
  end
  LAYOUT.snaps("board", row)

  buildControls()
  refresh()

  LOG.info("ready — round " .. game.data.round .. ", " ..
    woodInSupply() .. " wood in the supply")
end

-- One generated onSave for every store in this script.
function onSave()
  return ttslib.store.serialize()
end

-- A player who joins later never saw onLoad run, and buttons are not saved.
function onPlayerConnect(player)
  ASYNC.keyed("rebuild." .. tostring(player and player.color), 1.0, function()
    buildControls()
    refresh()
  end)
end
