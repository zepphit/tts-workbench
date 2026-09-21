-- src/00-config.lua — the numbers, in one place.  Data only, no behaviour.
--
-- Everything about *art* comes from AMAZONIA_ART, which scripts/tilegen.py
-- generates into art/index.lua from spec/tiles.json and build.sh concatenates
-- ahead of this file.  Nothing here restates a mesh URL, a cell layout or a
-- tint: a second copy would go stale the first time the spec changed.
--
-- What is here is the part tilegen has no opinion about — how big the map is,
-- how high things float, which tags the registry expects, and how a hub button
-- looks.  An L1 change (build plan section 6) usually means one number in this
-- file followed by a rebuild, or the same value poked live through `A.*`.

ART = AMAZONIA_ART or error(
  "art/index.lua was not loaded before src/00-config.lua — run "
  .. "`python3 scripts/tilegen.py` and rebuild with proto/amazonia/build.sh")

-- Component tags.  One axis per tag: every tile carries "tile" *and*
-- "tile.<kind>", so "every tile" and "every jungle tile" are both one query and
-- neither has to be parsed out of the other.
ROLES = {
  ["map.anchor"] = 1, -- the locked plate every position is measured against
  tile = "*", -- any number: the map is rebuilt and rerolled
  tray = "*", -- the subset of those tiles that is the palette, not the map
}

MAP = {
  rings = 3, -- radius of the hex disc the packer fills
  seed = 1, -- the draw; AZ.reroll(n) changes it live
  tileY = 0.15, -- world units above the anchor's centre a tile floats
  overflow = true, -- let tiles hang over the rim: a ragged coast, no holes
  shape = "trihex", -- which shape from the spec the map is laid out in

  -- Two different snapping systems, and the whole point is that they are set
  -- opposite ways round.
  --
  --   snap      the lattice: one snap point per slot, tagged `tile`, which is
  --             what makes a tri-hex dropped by hand land interlocked with its
  --             neighbours instead of a few millimetres off.  **On.**
  --   gridSnap  TTS's own grid — Options > Grid > Snapping.  It is not per
  --             object and not per tag: it catches *everything*, which is why a
  --             cube laid on a tile jumped to the nearest hex centre.  **Off**,
  --             and enforced at boot, because the running game had it at Center
  --             (Grid.snapping = 3) while the save file said otherwise.
  --
  -- Belt and braces: 30-map.lua also clears `use_grid` and `use_snap_points` on
  -- every object that is not a tile, as it spawns. That makes "only tiles snap"
  -- true whatever TTS does with a snap point's tags.
  snap = true,
  gridSnap = false,

  -- The plate, in world units: one surface for the map *and* the tray, because
  -- two plates meant two floors to keep flush and a seam to fall through.
  -- 60 x 40.8 is three times the original anchor's 20 across and 1.2 times its
  -- 34 deep. Applied at boot the way gridSnap is — the size is the rig's, not
  -- the save file's, so a rebuild reproduces it.
  plate = { x = 60, z = 40.8 },

  -- How far the snap lattice reaches, in rings.  **0 means "cover the plate"**,
  -- which is what you want: the lattice is derived from the anchor's measured
  -- size, so resizing the plate re-derives it and no number here goes stale.
  -- A positive value pins it instead, for a lattice smaller than the plate.
  --
  -- This is a *separate, larger* lattice from MAP.rings, which stays the disc
  -- the random map is drawn over. Until 2026-09-21 they were the same thing, so
  -- the only snappable positions on the table were the slots the map already
  -- filled: every tile dragged from the tray landed on top of another tile and
  -- looked like it was refusing to snap.
  snapRings = 0,
  snapMaxRings = 24, -- a guard: rings^2 cells, and a typo in plate.x is cheap
}

TILES = {
  scaleY = 0.5, -- RotLA's; X and Z stay at 1 so button positions are unscaled
  locked = true, -- AZ.lock(false) frees them for hand-rearranging
  material = 3, -- Cardboard; TypeIndex 0 is Generic. Both copied from RotLA.
  convex = true, -- the collider is three convex hex prisms, so this is honest
  grid = false, -- a tile ignores TTS's own grid ...
  snap = true, -- ... and uses the lattice, which is what interlocks them
}

