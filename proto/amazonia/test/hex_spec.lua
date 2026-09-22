-- test/hex_spec.lua — the axial math, proved outside TTS.
--
--   luajit proto/amazonia/test/hex_spec.lua
--
-- 10-hex.lua touches no TTS global, so this needs no harness at all: it loads
-- the file and calls it.  What it proves is that the lattice, the rotation and
-- the packer agree with each other and with the geometry measured from RotLA's
-- mesh; what it cannot prove is anything about TTS — whether a spawned tile
-- really lands on the position this arithmetic returns is the step-3 gate.
--
-- The rotation case is the one worth reading. It does not check the axial
-- formula against itself; it turns each cell in *world space* by TTS's own rotY
-- transform and asserts the axial result lands on the same spot. Getting the
-- direction of rotY backwards is the easiest mistake here and that is the test
-- that would catch it.

local HERE = arg[0]:match("^(.*)/[^/]+$") or "."
dofile(HERE .. "/../src/10-hex.lua")

local out = print
local checks, failures, currentCase = 0, 0, "?"

local function check(ok, label)
  checks = checks + 1
  if not ok then
    failures = failures + 1
    out(string.format("  FAIL  %s: %s", currentCase, label))
  end
  return ok
end

local function eq(got, want, label)
  return check(got == want,
    string.format("%s (got %s, want %s)", label, tostring(got), tostring(want)))
end

local function near(got, want, label)
  return check(math.abs((got or 0) - want) < 1e-6,
    string.format("%s (got %s, want %s)", label, tostring(got), tostring(want)))
end

