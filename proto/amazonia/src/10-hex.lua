-- src/10-hex.lua — axial hex math for the tri-hex lattice.  Pure: no TTS.
--
-- Nothing in this file touches a TTS global, which is deliberate — it is the
-- only part of Amazonia that can be proved correct outside the game, and
-- test/hex_spec.lua does exactly that with luajit.  Everything that needs an
-- Object lives in 20-tiles.lua and 30-map.lua.
--
-- The convention is **pointy-top axial (q, r)**, matching RotLA's `Grid.Type 2`
-- (vertical hexes) and the cells written in spec/tiles.json.  With circumradius
-- R:
--
--     x = sqrt(3) * R * (q + r/2)          a step in q is sqrt(3)R east
--     z = 1.5 * R * r                      a step in r is 1.5R "north" and
--                                          sqrt(3)R/2 east — the row offset
--
-- so a tri-hex's three cells are (0,0), (-1,1) and (0,1): at R = 1 that is
-- (0,0), (-0.866, 1.5) and (+0.866, 1.5), which is the mesh measured from
-- RotLA's own .obj (build plan section 2.1).
--
-- Rotation is in 60-degree steps and follows TTS's rotY, which turns +z toward
-- +x.  In axial terms one step is (q, r) -> (q + r, -q); the derivation is the
-- cube-coordinate rotation (x,y,z) -> (-y,-z,-x), and the test pins it against
-- the world-space transform rather than against itself.

-- Global on purpose, like every module here: TTS has no `require`, a build is a
-- concatenation, and `ttsd.py exec` can only reach what is global.  A Lua
-- linter will call this out; it is the shape the platform forces.
hex = {}

hex.SQRT3 = math.sqrt(3)

-- The six neighbours, in the same order as a rotation step, so
-- hex.DIRECTIONS[i] rotated once is hex.DIRECTIONS[i+1].
hex.DIRECTIONS = {
  { 1, 0 }, { 1, -1 }, { 0, -1 }, { -1, 0 }, { -1, 1 }, { 0, 1 },
}

-- ------------------------------------------------------------------ the grid

function hex.toWorld(q, r, radius)
  radius = radius or 1
  return hex.SQRT3 * radius * (q + r / 2), 1.5 * radius * r
end

-- fromWorld(x, z, radius) or fromWorld(vector, radius) — the inverse, with cube
-- rounding.  This is what turns a dropped cube's float position back into
-- hex(1,-1) for the changelog, so it has to round the way the lattice does
-- rather than the way `math.floor` does.
function hex.fromWorld(x, z, radius)
  if type(x) == "table" then
    radius = z
    z = x.z or x[3] or 0
    x = x.x or x[1] or 0
  end
  radius = radius or 1
  local fr = (2 / 3) * z / radius
  local fq = (x / (hex.SQRT3 * radius)) - fr / 2

  -- Round in cube space, then repair whichever axis moved furthest: rounding
  -- the two axial numbers on their own lands on the wrong hex near a corner.
  local fy = -fq - fr
  local q, r, y = math.floor(fq + 0.5), math.floor(fr + 0.5), math.floor(fy + 0.5)
  local dq, dr, dy = math.abs(q - fq), math.abs(r - fr), math.abs(y - fy)
  if dq > dr and dq > dy then
    q = -r - y
  elseif dr > dy then
    r = -q - y
  end
  return q, r
end

function hex.neighbours(q, r)
  local out = {}
  for i = 1, 6 do
    out[i] = { q + hex.DIRECTIONS[i][1], r + hex.DIRECTIONS[i][2] }
  end
  return out
end

function hex.distance(q1, r1, q2, r2)
  local dq, dr = q1 - q2, r1 - r2
  return (math.abs(dq) + math.abs(dq + dr) + math.abs(dr)) / 2
end

