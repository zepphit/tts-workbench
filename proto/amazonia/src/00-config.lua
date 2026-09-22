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
  rubber = "*", -- the cubes on deep forest hexsides; none until a tile spawns
  ["rubber.bag"] = "*", -- the supply bag; 1 once booted, 0 before
  ["tray.divider"] = "*", -- the line between the map and the palette
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

  -- The divider: a line on the floor between the map and the palette.
  --
  -- There is one plate now (MAP.plate), which removed the seam the two used to
  -- have and with it the only thing that showed where the map stopped and the
  -- palette began. This puts the boundary back as a mark rather than as a
  -- second surface — nothing to keep flush, nothing to fall down.
  --
  -- **x is a gap, not a guess.** The map is a rings-3 disc: its furthest cell
  -- centre is at x = 5.20 and a tri-hex reaches 0.87 past that, so the map ends
  -- around 6.1 and an overflow tile can reach 7.8. The palette's west column is
  -- centred at TRAY.origin.x = 12.5 and a tile is 3.46 across, so it starts at
  -- 10.77. 9.9 sits in the clear between them.
  --
  -- **y is under a tile, not over it.** The plate's top is 0.1 above the
  -- anchor's centre and a tile floats with its own bottom face exactly there
  -- (MAP.tileY 0.15, 0.1 thick). A bar 0.06 tall centred at 0.13 spans 0.10 to
  -- 0.16, so a tile laid across it hides it instead of being pierced by it.
  divider = {
    enabled = true,
    tag = "tray.divider",
    x = 9.9,
    y = 0.13,
    width = 0.22,
    height = 0.06,
    margin = 2.0, -- inset from each end of the plate, so it stops short of the rim
    colour = { 0.72, 0.62, 0.38 }, -- ochre: the one warm thing on a green table
  },
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

-- Rubber: a white cube on every deep forest hexside, placed as the tile spawns.
--
-- A "deep forest hexside" is an **outer** edge a kind's `paint` block names
-- `deep_jungle` — the walls of a glade, the far bank of a DF coast.  That is
-- narrower than "every hexside whose terrain is deep forest", and deliberately:
-- a plain `deep_jungle` triplet is deep forest all over, so the wider rule would
-- ring each of the five on the current map with twelve cubes and double them up
-- along every seam where two of them meet.  The owner chose the narrow rule
-- (2026-09-22).  `terrain` below is the only thing that decides it, so the wider
-- reading is a different value here plus reading `edges` differently — the data
-- for both is in art/index.lua.
--
-- **Spawn only.**  Rubber appears when a tile appears and never again: nothing
-- watches a drop, a pick-up or a rotate, so moving cubes and tiles around by
-- hand is free and no cube grows back.  A reload does not respawn either —
-- TTS saves spawned objects, so the cubes come back from the save file with
-- the tiles they sit on.  The places that *do* spawn are Map.build, Map.put and
-- a tray sync; Tiles.reskin explicitly does not, because it destroys and
-- respawns a tile in place and its cubes never moved.
RUBBER = {
  enabled = true,
  terrain = "deep_jungle", -- which painted edge terrain earns a cube

  -- How far from a cell's centre a cube has to be to count as that cell's,
  -- in hex radii. See Rubber.clearNear — 0.9 sits between a tile's own cubes
  -- at 0.66 and a neighbouring tile's at 1.07.
  claim = 0.9,

  -- Two tags, and the split is what decides whose cubes survive a reroll.
  --
  --   rubber      every cube, including the ones dragged out of the bag by
  --               hand. This is what Rubber.count() reports.
  --   rubber.map  only the ones a tile spawned. Rubber.clear() takes these and
  --               nothing else, so `AZ.reroll` rebuilds the map without
  --               sweeping away rubber the owner placed himself.
  --
  -- The bag carries neither — it is `bagTag` alone, or clearing the map's
  -- rubber would destroy the supply it came from.
  tag = "rubber",
  mapTag = "rubber.map",
  bagTag = "rubber.bag",

  -- The supply bag, beside the creek and road bags he made by hand. Those two
  -- sit at x = 1.6 and 3.6 on z = 10.6, two apart; this takes the free side of
  -- the creek so the three read as one row. Anchor-local like everything else
  -- in this file, so dragging the plate takes it along — which is the one way
  -- it differs from the hand-made two.
  bag = { x = -0.4, y = 0.083, z = 10.6 },
  name = "Rubber",
  block = "BlockSquare", -- TTS's own 1-unit cube; the owner's sample is one
  scale = 0.25,
  colour = { 1, 1, 1 },

  -- How far in from the cell's centre a cube sits, in world units, along the
  -- normal of its hexside.  Measured off the cube the owner placed on
  -- glade_mix_a on 2026-09-22: 0.66 from the centre of the top-right cell,
  -- towards its NE edge.
  --
  -- It is **not** the apothem (0.866, the edge itself) and that is the point.
  -- The jungle|deep_jungle frontier reaches 0.44 in from the rim, so the DF
  -- band runs from 0.43 to 0.87 and 0.66 is the middle of it: the cube sits on
  -- the deep forest it marks rather than on the line. It also keeps two cubes
  -- apart where two DF walls meet across a seam — they land 0.4 from each
  -- other rather than in the same place.
  inset = 0.66,

  -- Above the tile's own centre, not its face: a tile is 0.1 thick at scaleY
  -- 0.5 and a 0.25 cube is 0.26 tall, so 0.18 rests one on the other. The cube
  -- spawns unlocked and settles anyway; this only stops it dropping through.
  y = 0.18,
}

-- The resources a hub can cycle through on right-click.  Not a rules decision —
-- a prototype needs *some* list, and this one is trivially edited.
RESOURCES = { "rubber", "timber", "cacao", "fish", "gold", "camp" }