local cases = {}
local function case(name, fn)
  cases[#cases + 1] = { name = name, fn = fn }
end

local TRIHEX = { { 0, 0 }, { -1, 1 }, { 0, 1 } }
local SQRT3 = math.sqrt(3)

-- ------------------------------------------------------------------ lattice

case("toWorld reproduces the measured tri-hex", function()
  local x, z = hex.toWorld(0, 0, 1)
  near(x, 0, "cell A x")
  near(z, 0, "cell A z")
  x, z = hex.toWorld(-1, 1, 1)
  near(x, -SQRT3 / 2, "cell B x")
  near(z, 1.5, "cell B z")
  x, z = hex.toWorld(0, 1, 1)
  near(x, SQRT3 / 2, "cell C x")
  near(z, 1.5, "cell C z")
end)

case("the lattice steps are sqrt(3)R across and 1.5R up", function()
  local x0, z0 = hex.toWorld(0, 0, 1)
  local x1, z1 = hex.toWorld(1, 0, 1)
  near(x1 - x0, SQRT3, "one step in q is sqrt(3)R east")
  near(z1 - z0, 0, "one step in q does not move z")
  local x2, z2 = hex.toWorld(0, 1, 1)
  near(z2 - z0, 1.5, "one step in r is 1.5R")
  near(x2 - x0, SQRT3 / 2, "one step in r offsets the row by sqrt(3)R/2")
end)

case("radius scales the lattice", function()
  local x, z = hex.toWorld(2, -1, 2.5)
  near(x, SQRT3 * 2.5 * 1.5, "x at R = 2.5")
  near(z, 1.5 * 2.5 * -1, "z at R = 2.5")
end)

case("fromWorld is the exact inverse of toWorld on centres", function()
  for _, cell in ipairs(hex.disc(4)) do
    local x, z = hex.toWorld(cell[1], cell[2], 1)
    local q, r = hex.fromWorld(x, z, 1)
    eq(q .. "," .. r, cell[1] .. "," .. cell[2], "round trip")
  end
end)

case("fromWorld rounds to the nearest cell, not the nearest integer", function()
  -- A point just inside cell (1,0)'s edge, nearer that centre than any other.
  local cx, cz = hex.toWorld(1, 0, 1)
  local q, r = hex.fromWorld(cx - 0.4, cz + 0.2, 1)
  eq(q .. "," .. r, "1,0", "off-centre point")
  -- The corner shared by (0,0), (-1,1) and (0,1): whichever it picks, it must
  -- pick one of the three and not something further away.
  q, r = hex.fromWorld(0, 1, 1)
  local ok = (q == 0 and r == 0) or (q == -1 and r == 1) or (q == 0 and r == 1)
  check(ok, "a shared corner resolves to one of its three cells, got " .. q .. "," .. r)
end)

case("fromWorld accepts a TTS vector", function()
  local q, r = hex.fromWorld({ x = SQRT3, y = 1.4, z = 0 }, 1)
  eq(q .. "," .. r, "1,0", "table form")
  q, r = hex.fromWorld({ SQRT3 / 2, 1.4, 1.5 }, 1)
  eq(q .. "," .. r, "0,1", "array form")
end)

-- --------------------------------------------------------------- topology

case("neighbours are all at distance 1, and are six distinct cells", function()
  local seen = {}
  for _, n in ipairs(hex.neighbours(2, -3)) do
    eq(hex.distance(2, -3, n[1], n[2]), 1, "neighbour distance")
    seen[hex.key(n[1], n[2])] = true
  end
  local count = 0
  for _ in pairs(seen) do count = count + 1 end
  eq(count, 6, "six distinct neighbours")
end)

case("ring(n) has 6n cells all at distance n; ring(0) is the origin", function()
  eq(#hex.ring(0), 1, "ring(0) size")
  for n = 1, 4 do
    eq(#hex.ring(n), 6 * n, "ring(" .. n .. ") size")
    for _, cell in ipairs(hex.ring(n)) do
      eq(hex.distance(0, 0, cell[1], cell[2]), n, "ring(" .. n .. ") distance")
    end
  end
end)

case("disc(n) is 3n(n+1)+1 cells, distinct, in a stable order", function()
  for n = 0, 4 do
    local disc = hex.disc(n)
    eq(#disc, 3 * n * (n + 1) + 1, "disc(" .. n .. ") size")
    local seen = {}
    for _, cell in ipairs(disc) do
      check(not seen[hex.key(cell[1], cell[2])], "disc has no duplicates")
      seen[hex.key(cell[1], cell[2])] = true
      check(hex.distance(0, 0, cell[1], cell[2]) <= n, "disc stays within n")
    end
  end
  local a, b = hex.disc(3), hex.disc(3)
  for i = 1, #a do
    eq(hex.key(a[i][1], a[i][2]), hex.key(b[i][1], b[i][2]), "disc order is stable")
  end
end)

-- --------------------------------------------------------------- rotation

case("one rotate step matches TTS's rotY transform in world space", function()
  -- positionToWorld's rotation, as the stub harness and TTS both apply it:
  --   x' = x*cos + z*sin ;  z' = -x*sin + z*cos
  local function turn(x, z, degrees)
    local rad = math.rad(degrees)
    return x * math.cos(rad) + z * math.sin(rad), -x * math.sin(rad) + z * math.cos(rad)
  end
  for steps = 0, 5 do
    for _, cell in ipairs(hex.disc(2)) do
      local x, z = hex.toWorld(cell[1], cell[2], 1)
      local wx, wz = turn(x, z, 60 * steps)
      local q, r = hex.rotate(cell[1], cell[2], steps)
      local ax, az = hex.toWorld(q, r, 1)
      near(ax, wx, "rotate " .. steps .. " x for " .. hex.key(cell[1], cell[2]))
      near(az, wz, "rotate " .. steps .. " z for " .. hex.key(cell[1], cell[2]))
    end
  end
end)

case("six rotate steps are the identity, and rotation keeps distance", function()
  for _, cell in ipairs(hex.disc(3)) do
    local q, r = hex.rotate(cell[1], cell[2], 6)
    eq(hex.key(q, r), hex.key(cell[1], cell[2]), "rotate 6 is identity")
    q, r = hex.rotate(cell[1], cell[2], 2)
    eq(hex.distance(0, 0, q, r), hex.distance(0, 0, cell[1], cell[2]),
      "rotation preserves distance")
  end
end)

case("all six rotations of a tri-hex are distinct footprints", function()
  -- The pivot is a hex centre, not the centroid, so a turn does not map the
  -- shape onto itself and does not merely repeat after two steps: all six land
  -- on different cells. That is what gives the packer six options at each slot.
  local shapes, seen = {}, {}
  for steps = 0, 5 do
    local keys = {}
    for _, cell in ipairs(hex.footprint(TRIHEX, 0, 0, steps)) do
      keys[#keys + 1] = hex.key(cell[1], cell[2])
    end
    table.sort(keys)
    shapes[steps] = table.concat(keys, " ")
    check(not seen[shapes[steps]], "rotation " .. steps .. " repeats an earlier one")
    seen[shapes[steps]] = true
  end
  eq(shapes[0], "-1,1 0,0 0,1", "the unrotated footprint is the measured one")
  eq(shapes[1], "0,0 0,1 1,0", "one step gives the other orientation")
end)

case("rotations alternate between up- and down-pointing triangles", function()
  -- A triangle of three hexes surrounds one lattice vertex, and lattice
  -- vertices come in two classes. Sum (q + r) over the cells, mod 3, tells you
  -- which: even steps give one class, odd steps the other. This is the property
  -- the packer exploits to interlock tiles, and it survives translation.
  local function class(cells)
    local total = 0
    for _, cell in ipairs(cells) do total = total + cell[1] + cell[2] end
    return total % 3
  end
  local even = class(hex.footprint(TRIHEX, 0, 0, 0))
  local odd = class(hex.footprint(TRIHEX, 0, 0, 1))
  check(even ~= odd, "the two orientations are distinguishable")
  for _, at in ipairs({ { 0, 0 }, { 3, -2 }, { -4, 1 }, { 2, 2 } }) do
    for steps = 0, 5 do
      local want = (steps % 2 == 0) and even or odd
      eq(class(hex.footprint(TRIHEX, at[1], at[2], steps)), want,
        "class at " .. hex.key(at[1], at[2]) .. " step " .. steps)
    end
  end
end)

case("footprint translates as well as turns, and the pivot stays put", function()
  local shape = hex.footprint(TRIHEX, 3, -2, 0)
  eq(hex.key(shape[1][1], shape[1][2]), "3,-2", "cells[1] is the pivot")
  for steps = 0, 5 do
    local turned = hex.footprint(TRIHEX, 3, -2, steps)
    eq(hex.key(turned[1][1], turned[1][2]), "3,-2", "the pivot never moves")
    eq(#turned, 3, "three cells")
  end
end)

-- ---------------------------------------------------------------- packing

case("pack covers the disc with no overlaps", function()
  for _, rings in ipairs({ 1, 2, 3, 4, 5, 6 }) do
    local placements, holes = hex.pack(TRIHEX, rings)
    local used = {}
    for _, p in ipairs(placements) do
      for _, cell in ipairs(hex.footprint(TRIHEX, p[1], p[2], p[3])) do
        local k = hex.key(cell[1], cell[2])
        check(not used[k], "rings=" .. rings .. ": cell " .. k .. " covered twice")
        used[k] = true
      end
    end
    eq(#placements * 3, (function()
      local n = 0
      for _ in pairs(used) do n = n + 1 end
      return n
    end)(), "rings=" .. rings .. ": every tile contributes three cells")
    -- A ragged coastline is expected; a hole-riddled interior is not.
    check(#holes <= 2, "rings=" .. rings .. ": " .. #holes .. " holes, want at most 2")
  end
end)

case("pack is deterministic", function()
  local a = hex.pack(TRIHEX, 4)
  local b = hex.pack(TRIHEX, 4)
  eq(#a, #b, "same tile count")
  for i = 1, #a do
    eq(table.concat(a[i], ","), table.concat(b[i], ","), "placement " .. i)
  end
end)

case("pack with overflow=false stays inside the disc and leaves gaps", function()
  local placements, holes = hex.pack(TRIHEX, 4, { overflow = false })
  for _, p in ipairs(placements) do
    for _, cell in ipairs(hex.footprint(TRIHEX, p[1], p[2], p[3])) do
      check(hex.distance(0, 0, cell[1], cell[2]) <= 4, "no tile hangs over the rim")
    end
  end
  check(#holes > 0, "a strict pack of a disc leaves gaps (got " .. #holes .. ")")
end)

case("pack handles a one-cell shape exactly", function()
  local placements, holes = hex.pack({ { 0, 0 } }, 3)
  eq(#placements, #hex.disc(3), "one tile per cell")
  eq(#holes, 0, "no holes")
end)

-- The packer's prefix property.  hex.disc sorts by r then q, so a bigger disc
-- starts in a different corner and — the pack being greedy — comes out as a
-- tiling offset from the small one.  Walking the small disc's cells first makes
-- the small packing an exact prefix of the big one, so a bigger pack extends a
-- smaller one instead of replacing it.
--
-- The snap field used to be what needed this.  It is per cell since 2026-09-22
-- and does not pack at all (30-map.lua, Map.lattice), so nothing in the rig
-- passes opts.order today.  Kept pinned because it is a real property of the
-- packer and the next shape laid over a growing disc will want it.
case("a plain bigger pack does NOT contain the smaller one", function()
  local small = hex.pack(TRIHEX, 3)
  local big = hex.pack(TRIHEX, 8)
  local same = true
  for i = 1, #small do
    local a, b = small[i], big[i]
    if not b or a[1] ~= b[1] or a[2] ~= b[2] or a[3] ~= b[3] then
      same = false
      break
    end
  end
  check(not same,
    "disc order makes the two tilings disagree — this is why opts.order exists")
end)

case("opts.order makes the small pack a prefix of the big one", function()
  local small = hex.pack(TRIHEX, 3)

  local order, seen = {}, {}
  for _, cell in ipairs(hex.disc(3)) do
    order[#order + 1] = cell
    seen[hex.key(cell[1], cell[2])] = true
  end
  for _, cell in ipairs(hex.disc(8)) do
    if not seen[hex.key(cell[1], cell[2])] then order[#order + 1] = cell end
  end

  local big = hex.pack(TRIHEX, 8, { order = order })
  check(#big > #small, "the big pack has more placements (" .. #big .. ")")
  for i = 1, #small do
    eq(big[i][1], small[i][1], "placement " .. i .. " q")
    eq(big[i][2], small[i][2], "placement " .. i .. " r")
    eq(big[i][3], small[i][3], "placement " .. i .. " rot")
  end

  -- and it is still a legal packing: nothing overlaps
  local used = {}
  for _, p in ipairs(big) do
    for _, cell in ipairs(hex.footprint(TRIHEX, p[1], p[2], p[3])) do
      local k = hex.key(cell[1], cell[2])
      check(not used[k], "cell " .. k .. " covered once")
      used[k] = true
    end
  end
end)

case("pack handles a three-in-a-row shape", function()
  local row = { { 0, 0 }, { 1, 0 }, { 2, 0 } }
  local placements = hex.pack(row, 4)
  local used = {}
  for _, p in ipairs(placements) do
    for _, cell in ipairs(hex.footprint(row, p[1], p[2], p[3])) do
      local k = hex.key(cell[1], cell[2])
      check(not used[k], "row shape overlaps at " .. k)
      used[k] = true
    end
  end
  check(#placements > 0, "something was placed")
end)

-- --------------------------------------------------------------------- rng

case("rng is deterministic per seed and differs between seeds", function()
  local a, b, c = hex.rng(7), hex.rng(7), hex.rng(8)
  local first = {}
  for i = 1, 20 do
    first[i] = a.next()
    eq(b.next(), first[i], "same seed, same sequence")
  end
  local same = true
  for i = 1, 20 do
    if math.abs(c.next() - first[i]) > 1e-12 then same = false end
  end
  check(not same, "a different seed gives a different sequence")
end)

case("rng.next stays in (0, 1) and rng.int in [1, n]", function()
  local rng = hex.rng(12345)
  for _ = 1, 500 do
    local value = rng.next()
    check(value > 0 and value < 1, "next() in range, got " .. value)
  end
  for _ = 1, 500 do
    local n = rng.int(6)
    check(n >= 1 and n <= 6, "int(6) in range, got " .. n)
  end
end)

case("rng.pick honours weights and skips zero-weight entries", function()
  local rng = hex.rng(99)
  local counts = { a = 0, b = 0, z = 0 }
  for _ = 1, 3000 do
    local picked = rng.pick({ { 3, "a" }, { 1, "b" }, { 0, "z" } })
    if picked and counts[picked] then counts[picked] = counts[picked] + 1 end
  end
  eq(counts.z, 0, "a zero weight is never drawn")
  eq(counts.a + counts.b, 3000, "every draw returns something")
  check(counts.a > counts.b * 2, "weight 3 beats weight 1 (" ..
    counts.a .. " vs " .. counts.b .. ")")
  eq(rng.pick({}), nil, "an empty pool returns nil")
end)

-- ------------------------------------------------------------------- runner

out("hex_spec")
for _, entry in ipairs(cases) do
  currentCase = entry.name
  local ok, err = pcall(entry.fn)
  if not ok then
    failures = failures + 1
    out(string.format("  ERROR %s: %s", entry.name, tostring(err)))
  end
end
out(string.format("%d cases, %d checks, %d failures", #cases, checks, failures))
os.exit(failures == 0 and 0 or 1)
