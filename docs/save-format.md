# Save & mod JSON format

Everything TTS persists — a save, a Workshop mod, a Saved Object — uses one
schema. They differ only in which optional top-level keys are present and how
many objects sit in `ObjectStates`.

All of it is written as **2-space pretty-printed JSON with no trailing newline**
— TTS is a C# program, so float exponents come out C#-style (`1E+07`,
`2.24779573E-08`) and non-ASCII is written literally. A save runs to 100,000
lines and 4 MB, so these files are still expensive to hand to an agent. Use
`scripts/tts.py` (see [Reading a save](#reading-a-save)).

`scripts/tts.py` reproduces that format exactly: `tts.py selftest` round-trips
every save and mod in this folder through load-then-write and confirms all 185
come back byte-identical. Re-run it after a TTS update.

## Top-level keys

| Key | Notes |
| --- | --- |
| `SaveName` | The name typed in TTS. Not the filename, and not unique. |
| `Date`, `EpochTime` | When it was saved. `Date` is a US-format string. |
| `VersionNumber` | TTS build that wrote it, e.g. `v14.2.2`. |
| `GameMode` | Usually the mod's title; often differs from `SaveName`. |
| `GameType`, `GameComplexity`, `PlayingTime`, `PlayerCounts` | Workshop metadata. |
| `Tags` | Workshop categories, e.g. `["Board Games", "Scripting"]`. |
| `Note` | The on-screen notebook. Carries `[rrggbb]` inline colour codes. |
| `TabStates` | Notebook tabs. |
| `Gravity`, `PlayArea`, `Table`, `Sky`, `Lighting`, `Grid`, `Hands`, `Turns`, `DecalPallet`, `ComponentTags`, `SnapPoints`, `VectorLines` | Table setup. `SnapPoints` here are table-level; objects can carry their own `AttachedSnapPoints`. |
| `LuaScript`, `LuaScriptState`, `XmlUI` | The global script and UI. See [Lua and XML UI](#lua-and-xml-ui). |
| `ObjectStates` | Everything on the table. See below. |

Variations worth knowing:

- **Workshop mods** (`Mods/Workshop/<id>.json`) add `SkyURL` and omit
  `PlayArea` / `MusicPlayer`.
- **Saved Objects** (`Saves/Saved Objects/*.json`) use the same schema with
  exactly one entry in `ObjectStates`. That is the whole trick to building a
  reusable component: a normal save wrapping one object.

## ObjectStates

A recursive tree, not a flat list. Two kinds of nesting:

- `ContainedObjects` — a list, for anything holding other objects (`Bag`,
  `Deck`, `Infinite_Bag`, `Custom_Model_Bag`).
- `States` — a **dict keyed by state number as a string** (`"2"`, `"3"`), for
  objects with flip/variant states. Easy to miss when walking the tree; a lot of
  naive scripts do.

`scripts/tts.py tree` walks both and prints a path for every node.

### Object types

The `Name` field is the object's *type*, not its label — the label is `Nickname`.
Types seen in this folder:

| Type | What it is |
| --- | --- |
| `Card`, `CardCustom` | A single card. `CardCustom` uses a custom image sheet. |
| `Deck`, `DeckCustom` | A stack of cards; the cards live in `ContainedObjects`. |
| `Bag`, `Infinite_Bag` | Containers. Infinite bags re-deal the same object. |
| `Custom_Token` | A flat die-cut shape from an image. |
| `Custom_Tile` | A square/hex/circle tile from an image. |
| `Custom_Model` | An imported 3D mesh. |
| `Custom_PDF` | An embedded rulebook. |
| `Custom_Assetbundle` | A Unity assetbundle (scripted/animated components). |
| `ScriptingTrigger`, `HandTrigger` | Invisible zones. `HandTrigger` is a player hand. |
| `3DText` | Floating text. |
| `BlockSquare`, `BlockRectangle` | Built-in primitive blocks. |
| `Chinese_Checkers_Piece`, `Die_*`, `Checker_*` | Built-in components. |

### Common object fields

Every object carries `GUID`, `Name`, `Transform` (`posX/Y/Z`, `rotX/Y/Z`,
`scaleX/Y/Z`), `Nickname`, `Description`, `GMNotes`, `ColorDiffuse`, `Locked`,
`Snap`, `Autoraise`, `Grid`, `Tooltip`, `Hands`, plus its own `LuaScript`,
`LuaScriptState` and `XmlUI`.

**Safe to edit freely — in an *unscripted* save:** `Nickname`, `Description`,
`GMNotes`, `Transform`, `Locked`, `ColorDiffuse`, `Tooltip`.

**⚠ In a scripted save, `Nickname`, `Description` and `GMNotes` are often
load-bearing.** They look like fields for humans, and every one of the five
reference mods uses at least one of them as storage. Editing one to tidy up can
silently break the mod:

| Mod | Field | What it carries |
| --- | --- | --- |
| Arcs | `Description` on `bb7d21` | `"in progress"` — the save/restore flag the whole `onLoad` branches on (`arcs/global/src__Global.lua:2411`, read back at `:2521`) |
| Arcs | `Nickname` | the identity scripts match on — `getName() == "SONG OF FREEDOM"`, `== "Action Card"`, `== "Zero Marker"` |
| RotLA | `GMNotes` | a supply item's home bag GUID, stamped on the way out (`rotla/objects/54bdb7/script.lua:5`) and read back by the sorting bag (`rotla/objects/93c2a0/script.lua:3`) |
| Rurik | `GMNotes` | the round counter and the selected player count, parsed with `string.match(..., "%d+")` (`rurik/global/script.lua:67`) |
| Almoravid | `Nickname` | how `DrawSpecificCard` finds a card in a deck (`almoravid/global/script.lua:251`) |

**The rule: grep the Lua for the field before editing it.**

```bash
python3 scripts/tts.py refs Saves/TS_Save_125.json bb7d21
grep -rn "getDescription\|getName()\|getGMNotes" reference/mods/<slug>/
```

`tts.py refs` searches Lua, XML, `GMNotes` and `Description` together, which is
why it is the right first call before touching or deleting anything.

**Load-bearing — change with care:**

- `GUID` must be unique **among objects that can be on the table at once** — not
  across the whole file. Objects sitting in different containers routinely share
  a GUID (169 pairs in Arcs, 40 in the owner's own `TS_Save_125`) because TTS
  assigns a fresh one when a duplicate would collide on spawn, and an object's
  `States` share GUIDs by nature. Two objects at table level with the same GUID
  is the real error: `getObjectFromGUID` cannot tell them apart. `tts.py
  validate` reports that case and leaves the harmless ones alone.
  Scripts address objects by GUID, so changing one breaks any script that
  references it — run `tts.py refs <save> <guid>` before you touch it.
- `Name` determines how TTS instantiates the object. Changing it does not convert
  the object; it produces a broken one.
- `CardID` / `DeckIDs` — see below.

### Decks and card IDs

A deck's art comes from sheet images listed in `CustomDeck`, keyed by sheet
number as a string. Card IDs encode which sheet and which slot:

```
CardID = <CustomDeck sheet key> * 100 + <zero-based index on that sheet>
```

Verified in `Saves/TS_Save_125.json`: sheet `"993"` yields `99300, 99301, ...`;
sheet `"478"` yields `47812, 47811, 47810, 47809`.

Two invariants a deck must satisfy:

1. Every `CardID` in `ContainedObjects` refers to a sheet key that exists in that
   object's `CustomDeck`.
2. `DeckIDs` lists the same IDs as `ContainedObjects`, **in the same order** —
   it is the draw order. Reordering one without the other corrupts the deck.

Removing a card means removing it from *both* lists. Adding one means it must
land on a sheet with a free slot, or you add a new sheet to `CustomDeck`.

```jsonc
{
  "Name": "Deck",
  "DeckIDs": [99300, 99301, 99302],
  "CustomDeck": {
    "993": {
      "FaceURL": "https://steamusercontent-a.akamaihd.net/ugc/.../",
      "BackURL": "https://steamusercontent-a.akamaihd.net/ugc/.../",
      "NumWidth": 10, "NumHeight": 7,
      "BackIsHidden": true, "UniqueBack": false, "Type": 0
    }
  },
  "ContainedObjects": [ { "Name": "Card", "CardID": 99300, "...": "..." } ]
}
```

### Custom assets on an object

- `CustomImage` → `ImageURL`, `ImageSecondaryURL`, plus a `CustomTile` /
  `CustomToken` block controlling thickness, stackability, stretch.
- `CustomMesh` → `MeshURL`, `DiffuseURL`, `NormalURL`, `ColliderURL`,
  `MaterialIndex`, `TypeIndex`.
- `CustomDeck` → per-sheet `FaceURL` / `BackURL` as above.

All URLs resolve to files under `Mods/`. See [asset-cache.md](asset-cache.md).

## Lua and XML UI

Three fields, at both save level and object level:

- **`LuaScript`** — the source. Loaded on spawn.
- **`LuaScriptState`** — whatever `onSave()` returned, almost always a JSON
  document stored *as a string inside the JSON*, so it is double-encoded. It is
  runtime state, not code; TTS overwrites it on the next save. Don't hand-edit it
  to change behaviour — change the script.
- **`XmlUI`** — the custom UI markup
  (<https://api.tabletopsimulator.com/ui/introUI/>).

### luabundle

Global scripts from scripted mods are almost never hand-written — they are
[luabundle](https://github.com/Benjamin-Dobell/luabundle) 1.6.0 output, produced
by a developer's real source tree. The layout:

```lua
-- Bundled by luabundle {"rootModuleName":"Global.-1.lua","version":"1.6.0"}
local __bundle_require, ... -- ~1 KB runtime preamble
__bundle_register("src/Global", function(require, _LOADED, __bundle_register, __bundle_modules)
  ...the actual module source...
end)
__bundle_register("src/ArcsPlayer", function(...)
  ...
end)
return __bundle_require("Global.-1.lua")
```

`Saves/TS_Save_125.json` (Arcs) packs 26 modules into 550 KB. The module you
actually want to edit is usually `src/Global` or a named service — not the
preamble.

### Editing Lua safely

Never edit the escaped string inside the JSON by hand. Use the round-trip:

```bash
# 1. Pull the Lua out as real .lua files (one per bundled module)
python3 scripts/tts.py lua extract Saves/TS_Save_125.json -o /tmp/arcs

# 2. Edit /tmp/arcs/global/src__Global.lua in a normal editor

# 3. Write a NEW save with the edited script
python3 scripts/tts.py lua inject Saves/TS_Save_125.json /tmp/arcs/global \
    -o Saves/TS_Save_127.json
```

`extract` records each module's byte range in `_index.json` and keeps the
original bundle as `_bundle.lua`; `inject` splices edited bodies back into that
original rather than re-bundling. An unmodified round-trip is therefore
byte-identical — verified against the 550 KB Arcs bundle.

`--object GUID` does the same for a single object's script; `--list` shows
everything in a save that holds Lua without writing anything.

## Reading a save

```bash
python3 scripts/tts.py summary Saves/TS_Save_123.json          # what is this?
python3 scripts/tts.py tree    Saves/TS_Save_123.json --depth 0
python3 scripts/tts.py tree    Saves/TS_Save_123.json --filter Deck
python3 scripts/tts.py tree    Saves/TS_Save_123.json --nickname Factory
python3 scripts/tts.py get     Saves/TS_Save_123.json 'ObjectStates[38]' --no-children
```

`tree` prints a path for every object; `get` takes that path back. That pair is
how you locate a specific component in a 400-object save without loading the
file into context.

## Writing a save

Three commands generate this schema rather than asking you to type it:

```bash
python3 scripts/tts.py new        -o Saves/TS_Save_127.json --name "My Game"
python3 scripts/tts.py deck build --face <url> --back <url> --cols 10 --rows 7 \
                                  --names cards.txt -o parts/deck.json
python3 scripts/tts.py object add Saves/TS_Save_127.json parts/deck.json \
                                  -o Saves/TS_Save_128.json --at 0,1.5,0
```

- **`new`** writes an empty table with TTS's own key order, defaults and 320-char
  Lua stub.
- **`deck build`** writes a **Saved Object** holding one `DeckCustom`, with
  `CardID`, `DeckIDs` and `CustomDeck` consistent by construction.
- **`object add`** inserts a Saved Object into a save. It mints a fresh GUID for
  every object in the subtree — a GUID is per instance, so two copies of one
  Saved Object must not share one — repoints the subtree's own GUID references
  in `LuaScript`, `XmlUI`, `GMNotes` and `Description`, and declares the
  objects' component tags in the save's `ComponentTags.labels`, which is the
  list TTS's own tag UI reads from.

GUIDs are derived from the source rather than drawn at random, so building the
same thing twice gives the same file. `reference/framework/demo/build.sh` is a
worked example from empty table to loadable save.

To learn what a field does, change it by hand in TTS, save to a new number, and
read the delta:

```bash
python3 scripts/tts.py diff Saves/TS_Save_106.json Saves/TS_Save_107.json --full
```

`diff` matches objects by GUID at each scope and ignores movement below 1 mm, so
physics jitter does not report every object in the save as changed.

## Gotchas when writing JSON

- Match TTS's own formatting: `json.dumps(save, indent=2, ensure_ascii=False)`,
  no trailing newline, then C#-style float exponents. TTS loads any valid JSON,
  but anything else is reformatted on its next save, which turns a one-line edit
  into a whole-file diff. `tts.py`'s `dump_save()` does all of this — write
  through it rather than calling `json.dump` yourself.
- Preserve numeric types. TTS is strict: a float field written as `1` instead of
  `1.0` can be rejected on load. Integers stay integers — `EpochTime` is an int,
  not a float, and must not be written in E notation.
- Use `newline=""` when reading or writing Lua to files. Some bundles contain
  CRLF line endings, and Python's default universal-newline translation silently
  eats the `\r`, corrupting the script. This cost 2,883 characters in testing
  before it was caught.
- Keep `ensure_ascii=False`. Mod notes and card text contain non-ASCII
  characters, and escaping them bloats the file for no reason.
