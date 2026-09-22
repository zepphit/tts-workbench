#!/usr/bin/env python3
"""Mint hex-tile art for a prototype: mesh, collider and diffuse, stdlib only.

There is no PIL, no ImageMagick and no cairosvg on this machine, and there is no
package manager step in this folder either — so a PNG here is `zlib` plus
`struct`, and an `.obj` is plain text.  That is a constraint, not a hardship:
both formats are simple, and being able to regenerate every asset from a 60-line
spec is what makes a tile change cost one edit instead of a round trip through
an image editor.

    python3 scripts/tilegen.py                     # -> proto/amazonia/art/
    python3 scripts/tilegen.py --check             # regenerate, assert unchanged
    python3 scripts/tilegen.py --prune             # delete unreferenced art
    python3 scripts/tilegen.py --jobs 1            # one core, same bytes
    python3 scripts/tilegen.py --spec S --out DIR

Everything it emits is derived from `spec/tiles.json` and nothing else, so the
same spec gives the same bytes and the same filenames on every run.  Filenames
are content hashes (`trihex-a1b2c3d4.obj`) because TTS caches by mangled URL
(docs/asset-cache.md): reuse a filename and TTS may keep serving you the file
you just replaced.  A new hash is a new URL and always reloads.

The geometry is not invented.  Every constant below was measured from Railways
of the Lost Atlas's own tri-hex, cached in Mods/Models/ — see
docs/amazonia-build-plan.md#21-the-tri-hex-mesh.  Three of those measurements
are easy to get backwards and are therefore restated where they are used:

  * pointy-top hexes, circumradius R = 1, so a cell's corners sit at
    (0, +-R) and (+-R*sqrt(3)/2, +-R/2) and the lattice step is sqrt(3)R across
    and 1.5R up;
  * UVs are a planar projection from above, normalised to the mesh bounding box,
    with **v flipped**: u = (x-xmin)/width, v = 1 - (z-zmin)/depth.  Read off
    RotLA's own mesh, where the vertex at z = zmin carries v = 1.0;
  * a face whose normal is +y winds **clockwise** in the (x, z) plane.  Also
    read off RotLA's mesh: its top triangles all have negative 2-D signed area.

The collider is three separate convex hex prisms rather than one inset
silhouette, again copying RotLA: a tri-hex is not convex, and `Convex: true` on
a single non-convex mesh gives you its hull, which would be a solid triangle.
"""

import argparse
import hashlib
import json
import math
import multiprocessing
import os
import shutil
import struct
import sys
import tempfile
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEFAULT_SPEC = os.path.join(ROOT, "proto", "amazonia", "spec", "tiles.json")
DEFAULT_OUT = os.path.join(ROOT, "proto", "amazonia", "art")

SQRT3 = math.sqrt(3.0)
EPS = 1e-6
QUANT = 6  # decimal places a vertex is snapped to before edges are matched

# The six neighbours of a pointy-top hex, in the same order and the same
# 1-based numbering src/10-hex.lua's DIRECTIONS uses, so a `paint` block in the
# spec and the Lua that reads the lattice name an edge identically:
#
#     1 = E   2 = SE   3 = SW   4 = W   5 = NW   6 = NE
#
# Edge d of a cell is the edge it shares with neighbour d.
DIRECTIONS = [(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)]
EDGE_NAMES = ["E", "SE", "SW", "W", "NW", "NE"]


def die(msg):
    sys.stderr.write("tilegen: %s\n" % msg)
    raise SystemExit(2)


def refuse_managed(path):
    """Never write into TTS's own territory.  Mirrors tts.py's corpus guard."""
    full = os.path.abspath(path)
    for managed in ("Mods", "Saves"):
        root = os.path.join(ROOT, managed) + os.sep
        if full == os.path.join(ROOT, managed) or full.startswith(root):
            die("refusing to write under %s/ — that is TTS's, not ours (%s)"
                % (managed, path))


# --------------------------------------------------------------- hex geometry
#
# Axial coordinates (q, r) on a pointy-top lattice, the same convention
# src/10-hex.lua uses, so a spec and the Lua that loads it talk about cells the
# same way.  q runs east, r runs south-east-ish; see 10-hex.lua for the inverse.


def axial_to_world(q, r, radius):
    return (radius * SQRT3 * (q + r / 2.0), radius * 1.5 * r)


def hex_corners(cx, cz, radius):
    """The six corners of a pointy-top hex, counter-clockwise in the (x, z) plot.

    Corner 0 is the +z point.  Counter-clockwise here is the plain 2-D reading
    of the plot; which winding TTS wants for a given face normal is a separate
    question, handled once in `emit_prism`.
    """
    out = []
    for i in range(6):
        angle = math.radians(90.0 + 60.0 * i)
        out.append((cx + radius * math.cos(angle), cz + radius * math.sin(angle)))
    return out


def key(point):
    return (round(point[0], QUANT), round(point[1], QUANT))


def outline(cells, radius):
    """The boundary of a union of hexes, plus the interior edges it dropped.

    An edge shared by two neighbouring cells appears twice and is interior; what
    survives is the silhouette.  Because every cell contributes its edges in the
    same rotational order, the survivors already agree on direction, so chaining
    them is a matter of following end -> start.

    Returns (loop, seams).  `seams` — the dropped edges — are exactly the lines
    that make the three hexes read as three in the texture, so they are worth
    handing back rather than discarding.
    """
    edges = {}
    seams = []
    for q, r in cells:
        cx, cz = axial_to_world(q, r, radius)
        corners = hex_corners(cx, cz, radius)
        for i in range(6):
            a, b = corners[i], corners[(i + 1) % 6]
            pair = tuple(sorted((key(a), key(b))))
            if pair in edges:
                del edges[pair]
                seams.append((a, b))
            else:
                edges[pair] = (a, b)

    if not edges:
        die("a shape with no boundary edges — are two cells identical?")

    following = {}
    for a, b in edges.values():
        following.setdefault(key(a), []).append((a, b))

    start = min(edges.values(), key=lambda e: (key(e[0])[1], key(e[0])[0]))
    loop = [start[0]]
    cursor = start
    for _ in range(len(edges)):
        loop.append(cursor[1])
        options = following.get(key(cursor[1]), [])
        nxt = None
        for candidate in options:
            if key(candidate[1]) != key(cursor[0]):
                nxt = candidate
                break
        if nxt is None:
            break
        cursor = nxt
        if key(cursor[0]) == key(start[0]):
            break
    if key(loop[-1]) == key(loop[0]):
        loop.pop()
    if len(loop) != len(edges):
        die("the cells of this shape are not edge-connected: traced %d of %d "
            "boundary edges. Every cell must touch another." % (len(loop), len(edges)))
    return loop, seams


