# Amazonia — the tri-hex prototyping rig

`Saves/TS_Save_127.json`. A locked anchor plate and a hex map laid out at load
from generated tri-hex tiles, plus the two things that make iterating on it
cheap: a stdlib tile minter and a live channel to the running game.

Built to [docs/amazonia-build-plan.md](../../docs/amazonia-build-plan.md). It is
**not one save** — it is a rig, and the save is its output.

## The three loops

The whole design exists to keep changes in the top row.

| | Cost | What it changes | How |
| --- | --- | --- | --- |
| **L1** live tweak | one line, under a second, no reload | colour, hub label, map reroll, map size | `ttsd.py call …` |
| **L2** art change | one edit + two commands, no restart | silhouette, texture, per-cell colour | edit [`spec/tiles.json`](spec/tiles.json) → `tilegen.py` → `ttsd.py call reskin …` |
| **L3** structural | a rebuild and a TTS reload | new Lua, new components | edit [`src/`](src/) → `build.sh` → a new numbered save |

```bash
# L1 — the default
python3 scripts/ttsd.py call tint deep_jungle 14351F
python3 scripts/ttsd.py call reroll
python3 scripts/ttsd.py exec 'return AZ.state()'

# L2
$EDITOR proto/amazonia/spec/tiles.json
python3 scripts/tilegen.py
python3 scripts/ttsd.py call reskin jungle

# L3
$EDITOR proto/amazonia/src/30-map.lua
proto/amazonia/build.sh Saves/TS_Save_128.json
```

`ttsd.py push` sits between L2 and L3: it sends the whole `src/` tree to the
running game and reloads it, with no new save file. Good for trying a script
change; `build.sh` is what makes it permanent.

## The command surface

Every verb is in `AZ`, is short, takes strings, and returns something printable —
so one iteration is about a hundred tokens. `ttsd.py call <verb> a b` is sugar
for `return AZ.<verb>("a", "b")`.

| Verb | |
| --- | --- |
| `AZ.state()` | seed, rings, shape, counts, what is on and off — one round trip |
| `AZ.build(seed)` `AZ.reroll([seed])` `AZ.clear()` `AZ.n()` | the map |
| `AZ.rings(n)` `AZ.shape(name)` | resize it, or relay it in another tile shape |
| `AZ.tray()` | sync the palette to the spec — spawn what is missing, leave the rest put |
| `AZ.tray(false)` `AZ.tray("rebuild")` | clear it, or relay the whole catalogue on the grid (**destroys a hand arrangement**) |
| `AZ.divider(x)` `AZ.divider(false)` | the line between the map and the palette: move it, or hide it |
| `AZ.rubber(on)` | whether a spawning tile brings cubes. **Spawn only** — see below |
| `AZ.rubber("apply")` `AZ.rubber("clear")` | cover the map tiles already out, or take the cubes off |
| `AZ.plate(w, d)` | resize the one plate the map and the tray share, in world units |
| `AZ.snaprings(n)` | how far the snap field reaches; **0 = cover the plate**, the default |
| `AZ.put(kind, q, r[, rot])` | one named tile on one cell, replacing what covered it |
| `AZ.snap(on)` | the hex snap lattice, which interlocks tiles. **On** |
| `AZ.gridsnap(on)` | TTS's own grid snapping. **Off** — see below |
| `AZ.labels(on)` | the resource stripes. **Off** — the tiles read plain |
| `AZ.tint(kind, hex)` | **L1.** Instant, no respawn. Flat kinds only |
| `AZ.reskin(kind[, url])` `AZ.reskinall()` | **L2.** Respawn with new art |
| `AZ.hub(kind, cell, resource[, n])` | set or clear a resource hub on a cell |
| `AZ.hubstyle(w, h, font)` | the stripe's proportions, live; omit an argument to keep it |
| `AZ.hubface(deg)` | which way hub text reads. 180 is TTS's convention |
| `AZ.weight(kind, n)` | how often a kind is drawn; 0 retires it |
| `AZ.lock(bool)` `AZ.at(q,r)` `AZ.capture()` | rearrange by hand, query, snapshot |
| `AZ.note(text)` | the one thing the rig cannot observe: why |

