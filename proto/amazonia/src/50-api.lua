-- src/50-api.lua — the command surface an agent drives the rig through.
--
-- This is the contract `ttsd.py` talks to, and the reason it exists is the
-- owner's first requirement: fewest possible tokens per iteration.  One
-- iteration should be one short line:
--
--   python3 scripts/ttsd.py call tint deep_jungle 14351F
--   python3 scripts/ttsd.py exec 'return AZ.n()'
--
-- so every verb is short, takes strings and numbers only, returns something
-- printable, and never needs a second call to find out whether it worked.
-- `ttsd.py call <verb> <args...>` is sugar for `return AZ.<verb>(...)`, which is
-- why the arguments are all strings: they arrive off a command line.
--
-- Everything here is a thin wrapper.  The behaviour lives in 20-tiles.lua and
-- 30-map.lua; this file is the vocabulary.
--
-- **It is `AZ` and not `A` for a reason.**  A build is a concatenation, so a
-- top-level `local` in an earlier file is still in scope here — and
-- ttslib/01-async.lua holds its module table in `local A`.  Writing `A = {}`
-- below does not make a global: it overwrites that local, and the library's own
-- `A.cancel(key)` on the first line of `A.keyed` then calls nil.  `ttslib.async`
-- still points at the real table, so nothing looks wrong until TTS says
-- "attempt to call a nil value at A.keyed" and names neither file.  That cost a
-- load failure on 2026-09-21; `scripts/luacat.py --lint` now refuses to build
-- it, and every name declared here must stay clear of ttslib's locals:
-- A, S, U, E, R, L, LOG, ASYNC, EVENTS, REGISTRY, Store.

local LOG = ttslib.log

AZ = {}

-- ------------------------------------------------------------------- the map

function AZ.build(seed) return Map.build(tonumber(seed)) end

function AZ.reroll(seed) return Map.reroll(seed and tonumber(seed) or nil) end

function AZ.clear() return Map.clear() end

function AZ.n() return Map.count() end

-- rings(n) — resize the map. The lattice is recomputed, so this is a rebuild.
function AZ.rings(n)
  n = tonumber(n)
  if not n or n < 0 or n > 8 then
    LOG.error("AZ.rings wants 0..8, got " .. tostring(n))
    return false
  end
  MAP.rings = math.floor(n)
  Map.invalidate()
  Map.snaps()
  return Map.build()
end