def signed_area(poly):
    total = 0.0
    for i in range(len(poly)):
        a, b = poly[i], poly[(i + 1) % len(poly)]
        total += a[0] * b[1] - b[0] * a[1]
    return total / 2.0


def ear_clip(poly):
    """Triangulate a simple polygon, counter-clockwise in, counter-clockwise out.

    A tri-hex silhouette is a 12-gon with three reflex notches, so a fan will not
    do.  Ear clipping is O(n^2) and n is 12.
    """
    pts = list(poly)
    if signed_area(pts) < 0:
        pts.reverse()
    index = list(range(len(pts)))
    triangles = []

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    def inside(p, a, b, c):
        d1, d2, d3 = cross(a, b, p), cross(b, c, p), cross(c, a, p)
        return not ((d1 < -EPS or d2 < -EPS or d3 < -EPS)
                    and (d1 > EPS or d2 > EPS or d3 > EPS))

    guard = 0
    while len(index) > 3 and guard < 1000:
        guard += 1
        for i in range(len(index)):
            prev, cur, nxt = index[i - 1], index[i], index[(i + 1) % len(index)]
            a, b, c = pts[prev], pts[cur], pts[nxt]
            if cross(a, b, c) <= EPS:
                continue  # reflex, or collinear
            if any(inside(pts[j], a, b, c)
                   for j in index if j not in (prev, cur, nxt)):
                continue
            triangles.append((a, b, c))
            index.pop(i)
            break
        else:
            break
    if len(index) == 3:
        triangles.append(tuple(pts[j] for j in index))
    return triangles


# ------------------------------------------------------------------ .obj mesh


def normalise(vector):
    length = math.sqrt(sum(c * c for c in vector))
    if length < EPS:
        return (0.0, 0.0, 0.0)
    return tuple(c / length for c in vector)


class ObjWriter:
    """Accumulates (position, normal) vertices and faces, then formats an .obj.

    Vertices are split per normal, exactly as Blender did for RotLA's mesh: a
    corner of the silhouette belongs to one top face and two walls, so it is
    written three times with three different normals.  UVs come from position
    alone, so the copies share a UV — which is what gives the top face a clean
    planar projection and leaves the walls showing the texture's edge band.
    """

    def __init__(self, bbox):
        self.minx, self.maxx, self.minz, self.maxz = bbox
        self.vertices = []
        self.normals = []
        self.uvs = []
        self.faces = []
        self.groups = []
        self._vcache = {}
        self._ncache = {}

    def uv(self, x, z):
        width = self.maxx - self.minx
        depth = self.maxz - self.minz
        u = (x - self.minx) / width if width > EPS else 0.0
        # v is flipped: RotLA's vertex at z = zmin carries v = 1.0.
        v = 1.0 - ((z - self.minz) / depth if depth > EPS else 0.0)
        return (u, v)

    def vertex(self, position, normal):
        nkey = tuple(round(c, 4) for c in normal)
        if nkey not in self._ncache:
            self.normals.append(nkey)
            self._ncache[nkey] = len(self.normals)
        vkey = (tuple(round(c, 6) for c in position), nkey)
        if vkey not in self._vcache:
            self.vertices.append(position)
            self.uvs.append(self.uv(position[0], position[2]))
            self._vcache[vkey] = (len(self.vertices), self._ncache[nkey])
        return self._vcache[vkey]

    def triangle(self, a, b, c, normal):
        self.faces.append([self.vertex(p, normal) for p in (a, b, c)])

    def group(self, name):
        self.groups.append((name, len(self.faces)))

    def text(self, title):
        out = ["# %s" % title,
               "# generated by scripts/tilegen.py — do not edit; edit spec/tiles.json"]
        if not self.groups:
            self.groups = [("mesh", 0)]
        emitted = 0
        body = []
        for position in self.vertices:
            body.append("v %.6f %.6f %.6f" % position)
        for u, v in self.uvs:
            body.append("vt %.6f %.6f" % (u, v))
        for normal in self.normals:
            body.append("vn %.4f %.4f %.4f" % normal)
        bounds = [start for _, start in self.groups] + [len(self.faces)]
        for index, (name, start) in enumerate(self.groups):
            body.append("o %s" % name)
            body.append("s 1")
            for face in self.faces[start:bounds[index + 1]]:
                body.append("f " + " ".join("%d/%d/%d" % (v, v, n) for v, n in face))
                emitted += 1
        assert emitted == len(self.faces)
        return "\n".join(out + body) + "\n"


def emit_prism(writer, loop, half, name):
    """One extruded silhouette: top cap, bottom cap and a wall per boundary edge.

    The winding rules are the whole content of this function, and both were read
    off RotLA's mesh rather than reasoned about:

      * +y faces wind clockwise in the (x, z) plot (negative signed area), so
        the caps are ear-clipped counter-clockwise and the top is reversed;
      * with the outline walked clockwise, an edge's outward direction is to its
        left, (-dz, dx).
    """
    writer.group(name)

    clockwise = list(loop)
    if signed_area(clockwise) > 0:
        clockwise.reverse()

    for a, b, c in ear_clip(clockwise):
        top = [(p[0], half, p[1]) for p in (a, b, c)]
        writer.triangle(top[2], top[1], top[0], (0.0, 1.0, 0.0))
        bottom = [(p[0], -half, p[1]) for p in (a, b, c)]
        writer.triangle(bottom[0], bottom[1], bottom[2], (0.0, -1.0, 0.0))

    for i in range(len(clockwise)):
        p, q = clockwise[i], clockwise[(i + 1) % len(clockwise)]
        dx, dz = q[0] - p[0], q[1] - p[1]
        normal = normalise((-dz, 0.0, dx))
        top_p = (p[0], half, p[1])
        top_q = (q[0], half, q[1])
        bot_p = (p[0], -half, p[1])
        bot_q = (q[0], -half, q[1])
        writer.triangle(top_p, bot_p, bot_q, normal)
        writer.triangle(top_p, bot_q, top_q, normal)