-- The tray: one of every `tray` kind in the spec, laid out beside the anchor
-- plate for hand-placing.  These are the frontier tiles — the ones that draw a
-- shoreline or a walled clearing — and they are drawn from by hand rather than
-- by the random map, so every one of them sits at weight 0.
--
-- Positions are anchor-local like everything else, so dragging the plate takes
-- the tray with it.  The numbers below are in **world units** and are divided
-- by the anchor's scale on the way in, exactly as Map.slots does — that is the
-- one place the two coordinate systems meet.
--
-- A tri-hex's bounding box is 3.46 x 3.5, so the spacing is one tile plus a
-- finger's width, and six columns beside the 20 x 17 plate come out roughly the
-- plate's own footprint: the tray sits next to the map rather than across the
-- room from it.
-- **The tray brings its own plate, and that is not decoration.** The table is
-- Table_None: there is no table, and the anchor plate is the floor. An unlocked
-- tile past its rim falls out of the world — which is what the first build did,
-- heaping all twenty-two against the plate's east edge. The tray's own plate is
-- sized to the grid, butted against the map plate with no gap to fall through,
-- and its top sits flush with the map plate's so a tile dragged from one to the
-- other does not step up or down.
-- The grid is four columns because the table was measured, not guessed.
-- Table_RPG's flat surface runs to x = 28 and its raised rim starts at x = 29
-- (Physics.cast straight down, 2026-09-21); four columns from x = 12.5 put the
-- far tile's edge at 25.6, clear of it. Six columns reached 33 and hung over
-- the edge — which, before there was a table at all, is how twenty-two tiles
-- ended up heaped against the map plate's rim.
TRAY = {
  tag = "tray", -- the third tag a tray tile carries, beside tile and tile.<kind>
  plateTag = "tray.plate",
  columns = 4,
  spacing = { x = 3.8, z = 3.9 },
  origin = { x = 12.5, z = -9.75 }, -- east of the plate, centred on its z axis
  margin = 1.2, -- plate overhang: 0.6 a side, which closes the seam at x = 10
  colour = { 0.16, 0.14, 0.11 }, -- a shade off the map plate, so it reads apart
  locked = false, -- the whole point is to pick them up
}

-- Hub buttons: one stripe per cell, centred on that cell's own hex, a hair
-- above the tile's top face.  Wide and thin on purpose — a stripe, not a box.
--
-- The tile is scaled 0.5 in Y only, and ttslib's unscale leaves Y at 1, so the
-- pre-/post-scale ambiguity in review-2026-09-21's A8 cannot bite here.
--
-- Width, height and font are the numbers most likely to want nudging once you
-- can see them on the table, so AZ.hubstyle(w, h, font) sets all three live —
-- an L1 change, no rebuild.  Copy whatever you settle on back into this table.
HUB = {
  -- **Off.**  The tiles read plain while the terrain itself is being designed;
  -- a resource stripe over every cell is noise until there are resources.  The
  -- drawing code below it stays, because what it knows about TTS — the
  -- counter-rotation and the 180 in `facing` — took a session at the table to
  -- establish and is not worth rediscovering.  AZ.labels(true) brings it back,
  -- and a kind only shows a stripe if spec/tiles.json gives it `hubs` again.
  enabled = false,

  y = 0.12,
  width = 1040, -- a hex is sqrt(3) across the flats; this stays inside it
  height = 165, -- a stripe
  fontSize = 130,
  colour = { 0.12, 0.10, 0.07 },
  fontColour = { 0.95, 0.91, 0.82 },

  -- The baseline every hub stripe is turned to, on top of the counter-rotation
  -- that cancels its tile's own spin (20-tiles.lua).
  --
  -- It is 180 because TTS lays a button's text out with its "up" along the
  -- object's local -Z, and the default camera looks the other way: a button at
  -- rotation 0 on a perfectly upright object reads upside down. Measured on the
  -- table 2026-09-21 — the tiles were confirmed level first (rotX = rotZ = 0,
  -- getTransformUp().y = 1), so this is TTS's convention, not a flipped tile.
  --
  -- AZ.hubface(deg) changes it live if 180 is not what your camera wants.
  facing = 180,
}

-- The resources a hub can cycle through on right-click.  Not a rules decision —
-- a prototype needs *some* list, and this one is trivially edited.
RESOURCES = { "rubber", "timber", "cacao", "fish", "gold", "camp" }