The three `hub*` verbs still work and currently do nothing visible: labels are
off and no kind in the spec claims a hub. `AZ.labels(true)` plus
`AZ.hub("jungle", 1, "rubber")` brings the whole thing back in two calls.

The same verbs are on the screen panel ([`ui.xml`](ui.xml)), so the rig is
drivable by hand with no daemon running.

## Frontiers — terrain that changes inside a tile

Three terrains: `jungle` (F), `deep_jungle` (DF) and `river`. A tile used to be
one flat colour, so a river met a forest at a hex seam and there was no way to
draw a shoreline. A **frontier** is terrain reaching in from an edge, and it is
all spec — no new Lua per tile.

```json
"coast_f_n": {
  "shape": "trihex", "weight": 0, "tray": true,
  "paint": [
    { "terrain": "river" },
    { "terrain": "river", "edges": { "5": "jungle", "6": "jungle" } },
    { "terrain": "river", "edges": { "5": "jungle", "6": "jungle" } }
  ]
}
```

One entry per cell: a centre terrain, plus terrain on any of its **outer** edges.
Edges are numbered as `hex.DIRECTIONS` numbers them — 1=E 2=SE 3=SW 4=W 5=NW
6=NE — and an edge that faces another cell of the same tile blends to that
cell's own terrain, which `tilegen.py` refuses to let you override.

How two terrains meet is one entry in `frontiers`, and the **two numbers are not
the same question**:

| | |
| --- | --- |
| `reach` | how far the edge terrain pushes in, in hex radii. The apothem is 0.866, so 0.34 is about a third of the cell. 0 — always used for an interior seam — means they meet exactly on the edge |
| `band` | how wide the crossover is. 0.12 is an abrupt embankment, 0.5 a soft gradient |
| `shore` | a third colour where the mix crosses half and half: sand at the waterline |
| `warp` | wobbles the boundary, so a coast is not a straight chord |

Confuse `reach` with `band` and you get either a hairline of terrain stuck to
the rim or a long ramp with no terrain at either end of it.

**A painted kind bakes its colour** — one `ColorDiffuse` cannot hold two
terrains — so it is an L2 change, not an L1 tint: edit `terrains`, run
`tilegen.py`, then `ttsd.py call reskinall`. The four flat kinds still take the
L1 route and inherit their tint from the same `terrains` block, so there is one
answer to "what colour is jungle" either way.

Twenty-one of them are in the tray: eight coasts, six landfalls and river runs,
seven glades (an F clearing walled by DF on two to four of a cell's four outer
edges). All at weight 0 — the random map is untouched, and they are placed by
hand or with `AZ.put`.

## Rubber — a cube on every deep forest hexside

A white cube called **Rubber** sits on each deep forest hexside of a tile, put
there as the tile spawns. The Glades 2/3/4 triplet carries nine: two on the
pivot, three on the top-left cell, four on the top-right.

**A "deep forest hexside" is an outer edge a kind's `paint` block names
`deep_jungle`** — the walls of a glade, the far bank of a DF coast. It is not
every hexside whose terrain happens to be deep forest, and the difference is not
pedantry: a plain `deep_jungle` triplet is deep forest all over, so the wider
rule would ring each of the five on a rings-3 map with twelve cubes and stack
two rows along every seam where two of them meet. The narrow rule is the owner's
(2026-09-22) and `RUBBER.terrain` is the only thing that decides it.

Which hexsides those are is **data, not inference**: `scripts/tilegen.py` writes
an `edges` table into `art/index.lua` from the same `paint` block it draws the
diffuse from, so a spec edit moves the pixels and the cubes together.

**The divider is the rule, not decoration.** A tile is on the map when it is
west of `TRAY.divider.x`, and that is decided by **position, not by the `tray`
tag** — the owner builds by copying a palette tile with ctrl+c/ctrl+v and
dragging the copy across, and a copy carries its original's tags for ever. So
the line you can see on the table and the line the script tests are the same
number.

**Rubber follows the tile across it.** Two taps on a tile's own drag: the cubes
come off as it is lifted, and go back on if it lands west of the line. Drag a
glade out of the palette and its nine cubes appear; drag it back and they come
off with it.

