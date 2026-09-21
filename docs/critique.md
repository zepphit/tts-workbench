# What five shipped mods get wrong

Five complex scripted mods were mined into `reference/mods/` as a source corpus.
They are references for their **thoroughness**, not their design: between them
they use object scripts, XML UI, snap points, component tags, states, zones,
turns and context menus far more heavily than any prototype in this folder. They
are also production code carrying real defects and real structural debt.

This document is the catalogue. Each item is a verified defect or structural
flaw, and each one motivates a piece of the house framework (`ttslib`, see
[framework.md](framework.md)). The point is not "here is how Arcs does it" — it
is "here is how we will do it, and here is the evidence from five shipped mods
for why."

| Mod | Slug | Architecture |
| --- | --- | --- |
| Politik | `politik` | logic on objects, object-attached XML UI |
| Railways of the Lost Atlas | `rotla` | logic on objects, vendored 18Engine |
| Arcs: Celestial Edition | `arcs` | luabundle, 26 modules across 10 slots |
| Rurik: Second Edition | `rurik` | global XML panels, tag-based resolution |
| Almoravid | `almoravid` | one 219 KB monolith |

**Everything below was re-derived from the corpus**, not taken on faith. Every
claim cites a file and line you can open. Where an earlier draft of this
analysis was wrong, the correction is recorded in
[Corrections](#corrections-to-earlier-figures) rather than quietly dropped.

To check any of it yourself:

```bash
grep -rn "getObjectFromGUID" reference/mods/almoravid/global/script.lua | head
python3 scripts/tts.py validate Mods/Workshop/2804149704.json
```

---

## C1 — Objects addressed by hardcoded GUID

**Evidence.** Almoravid opens with a function that does nothing but bind GUIDs
to globals — `reference/mods/almoravid/global/script.lua:1`:

```lua
function getObjects()
	caowdeck = getObjectFromGUID("607a04")
	maowdeck = getObjectFromGUID("98eca0")
	    aowc1 = getObjectFromGUID("3c89b8")
```

It runs **205 `getObjectFromGUID` calls binding 200 distinct GUID literals**, and
is called from `onLoad()` at line 271. The file contains **zero** `if <name> then`
guards: nothing checks whether any of the 200 resolved.

RotLA takes the same approach one level up, as a literal table —
`reference/mods/rotla/global/script.lua:18`:

```lua
gameEntities = {
    OTHER_ACTORS = {
            ['BANK'] = {
                moneyLabelGUID = 'bf2867',
            },
```

That block runs 237 lines and holds **119 GUID literals**; the script as a whole
holds 252 (198 unique). Politik's Global has none, but its object scripts carry
**73 unique GUID literals** between them.

**Consequence.** A GUID is minted per object instance. Duplicating a component,
deleting and re-adding one, or taking one out of a bag produces a new GUID and
silently breaks every reference to it. Because Almoravid never guards, a single
stale GUID makes setup die part-way through, leaving the table half-placed with
no error naming the cause.

This is not hypothetical. `tts.py validate` finds it live in both mods today:

- `Saves/TS_Save_125.json` (Arcs): three GUIDs in `src/GUIDs` — `8cfcb9`,
  `9c97c9`, `a5e8a7` — match **no object in the save**.
- `Mods/Workshop/2804149704.json` (Almoravid): **54** `getObjectFromGUID`
  literals resolve only to objects *inside containers*, where the call returns
  nil until something takes them out.

**The framework's answer — `registry` (C1).** Objects are resolved by **role
tag**, not GUID: `reg.one("supply.wood")`, `reg.all("card")`. A declarative
manifest lists the roles a game expects, so a missing one is reported once,
loudly, at boot — not as a nil dereference in the middle of setup. GUIDs become
a cache, never an identity. Arcs half-discovered this already: it overwrites
`action_deck_GUID` at runtime rather than trusting the literal.

---

## C2 — Absolute world coordinates

**Evidence.** Almoravid's Global makes **925 `setPosition` / `setPositionSmooth`
calls** and contains **zero calls to `positionToWorld`**. Every destination is an
absolute table-space coordinate, anchored to a board that happens to sit at a
fixed transform.

For contrast, across the same corpus:

| Mod | `positionToWorld` calls |
| --- | --- |
| Arcs | 21 *(deduplicated; 65 raw module copies)* |
| Rurik | 4 |
| Politik | 1 |
| RotLA | 1 |
| **Almoravid** | **0** |

*Arcs is the only mod here with a bundle, so it is the only row the two rules in
[§ Method](#method) apply to: 21 is the count over its 38 deduplicated module
bodies, 65 the same count across every bundle slot, and 130 what you get if you
also count `_bundle.lua` — double-counting each slot. The other three mods have
no bundle, so their figures are unaffected.*

**Consequence.** Move the board, rescale it, or rebuild the table and all 925
placements are wrong at once. There is no transform to adjust — each coordinate
must be re-authored by hand.

**The framework's answer — `layout` (C2).** Placement is anchor-relative: named
spaces are written in **board-local** coordinates and resolved through
`anchor.positionToWorld()`. Move the board and everything follows. Y becomes an
explicit stacking-layer constant instead of a magic number repeated in 925
places.

---

## C3 — Button state addressed by positional index

**Evidence.** Arcs' `src/SetupControl` makes 32 `createButton` calls and 42
`editButton` calls, addressing buttons by their creation order. Its own author
left a warning at `reference/mods/arcs/global/src__SetupControl.lua:743`:

```lua
    -- must add buttons in the order of the actual indices !!!!!!!!!! lowest in here must have highest index
```

RotLA hit the same wall and solved it by hand-maintaining a counter —
`reference/mods/rotla/global/script.lua:1465`:

```lua
            local btnIndex = 0
            ...
                halfPayIndex = btnIndex
                btnIndex = btnIndex+1
            ...
                company.changeSizeButtonIndex = btnIndex
                btnIndex = btnIndex+1
```

The index base is **0**, confirmed by the API itself
([`reference/api/object.md`](../reference/api/object.md), `editButton`):
*"Indexes start at 0. The first button on any given Object has an index of 0, the
next button on it has an index of 1, etc. Each Object has its own indexes."*

**Consequence.** Inserting one `createButton` shifts every later index, silently.
Nothing errors — the wrong button simply gets edited. The Arcs comment is an
author telling the next reader that the code is load-bearing on statement order.

**The framework's answer — `ui` (C3).** Buttons are named, not numbered:
`ui.button(obj, "total", {...})` keeps the name→index map, so
`ui.set("total", {label = …})` survives insertions anywhere in the file. The
index arithmetic still happens; it just stops being the author's problem.

---

## C4 — State scattered across ad-hoc channels

**Evidence, three different channels in three mods.**

*A field meant for humans, used as a flag.* Arcs stores whether a game is in
progress in an object's **Description** —
`reference/mods/arcs/global/src__Global.lua:2411`:

```lua
    reach_board.setDescription("in progress")
```

and branches its entire load path on reading it back, at line 2521:

```lua
    if (reach_board.getDescription() == "in progress") then
```

*A kill switch, because saved state overrides edited source.* RotLA —
`reference/mods/rotla/global/script.lua:6`:

```lua
USE_SAVES = true
--set this to false while editing your mod or treasuries will persist.
--set this to true, copy in the script, use "save and play" from the modding menu, and then actually save your mod to enable saves (TTS is dumb).
--WARNING: If you intend on modifying any gameOptions, turn use_saves to false first.
```

*Fossils that nothing reads.* Politik's resource objects save with
`onSave() return JSON.encode(data) end`, serialising the whole table blindly. The
persisted `LuaScriptState` of object `1efc34` contains:

```json
{ "max1": 5, "max2": 5, "max3": 5,
  "statName1": "Stat 1", "statName2": "Stat 2", "statName3": "Stat 3",
  "val1": 0, "val2": 0, "val3": 0, ... }
```

`max1`, `max2`, `max3`, `statName1`, `statName2` and `statName3` appear **nowhere
in the object's script**. They are leftovers from an older version, re-saved
forever because `onSave` serialises whatever `data` happens to hold.

**Consequence.** No schema, no defaults, no migration path. State lives wherever
was convenient — `Description`, `GMNotes`, component tags, a global boolean —
so nothing can validate it, and stale keys persist indefinitely. RotLA needed a
documented kill switch because there is no way to say "this saved value is from
an older schema, drop it."

**The framework's answer — `store` (C4).** One state object per script, with
declared defaults and a `version`, serialised by a single generated `onSave`.
Unknown keys are dropped on load; migrations run by version number. Nothing else
persists state — no `Description` flags, no `GMNotes` payloads.

---

## C5 — Shared code duplicated per bundle

**Evidence.** luabundle inlines every dependency into every bundle, so a module
used by both Global and an object script is compiled into both. In the Arcs mod,
**16 modules exist in two to four slots each**:

| Module | Slots |
| --- | --- |
| `src/GUIDs` | `global`, `0289cb`, `6e21fe`, `7299d7` |
| `src/LOG` | `global`, `0289cb`, `6e21fe`, `7299d7` |
| `src/ArcsPlayer` | `global`, `0289cb`, `6e21fe`, `7299d7` |
| `src/Resource`, `src/Supplies`, `src/ActionCards` | 4 slots each |
| `src/BaseGame`, `src/Campaign`, `src/Counters`, `src/Merchant`, `src/SetupControl` | `global`, `7299d7` |
| `src/Control`, `src/RoundManager`, `src/InitiativeMarker`, `src/AmbitionMarkers` | 2–3 slots |
| `src/DiceCounter` | `069307`, `4798a5` |

All copies are **currently byte-identical**. That is the whole danger: they are
identical until someone edits one.

**Consequence.** Editing `src/GUIDs` in the Global bundle leaves three other
copies resolving the old values, with no error and no warning. The mod half-works
in a way that is very hard to diagnose.

**Tooling.** This is why `tts.py` checks it. `lua extract` prints a warning
listing every module that appears in more than one slot; `validate` reports them
as `duplicated-module`, and escalates to `drifted-module` (an ERROR) the moment
two copies stop matching.

**The framework's answer — architectural rule 1.** One bundle. Object scripts
stay thin, delegating to Global in a line or two; shared libraries are never
compiled into many objects.

---

## C6 — Copy-paste component scripts

**Evidence.** RotLA's supply bags carry a 997-character script. It exists in
**51 byte-identical copies** — `reference/mods/rotla/objects/54bdb7/script.lua`
and 50 siblings. Two further groups of 4 identical copies sit beside them.

Politik does the same with markup rather than code: **6 objects share a
byte-identical 1,614-character `XmlUI`** (`1efc34`, `5cfd6c`, `f0237c`,
`1c1690`, `241e2d`, `2b84d7`).

**Consequence.** A one-line fix is a 51-site edit. Nothing guarantees the copies
stay in step, the behaviour cannot be versioned, and it cannot be tested once and
trusted everywhere.

**The framework's answer — `events` (C6) and architectural rule 3.** Component
variation lives in **tags and a config table**, not in 51 copies of a file.
Behaviour is registered once against a tag —
`events.on("enterContainer", "supply", handler)` — and every object carrying that
tag gets it.

---

## C7 — Broadcast events filtered per object

**Evidence.** TTS delivers container events to *every* script that defines the
handler, so each of RotLA's 51+ bag scripts opens by discarding events that are
not about itself — `reference/mods/rotla/objects/54bdb7/script.lua:2`:

```lua
--CHILD BAG
function onObjectLeaveContainer(bag, obj)
    if bag~=self then return end
```

**55 scripts** in RotLA carry that guard, **106 occurrences** in total — two per
script, one for enter and one for leave.

**Consequence.** Every container event in the game is dispatched to 55 scripts,
54 of which immediately return. The cost is `O(objects × events)`. Worse, the
guard is load-bearing boilerplate: omit it in one script and that script reacts
to every other bag's contents, corrupting state silently.

**The framework's answer — `events` (C7).** One central dispatcher subscribes
once and routes by tag. Individual objects never see events that are not theirs,
so the guard cannot be forgotten.

---

## C8 — Blanket `pcall` hiding real bugs

**Evidence.** Arcs wraps errors away at scale: **255 `pcall` call sites across 38
deduplicated modules and 18,067 lines** — roughly one every 71 lines. (256
counting textual mentions; the odd one is a comment at
`reference/mods/arcs/global/src__SheetsSender.lua:330`.)

One of them hides a feature that has never worked. At
`reference/mods/arcs/global/src__Global.lua:231`:

```lua
          if not draw_bottom_patched[guid] then
            pcall(function()
              obj.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
            end)
            draw_bottom_patched[guid] = true
          end
```

`ActionCards` is not in scope here. The binding
`local ActionCards = require("src/ActionCards")` sits at **line 268** — 35 lines
*below* this use — and the name appears nowhere in lines 1–231. So at line 233
`ActionCards` is a nil global, `ActionCards.draw_bottom` raises, the `pcall`
swallows it, and **line 235 marks the object patched anyway**, so it is never
retried.

The same call made from correct scope works fine — line **2641** calls
`ActionCards.draw_bottom` unwrapped and succeeds, and it is the model to copy: it
tests `if action_deck then` first and logs a `LOG.WARNING` on the else branch, so
a missing deck is reported rather than swallowed. The `pcall` is the only reason
nobody noticed the broken one.

**The defect occurs twice.** `:898-901` is the same shape again, in the
per-object patcher:

```lua
    if draw_bottom_patched[guid] then return end
    pcall(function()
      object.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
    end)
    draw_bottom_patched[guid] = true
```

Swallowed error, then the "patched" flag set unconditionally on the next line —
so whatever happened inside the `pcall`, the object is marked done and never
retried. The early `return` at `:897` then makes that permanent for the rest of
the session. Two of the three `ActionCards.draw_bottom` call sites are wrapped
this way; only the guarded one at `:2641` is not.

**Consequence.** An error becomes a permanent silent no-op. The mod degrades
instead of reporting, and the failure is invisible in the one place that would
have named it.

**The framework's answer — `log` (C8) and architectural rule 4.** Levelled
logging with a build-time level, plus `assert`/`expect` helpers that **fail
loudly in development** and degrade only at declared boundaries. A `pcall`
becomes a deliberate statement about a specific untrusted call, not ambient
padding.

---

## C9 — Ad-hoc async

**Evidence.** Almoravid hand-writes its setup as a long run of
`takeObject` → `Wait.frames` → `setPositionSmooth` blocks: **538 lines mention
`takeObject`**, feeding the 925 positioning calls from C2.

Arcs, at the other extreme, invents good abstractions and then buries them — a
cancellable keyed wait registry, a bounded retry, and a 1.25-second duplicate-event
suppressor, each written once, inline, unnamed and unreusable.

**Consequence.** Every author re-derives TTS's spawn-timing rules from scratch.
Almoravid's version is 538 copies of the same three-line idiom; Arcs' version is
better but cannot be reached from anywhere except the function it lives in.

**The framework's answer — `async` (C9).** The good patterns, extracted and named
once: `async.afterFrames(n, fn)`, `async.whenSettled(obj, fn)` (the
`isSmoothMoving`/`resting` guard), `async.retry(fn, {times, delay})`,
`async.keyed(key, …)` cancellable waits, `async.debounce(key, window)`.

---

## C10 — No source tree, no build, no tests

**Evidence.** RotLA is a vendored paste of a third-party engine, with the upgrade
boundary marked in a comment — `reference/mods/rotla/global/script.lua:258`:

```lua
---VERSION 2.96, copy and paste everything below this line to update!
```

Arcs is luabundle output from a private repository: a runtime preamble followed
by 26 `__bundle_register` calls. The source tree that produced it is not in the
mod.

**Consequence.** Any edit below RotLA's line 258 is destroyed by the next engine
upgrade, and nothing in the file prevents it. Neither mod can be diffed or tested
in place: the unit of change is a 93 KB or 550 KB string inside a JSON field.

**The framework's answer — architectural rule 5.** Source lives in files under
`src/`, built into the save with `tts.py lua inject`. The round-trip is verified
byte-identical, so the save is an artifact and the files are the truth. TTS's
External Editor API is the live iteration path — see
[`reference/api/externaleditorapi.md`](../reference/api/externaleditorapi.md).

---

## Live bugs, as teaching material

Five bugs sitting in these mods right now. Each is a named trap for
[`cookbook/10-antipatterns.md`](cookbook/10-antipatterns.md).

**1. A malformed colour that renders nothing.** Politik's camera buttons —
`reference/mods/politik/global/script.lua:179`:

```lua
{name = "Blue", color = "#1E87FFF", yOffset = 0, onClick = "onCameraBlueClick", playerColor = "Blue"},
```

`#1E87FFF` is **seven** hex digits. Every sibling entry has six. *(An earlier
draft of this analysis also claimed `createCameraButtons` is never called. That
is wrong — it is bound to a button at `objects/f782d2/script.lua:15` via
`click_function = "refreshCameraButtons"`, which calls it at line 105.)*

**2. A cap that never fires.** Politik's stat increment —
`reference/mods/politik/objects/1c1690/script.lua:76`:

```lua
function plus(player, value, id)
  local valId = getValId(id)
  ...
  if data[maxId] ~= nil then
    data[valId] = math.min(data[valId], data[maxId])
  end
```

`maxId` is never declared — it appears only on lines 82 and 83. It is therefore a
nil global, and `data[nil]` **reads** as nil rather than raising, so the
condition is always false and the maximum is never applied. Reading a table with
a nil key is legal Lua; only writing one errors. That is precisely why this
survived.

**3. Handlers registered in the wrong environment.** Rurik's advisor payment
panel (`reference/mods/rurik/objects/8e05ed/script.lua`) creates 4 buttons with:

```lua
            function_owner = Global, -- IMPORTANT: functions live on Global environment
```

but defines the handlers in **its own** script:

```lua
-- Global-owned handlers (since function_owner = Global)
function AdvisorPayPanel_cancel(_, playerColor, alt_click)
```

`AdvisorPayPanel_cancel` and `AdvisorPayPanel_pay` appear 0 times in Rurik's
Global script. `function_owner = Global` tells TTS to look the click function up
in *Global's* environment, so these buttons are inert. Global builds its own
working panel separately via `AdvisorPay.buildPaymentPanel` (`global/script.lua:156`).

**4. A handler defined twice.** RotLA declares `onPlayerChangeColor` at
`global/script.lua:560` **and** at `global/script.lua:2336`. In Lua the second
assignment silently wins; the first body is dead code.

**5. Case-sensitivity turning a warning into a crash.** Arcs'
`src/ArcsPlayer:328` and `:346`:

```lua
            Log.warning("Power bonus zone not found: " .. zone_info.guid)
```

`src/ArcsPlayer:2` binds `local Log = require("src/LOG")`, and `src/LOG` exports
only uppercase names — `LOG.TRACE`, `LOG.DEBUG`, `LOG.INFO`, `LOG.WARNING`,
`LOG.ERROR`. `Log.warning` is nil, so calling it raises. A missing-zone *warning*
becomes a hard error.

---

## Corrections to earlier figures

The numbers in the original brief were produced by a first scan. Re-deriving
them from the corpus corrected six:

| Claim | Corrected |
| --- | --- |
| Politik's XML UI is on 7 objects | **6** objects, byte-identical at 1,614 chars. The seventh holder was TTS's 81-char default comment stub at save level, present in four of the five mods and not UI at all. |
| Arcs: 62 deduplicated `Global.call` sites | **60 real call sites**, over **13 distinct names**. 62 textual `Global.call(` occurrences, 2 of them inside comments; 63 counts one further comment mention. Superseded this file's own earlier "63" — see [mods/README.md § Corrections](mods/README.md#corrections-to-earlier-figures). |
| Arcs: 255 `pcall` sites, one per ~15 lines | **255** call sites (256 textual mentions), one per **71** lines across 18,067 deduplicated lines. |
| Arcs' `ActionCards` `require` sits 60 lines below its use | **35** lines below (use at 233, binding at 268). |
| Politik's `createCameraButtons` is never called | **It is called** — see live bug 1. The malformed hex colour is real; the dead-code claim is not. |
| Rurik `8e05ed` leaves six buttons inert | **4** `createButton` calls. |

`editButton`'s index base was listed in the brief as unresolved, to be settled by
testing in TTS. It did not need a test: the official API documentation states it
plainly, and it is **0-based** (C3). Rurik's `index = 1` call sites are editing
the second button or are simply wrong — worth checking per call site, not a
reason to doubt the base.

One question from the brief remains genuinely open: whether TTS matches
component tags **case-insensitively**. Nothing in the corpus or the API docs
settles it, so it still needs a test in TTS.

## Method

Counts come from `reference/mods/`, extracted by `tts.py corpus` and verified
byte-identical against the mod JSON. Two rules matter when re-deriving them:

- **Exclude `_bundle.lua`.** Each bundled slot is written out both as individual
  modules and as the original concatenated bundle. Counting both double-counts
  everything in that slot.
- **Deduplicate module bodies by hash before counting anything about Arcs.** Its
  16 shared modules are compiled into 2–4 slots each, so a naive grep across all
  slots inflates every Arcs figure — which is how the brief's `Global.call` count
  came out at 114 before deduplication against a true 60.

Both rules apply to `.xml` as well as `.lua`: Politik's six `ui.xml` holders are
byte-identical, so they count once. Applied together — exclude `_bundle.lua`,
deduplicate `.lua` and `.xml` by sha256 — they reproduce every line total in
[cookbook/01-architecture.md](cookbook/01-architecture.md) exactly.

One reading to fix before quoting a count: **a call site is not a textual
mention.** Grepping a bare name also matches comments and prose. Where the two
differ this folder quotes the call-site figure and names the other, as with Arcs'
255 `pcall` sites against 256 mentions.
