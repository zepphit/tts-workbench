# 01 — Architecture

Where the code lives, and what that choice costs you later.

The five mods in `reference/mods/` represent three architectures. None of them
is the one this folder recommends, and the reasons are specific.

| Mod | Architecture | Global Lua | Object scripts | Deduplicated lines |
| --- | --- | --- | --- | --- |
| Almoravid | one monolith | 219 KB | 1 | 7,735 |
| Politik | logic on objects | 9.8 KB | 23 | 2,980 |
| RotLA | logic on objects + vendored engine | 93 KB | 64 | 3,032 |
| Rurik | global + tag resolution | 58 KB | 52 | 2,373 |
| Arcs | luabundle, 26 modules | 550 KB | 9 | 18,067 |

*(Line counts deduplicate `.lua` and `.xml` bodies by hash and exclude
`_bundle.lua`. See [critique.md § Method](../critique.md#method).)*

**That last column is the mod-wide total — every slot, not the Global script.**
The two differ by however much lives on objects, and quoting one as the other is
the mistake to avoid: the Global scripts alone are **2,453** lines for RotLA,
**7,697** for Almoravid and **1,834** for Rurik. Arcs' global slot is a bundle,
so it has no single Global script; its 18,067 is 38 module bodies.

---

## The monolith — Almoravid

Everything in one `LuaScript` field. 7,697 lines, one object script, no modules,
no tags. (The table above says 7,735: that is the mod total, this file plus the
38-line d6 roller.)

```lua
function getObjects()
	caowdeck = getObjectFromGUID("607a04")
	maowdeck = getObjectFromGUID("98eca0")
	    aowc1 = getObjectFromGUID("3c89b8")
```
— `reference/mods/almoravid/global/script.lua:1`

That function binds **200 distinct GUIDs to globals** in 205 calls and is invoked
from `onLoad` at line 271. There is not one `if <name> then` guard in the file.

**When a monolith is right.** A prototype under 500 lines, where everything is
in one place and you can read it top to bottom. That is genuinely most of the
owner's work.

**When it stops being right.** Almoravid is the failure mode: 7,697 lines with
925 `setPosition`/`setPositionSmooth` calls and 538 lines mentioning
`takeObject` (C2, C9). There is no seam to test, no seam to reuse, and the
setup routine is a single straight line of statements whose order is load-bearing.

**Verdict.** Fine below ~500 lines. Above that, the cost is not the size — it is
that a monolith has nowhere to put a *table*. Almoravid's 925 coordinates should
have been data; instead each one is a statement.

---

## Logic on objects — Politik and RotLA

Behaviour attached to the components it governs. Intuitive, and it scales badly
in exactly one way: duplication.

RotLA's supply bags carry a 997-character script in **51 byte-identical copies**
(`reference/mods/rotla/objects/54bdb7/script.lua` and 50 siblings), each opening
with the same guard:

```lua
function onObjectLeaveContainer(bag, obj)
    if bag~=self then return end
```
— `reference/mods/rotla/objects/54bdb7/script.lua:2`

Note the spacing: `bag~=self`, no spaces. Grep for `bag ~= self` and you find
nothing.

Politik does the same with markup: six objects share a byte-identical
1,614-character `XmlUI` and a byte-identical 4,304-character script —
`1efc34`, `5cfd6c`, `f0237c`, `1c1690`, `241e2d`, `2b84d7`, all nicknamed
`[E9E2B6]Resources`.

Rurik's version is subtler and worse, because the copies are *nearly* identical:
24 inventory-bag scripts, 20 of one variant and 4 of another, differing only in
three numbers.

```lua
        position = {0,-1,0},
        height = 500,
        width = 500,
```
— `reference/mods/rurik/objects/064e16/script.lua:41`

The 20-copy variant has `{0,0,0}` and `220`. That is a config table wearing a
disguise.

**Verdict.** Object scripts are correct for behaviour that is genuinely local and
genuinely singular — RotLA's sorting bag (`93c2a0`), its Flex Table Control
(`bd69bd`). The moment a script exists in two copies it is the wrong shape: the
variation belongs in **tags and a config table**, dispatched from one place
(C6, C7). See [06](06-objects-tags-containers.md).

### The vendored-engine boundary

RotLA is a paste of a third-party engine with the upgrade line marked in a
comment:

```lua
---VERSION 2.96, copy and paste everything below this line to update!
```
— `reference/mods/rotla/global/script.lua:258`

Lines 1–257 are the mod's own configuration; everything below is 18Engine v2.96
and will be overwritten wholesale on the next upgrade. Eighty-two lines further
down, the file marks its other half:

```lua
-----YOU DO NOT NEED TO EDIT ANYTHING BELOW THIS LINE-----
```
— `reference/mods/rotla/global/script.lua:340`

**If you edit RotLA, edit above line 258 or accept that the change is
temporary.** This is pre-flight check 2 for any mod surgery: look for an upstream
boundary before touching anything.

---

## luabundle — Arcs

[luabundle](https://github.com/Benjamin-Dobell/luabundle) output from a private
source tree: a ~1 KB runtime preamble, then one `__bundle_register` call per
module, then `return __bundle_require("Global.-1.lua")`.

This is the only architecture here with real modules, and the corpus lets you
read them as files. Arcs' Global bundle alone holds 26:

```
reference/mods/arcs/global/
├── _bundle.lua                     the original 550 KB field — never grep this
├── _index.json                     byte ranges, for lossless re-splicing
├── src__Global.lua                 module src/Global
├── src__ArcsPlayer.lua             module src/ArcsPlayer
└── ...
```

**The cost is C5.** luabundle inlines every dependency into every bundle, so a
module required by both Global and an object script is compiled into both. Arcs
ships **16 modules in two to four slots each**:

| Module | Copies | Slots |
| --- | --- | --- |
| `src/ActionCards`, `src/ArcsPlayer`, `src/GUIDs`, `src/LOG`, `src/Resource`, `src/Supplies` | 4 each | `global`, `0289cb`, `6e21fe`, `7299d7` |
| `src/AmbitionMarkers` | 3 | `global`, `0289cb`, `6e21fe` |
| `src/InitiativeMarker` | 3 | `global`, `6e21fe`, `7299d7` |
| `src/BaseGame`, `src/Campaign`, `src/Counters`, `src/Merchant`, `src/SetupControl` | 2 each | `global`, `7299d7` |
| `src/Control`, `src/RoundManager` | 2 each | `global`, `6e21fe` |
| `src/DiceCounter` | 2 | `069307`, `4798a5` |

That is 6 + 1 + 1 + 5 + 2 + 1 = **16 modules**, compiled into **46 copies** across
six slots (`global`, `0289cb`, `6e21fe`, `7299d7`, `069307`, `4798a5`).

All copies are currently byte-identical — `manifest.json`'s `shared_modules`
records each one's sha256, and `tts.py validate` escalates to `drifted-module`
the moment two stop matching. You can see the duplication with one command:

```bash
python3 scripts/tts.py refs Mods/Workshop/3683918449.json bb7d21
```

`reach_board_GUID = "bb7d21"` comes back **four times** — once in Global and once
in each of `0289cb`, `6e21fe`, `7299d7`. Edit one and three keep the old value,
silently.

**Verdict.** Modules are right; compiling them into many objects is not. Keep
**one bundle** and make object scripts thin enough to need no library at all.

---

## The central fork: tags or GUIDs

This is the decision that determines whether your setup survives editing.

**GUIDs.** Minted per object instance. Duplicate a component, delete and re-add
one, or take one out of a bag, and you get a new GUID. Every literal referring to
the old one silently resolves to nil.

It is live in the corpus today:

```lua
artifact_deck_GUID = "9c97c9"
reach_feature_deck_GUID = "a5e8a7"
windfall_deck_Guid = "8cfcb9"
```
— `reference/mods/arcs/global/src__GUIDs.lua:11`

All three match **no object** in `Saves/TS_Save_125.json`. `tts.py validate`
reports them as errors. Almoravid is worse: 54 of its `getObjectFromGUID`
literals resolve only to objects *inside containers*, where the call returns nil
until something takes them out.

**Tags.** Typed by you, survive duplication, and are queryable:
`getObjectsWithTag("supply")`, `obj.hasTag("supply")`. Rurik is the mod that
committed to this — 86 tag call sites, only 4 `getObjectFromGUID` in its entire
Global script — and it builds a cache:

```lua
local function rebuildTagCache()
    TAG_MULTI = {}
    for _, o in ipairs(getAllObjects()) do
        local tags = o.getTags()
```
— `reference/mods/rurik/global/script.lua:34`

Rurik's version has two flaws worth not copying. `rebuildTagCache` is invoked by
hand at six sites and is never invalidated on spawn or destroy, so a stale cache
is always possible; and `waitByTag` rebuilds the **entire** cache on every frame
of its wait loop:

```lua
function waitByTag(tag, timeoutSeconds)
    local start = Time.time
    while true do
        rebuildTagCache()
```
— `reference/mods/rurik/global/script.lua:53`

That is a full `getAllObjects()` sweep per frame. The timeout and the loud
failure that follows it, though, are exactly right — see
[02](02-lifecycle.md).

Arcs half-discovered the same lesson from the other direction: it keeps a central
`src/GUIDs` registry but **overwrites** `action_deck_GUID` at runtime rather than
trusting the literal.

**Verdict.** Anything you type is a role name. A GUID is a seed, never an
identity (C1). `ttslib`'s `registry` module is this idea with cache invalidation
and a boot-time manifest that reports a missing role **once, loudly**, instead of
as a nil dereference mid-setup.

---

## The layout this folder recommends

```
src/
├── 00-config.lua       component roles, layout tables, constants — data only
├── 10-<feature>.lua    one file per feature
└── 99-Global.lua       thin: wires events and buttons, nothing else
```

TTS has no `require`, so a build is a concatenation in load order — which is
what the numeric prefixes are for. `ttslib` ships the same way
([framework.md](../framework.md)):

```bash
cat reference/framework/ttslib/*.lua src/*.lua > /tmp/global.lua
python3 scripts/tts.py lua inject Saves/TS_Save_125.json /tmp/global.lua -o Saves/TS_Save_127.json
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

`lua inject` takes a *file*, or a slot directory that `lua extract` wrote (one
carrying an `_index.json`); it will not concatenate a `src/` tree for you.

The round-trip is verified byte-identical, so the save is an artifact and the
files are the truth (C10). For live iteration while TTS is running, TTS's
External Editor API is the supported path — read
[`reference/api/externaleditorapi.md`](../../reference/api/externaleditorapi.md)
rather than assuming the protocol.

**Next:** [02 — Lifecycle](02-lifecycle.md).