That is the only thing that is not spawn-time, and it is still not a watcher —
**a cube is never touched by any of it**. Pick a cube up, move it, delete it:
nothing grows back. Only moving the *tile* re-derives that tile's set.

| | |
| --- | --- |
| **places** | a drop west of the line (dragged, or pasted with ctrl+v); `Map.build`, `Map.reroll`, `AZ.put`; a tray sync, for anything already west of it |
| **does not** | a reload, a reskin (the tile is respawned in place; its cubes never moved), a rotate, anything done to a cube |
| **removes** | lifting the tile; a drop east of the line; `Map.clear` and a reroll take `rubber.map`; `AZ.put` takes the replaced tile's |

Moving a tile around inside the map takes its cubes with it and does not double
them: the drop clears the tile's footprint before it spawns, so a paste and a
drag come out the same.

Two tags, and the split decides whose cubes survive a reroll: `rubber` is every
cube including the ones dragged out of the bag by hand, `rubber.map` only the
ones a tile spawned. Clearing takes `rubber.map` alone, so **rubber you placed
yourself is not swept away by a rebuild**.

The toggle is on the screen panel and at `AZ.rubber(on)`. It governs the *next*
tile, so switching it on does nothing to what is already on the table — which is
what **Apply** is for. It clears first, so running it twice does not stack.

```bash
python3 scripts/ttsd.py call rubber false     # the next tile brings none
python3 scripts/ttsd.py call rubber apply     # cover the map tiles already out
python3 scripts/ttsd.py exec 'return AZ.put("glade_mix_a", 0, 0)'   # nine cubes
```

The cube's geometry is measured, not chosen. `RUBBER.inset` is 0.66 from the
cell's centre along the hexside's normal — **not** the apothem 0.866, which is
the edge itself. The jungle|deep_jungle frontier reaches 0.44 in from the rim,
so the DF band runs 0.43 to 0.87 and 0.66 is the middle of it: the cube sits on
the deep forest it marks rather than on the line, and two cubes facing each
other across a seam land 0.4 apart instead of in the same place.

**A tile dragged off the tray keeps its `tray` tag** wherever it ends up — that
tag means "came from the palette", not "is in the palette". Rubber ignores it
and goes by the line instead, and so does `apply`. It still matters elsewhere:
`Map.count()` does not count such a tile and **a reroll will not destroy it**,
which is usually what you want when you have hand-built a map out of copies.

The supply is an `Infinite_Bag` called **Rubber**, beside the creek and road
bags. It is spawned once and found by its tag on every later boot, so a reload
neither replaces it nor leaves a second one.

## The divider

One plate carries the map and the palette, which removed the seam that used to
show where one ended and the other began. `TRAY.divider` puts that boundary back
as a locked ochre bar in the gap at x = 9.9 — east of anything the map can reach
(a rings-3 disc ends around 6.1, an overflow tile at 7.8), west of the palette's
first column (centred at 12.5, so its tiles start at 10.77).

It sits 0.10 to 0.16 above the anchor's centre, under the top face of a tile at
0.20, so a tile laid across it hides it rather than being pierced by it.
`AZ.divider(8.0)` moves it live; `AZ.divider(false)` hides it.

## Only tiles snap

Two independent systems, set opposite ways round:

| | | |
| --- | --- | --- |
| **the lattice** | `MAP.snap`, `AZ.snap(on)` | **on** — a tagged snap point at every tri-hex position on the plate, with a rotation, so a tile dropped by hand lands interlocked |
| **TTS's grid** | `MAP.gridSnap`, `AZ.gridsnap(on)` | **off** — Options > Grid, global, no tags: this is what was pulling cubes to hex centres |

**The snap field is not the map.** `MAP.rings` is the disc the random map is
drawn over — 14 slots at rings 3. The snap field is a separate, much larger
packing (242 positions on the 60 x 40.8 plate) derived from the plate's measured
size, and `Map.slots()` is an exact prefix of it. They were the same set until
2026-09-21, which meant the only snappable positions on the table were the ones
the map already filled: every tile dragged off the tray landed on top of another
tile and looked like it was ignoring the lattice. A drop probe settled it — a
tile let go 0.00 from a point snapped, one let go 4.77 away did not.