def bbox_of(loop):
    xs = [p[0] for p in loop]
    zs = [p[1] for p in loop]
    return (min(xs), max(xs), min(zs), max(zs))


def build_mesh(cells, radius, half, label):
    loop, seams = outline(cells, radius)
    box = bbox_of(loop)
    writer = ObjWriter(box)
    emit_prism(writer, loop, half, label)
    return writer.text("%s — %d cell(s), R=%g" % (label, len(cells), radius)), loop, seams, box


def build_collider(cells, radius, half, inset, box, label):
    """One convex hex prism per cell, each shrunk about its own centre.

    RotLA's collider is three separate objects and its CustomMesh says
    `Convex: true`; a single non-convex tri-hex hull would be a solid triangle
    and tiles would refuse to interlock.  The inset keeps neighbouring tiles
    from fighting at their shared edge.
    """
    writer = ObjWriter(box)
    for index, (q, r) in enumerate(cells):
        cx, cz = axial_to_world(q, r, radius)
        corners = [(cx + (x - cx) * inset, cz + (z - cz) * inset)
                   for x, z in hex_corners(cx, cz, radius)]
        emit_prism(writer, corners, half, "%s_collider_%d" % (label, index))
    return writer.text("%s collider — %d convex hex prism(s), inset %g"
                       % (label, len(cells), inset))


# ------------------------------------------------------------------- PNG art


def value_noise(seed):
    """Deterministic 2-D value noise: an integer hash, bilinear, smoothstepped.

    `random` would do, but a hand-rolled hash is stable across Python releases
    and across the two places it could ever be reimplemented, which matters when
    `--check` asserts that today's bytes equal yesterday's.
    """
    cache = {}

    def lattice(ix, iz):
        hit = cache.get((ix, iz))
        if hit is not None:
            return hit
        n = (ix * 374761393 + iz * 668265263 + seed * 1274126177) & 0xFFFFFFFF
        n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
        value = ((n ^ (n >> 16)) & 0xFFFF) / 65535.0
        cache[(ix, iz)] = value
        return value

    def sample(x, z):
        ix, iz = math.floor(x), math.floor(z)
        fx, fz = x - ix, z - iz
        sx = fx * fx * (3.0 - 2.0 * fx)
        sz = fz * fz * (3.0 - 2.0 * fz)
        n00 = lattice(ix, iz)
        n10 = lattice(ix + 1, iz)
        n01 = lattice(ix, iz + 1)
        n11 = lattice(ix + 1, iz + 1)
        top = n00 + (n10 - n00) * sx
        bottom = n01 + (n11 - n01) * sx
        return top + (bottom - top) * sz

    return sample


def point_in_polygon(x, z, poly):
    inside = False
    n = len(poly)
    j = n - 1
    for i in range(n):
        xi, zi = poly[i]
        xj, zj = poly[j]
        if (zi > z) != (zj > z):
            if x < (xj - xi) * (z - zi) / (zj - zi) + xi:
                inside = not inside
        j = i
    return inside


def distance_to_segments(x, z, segments):
    best = 1e9
    for ax, az, dx, dz, inv in segments:
        t = ((x - ax) * dx + (z - az) * dz) * inv
        if t < 0.0:
            t = 0.0
        elif t > 1.0:
            t = 1.0
        px, pz = x - (ax + dx * t), z - (az + dz * t)
        d = px * px + pz * pz
        if d < best:
            best = d
    return math.sqrt(best)


def prepare_segments(pairs):
    out = []
    for a, b in pairs:
        dx, dz = b[0] - a[0], b[1] - a[1]
        length2 = dx * dx + dz * dz
        out.append((a[0], a[1], dx, dz, (1.0 / length2) if length2 > EPS else 0.0))
    return out


