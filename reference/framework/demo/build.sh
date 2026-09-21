#!/bin/bash
# Build the Woodcutter demo save from source.
#
#   reference/framework/demo/build.sh [Saves/TS_Save_126.json]
#
# Every step is one of the commands in scripts/tts.py, which is the point: the
# demo proves the authoring commands and ttslib at the same time. Nothing here
# edits a save in place, and the run is deterministic — GUIDs are derived, not
# drawn at random, so building twice gives a byte-identical file.
#
# Check TTS is not running first (`ls -lt Saves | head`): it overwrites on a
# timer and will clobber whatever this writes.

set -euo pipefail

cd "$(dirname "$0")/../../.."   # the Tabletop Simulator folder
OUT="${1:-Saves/TS_Save_126.json}"
DEMO="reference/framework/demo"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

tts() { python3 scripts/tts.py "$@"; }

# 1. An empty table.
tts new -o "$TMP/0.json" --name "ttslib demo — Woodcutter" --table Table_RPG

# 2. The components, each a Saved Object, each inserted with fresh GUIDs and
#    its tags declared at save level. The board goes down first: it is the
#    anchor every position in Global.lua is measured against.
tts object add "$TMP/0.json" "$DEMO/objects/board.json"  -o "$TMP/1.json"
tts object add "$TMP/1.json" "$DEMO/objects/supply.json" -o "$TMP/2.json"
tts object add "$TMP/2.json" "$DEMO/objects/marker.json" -o "$TMP/3.json"

#    Four loose cubes in a row, from one Saved Object. --spacing is what keeps
#    them from being inserted on top of each other.
tts object add "$TMP/3.json" "$DEMO/objects/wood.json" -o "$TMP/4.json" \
    --count 4 --at -1.6,1.4,3.4 --spacing 1.05,0,0

# 3. The script: the library, in filename order, then the game. TTS has no
#    require, so a build is a concatenation (critique C5, C10).
cat reference/framework/ttslib/*.lua "$DEMO/Global.lua" > "$TMP/global.lua"
tts lua inject "$TMP/4.json" "$TMP/global.lua" -o "$TMP/5.json"

# 4. The screen panel.
tts xml inject "$TMP/5.json" "$DEMO/ui.xml" -o "$OUT" --force

# 5. Never load a generated save without this.
tts validate "$OUT"

echo
echo "built $OUT"
echo "Load it from TTS: Games > Save & Load."