-- ring(n) — the n cells at exactly distance n from the origin; ring(0) is the
-- origin itself.  disc(n) is every cell within n, in a stable order: by r, then
-- by q, so a map built twice is laid out identically.
function hex.ring(n)
  if n <= 0 then return { { 0, 0 } } end
  local out = {}
  local q, r = -n, n -- one corner of the ring
  for side = 1, 6 do
    local dq, dr = hex.DIRECTIONS[side][1], hex.DIRECTIONS[side][2]
    for _ = 1, n do
      out[#out + 1] = { q, r }
      q, r = q + dq, r + dr
    end
  end
  return out
end

function hex.disc(n)
  local out = {}
  for q = -n, n do
    local lo = math.max(-n, -q - n)
    local hi = math.min(n, -q + n)
    for r = lo, hi do
      out[#out + 1] = { q, r }
    end
  end
  table.sort(out, function(a, b)
    if a[2] ~= b[2] then return a[2] < b[2] end
    return a[1] < b[1]
  end)
  return out
end

-- ---------------------------------------------------------------- rotation

-- rotate(q, r, steps) — steps of 60 degrees in TTS's rotY direction.
function hex.rotate(q, r, steps)
  steps = (steps or 0) % 6
  for _ = 1, steps do
    q, r = q + r, -q
  end
  return q, r
end

-- footprint(cells, q, r, steps) — where a tile's cells land when its pivot is
-- at (q, r) and it is turned `steps` sixths of a turn.  The pivot is cells[1],
-- which is why it is always (0, 0) in the spec: a tile turns about one of its
-- own hex centres, not about its centroid, and that is what lets up- and
-- down-pointing tiles interlock on one lattice.
function hex.footprint(cells, q, r, steps)
  local out = {}
  for i = 1, #cells do
    local cq, cr = hex.rotate(cells[i][1], cells[i][2], steps)
    out[i] = { q + cq, r + cr }
  end
  return out
end

function hex.key(q, r)
  return q .. "," .. r
end

-- ----------------------------------------------------------------- packing

-- pack(cells, rings, opts) — lay non-overlapping copies of one tile shape over
-- a disc, trying each rotation in turn.
--
-- This is the map generator's only geometry.  It is greedy and deterministic:
-- walk the disc in disc() order, and at the first uncovered cell place the
-- first rotation that fits.  Rerolling the map redraws which *kind* goes where
-- (30-map.lua) and leaves the lattice alone, so a reroll changes the terrain
-- rather than the shape of the table.
--
-- opts:
--   overflow  default true — a tile may hang over the rim of the disc, which
--             covers it completely and gives a ragged, organic coastline.
--             false keeps every tile inside and leaves gaps instead.
--   rotations default { 0, 1, 2, 3, 4, 5 }, the order rotations are tried in.
--   order     the cells to walk, in place of hex.disc(rings).  **The packing is
--             greedy, so the order is the tiling**: hex.disc sorts by r then q,
--             which means disc(18) starts in a different corner from disc(3)
--             and the two produce tilings that do not line up.  Pass the small
--             disc's cells first, then the rest of the big one, and the small
--             packing comes out as an exact prefix of the big one, so a bigger
--             pack extends a smaller one instead of replacing it.
--             The rig had one caller for that — the snap field, when it was
--             still a tiling — and since 2026-09-22 it has none: Map.lattice is
--             per cell now, and Map.slots packs one disc and only one.  The
--             property is the packer's own and hex_spec still pins it, because
--             the next shape laid over a growing disc will want it.
--
-- Returns placements = { { q, r, rot } } with rot in 60-degree steps, and
-- holes = the cells of the disc nothing covered (0 to 2 of them for a tri-hex).
function hex.pack(cells, rings, opts)
  opts = opts or {}
  local overflow = opts.overflow ~= false
  local rotations = opts.rotations or { 0, 1, 2, 3, 4, 5 }

  local target, used = {}, {}
  local disc = opts.order or hex.disc(rings)
  for _, cell in ipairs(disc) do
    target[hex.key(cell[1], cell[2])] = true
  end

  local placements = {}
  for _, cell in ipairs(disc) do
    local q, r = cell[1], cell[2]
    if not used[hex.key(q, r)] then
      for _, rot in ipairs(rotations) do
        local shape = hex.footprint(cells, q, r, rot)
        local fits = true
        for _, c in ipairs(shape) do
          local k = hex.key(c[1], c[2])
          if used[k] or (not overflow and not target[k]) then
            fits = false
            break
          end
        end
        if fits then
          for _, c in ipairs(shape) do
            used[hex.key(c[1], c[2])] = true
          end
          placements[#placements + 1] = { q, r, rot }
          break
        end
      end
    end
  end

  local holes = {}
  for _, cell in ipairs(disc) do
    if not used[hex.key(cell[1], cell[2])] then
      holes[#holes + 1] = cell
    end
  end
  return placements, holes
end

-- -------------------------------------------------------------------- chance
--
-- A 32-bit LCG, here rather than in 30-map.lua because a seeded map has to
-- come out the same twice and math.random's sequence is TTS's business, not
-- ours.  Being in this file means the draw is covered by the luajit tests.

function hex.rng(seed)
  local state = (tonumber(seed) or 0) % 2147483647
  if state <= 0 then state = state + 2147483646 end
  local self = {}

  -- Park-Miller, in the double-safe form: 16807 * state stays under 2^53.
  function self.next()
    state = (16807 * state) % 2147483647
    return state / 2147483647
  end

  -- An integer in [1, n], and a weighted pick over { { weight, value } }.
  function self.int(n)
    return math.floor(self.next() * n) + 1
  end

  function self.pick(weighted)
    local total = 0
    for _, entry in ipairs(weighted) do total = total + entry[1] end
    if total <= 0 then return nil end
    local roll = self.next() * total
    for _, entry in ipairs(weighted) do
      roll = roll - entry[1]
      if roll <= 0 then return entry[2] end
    end
    return weighted[#weighted][2]
  end

  return self
end
