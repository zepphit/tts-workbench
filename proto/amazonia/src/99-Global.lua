-- src/99-Global.lua — boot.
--
-- Load order is filename order, because TTS has no `require` and a build is a
-- concatenation (critique C5, C10): ttslib, then art/index.lua, then 00 to 99
-- of this directory.  Everything above is definitions; this is the only file
-- that does anything on load.
--
-- The sequence is the framework's, in the framework's order:
--
--   store.restore    what the table cannot tell us: the seed, the ring count
--   registry.declare the manifest, so a missing anchor is one loud line at boot
--                    rather than a nil dereference halfway through setup
--   layout.anchor    a role, not a GUID: the plate can be replaced
--   Map.snaps        the snap lattice — which MAP.snap turns off, in which case
--                    this is what clears the points a previous save left behind
--   Tray.build       the palette of frontier tiles, if it is not already there
--   Map.build        only if the table is empty — TTS saves spawned objects,
--                    so a reload already has its tiles
--
-- Nothing here writes a world-space coordinate.  Every position is the anchor's
-- local space resolved through positionToWorld, which is what makes dragging
-- the plate move the whole map (critique C2).

local LOG = ttslib.log
local ASYNC = ttslib.async
local EVENTS = ttslib.events
local REG = ttslib.registry
local LAYOUT = ttslib.layout

LOG.prefix = "[amazonia]"
LOG.level = "info" -- "debug" narrates to the host console (~)

-- The only state worth persisting.  Which tiles are where is not here: the
-- table already knows, and Map.cells() derives it (critique C4).
local game = ttslib.store.new("amazonia", {
  version = 1,
  defaults = {
    seed = 1,
    rings = 3,
  },
})

-- ---------------------------------------------------------------- lifecycle

function onLoad(script_state)
  ttslib.store.restore(script_state)
  MAP.seed = game.data.seed
  MAP.rings = game.data.rings

  REG.declare(ROLES)
  LAYOUT.anchor("map.anchor")

  Journal.attach()

  -- Rubber follows a dragged tile across the divider: off as it is lifted, on
  -- again if it lands west of the line. This is what makes "copy a tray tile,
  -- drag it onto the map" bring its cubes, which nothing at spawn time can see.
  Rubber.attach()

  -- Hub stripes are counter-rotated so their text reads one way across the
  -- whole map (20-tiles.lua). A tile turned by hand invalidates that, and TTS
  -- has no event for "rotation finished" — so this redraws on rotate, keyed per
  -- object so a spin costs one redraw rather than one per face.
  EVENTS.on("rotate", "tile", function(obj)
    Tiles.repin(obj)
  end)

  -- Only tiles snap. TTS's grid is global and catches everything, so it goes
  -- off; the lattice stays on, because it is what interlocks the tri-hexes.
  -- Anything else that appears is taken out of both systems as it spawns —
  -- "*" is every tag, and Map.unsnap skips a tile.
  EVENTS.on("spawn", "*", function(obj)
    Map.unsnap(obj)
  end)

  if not REG.check() then
    LOG.error("setup stopped: tag the components listed above and reload")
    return
  end
  EVENTS.check() -- has anything redefined a TTS event handler?

  -- The lattice on, TTS's own grid off, and everything already on the table
  -- that is not a tile taken out of both. Map.grid is enforced here rather than
  -- left to the save file because the two disagreed on 2026-09-21: the file
  -- said Snapping false and the running game was at Center.
  -- One plate for the map and the tray, sized from the rig rather than from the
  -- save file for the same reason the grid is (Map.grid): the two disagreed
  -- once already. This re-derives the lattice and rewrites the snap field, so
  -- it stands in for the Map.snaps() that used to be here.
  Map.plate(MAP.plate.x, MAP.plate.z)
  Map.grid(MAP.gridSnap)
  Map.unsnapAll()

  -- The tray is spawned like the map is, and like the map it is already there
  -- after a reload — TTS saves spawned objects.  sync() rather than build():
  -- the owner curates this palette by hand and every push reloads the save, so
  -- a rebuild would undo his arrangement on each code change.  See Tray.sync.
  Tray.sync()

  -- The rubber supply, beside the creek and road bags. Spawned once and then
  -- recognised by its tag on every later boot, so a reload neither replaces
  -- what he has been dragging from nor leaves him a second one.
  Rubber.bag()

  if Map.count() == 0 then
    LOG.info("empty table — building map " .. MAP.seed)
    Map.build(MAP.seed)
  else
    -- A reload: the tiles came back with the save, but scripted buttons never
    -- do, so the hubs have to be drawn again.
    local tiles = Tiles.all()
    for _, obj in ipairs(tiles) do
      Tiles.hubs(obj)
    end
    LOG.info("restored " .. #tiles .. " tiles, seed " .. MAP.seed)
  end

  ASYNC.keyed("boot.hud", 0.75, function()
    uiRefresh()
    LOG.info("ready — " .. AZ.state())
    LOG.info("drive it with: python3 scripts/ttsd.py exec 'return AZ.state()'")
  end)
end

function onSave()
  game.data.seed = MAP.seed
  game.data.rings = MAP.rings
  return ttslib.store.serialize()
end

-- A player who joins later never saw onLoad run, and buttons are not saved.
function onPlayerConnect(player)
  ASYNC.keyed("rebuild." .. tostring(player and player.color), 1.0, function()
    for _, obj in ipairs(Tiles.all()) do
      Tiles.hubs(obj)
    end
    uiRefresh()
  end)
end