The prefix matters. `hex.pack` is greedy, so the walk order *is* the tiling, and
`hex.disc` sorts by r then q — `disc(18)` starts in a different corner from
`disc(3)` and packs a tiling offset from it. `Map.lattice()` walks the map's own
disc first, in its own order, then the rest; `hex_spec.lua` asserts both halves.

The grid is forced off at boot rather than trusted from the save file, because
the two disagreed: `TS_Save_127.json` says `"Snapping": false` and the running
game reported `Grid.snapping = 3`. Read the live value, not the file.

Belt and braces, because whether a tagged snap point spares an *untagged* object
is not established: every object that is not a tile has `use_grid` and
`use_snap_points` cleared as it spawns (`Map.unsnap`), and `Map.unsnapAll()`
does the same at boot for what is already there.

Note that `Map.snaps()` with the lattice off *clears* the plate rather than
skipping, which is what removes the points from a save built while it was on.

## The changelog

Two layers, because neither is enough alone:

- **Ground truth** — `ttsd.py serve` runs `tts.py diff` on every Game Saved, so
  every hand-moved cube is caught whether the script knew about it or not.
- **Narrative** — [`src/40-journal.lua`](src/40-journal.lua) taps drop, pickUp,
  spawn and destroy and sends a record out through `sendExternalMessage`. That
  gives ordering and intent a diff cannot recover.

Both render hex-aware: a float triple goes back through `hex.fromWorld`, so an
entry reads `hex(1,-1) -> hex(0,2)`.

```bash
python3 scripts/ttsd.py serve         # leave it running while you play
python3 scripts/ttsd.py log --since last
```

`JOURNAL.md` gets a section per save, appended and never rewritten.
`log --since last` is the one an agent should use — the event file grows
forever and nothing should read all of it.

## Layout

```
spec/tiles.json     the tile catalogue — terrains, frontiers, kinds. The file
                    to edit for an L2 change
art/                generated: .obj, collider, .png, index.json, index.lua
                    content-hashed, so a new texture is always a new URL
src/00-config.lua   ROLES, MAP, TILES, TRAY, HUB — data only
src/10-hex.lua      axial math. Pure: no TTS global, luajit-testable
src/20-tiles.lua    spawn / tint / reskin / hub buttons
src/25-rubber.lua   a cube on every deep forest hexside, and the supply bag
src/30-map.lua      build / clear / reroll / put / capture, seeded
src/35-tray.lua     the palette: one of every frontier tile, beside the plate,
                    and the divider that marks where the map stops
src/40-journal.lua  event taps -> sendExternalMessage
src/50-api.lua      the A.* command surface
src/99-Global.lua   onLoad, onSave, boot
objects/anchor.json the locked plate every position is measured against
ui.xml              the screen panel
build.sh            -> Saves/TS_Save_127.json
test/               hex_spec.lua, boot_spec.lua, bridge_spec.py
.journal/           events.jsonl + snapshots (daemon-owned, never under Saves/)
```

`scripts/tilegen.py` and `scripts/ttsd.py` are the two new tools; both are
stdlib-only and neither writes under `Mods/` or `Saves/`.

## What it is built on

- **The mesh is RotLA's, re-derived.** `tilegen.py` generates a tri-hex whose
  vertex set is identical to Railways of the Lost Atlas's cached `.obj` — same
  24 unique vertices, same 44 faces, same UV rule, same winding — from
  arithmetic rather than from a copy. Check it with `--check`.
- **No GUID appears in `src/`.** Every object is found by component tag, and a
  missing one is one loud line at boot (`registry.check`).
- **No world-space coordinate appears in `src/`.** Every position is the
  anchor's local space through `positionToWorld`. Drag the plate, rebuild, and
  the whole map is where the plate now is.
- **Tiles are spawned, not saved into the file.** `tts.py object add` offsets
  copies linearly, which a hex field is not, so `TS_Save_127` holds one object
  and `onLoad` lays out the rest.

## Verify