def parse_colour(text):
    """'#2E6B33' or '2E6B33' -> (r, g, b) as three floats in 0..1."""
    raw = str(text).lstrip("#")
    if len(raw) != 6:
        die("colour %r is not six hex digits" % text)
    try:
        return tuple(int(raw[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    except ValueError:
        die("colour %r is not hexadecimal" % text)


# ------------------------------------------------------------------ frontiers
#
# A *frontier* is terrain that changes inside one tile: a river cell with forest
# reaching in over two of its edges, a clearing walled by deep jungle on four.
# The spec expresses it per cell — a centre terrain plus per-edge overrides —
# and everything below turns that into a field that can be sampled per pixel.
#
# Two properties are worth stating because the arithmetic is chosen to get them:
#
#   continuity  a tile's three hexes must read as one landscape, so the blend
#               has to agree from both sides of an interior seam. It does,
#               because an interior edge puts its crossover exactly on the
#               seam: approached from either cell the mix there is half and
#               half of the same two terrains.
#   registration a frontier drawn on one tile has to meet a plain tile of the
#               same terrain without a step, so an outer edge's crossover sits
#               `reach` *inside* the cell — at the rim itself the pixel is
#               already pure edge terrain.


def frontier_key(a, b):
    return "|".join(sorted((a, b)))


def load_terrains(spec, base_texture):
    """terrains: id -> colour and grain. The one source of truth for a colour."""
    out = {}
    for name, entry in (spec.get("terrains") or {}).items():
        if name.startswith("_"):
            continue
        out[name] = {
            "colour": parse_colour(entry.get("colour", "FFFFFF")),
            "grain": float(entry.get("grain", base_texture["grain"])) / 255.0,
            "grain_scale": float(entry.get("grain_scale",
                                           base_texture["grain_scale"])),
        }
    return out


FRONTIER_DEFAULTS = {"reach": 0.35, "band": 0.35, "warp": 0.12, "shore": None,
                     "shore_width": 0.14}


def load_frontiers(spec):
    """frontiers: an unordered terrain pair -> how the two meet.

    Two numbers, and keeping them apart is the whole trick.  **`reach`** is how
    far the edge terrain pushes in from the tile's rim, in hex radii — how much
    of the cell it takes.  **`band`** is how wide the crossover is — how abrupt
    it looks.  A beach is a long reach and a narrow band; a forest gradient is
    a shorter reach and a wide one.  Confusing the two gives either a hairline
    of terrain at the rim or a ramp with no terrain at either end of it.

    The apothem is sqrt(3)/2 = 0.866 radii, so `reach` above that floods the
    cell and `reach` of 0 leaves the two terrains meeting exactly on the edge.

    `shore` paints a third colour where the mix crosses half and half — sand at
    the waterline — and `warp` wobbles the boundary with a value-noise field, so
    a coast is ragged rather than a straight chord.
    """
    out = {}
    for key, entry in (spec.get("frontiers") or {}).items():
        if key.startswith("_"):
            continue  # a note to the reader, like the spec's other _comments
        if key == "default":
            name = "default"
        else:
            parts = [p.strip() for p in key.split("|")]
            if len(parts) != 2:
                die("frontier %r is not a 'terrain|terrain' pair" % key)
            name = frontier_key(*parts)
        style = dict(FRONTIER_DEFAULTS)
        style.update({k: float(v) for k, v in entry.items()
                      if k in ("reach", "band", "warp", "shore_width")})
        if entry.get("shore"):
            style["shore"] = parse_colour(entry["shore"])
        out[name] = style
    out.setdefault("default", dict(FRONTIER_DEFAULTS))
    return out


def frontier_style(frontiers, a, b):
    return frontiers.get(frontier_key(a, b), frontiers["default"])


def prepare_paint(name, kind, shape, terrains, frontiers, radius):
    """Validate a kind's `paint` block and flatten it into per-pixel arithmetic.

    Everything that can be wrong with a spec is caught here, in the parent
    process, before any pixel is drawn or any worker is forked: an unknown
    terrain, an override on an interior edge, the wrong number of cells.

    Returns a list, one entry per cell:
        (cx, cz, terrain, apothem, [(ux, uz, terrain, reach, band, warp), ...])
    where the tuples are the cell's edges that actually change terrain and
    `ux, uz` is the unit vector from the cell's centre towards that edge.

    An **interior** edge — one facing another cell of the same tile — always
    gets `reach = 0`, so the crossover sits exactly on the seam and the mix
    there is half and half whichever cell you approach it from.  That is what
    makes a tile's three hexes read as one landscape instead of three pictures.
    """
    paint = kind.get("paint")
    if paint is None:
        return None
    cells = [tuple(cell) for cell in shape["cells"]]
    if len(paint) != len(cells):
        die("kind %r paints %d cells for a %d-cell shape"
            % (name, len(paint), len(cells)))

    index_of = {cell: i for i, cell in enumerate(cells)}
    apothem = radius * SQRT3 / 2.0

    def terrain_of(index):
        terrain = paint[index].get("terrain")
        if terrain not in terrains:
            die("kind %r cell %d names terrain %r; the spec defines %s"
                % (name, index + 1, terrain, ", ".join(sorted(terrains)) or "none"))
        return terrain

    out = []
    for index, (q, r) in enumerate(cells):
        base = terrain_of(index)
        overrides = paint[index].get("edges") or {}
        for raw in overrides:
            try:
                number = int(raw)
            except (TypeError, ValueError):
                number = 0
            if not 1 <= number <= 6:
                die("kind %r cell %d has edge %r; edges are 1..6 (%s)"
                    % (name, index + 1, raw, " ".join(EDGE_NAMES)))

        cx, cz = axial_to_world(q, r, radius)
        edges = []
        for d, (dq, dr) in enumerate(DIRECTIONS):
            neighbour = (q + dq, r + dr)
            sibling = index_of.get(neighbour)
            override = overrides.get(str(d + 1), overrides.get(d + 1))
            if sibling is not None:
                if override is not None:
                    die("kind %r cell %d overrides edge %d (%s), which is "
                        "interior — it faces cell %d of the same tile. Paint "
                        "that cell instead."
                        % (name, index + 1, d + 1, EDGE_NAMES[d], sibling + 1))
                # An interior seam is drawn twice, once from each cell, and the
                # two have to land on the same boundary. Distance measured from
                # A is exactly minus the distance measured from B, so a wobble
                # added to both would push the boundary *into* each cell and
                # leave a step down the seam. Flipping its sign on the higher-
                # indexed cell keeps the two distances exact negatives, and the
                # smoothstep's symmetry about 0.5 then makes the two mixes
                # identical pixel for pixel.
                terrain, reach = terrain_of(sibling), 0.0
                flip = -1.0 if index > sibling else 1.0
            elif override is not None:
                if override not in terrains:
                    die("kind %r cell %d edge %d names terrain %r; the spec "
                        "defines %s" % (name, index + 1, d + 1, override,
                                        ", ".join(sorted(terrains))))
                terrain, reach, flip = override, None, 1.0
            else:
                continue
            if terrain == base:
                continue
            nx, nz = axial_to_world(neighbour[0], neighbour[1], radius)
            length = math.hypot(nx - cx, nz - cz)
            style = frontier_style(frontiers, base, terrain)
            if reach is None:
                reach = style["reach"]
            edges.append(((nx - cx) / length, (nz - cz) / length, terrain,
                          reach * radius, max(style["band"] * radius, EPS),
                          style["warp"] * radius * flip))
        out.append((cx, cz, base, apothem, edges))
    return out


def painted_edges(name, kind, shape):
    """Per cell, the terrain each of its six edges is painted with.

    `prepare_paint` flattens a `paint` block into pixel arithmetic — unit
    vectors, reach, band — which is everything the renderer needs and nothing
    the *game* can read back.  This keeps the other half: which numbered
    hexside carries which terrain, in the spec's own 1..6 numbering, so the Lua
    can ask "is edge 6 of cell 3 deep forest?" without re-deriving it from the
    diffuse.  src/25-rubber.lua is what asks.

    Six slots per cell so an edge number indexes the row directly, with `false`
    where the edge is not overridden.  Only an **outer** edge can carry one —
    prepare_paint refuses an override on an interior seam, and that runs first —
    so a non-false entry is always a hexside on the tile's rim.

    A flat kind has no `paint` and gets an empty list rather than a grid of
    `false`: index.lua is read by a human often enough to be worth the terse
    form, and the Lua treats missing and empty the same way.
    """
    paint = kind.get("paint")
    if paint is None:
        return []
    out = []
    for index in range(len(shape["cells"])):
        overrides = paint[index].get("edges") or {}
        out.append([overrides.get(str(d), overrides.get(d)) or False
                    for d in range(1, 7)])
    return out


def write_png(width, height, pixels):
    """An 8-bit RGBA PNG, adaptively filtered.

    Filtering is worth the twenty lines: on smooth value noise the Up filter
    turns a 1 MB raw image into a couple of hundred kilobytes, and these files
    live in the folder next to the save.
    """
    raw = bytearray()
    stride = width * 4
    previous = bytearray(stride)
    for y in range(height):
        line = pixels[y * stride:(y + 1) * stride]
        candidates = []

        none = bytes(line)
        candidates.append((0, none))

        sub = bytearray(stride)
        for i in range(stride):
            left = line[i - 4] if i >= 4 else 0
            sub[i] = (line[i] - left) & 0xFF
        candidates.append((1, bytes(sub)))

        up = bytearray(stride)
        for i in range(stride):
            up[i] = (line[i] - previous[i]) & 0xFF
        candidates.append((2, bytes(up)))

        # The usual heuristic: the filtered line whose bytes are smallest when
        # read as signed values tends to be the one that deflates best.
        def cost(candidate):
            return sum(b if b < 128 else 256 - b for b in candidate[1])

        best = min(candidates, key=cost)
        raw.append(best[0])
        raw.extend(best[1])
        previous = line

    def chunk(tag, payload):
        return (struct.pack(">I", len(payload)) + tag + payload
                + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF))

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", header)
            + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
            + chunk(b"IEND", b""))


def blend(x, z, painted, terrains, frontiers, warp_noise, warp_frequency):
    """The terrain at one pixel: a colour, and the grain that terrain carries.

    The Voronoi region of a point on a hex lattice is exactly its hexagon, so
    "nearest centre" picks the cell the pixel is inside — no polygon test — and
    `distance` below is then the perpendicular distance in to that cell's edge,
    zero on the edge and one apothem at the centre.
    """
    nearest, best = painted[0], 1e9
    for entry in painted:
        d = (x - entry[0]) ** 2 + (z - entry[1]) ** 2
        if d < best:
            nearest, best = entry, d
    cx, cz, base, apothem, edges = nearest

    weights = {}
    claimed = 0.0
    if edges:
        wobble = (warp_noise(x * warp_frequency, z * warp_frequency) - 0.5)
        for ux, uz, terrain, reach, band, warp in edges:
            # distance: 0 on the edge, one apothem at the centre. The crossover
            # sits `reach` in from the edge and the ramp spans `band` about it.
            distance = apothem - ((x - cx) * ux + (z - cz) * uz) + wobble * warp
            t = 0.5 + (reach - distance) / band
            if t <= 0.0:
                continue
            if t > 1.0:
                t = 1.0
            weight = t * t * (3.0 - 2.0 * t)
            weights[terrain] = weights.get(terrain, 0.0) + weight
            claimed += weight
    if claimed < 1.0:
        weights[base] = weights.get(base, 0.0) + 1.0 - claimed

    total = 0.0
    for weight in weights.values():
        total += weight
    red = green = blue = 0.0
    grain = scale = 0.0
    for terrain, weight in weights.items():
        share = weight / total
        entry = terrains[terrain]
        colour = entry["colour"]
        red += share * colour[0]
        green += share * colour[1]
        blue += share * colour[2]
        grain += share * entry["grain"]
        scale += share * entry["grain_scale"]

    # The shore: a third colour laid over the line where the two heaviest
    # terrains are half and half.  This is what makes a river's edge read as a
    # beach or an embankment rather than as a colour ramp — and why an abrupt
    # `band` and a `shore` go together.
    if len(weights) > 1:
        first = second = None
        for terrain, weight in weights.items():
            if first is None or weight > first[1]:
                first, second = (terrain, weight), first
            elif second is None or weight > second[1]:
                second = (terrain, weight)
        style = frontier_style(frontiers, first[0], second[0])
        shore = style["shore"]
        if shore is not None:
            width = style["shore_width"]
            balance = second[1] / (first[1] + second[1])  # 0 .. 0.5
            if balance > 0.5 - width:
                near = (0.5 - balance) / width
                strength = 1.0 - near * near
                red += (shore[0] - red) * strength
                green += (shore[1] - green) * strength
                blue += (shore[2] - blue) * strength

    return (red, green, blue), grain, scale


def build_diffuse(kind, shape, texture, radius, painted=None, terrains=None,
                  frontiers=None):
    """The tile face: grey by default, because colour belongs to ColorDiffuse.

    Keeping the PNG greyscale is what makes "make it darker green" a one-line
    tint at runtime instead of a regenerate and a respawn — the L1/L2 split in
    the build plan.  A kind that genuinely needs mixed terrain sets `per_cell`
    or `paint` and accepts being an L2 change.

    `painted` is prepare_paint's output.  When it is present the luminance is
    still the same grey — so a frontier tile sits at the same brightness as a
    plain tinted one — but it multiplies a *blended* terrain colour instead of
    being left for ColorDiffuse.
    """
    loop, seams, box, cells = shape["loop"], shape["seams"], shape["bbox"], shape["cells"]
    minx, maxx, minz, maxz = box
    width_units = maxx - minx
    depth_units = maxz - minz

    width = int(texture["resolution"])
    height = max(1, int(round(width * depth_units / width_units)))

    base = float(texture["base"]) / 255.0
    grain = float(texture["grain"]) / 255.0
    grain_scale = float(texture["grain_scale"])
    octaves = int(texture["octaves"])
    edge = float(texture["edge"])
    edge_darken = float(texture["edge_darken"])
    seam_width = float(texture["seam_width"])
    seam_darken = float(texture["seam_darken"])
    draw_seams = bool(texture["seams"]) and bool(seams)

    noise = value_noise(int(texture["seed"]))
    # A second, decorrelated field displaces a frontier's boundary. Sampling it
    # from (x, z) alone is what keeps the wobble identical on both sides of an
    # interior seam, and therefore keeps the blend continuous across it.
    warp_noise = value_noise(int(texture["seed"]) + 7919)
    warp_frequency = 1.0 / float(texture["warp_scale"])
    border = prepare_segments([(loop[i], loop[(i + 1) % len(loop)])
                               for i in range(len(loop))])
    seam_segments = prepare_segments(seams) if draw_seams else []

    centres = [axial_to_world(q, r, radius) for q, r in cells]
    per_cell = kind.get("per_cell")
    if per_cell is not None:
        if len(per_cell) != len(cells):
            die("kind %r has %d per_cell colours for a %d-cell shape"
                % (kind["name"], len(per_cell), len(cells)))
        per_cell = [parse_colour(c) for c in per_cell]

    markers = []
    if kind.get("markers"):
        # Two asymmetric dots on cell 0, so a texture that has come out mirrored
        # or z-flipped in TTS is obvious at a glance rather than plausible.
        cx, cz = centres[0]
        markers.append(((cx, cz + radius * 0.62), radius * 0.16, (1.0, 1.0, 1.0)))
        markers.append(((cx + radius * SQRT3 / 2 * 0.62, cz + radius * 0.31),
                        radius * 0.16, (0.0, 0.0, 0.0)))

    pixels = bytearray(width * height * 4)
    for py in range(height):
        # Row 0 is v = 1, which is z = zmin: the flip lives here and nowhere else.
        z = minz + (py + 0.5) / height * depth_units
        row = py * width * 4
        for px in range(width):
            x = minx + (px + 0.5) / width * width_units
            offset = row + px * 4
            if not point_in_polygon(x, z, loop):
                continue  # left at (0,0,0,0): outside the silhouette

            mix = None
            pixel_grain, pixel_scale = grain, grain_scale
            if painted is not None:
                mix, pixel_grain, pixel_scale = blend(
                    x, z, painted, terrains, frontiers,
                    warp_noise, warp_frequency)

            value = base
            amplitude, frequency, total = pixel_grain, 1.0 / pixel_scale, 0.0
            for _ in range(octaves):
                total += (noise(x * frequency, z * frequency) - 0.5) * amplitude
                amplitude *= 0.5
                frequency *= 2.0
            value += total

            distance = distance_to_segments(x, z, border)
            if distance < edge and edge > EPS:
                value *= 1.0 - edge_darken * (1.0 - distance / edge) ** 2

            if seam_segments:
                seam = distance_to_segments(x, z, seam_segments)
                if seam < seam_width and seam_width > EPS:
                    value *= 1.0 - seam_darken * (1.0 - seam / seam_width)

            if value < 0.0:
                value = 0.0
            elif value > 1.0:
                value = 1.0
            colour = [value, value, value]

            if mix is not None:
                colour = [value * mix[0], value * mix[1], value * mix[2]]

            if per_cell is not None:
                nearest, best = 0, 1e9
                for index, (ccx, ccz) in enumerate(centres):
                    d = (x - ccx) ** 2 + (z - ccz) ** 2
                    if d < best:
                        nearest, best = index, d
                tint = per_cell[nearest]
                colour = [value * tint[0], value * tint[1], value * tint[2]]

            for centre, size, mark in markers:
                if (x - centre[0]) ** 2 + (z - centre[1]) ** 2 < size * size:
                    colour = list(mark)

            pixels[offset] = int(colour[0] * 255 + 0.5)
            pixels[offset + 1] = int(colour[1] * 255 + 0.5)
            pixels[offset + 2] = int(colour[2] * 255 + 0.5)
            pixels[offset + 3] = 255

    return write_png(width, height, pixels)


# ---------------------------------------------------------------- the catalog


TEXTURE_DEFAULTS = {
    "resolution": 512,
    "base": 196,
    "grain": 34,
    "grain_scale": 0.42,
    "octaves": 3,
    "seed": 1,
    "edge": 0.20,
    "edge_darken": 0.42,
    "seams": True,
    "seam_width": 0.045,
    "seam_darken": 0.30,
    "warp_scale": 0.55,  # how many wobbles a frontier boundary has per hex
}

# What a painted kind wants that a flat one does not: the hex seams still have
# to register, but a hard dark line through a shoreline reads as a crack.
PAINTED_TEXTURE = {"seam_darken": 0.12}


def load_spec(path):
    if not os.path.exists(path):
        die("no spec at %s" % path)
    with open(path, encoding="utf-8") as handle:
        try:
            spec = json.load(handle)
        except ValueError as exc:
            die("%s is not valid JSON: %s" % (path, exc))
    for required in ("shapes", "kinds"):
        if required not in spec:
            die("%s has no %r block" % (path, required))
    return spec


def stamp(data):
    return hashlib.sha256(data).hexdigest()


def file_url(path, style="encoded"):
    """A local URL in the form TTS itself writes.

    Every `file:///` URL TTS has written into this folder's saves takes the form
    `file://` + the absolute path, which means four slashes:

        file:////Users/zepphit/Desktop/.../CardBack.png

    None of them contains a space, and this folder's own path does
    ("Tabletop Simulator"), so whether Unity's downloader accepts a raw space is
    untested here.  `encoded` (the default) percent-escapes it and anything else
    outside the unreserved set; `--url-style raw` is the one-flag fallback if the
    gate shows blank tiles.  Either way `tts.py`'s cache mangling strips the
    punctuation, so only the cache filename differs, never the behaviour.
    """
    path = os.path.abspath(path).replace(os.sep, "/")
    if style == "encoded":
        safe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~/"
        path = "".join(c if c in safe else
                       "".join("%%%02X" % b for b in c.encode("utf-8"))
                       for c in path)
    return "file://" + path


def render(job):
    """One diffuse, as a worker sees it: nothing but arithmetic.

    Every way a spec can be wrong has already been caught in generate(), so a
    worker cannot die() — which is what makes farming these out to a Pool safe.
    """
    name, kind, shape, texture, radius, painted, terrains, frontiers = job
    return name, build_diffuse(kind, shape, texture, radius, painted, terrains,
                               frontiers)


def generate(spec, out_dir, url_style="encoded", jobs=None):
    """Produce every artefact in memory first, so a failure writes nothing."""
    radius = float(spec.get("radius", 1.0))
    half = float(spec.get("thickness", 0.1))
    inset = float(spec.get("collider_inset", 0.9425))

    base_texture = dict(TEXTURE_DEFAULTS)
    base_texture.update(spec.get("texture", {}))
    terrains = load_terrains(spec, base_texture)
    frontiers = load_frontiers(spec)

    shapes = {}
    files = {}
    for name in sorted(spec["shapes"]):
        entry = spec["shapes"][name]
        cells = [tuple(cell) for cell in entry["cells"]]
        if not cells:
            die("shape %r has no cells" % name)
        if len(set(cells)) != len(cells):
            die("shape %r lists the same cell twice" % name)

        mesh_text, loop, seams, box = build_mesh(cells, radius, half, name)
        mesh_bytes = mesh_text.encode("utf-8")
        mesh_file = "%s-%s.obj" % (name, stamp(mesh_bytes)[:8])

        collider_text = build_collider(cells, radius, half, inset, box, name)
        collider_bytes = collider_text.encode("utf-8")
        collider_file = "%s-collider-%s.obj" % (name, stamp(collider_bytes)[:8])

        files[mesh_file] = mesh_bytes
        files[collider_file] = collider_bytes
        shapes[name] = {
            "cells": [list(cell) for cell in cells],
            "loop": loop,
            "seams": seams,
            "bbox": box,
            "mesh": {"file": mesh_file, "sha256": stamp(mesh_bytes)},
            "collider": {"file": collider_file, "sha256": stamp(collider_bytes)},
            "size": [round(box[1] - box[0], 4), round(2 * half, 4),
                     round(box[3] - box[2], 4)],
        }

    kinds = {}
    queue = []
    for name in sorted(spec["kinds"]):
        entry = dict(spec["kinds"][name])
        entry["name"] = name
        shape_name = entry.get("shape", "trihex")
        if shape_name not in shapes:
            die("kind %r wants shape %r, which the spec does not define"
                % (name, shape_name))
        shape = shapes[shape_name]

        painted = prepare_paint(name, entry, shape, terrains, frontiers, radius)

        texture = dict(base_texture)
        if painted is not None:
            texture.update(PAINTED_TEXTURE)
        texture.update(entry.get("texture", {}))
        if "seed" not in entry.get("texture", {}):
            # A per-kind seed by default, so two kinds do not share a grain
            # pattern, but still derived rather than drawn: same spec, same bytes.
            texture["seed"] = int(base_texture["seed"]) + (
                int(hashlib.sha256(name.encode("utf-8")).hexdigest()[:6], 16) % 99991)

        # A painted kind bakes its colour, so ColorDiffuse must not tint it a
        # second time.  A flat one takes its tint from the terrain of the same
        # name when it has not named one itself: the `terrains` block is then
        # the single answer to "what colour is jungle", whether the tile is a
        # plain hex or one side of a frontier.
        if painted is not None:
            if entry.get("tint"):
                die("kind %r has both `paint` and `tint`; a painted kind bakes "
                    "its colour, so ColorDiffuse has to stay white" % name)
            tint = (1.0, 1.0, 1.0)
        elif entry.get("tint"):
            tint = parse_colour(entry["tint"])
        elif name in terrains:
            tint = terrains[name]["colour"]
        else:
            tint = (1.0, 1.0, 1.0)

        hubs = entry.get("hubs") or []
        if len(hubs) > len(shape["cells"]):
            die("kind %r declares %d hubs for a %d-cell shape"
                % (name, len(hubs), len(shape["cells"])))

        queue.append((name, entry, shape, texture, radius, painted, terrains,
                      frontiers))
        kinds[name] = {
            "shape": shape_name,
            "label": entry.get("label", name),
            "weight": entry.get("weight", 1),
            "tray": bool(entry.get("tray", False)),
            "tint": [round(c, 4) for c in tint],
            "hubs": hubs,
            # Which numbered hexside carries which terrain. The art bakes this
            # into pixels; the game needs it as data — see painted_edges.
            "edges": painted_edges(name, entry, shape),
        }

    # The diffuses are the whole cost of a run and each one is independent, so
    # they fan out.  Results are keyed by name and folded back in sorted order,
    # which is what keeps --check byte-exact whatever --jobs was.
    if jobs is None:
        jobs = multiprocessing.cpu_count()
    jobs = max(1, min(int(jobs), len(queue) or 1))
    if jobs > 1 and len(queue) > 1:
        pool = multiprocessing.Pool(jobs)
        try:
            drawn = dict(pool.map(render, queue, chunksize=1))
        finally:
            pool.close()
            pool.join()
    else:
        drawn = dict(render(job) for job in queue)

    for name in sorted(kinds):
        png = drawn[name]
        diffuse_file = "%s-%s.png" % (name, stamp(png)[:8])
        files[diffuse_file] = png
        kinds[name]["diffuse"] = {"file": diffuse_file, "sha256": stamp(png)}

    index = {
        "generated_by": "scripts/tilegen.py",
        "spec_sha256": stamp(json.dumps(spec, sort_keys=True,
                                        separators=(",", ":")).encode("utf-8")),
        "radius": radius,
        "thickness": half,
        "shapes": {name: {k: v for k, v in shape.items()
                          if k not in ("loop", "seams")}
                   for name, shape in shapes.items()},
        "kinds": kinds,
    }
    for name, shape in index["shapes"].items():
        for slot in ("mesh", "collider"):
            shape[slot]["url"] = file_url(os.path.join(out_dir, shape[slot]["file"]), url_style)
    for name, kind in index["kinds"].items():
        kind["diffuse"]["url"] = file_url(os.path.join(out_dir, kind["diffuse"]["file"]), url_style)

    files["index.json"] = (json.dumps(index, indent=2, sort_keys=True) + "\n").encode("utf-8")
    files["index.lua"] = lua_index(index).encode("utf-8")
    return files, index


def lua_table(value, indent):
    pad = "  " * indent
    inner = "  " * (indent + 1)
    if isinstance(value, dict):
        if not value:
            return "{}"
        rows = []
        for k in sorted(value):
            name = k if k.replace("_", "a").isalnum() and not k[0].isdigit() else '["%s"]' % k
            rows.append("%s%s = %s," % (inner, name, lua_table(value[k], indent + 1)))
        return "{\n" + "\n".join(rows) + "\n" + pad + "}"
    if isinstance(value, (list, tuple)):
        if not value:
            return "{}"
        return "{ " + ", ".join(lua_table(v, indent + 1) for v in value) + " }"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    return '"%s"' % str(value).replace("\\", "\\\\").replace('"', '\\"')


def lua_index(index):
    """The same catalogue as index.json, as a Lua literal.

    TTS has no `require` and no file I/O, so the save's script has to carry this
    rather than read it.  build.sh concatenates this file ahead of src/, and
    src/00-config.lua reads it — one generated source of truth instead of a
    table kept in step by hand.
    """
    payload = {
        "radius": index["radius"],
        "thickness": index["thickness"],
        "shapes": {name: {"cells": shape["cells"], "size": shape["size"],
                          "mesh": shape["mesh"]["url"],
                          "collider": shape["collider"]["url"]}
                   for name, shape in index["shapes"].items()},
        "kinds": {name: {"shape": kind["shape"], "label": kind["label"],
                         "weight": kind["weight"], "tint": kind["tint"],
                         "tray": kind["tray"], "hubs": kind["hubs"],
                         "edges": kind["edges"],
                         "diffuse": kind["diffuse"]["url"]}
                  for name, kind in index["kinds"].items()},
    }
    return ("-- proto/amazonia/art/index.lua — GENERATED by scripts/tilegen.py.\n"
            "-- Do not edit: edit proto/amazonia/spec/tiles.json and regenerate.\n"
            "-- The URLs are file:/// and therefore machine-local by design\n"
            "-- (docs/asset-cache.md); a Workshop upload would rewrite them.\n"
            "\nAMAZONIA_ART = " + lua_table(payload, 0) + "\n")


def referenced(index):
    names = {"index.json", "index.lua"}
    for shape in index["shapes"].values():
        names.add(shape["mesh"]["file"])
        names.add(shape["collider"]["file"])
    for kind in index["kinds"].values():
        names.add(kind["diffuse"]["file"])
    return names


def main():
    parser = argparse.ArgumentParser(
        description="Mint tri-hex tile meshes, colliders and diffuse art from a spec.")
    parser.add_argument("--spec", default=DEFAULT_SPEC)
    parser.add_argument("--out", default=DEFAULT_OUT)
    parser.add_argument("--check", action="store_true",
                        help="regenerate and assert every file is byte-identical")
    parser.add_argument("--prune", action="store_true",
                        help="delete files in --out that the new index does not name")
    parser.add_argument("--url-style", choices=("encoded", "raw"), default="encoded",
                        help="how a space in the folder path is written into a "
                             "file:// URL; try 'raw' if TTS shows blank tiles")
    parser.add_argument("--jobs", type=int, default=None,
                        help="how many diffuses to draw at once (default: one "
                             "per core; 1 to debug). The output is identical "
                             "either way.")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    refuse_managed(args.out)
    spec = load_spec(args.spec)
    files, index = generate(spec, args.out, args.url_style, args.jobs)

    if args.check:
        problems = []
        for name in sorted(files):
            path = os.path.join(args.out, name)
            if not os.path.exists(path):
                problems.append("missing: %s" % name)
                continue
            with open(path, "rb") as handle:
                if handle.read() != files[name]:
                    problems.append("changed: %s" % name)
        keep = referenced(index)
        stale = sorted(n for n in os.listdir(args.out)
                       if n not in keep and not n.startswith(".")) \
            if os.path.isdir(args.out) else []
        for name in stale:
            problems.append("unreferenced: %s (run --prune)" % name)
        if problems:
            for line in problems:
                sys.stderr.write("tilegen --check: %s\n" % line)
            return 1
        print("tilegen --check: %d files, all byte-identical" % len(files))
        return 0

    tmp = tempfile.mkdtemp(prefix="tilegen.")
    try:
        for name, payload in files.items():
            with open(os.path.join(tmp, name), "wb") as handle:
                handle.write(payload)
        os.makedirs(args.out, exist_ok=True)
        for name in sorted(files):
            shutil.copyfile(os.path.join(tmp, name), os.path.join(args.out, name))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    keep = referenced(index)
    stale = sorted(n for n in os.listdir(args.out)
                   if n not in keep and not n.startswith("."))
    if args.prune:
        for name in stale:
            os.remove(os.path.join(args.out, name))

    if not args.quiet:
        for name in sorted(files):
            size = len(files[name])
            print("  %-34s %8d bytes" % (name, size))
        print("%d files -> %s" % (len(files), os.path.relpath(args.out, ROOT)))
        for name, shape in sorted(index["shapes"].items()):
            print("  shape %-10s %d cells, bbox %s" % (name, len(shape["cells"]),
                                                       " x ".join("%g" % v for v in shape["size"])))
        if stale:
            verb = "pruned" if args.prune else "unreferenced (use --prune)"
            print("  %d %s: %s" % (len(stale), verb, ", ".join(stale)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