-- shape(name) — relay the whole map out of a different tile shape.  The
-- lattice is packed per shape and the draw is filtered to it, so this is the
-- one call that turns the rig from a tri-hex map into a single-hex one.
function AZ.shape(name)
  if not ART.shapes[name] then
    LOG.error("no shape '" .. tostring(name) .. "' in art/index.lua",
      "known: " .. table.concat((function()
        local names = {}
        for shape in pairs(ART.shapes) do names[#names + 1] = shape end
        table.sort(names)
        return names
      end)(), ", "))
    return false
  end
  if #Tiles.pool(name) == 0 then
    LOG.error("no '" .. name .. "' kind has a weight above zero",
      "give one a weight in spec/tiles.json, or use AZ.weight()")
    return false
  end
  MAP.shape = name
  Map.invalidate()
  Map.snaps()
  return Map.build()
end

function AZ.at(q, r)
  local hit = Map.at(tonumber(q) or 0, tonumber(r) or 0)
  return hit and hit.kind or "empty"
end

-- put(kind, q, r[, rot]) — one named tile on one cell, replacing what is there.
-- The cheap way to model a transition: lay a coast where you want the water to
-- stop and see what it wants next to it.
function AZ.put(kind, q, r, rot)
  return Map.put(kind, q, r, rot) or false
end

-- snap(on) — the hex snap lattice: what makes a tri-hex dropped by hand land
-- interlocked with its neighbours. **On.**
function AZ.snap(on)
  local want = not (on == false or on == "false" or on == "0" or on == 0)
  return Map.snap(want)
end

-- gridsnap(on) — TTS's own grid snapping, the other system. **Off**, and it is
-- the one that was pulling cubes to hex centres: it is global, so there is no
-- setting of it that catches tiles and spares everything else.
function AZ.gridsnap(on)
  local want = not (on == false or on == "false" or on == "0" or on == 0)
  return Map.grid(want)
end

function AZ.capture() return Map.capture() end

-- plate(w, d) — resize the one plate the map and the tray share, in world
-- units. The snap field is derived from it, so this widens where tiles can be
-- dropped as well as where they can rest. Either argument may be omitted.
function AZ.plate(w, d)
  return Map.plate(w and tonumber(w) or nil, d and tonumber(d) or nil)
end

-- snaprings(n) — how far the snap field reaches, in rings. **0 means cover the
-- plate**, which is the default and almost always what you want; a positive
-- number pins a smaller field. This does not touch MAP.rings, which is the disc
-- the random map is drawn over.
function AZ.snaprings(n)
  n = tonumber(n)
  if not n or n < 0 or n > MAP.snapMaxRings then
    LOG.error("AZ.snaprings wants 0.." .. MAP.snapMaxRings .. ", got " .. tostring(n))
    return false
  end
  MAP.snapRings = math.floor(n)
  Map.invalidate()
  return Map.snaps()
end

-- --------------------------------------------------------------------- tray

-- tray([on]) — the palette of frontier tiles beside the map. No argument
-- **syncs**: spawns whatever the spec says is missing, destroys tiles whose
-- kind is gone, and leaves everything else exactly where it is. "false" clears
-- it, "rebuild" relays the whole catalogue on the generated grid — which throws
-- away a hand arrangement, so it has to be asked for by name.
function AZ.tray(on)
  if on == false or on == "false" or on == "0" or on == 0 then
    return Tray.clear()
  end
  if on == "rebuild" then return Tray.build() end
  local added, orphans = Tray.sync()
  return "tray " .. Tray.count() .. " tiles (+" .. added .. " -" .. orphans .. ")"
end

-- divider([x|off|on]) — the line on the floor between the map and the palette.
--
-- L1: a number moves it and respawns the bar in one call, so "is it in the
-- right place" is answered by looking rather than by rebuilding. Copy what you
-- settle on into TRAY.divider in 00-config.lua, which is the source of truth —
-- a live change is lost on the next reload, like every other L1 tweak here.
function AZ.divider(x)
  local spec = TRAY.divider
  if x == false or x == "false" or x == "0" or x == 0 or x == "off" then
    spec.enabled = false
  elseif x == true or x == "true" or x == "on" then
    spec.enabled = true
  elseif tonumber(x) then
    spec.x = tonumber(x)
    spec.enabled = true
  end
  Tray.divider()
  return "divider " .. (spec.enabled and ("at x=" .. spec.x) or "off")
end

-- ------------------------------------------------------------------ rubber

-- rubber([on|"apply"|"clear"]) — the white cubes on deep forest hexsides.
--
-- No argument reports. A boolean sets the flag, and the flag governs **future
-- spawns only** — which is the whole design (00-config.lua, RUBBER), so
-- switching it on does nothing to the tiles already out and switching it off
-- leaves the cubes where they are. The two verbs that touch what is on the
-- table have to be asked for by name:
--
--   "apply"  rubber on every map tile now, clearing first so it does not stack
--   "clear"  take the map's cubes off and leave the tiles
function AZ.rubber(on)
  if on == "apply" then return Rubber.apply() end
  if on == "clear" then return Rubber.clear() end
  if on == nil or on == "" then return Rubber.status() end
  RUBBER.enabled = not (on == false or on == "false" or on == "0" or on == 0)
  LOG.info("rubber " .. (RUBBER.enabled and "on" or "off") ..
    " — spawn only, so this takes effect on the next tile" ..
    " (AZ.rubber('apply') for the ones already out)")
  Journal.emit("rubber", { enabled = RUBBER.enabled })
  uiRefresh()
  return Rubber.status()
end

-- ------------------------------------------------------------------- tiles

function AZ.tint(kind, colour) return Tiles.tint(kind, colour) end

function AZ.reskin(kind, url) return Tiles.reskin(kind, url) end

-- reskinall() — every kind at once. A frontier tile bakes its terrain colours
-- into the diffuse (one ColorDiffuse cannot hold two terrains), so editing
-- `terrains` or `frontiers` in spec/tiles.json is a regenerate and a respawn,
-- not a tint: tilegen.py, then this.
function AZ.reskinall() return Tiles.reskinAll() end

-- labels(on) — the resource stripes over each cell. Off: the tiles read as
-- plain terrain. Nothing in the spec claims a hub at the moment, so turning
-- them on shows nothing until a kind is given `hubs` again.
function AZ.labels(on)
  local want = not (on == false or on == "false" or on == "0" or on == 0)
  return Tiles.labels(want)
end

function AZ.hub(kind, cell, resource, n)
  return Tiles.hub(kind, tonumber(cell) or 1, resource, n)
end

-- hubstyle(w, h, font) — the stripe's proportions, live. Any argument omitted
-- keeps its current value, so `AZ.hubstyle(nil, 200)` only changes the height.
function AZ.hubstyle(w, h, font)
  return Tiles.restyle(w, h, font)
end

-- hubface(deg) — which way hub text reads. 180 is TTS's convention and the
-- default; try 0, 90 or 270 if your camera disagrees.
function AZ.hubface(deg)
  return Tiles.face(deg)
end

function AZ.lock(on)
  -- Off the command line "false" arrives as a string, and a string is truthy.
  local want = not (on == false or on == "false" or on == "0" or on == 0)
  return Tiles.lock(want)
end

-- weight(kind, n) — change how often a kind is drawn. Takes effect on the next
-- build or reroll; set 0 to retire a kind without deleting its art.
function AZ.weight(kind, n)
  local entry = Tiles.kind(kind)
  if not entry then return false end
  entry.weight = tonumber(n) or 0
  LOG.info("weight " .. kind .. " = " .. entry.weight)
  return entry.weight
end

-- ------------------------------------------------------------------- reading

-- kinds() — the catalogue as one printable line, which is what an agent wants
-- back from a single exec rather than a table it has to walk.
function AZ.kinds()
  local rows = {}
  for _, name in ipairs(Tiles.kinds()) do
    local kind = ART.kinds[name]
    rows[#rows + 1] = string.format("%s(%s w%s n%d)", name, kind.shape,
      tostring(kind.weight), #Tiles.ofKind(name))
  end
  return table.concat(rows, " ")
end

-- state() — everything an agent usually asks for, in one round trip.
--
-- The catalogue is no longer one line's worth — there are two dozen frontier
-- kinds — so state() counts them and AZ.kinds() is the call that lists them.
function AZ.state()
  return string.format(
    "seed=%d rings=%d shape=%s tiles=%d slots=%d snapfield=%d plate=%gx%g " ..
    "tray=%d snap=%s grid=%s labels=%s rubber=%s/%d kinds=%d",
    MAP.seed, MAP.rings, MAP.shape, Map.count(), #Map.slots(),
    #Map.lattice(), MAP.plate.x, MAP.plate.z, Tray.count(),
    tostring(MAP.snap), tostring(MAP.gridSnap), tostring(HUB.enabled),
    tostring(RUBBER.enabled), Rubber.count(),
    #Tiles.kinds())
end

function AZ.say(text)
  broadcastToAll(tostring(text), { 0.85, 0.82, 0.76 })
  return true
end

-- note(text) — put a line in the changelog by hand, for the one thing the rig
-- cannot observe: why.
function AZ.note(text)
  Journal.emit("note", { text = tostring(text) })
  return true
end

function AZ.help()
  return "AZ.build(seed) AZ.reroll([seed]) AZ.clear() AZ.n() AZ.rings(n) " ..
      "AZ.shape(name) AZ.at(q,r) AZ.put(kind,q,r[,rot]) AZ.capture() " ..
      "AZ.plate(w,d) AZ.snaprings(n) " ..
      "AZ.tray([on|false|rebuild]) AZ.divider([x|off]) " ..
      "AZ.rubber([on|apply|clear]) " ..
      "AZ.snap(on) AZ.gridsnap(on) AZ.labels(on) " ..
      "AZ.tint(kind,hex) " ..
      "AZ.reskin(kind[,url]) AZ.reskinall() AZ.hub(kind,cell,resource[,n]) " ..
      "AZ.lock(bool) AZ.weight(kind,n) AZ.kinds() AZ.state() AZ.say(text) " ..
      "AZ.note(text)"
end

-- ------------------------------------------------------------------ XML panel
--
-- Screen-space handlers take (player, value, id), not the button signature.
-- Global on purpose: ui.xml names them.

function uiReroll()
  Map.reroll()
end

function uiClear()
  Map.clear()
  uiRefresh()
end

-- The tray button is a toggle: it clears the palette if it is out, lays it out
-- if it is not, so one button covers both and the panel stays small.  It needs
-- no refresh — the panel counts map tiles, which a tray does not change, and
-- twenty-two tiles appearing beside the plate is its own feedback.
function uiTray()
  if Tray.count() > 0 then Tray.clear() else Tray.build() end
end

-- The rubber toggle carries its own state as its label, because a button that
-- reads "Rubber" cannot say whether the next tile will bring cubes. Shift- or
-- right-click applies it to the tiles already out, which is the other half of
-- a spawn-only feature: the flag alone changes nothing you can see.
function uiRubber()
  AZ.rubber(not RUBBER.enabled)
end

function uiRubberApply()
  Rubber.apply()
  -- Spawning is asynchronous and Rubber.apply's own flush is keyed at 0.5, so
  -- the count on the panel is read after that has landed rather than before.
  ttslib.async.keyed("rubber.hud", 0.75, uiRefresh)
end

function uiLock()
  local tiles = Tiles.all()
  local locked = tiles[1] and tiles[1].getLock()
  Tiles.lock(not locked)
  uiRefresh()
end

function uiGrow()
  AZ.rings(MAP.rings + 1)
end

function uiShrink()
  AZ.rings(MAP.rings - 1)
end

function uiRefresh()
  local UI_ = ttslib.ui
  UI_.value(nil, "hudSeed", "Seed " .. MAP.seed)
  UI_.value(nil, "hudTiles", "Tiles: " .. Map.count() .. " / " .. #Map.slots())
  UI_.value(nil, "hudRings", "Rings: " .. MAP.rings)
  -- A button's value is its label, so the toggle says which way it is set
  -- rather than what it is called.
  UI_.value(nil, "uiRubber",
    RUBBER.enabled and "Rubber on" or "Rubber off")
  UI_.attr(nil, "uiRubber", "color", RUBBER.enabled and "#2f3b27" or "#3c3524")
end
