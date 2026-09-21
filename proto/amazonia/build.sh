#!/bin/bash
# Build the Amazonia rig from source.
#
#   proto/amazonia/build.sh [Saves/TS_Save_127.json]
#
# Every step is one of the commands in scripts/tts.py plus one patch this tool
# has no subcommand for (the table's Grid block and its component tag labels).
# Nothing edits a save in place, and the run is deterministic: GUIDs are derived
# and the art is content-hashed, so building twice differs only in the timestamp.
#
# This is an L3 change in the build plan's terms — new Lua, new components, TTS
# reload. L1 (a tint, a reroll) and L2 (new art) do not come through here; they
# go through scripts/ttsd.py against the running game.

set -euo pipefail

cd "$(dirname "$0")/../.."   # the Tabletop Simulator folder
OUT="${1:-Saves/TS_Save_127.json}"
PROTO="proto/amazonia"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

tts() { python3 scripts/tts.py "$@"; }

# 0. Is TTS running? It saves on a timer and will overwrite whatever we write
#    (CLAUDE.md #5). Two independent tells, because neither is conclusive alone:
#
#      the port   TTS listens on 39999 for the External Editor API whenever it
#                 is up, so a successful connect is proof. A refused connect is
#                 not proof of absence — the feature can be off.
#      the clock  TTS rewrites the autosaves and SaveFileInfos.json on a timer.
#                 Only those, not every file under Saves/: a previous run of
#                 this script writes a save too, and that is not TTS.
if python3 -c 'import socket,sys
s=socket.socket(); s.settimeout(0.4)
sys.exit(0 if s.connect_ex(("127.0.0.1", 39999)) == 0 else 1)' 2>/dev/null; then
    echo "REFUSING: something is listening on port 39999, so TTS is running." >&2
    echo "It saves on a timer and would overwrite this. Quit TTS first." >&2
    exit 1
fi

if find Saves -maxdepth 1 -mmin -1 \
     \( -name 'TS_AutoSave*.json' -o -name 'SaveFileInfos.json' \) \
     2>/dev/null | grep -q .; then
    echo "REFUSING: TTS rewrote an autosave in the last minute, so it is" >&2
    echo "probably running. Quit it (or wait a minute) and try again." >&2
    exit 1
fi

if [ -e "$OUT" ]; then
    echo "REFUSING: $OUT already exists. There is no version control here, so" >&2
    echo "an overwrite is unrecoverable. Pick the next free number:" >&2
    ls Saves/TS_Save_*.json | sort -V | tail -3 >&2
    exit 1
fi

# 1. The art. Cheap when nothing changed; --check would only tell us it is
#    stale, and a build wants it fresh.
python3 scripts/tilegen.py --quiet

# 2. An empty table.
#
#    Table_RPG, not Table_None. With no table the anchor plate is the only floor
#    there is, and anything unlocked that misses its rim — a tray tile, a cube —
#    falls out of the world. The RPG table's flat surface was measured in the
#    running game at y = 0.96, running to x = 28 before its raised rim, which is
#    what TRAY's four columns are sized against.
tts new -o "$TMP/0.json" --name "Amazonia" --table Table_RPG

# 3. The anchor: a locked plate, tagged map.anchor. It is the only component in
#    the save — every tile is spawned from Lua at onLoad, because tts.py has no
#    tile minting command and `object add --spacing` offsets linearly, which a
#    hex field is not.
tts object add "$TMP/0.json" "$PROTO/objects/anchor.json" -o "$TMP/1.json"

# 4. Two things tts.py has no flag for.
#
#    Grid: RotLA's block — Type 2 is vertical (pointy-top) hexes, Offset true,
#    xSize = ySize = the across-corners diameter 2R. Lines and Snapping stay
#    off: the grid documents the geometry, the snap points do the work.
#
#    ComponentTags: the labels TTS's own tag UI offers. Tiles are spawned at
#    runtime carrying "tile" and "tile.<kind>", so nothing in the save file
#    declares them and they would be invisible in the UI.
python3 - "$TMP/1.json" "$TMP/2.json" "$PROTO/art/index.json" <<'PY'
import json, os, sys
sys.path.insert(0, "scripts")
import tts

source, target, index_path = sys.argv[1], sys.argv[2], sys.argv[3]
save = tts.load(source)

save["Grid"].update({
    "Type": 2, "Lines": False, "Opacity": 0.75, "ThickLines": False,
    "Snapping": False, "Offset": True, "BothSnapping": False,
    "xSize": 2.0, "ySize": 2.0,
})

with open(index_path, encoding="utf-8") as handle:
    index = json.load(handle)
labels = save.setdefault("ComponentTags", {"labels": []}).setdefault("labels", [])
known = {entry.get("normalized") for entry in labels}
for tag in ["tile"] + ["tile.%s" % name for name in sorted(index["kinds"])]:
    if tag.lower() not in known:
        known.add(tag.lower())
        labels.append({"displayed": tag, "normalized": tag.lower()})

tts.write_save(save, target)
print("  patched Grid -> Type 2 (pointy-top hexes), %d component tags declared"
      % len(labels))
PY

# 5. The script: the library, then the generated art catalogue, then the game,
#    each in filename order. TTS has no require, so a build is a concatenation —
#    and luacat.py is that `cat` plus the one lint concatenation needs. A file's
#    top-level `local` stays in scope for everything after it, so a later file
#    assigning the same name silently overwrites a library module instead of
#    making a global. It refuses to write the build if it finds one.
python3 scripts/luacat.py -o "$TMP/global.lua" --quiet
tts lua inject "$TMP/2.json" "$TMP/global.lua" -o "$TMP/3.json"

# 6. The screen panel. --force because `tts new` wrote TTS's own XML stub.
tts xml inject "$TMP/3.json" "$PROTO/ui.xml" -o "$OUT" --force

# 7. Never load a generated save without this.
tts validate "$OUT"

echo
echo "built $OUT"
echo "Load it from TTS: Games > Save & Load."
echo "Then: python3 scripts/ttsd.py exec 'return AZ.state()'"