```bash
python3 scripts/luacat.py --lint                # shadowed globals in the build
python3 scripts/tilegen.py --check              # 13 files, byte-identical
luajit proto/amazonia/test/hex_spec.lua         # the axial math, no TTS
luajit proto/amazonia/test/boot_spec.lua        # the rig, as one concatenated chunk
python3 proto/amazonia/test/bridge_spec.py      # ttsd against a fake TTS
proto/amazonia/build.sh Saves/TS_Save_128.json  # a fresh save
python3 scripts/tts.py validate Saves/TS_Save_128.json
```

All of it runs with the game open: `bridge_spec.py` puts its fake TTS on a
private port pair (39899/39898) so it does not fight the real one.

## Checked against the running game, 2026-09-21

Both gates in the build plan passed. What the live run established:

- **The assets load.** TTS decoded the generated mesh, collider and the three
  drawn diffuses into `Mods/Models Raw/` and `Mods/Images Raw/`, and it only
  writes a decoded file when the source parsed. The `%20` URL form is right;
  `--url-style raw` is not needed. Note `tts.py find-asset` will not locate
  these — TTS keeps no copy of a local file under `Mods/Models` or
  `Mods/Images`, only the decoded form in the `… Raw` directories.
- **The bridge works.** `ttsd.py` drives the live game: reroll, tint, rings, at,
  hub, lock all answer. One correction to the documented protocol —
  **TTS v14.2.2 never sends message ID 5**, so `exec` gets its answer back as a
  marked `print` instead. `ttsd.wrap_script` has the evidence.
- **The load error is fixed.** The command surface is `AZ`, not `A`, because
  `ttslib/01-async.lua` holds its module table in a top-level `local A` and a
  build is one concatenated chunk. `scripts/luacat.py --lint` now refuses to
  build a shadowed global, and `boot_spec.lua` loads one chunk rather than
  fifteen files so the whole bug class is reachable from the tests.

- **The magnet was TTS's grid, not the snap points**, and the save file said
  otherwise — `"Snapping": false` in `TS_Save_127.json`, `Grid.snapping = 3` in
  the game loaded from it. Read state that the Options menus can change through
  the API, not off disk. Written up in
  [cookbook/10-antipatterns.md](../../docs/cookbook/10-antipatterns.md#settled-on-the-table).

- **`positionToWorld` scales by the mesh, not by `getScale()`.** A
  `BlockRectangle`'s mesh is 1 x 1 x 2, so the anchor plate at scaleZ 17 is 34
  deep and one local Z unit is 34 world units. Every world offset here was
  divided by the scale, so the hex map shipped stretched by exactly two along Z
  and no two tri-hexes ever met along an edge. `ttslib.layout.basis` measures it
  now, `layout.localOffset` is what the lattice goes through, and the stub
  models the 1 x 1 x 2 mesh so the case cannot pass again.

Two things still want eyes on them, because nothing outside TTS can settle them:

- **The textures land square on the face**, confirmed on the table. The UV rule
  in `tilegen.py` — planar from above, v flipped — is right.
- **Hub stripes read one way across the whole map.** A button's `position` and
  `rotation` are both relative to the object, so the first build rendered its
  labels turned with the tile: upside down at 180 degrees, diagonal at 120.
  `Tiles.hubs` cancels the tile's own Y rotation, and `Tiles.repin` redraws on
  the rotate event so turning a tile by hand does not undo it. `position` still
  turns with the tile, because the cell it points at moves.
- **`HUB.facing` is 180 because TTS says so.** Cancelling the spin alone left
  every label uniformly upside down. The tiles are level (`getTransformUp().y`
  is 1), so it is not a flipped tile: **TTS lays button text out along the
  object's local -Z**, away from the default camera. Any label on a flat object
  in this folder needs the same 180.

The stripe's proportions are the one thing left to taste. They are live:

```bash
python3 scripts/ttsd.py call hubstyle 1200 140 120   # width, height, font
python3 scripts/ttsd.py call hubface 0               # 0 / 90 / 180 / 270
```

Copy whatever you settle on into `HUB` in [src/00-config.lua](src/00-config.lua),
which is the source of truth — a live change is lost on the next reload.
