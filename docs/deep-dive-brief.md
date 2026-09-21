# Brief: TTS reference deep-dive — corpus, critique, house framework, tooling

You are implementing this in `/Users/artur/Library/Tabletop Simulator`, the live
Tabletop Simulator data directory on macOS. **Read its `CLAUDE.md` first** — its
six rules are binding and this brief assumes them. There is no git here and no
undo: an overwrite is unrecoverable.

## Status

| Phase | State |
| --- | --- |
| 1 — Extraction and safety tooling | **Done** (2026-09-20). See [Phase 1](#phase-1--extraction-and-safety-tooling-scriptsttspy--done). |
| 2 — Vendored API reference | **Done** (2026-09-20). See [Phase 2](#phase-2--vendored-api-reference--done). |
| 3 — Documentation | **Done** (2026-09-20). See [Phase 3](#phase-3--documentation--done). |
| 4 — Build `ttslib` | **Done** (2026-09-21). See [Phase 4](#phase-4--build-ttslib--done). |
| 5 — Skills and agent | **Done** (2026-09-21). See [Phase 5](#phase-5--skills-and-agent--done). |
| 6 — Authoring commands and the demo save | **Done** (2026-09-21), except the one step that needs TTS. See [Phase 6](#phase-6--authoring-commands-and-the-demo-save--done). |

**All six phases are delivered.** One verification step remains and cannot be
done from here: **loading `Saves/TS_Save_126.json` in TTS** (verification item 4
below). Everything checkable outside TTS has been checked.

> **Audited 2026-09-21 — read [`review-2026-09-21.md`](review-2026-09-21.md)
> before working on any of this.** The infrastructure claims above all hold up
> under first-hand re-running, and that file records what was verified so it
> need not be redone. Where a figure in this brief disagrees with that review,
> the review is right.
>
> **The review's work order is now complete — all eleven steps, 2026-09-21.**
> Six runtime bugs in `ttslib` and its demo are fixed with a regression case
> each, two missing guards are in `tts.py`, and the documentation figures have
> been re-derived and corrected. `Saves/TS_Save_126.json` was rebuilt from the
> corrected source (twice: once for the `SLOTS` fix, once after the module
> headers changed) and is in sync with it. The suites stand at **53 cases / 155
> checks** and **20 / 54**; `selftest` round-trips every file, 0 differ.
>
> **What a reader of this brief should carry forward:**
>
> - **The counting rule is wider than the critique's § Method stated.** Dedup by
>   sha256 covers `.xml` as well as `.lua`. With that, all five line totals in
>   `cookbook/01-architecture.md` reproduce exactly. A count in this brief that
>   predates the rule may be wrong by the amount of one duplicated `ui.xml`.
> - **A call site is not a textual mention**, and this brief quotes some of each.
>   Arcs has 255 `pcall` call sites against 256 mentions, and **60** real
>   `Global.call` sites against 62 textual and 63 counting a comment — this
>   brief's "63" at the end of Phase 1 is superseded.
> - **A mod's line total is not its Global script's length.** Quoting one as the
>   other was the most systematic error the audit found, across ~11 sites.
> - **Numbers that track a moving target are no longer written down.** The
>   `ttslib` line counts moved three times in one work order; the text now names
>   `wc -l` as the authority instead. Do not reintroduce them here.
>
> One thing the review found that this brief cannot settle, and neither can the
> corpus: whether `createButton`'s `position` is measured before or after the
> object's own `scale`. It is **open question 4** in
> [`cookbook/10-antipatterns.md`](cookbook/10-antipatterns.md#open-questions-test-these-in-tts),
> with a two-minute test, and it is answered by the same TTS session that
> answers verification item 4 below.

**Three findings from phase 1 change what later phases should assume.** They are
verified against the corpus and the files on disk, not inferred:

1. **Saves are 2-space pretty-printed JSON, not single-line.** `CLAUDE.md` and
   `docs/save-format.md` both said single-line; both are now corrected. TTS is a
   C# program, so it writes float exponents as `1E+07` / `2.24779573E-08` and
   switches to scientific notation at a decimal exponent of ≤ -5 or ≥ 7 (.NET
   "G7"), where Python only switches at 1e16. `tts.py`'s `dump_save()` reproduces
   this exactly — `tts.py selftest` round-trips every save and mod in the
   folder byte-identically. **Anything that writes a save must go through
   `dump_save()`**, or TTS reformats the whole file on its next save.
2. **GUIDs are unique per scope, not per file.** `save-format.md` claimed unique
   across the entire save. In fact objects in different containers routinely
   share a GUID — 169 pairs in Arcs, 40 in the owner's own `TS_Save_125` — and
   `States` share them by nature. Zero of the five mods and zero of the owner's
   saves have a collision at *table* level, which is the case that actually
   breaks `getObjectFromGUID`. Corrected in `save-format.md`.
3. **A card inside a deck carries a stale `CustomDeck` key.** Only the deck's own
   `CustomDeck` is authoritative. Arcs' `SILVER TONGUES` is `CardID` 97007 in a
   deck keyed `970` while still carrying its own `CustomDeck` keyed `364`.
   Checking a contained card against its own sheet map reports hundreds of
   non-problems. This belongs in `docs/cookbook/09-decks-cards.md`.

## Why this work exists

The folder has good format documentation (`docs/save-format.md`,
`docs/asset-cache.md`) and a read-mostly CLI (`scripts/tts.py`), but no
knowledge of how scripted mods are actually built, and no Claude Code skills or
agents.

The owner designs their own board games here. The gap is measurable: their
prototypes (`Saves/TS_Save_111.json` "playtest_final_3",
`Saves/ProjStdwFinal/TS_Save_22.json`) carry TTS's 320-char default Lua stub,
zero object scripts, zero snap points, zero component tags, zero object States.
The five reference mods use all of it heavily.

Your job: mine five complex scripted mods into a durable asset — a greppable
source corpus, a vendored API reference, a **critique** of how those mods are
built, an **opinionated house framework** that fixes what they get wrong, three
skills and one lookup agent.

**The mods are references for their thoroughness, not their design.** All five
are production mods carrying real defects and real structural debt, catalogued
below. The flagship output is not "here is how Arcs does it" but "here is how we
will do it, and here is the evidence from five shipped mods for why." Recipes
cite the mods; the framework supersedes them. Be critical. Where a mod is wrong,
say so in the documentation and show the better way.

## The five mods

Numbers below came from a read-only scan; regenerate any of them with
`python3 scripts/tts.py summary <path>` and
`python3 scripts/tts.py lua extract <path> --list`.

| Mod | `Mods/Workshop/<id>.json` | Global Lua | Obj scripts | XML UI | Teaches |
| --- | --- | --- | --- | --- | --- |
| Politik | 3460664356 | 9.8 KB | 23 | 9.8 KB on 7 objects | object-attached XML UI: `Defaults`/`class`, one handler + id-suffix dispatch, 45×`UI.setAttribute`, runtime `setXml`, per-colour cameras |
| Railways of the Lost Atlas | 3026289764 | 93 KB | 64 | — | container tracking (55 per-object listeners), self-labelling supply bags, `GMNotes` back-pointers, closure handlers via `setVar` |
| Arcs: Celestial | 3683918449 | 550 KB / 26 modules | 9 (Setup 257 KB, Control 149 KB) | — | luabundle architecture, a 13-function `Global.call` bus, central `src/GUIDs`, zone-routed scoring, context menus, turns |
| Rurik 2E | 3663650077 | 58 KB | 52 | 3.7 KB global | global XML panels, `show`/`hide`, coroutine boot, **tags instead of GUIDs**, `Global.call` proxy pattern |
| Almoravid | 2804149704 | 219 KB monolith | 1 | — | bulk programmatic setup: 537 identical `takeObject`→`Wait.frames`→`setPositionSmooth` blocks, 925 literal coordinates |

Three architectures are represented: monolith (Almoravid), logic-on-objects
(Politik, RotLA), bundled modules (Arcs).

## The critique — what these mods get wrong

This is the spine of the work. Each item is a verified defect or structural
flaw, and each motivates a piece of the framework.

| # | Problem | Evidence | Consequence |
| --- | --- | --- | --- |
| C1 | **Objects addressed by hardcoded GUID** | Almoravid binds 200 GUIDs in one `getObjects()`; RotLA embeds ~119 in `gameEntities`; Politik scatters literals across every script | Duplicating or re-adding any object mints a new GUID and silently breaks references. Almoravid has no `if obj then` guard anywhere, so setup dies half-placed |
| C2 | **Absolute world coordinates** | Almoravid: 925 literal `{x,y,z}` triples, zero `positionToWorld` calls, anchored to a board at a fixed transform | Moving or rescaling the board invalidates every placement at once; all 925 must be re-authored by hand |
| C3 | **Button state addressed by positional index** | Arcs `src/SetupControl` creates 30 buttons then edits `index=12,15,21,22,27,29`; its own source warns "must add buttons in the order of the actual indices !!!!!!!!!!" | Inserting one `createButton` shifts every later index. RotLA maintains a manual `btnIndex` counter for the same reason |
| C4 | **State scattered across ad-hoc channels** | Arcs stores its save/restore flag in an object's `Description` (`"in progress"`); RotLA encodes data in `GMNotes`, `Description` and component tags at once, and needs a `USE_SAVES` kill switch because saved state silently overrides edited source | No schema, no defaults, no migration. Stale keys persist forever — Politik re-saves `max1`/`statName1` fossils nothing reads |
| C5 | **Shared code duplicated per bundle** | Arcs compiles 15 modules into multiple bundles; `src/GUIDs`, `src/LOG`, `src/ArcsPlayer` exist 4× each, currently byte-identical | Edit one copy and the other three keep resolving the old value, with no error |
| C6 | **Copy-paste component scripts** | RotLA: 51 byte-identical 997-char bag scripts. Rurik: 24 near-identical inventory bags, 24 advisor tokens | A one-line fix is a 51-site edit. Behaviour cannot be versioned or tested |
| C7 | **Broadcast events filtered per object** | 55 RotLA objects each open with `if bag ~= self then return end`; TTS delivers every container event to every script | O(objects × events) wasted dispatch, and omitting the guard in one script corrupts state silently |
| C8 | **Blanket `pcall` hiding real bugs** | Arcs: 255 unique `pcall` sites, roughly one per 15 lines. `src/Global:231` calls a nil `ActionCards` (its `require` sits 60 lines below), the `pcall` swallows it, and the "patched" flag is set anyway — the feature never works | Errors become permanent silent no-ops. The mod degrades instead of reporting |
| C9 | **Ad-hoc async** | Almoravid: 537 hand-written `Wait.frames` blocks. Arcs invents a cancellable keyed wait registry, a bounded retry and a 1.25 s duplicate-event suppressor — each once, inline | Every author re-derives spawn-timing rules; the good solutions stay buried |
| C10 | **No source tree, no build, no tests** | RotLA is a vendored paste of 18Engine v2.96 with "copy and paste everything below this line to update" at line 258; Arcs is luabundle output from a private repo | Edits below RotLA's line are lost on upgrade. Neither can be diffed or tested in place |

Live bugs to use as teaching material: Politik's `createCameraButtons` is never
called (and emits a malformed 7-digit hex colour); Politik's `plus()` caps
against an undeclared global so the cap never fires; Rurik object `8e05ed`
registers handlers in its own `_G` but passes `function_owner = Global`, leaving
six buttons inert while Global builds a working duplicate of the same panel;
RotLA defines `onPlayerChangeColor` twice and the second silently wins; Arcs
calls `Log.warning` where `src/LOG` exports only `LOG.WARNING`, turning a
missing-zone warning into a hard error.

Verify each of these against the corpus before publishing it as fact.

## The framework — `ttslib`

A small, opinionated Lua library plus a house architecture, each module
answering a numbered problem above. It must stay **readable and paste-able**: a
prototype author should be able to drop one file into a fresh save's Global
script.

| Module | Answers | Provides |
| --- | --- | --- |
| `registry` | C1 | Resolve objects by **role tag**, not GUID: `reg.one("supply.wood")`, `reg.all("card")`. Lazy, cached, invalidated on spawn/destroy. A declarative manifest lists expected roles so a missing one is reported once, loudly, at boot — not as a nil dereference mid-setup |
| `layout` | C2 | Anchor-relative placement: named spaces in **board-local** coordinates resolved through `anchor.positionToWorld()`. Move the board and everything follows. Snap-point and zone-position helpers; an explicit stacking-layer constant instead of magic Y values |
| `ui` | C3 | Named buttons: `ui.button(obj, "total", {...})` keeps the name→index map, so `ui.set("total", {label=…})` survives insertions. Idempotent attach across reloads, zero-size text labels, the drop-shadow pair, and XML helpers wrapping `setXml`/`setAttribute` |
| `store` | C4 | One state object per script with declared defaults and a `version`, serialized by a single generated `onSave`. Unknown keys dropped on load, migrations by version. Nothing else persists state — no `Description` flags |
| `events` | C6, C7 | One central dispatcher. Objects declare **behaviour by tag**, not by carrying code: `events.on("enterContainer", "supply", handler)`. Replaces 51 copies of a script with one registration |
| `async` | C9 | The good patterns from Arcs, extracted and named once: `async.afterFrames(n, fn)`, `async.whenSettled(obj, fn)` (the `isSmoothMoving`/`resting` guard), `async.retry(fn, {times, delay})`, `async.keyed(key, …)` cancellable waits, `async.debounce(key, window)` |
| `log` | C8 | Levelled logging with a build-time level, plus `assert`/`expect` helpers that **fail loudly in development** and degrade only at declared boundaries. Explicitly replaces blanket `pcall` |

Architectural rules the framework enforces, each inverting a mod's mistake:

1. **One bundle. Thin object scripts.** An object script delegates to Global in
   a line or two; shared libraries are never compiled into many objects (C5).
2. **Tags are identity; GUIDs are a cache.** Anything the author types is a role
   name. A GUID for a deck or stack is a seed, not an identity — Arcs already
   discovered this and overwrites `action_deck_GUID` at runtime (C1).
3. **Data, not duplicated code.** Component variation lives in tags and a config
   table, not in 51 copies of a script (C6).
4. **Fail loudly at boot, degrade only at boundaries** (C8).
5. **Source lives in files, not in the save.** Author under `src/`, build into
   the save with `tts.py lua inject`. Note TTS's External Editor API as the live
   iteration path — read `reference/api/externaleditorapi/` for the protocol
   rather than assuming it (C10).

Validate `ttslib` by building the demo save (phase 6) on it, not by assertion.

## Deliverables

```
/Users/artur/Library/Tabletop Simulator/
├── CLAUDE.md                     ← updated to point at the new material
├── .claude/
│   ├── agents/tts-reference.md   ← read-only lookup agent over the corpus
│   └── skills/
│       ├── tts-mod-surgery/SKILL.md
│       ├── tts-prototype/SKILL.md
│       └── tts-scripting/SKILL.md
├── docs/
│   ├── framework.md              ← the house architecture + ttslib guide
│   ├── critique.md               ← C1–C10 with full evidence
│   ├── cookbook/                 ← index + 10 task-keyed recipe files
│   └── mods/                     ← README + one profile per mod
├── reference/
│   ├── api/                      ← 55 vendored api.tabletopsimulator.com pages
│   ├── mods/<slug>/              ← extracted .lua/.xml grep corpus + manifest
│   └── framework/                ← ttslib source + a starter Global.lua
├── scripts/
│   ├── tts.py                    ← extended (phases 1 and 6)
│   └── fetch_api_docs.py         ← new, stdlib-only
└── Saves/TS_Save_126.json        ← runnable demo built on ttslib
```

## Phase 1 — Extraction and safety tooling (`scripts/tts.py`) — DONE

**Delivered 2026-09-20.** `scripts/tts.py` grew from 643 to ~1,280 lines and now
carries `xml extract` / `xml inject`, `corpus`, `validate`, `refs` and
`selftest`; `reference/mods/` holds 243 extracted files across the five mods.
Every existing command still works and the Lua round-trip is unchanged.

Verified:

- **Round-trip byte-identity** — `lua extract` and `xml extract` reproduce the
  source field exactly across all five mods: 154 Lua slots (68 bundled modules)
  and 7 XML slots, checked independently of the code that wrote them.
- **`corpus` is faithful** — each `manifest.json` records the source sha256 and a
  per-module sha256; re-splicing every module back into its bundle reproduces the
  save's Lua field byte for byte.
- **Every `validate` check fires** — each was proved against a deliberately
  broken copy of a save that validates clean, so no check is silently dead.
- **`Mods/` untouched** — `find Mods -newermt <start>` returns nothing.

What the plan did not anticipate:

- **`selftest` is new.** Discovering that TTS writes pretty-printed C#-formatted
  JSON made "does this tool still write what TTS writes" a real risk worth a
  standing check, since a TTS update could silently invalidate every file the
  tool writes.
- **Two `validate` checks needed scoping** to avoid drowning real findings.
  Unscoped, `duplicate-guid` reported 169 non-problems in Arcs and
  `card-sheet-missing` hundreds across every mod. Both now report only the case
  that actually breaks (see Status, findings 2 and 3), which is why the five mods
  come back with plausible short reports instead of noise.
- **`corpus` refuses to write under `Mods/` or `Saves/`**, making CLAUDE.md rule
  3 mechanical rather than a matter of care.

Findings on the five mods, from `validate`, all of them the mods' own bugs:

| Mod | ERROR | WARN | What |
| --- | --- | --- | --- |
| Politik | 0 | 1 | one GUID twice in one container |
| RotLA | 0 | 13 | duplicate GUIDs within containers |
| Arcs (mod) | 0 | 16 | 16 modules compiled into 2–4 slots each, all identical |
| Arcs (`TS_Save_125`) | 3 | 11 | 3 `getObjectFromGUID` literals in `src/GUIDs` that match no object — critique C1, live |
| Rurik | 0 | 2 | duplicate GUIDs within containers |
| Almoravid | 0 | 54 | 54 `getObjectFromGUID` literals resolving only inside containers — critique C1, live |
| *owner's `TS_Save_111`* | 0 | 0 | clean |

Corpus spot-checks confirming the critique's numbers, for phase 3 to cite:
Almoravid's 537 `Wait.frames` blocks and zero `positionToWorld` calls (C2, C9);
RotLA's 51 byte-identical 997-char bag scripts (C6) and 55 scripts carrying the
`bag~=self` container guard (C7); RotLA's vendored-engine boundary at
`global/script.lua:258` (C10).

Corrections to the brief's own numbers, found while verifying:

- Politik's XML UI is on **6** objects, not 7 — all six byte-identical at 1,614
  chars. The save-level `XmlUI` is TTS's 81-char default comment stub, present in
  four of the five mods and not UI at all. The brief's working notes already said
  "`1efc34` and its 5 byte-identical siblings", which is the correct 6.
- Arcs' `Global.call` sites in the global bundle count **63**, not 62.
  *Superseded: 63 and 62 both count text, 2 occurrences of which are inside
  comments. The figure is **60 real call sites** over 13 distinct names — see
  Phase 3's findings below and `docs/mods/README.md`'s Corrections table.*
- `editButton`'s index base — the brief's open question — is now greppable in the
  corpus: 54 uses of `index=0` against 48 of `index = 1`. Still unresolved, and
  still to be settled by testing in TTS rather than by counting.

The original specification follows.

Everything downstream reads from this. Preserve the file's invariants: **stdlib
only; every writer requires an explicit `-o` and refuses to target its input.**
Reuse the existing helpers rather than writing new traversal — `walk`
(`tts.py:102`), `lua_targets` (`tts.py:221`), `split_bundle` (`tts.py:197`).

- `xml extract` / `xml inject` — the round-trip `lua` already has, for `XmlUI`
  at save and object level. Today there is no safe way to edit XML UI. Mirror
  `cmd_lua_extract` (`tts.py:371`) and `cmd_lua_inject` (`tts.py:448`),
  including the `newline=""` rule from `docs/save-format.md`.
- `corpus <save> -o reference/mods/<slug>/` — extract every Lua module and XML
  block across **all** bundle slots, plus `manifest.json` recording source path,
  sha256, save date and object→file map. The sha256 detects a Steam update
  having staled the corpus.
- **Cross-slot duplicate detection** — hash every module body; report modules
  present in more than one slot and whether the copies are identical or drifted
  (C5). `lua extract` prints the warning; `validate` enforces it.
- `validate <save>` — run before loading any edited save: duplicate GUIDs across
  the nested tree, deck invariants (`CardID`'s sheet exists in `CustomDeck`;
  `DeckIDs` matches `ContainedObjects` in order and length), `getObjectFromGUID`
  literals resolving to nothing, `CustomUIAssets` names referenced by XML
  `image=` (a missing one renders a blank box with no error), drifted shared
  modules, single-line output. **Report only; never rewrite.**
- `refs <guid-or-nickname>` — every mention in Lua, XML, `GMNotes` and
  `Description`. Answers "what breaks if I delete this" before, not after.

Then run `corpus` for all five mods into `reference/mods/`.

## Phase 2 — Vendored API reference — DONE

**Delivered 2026-09-20.** `scripts/fetch_api_docs.py` (stdlib only, ~370 lines)
walks the nav, converts each page's `<article>` to markdown with a small
`html.parser` subclass, and writes `reference/api/` — 55 pages and an
`INDEX.md`, 455 KB of markdown from 3.4 MB of HTML. The absence of pandoc, bs4,
html2text, markdownify, requests and lxml was re-confirmed on this machine
before a line was written.

Verified:

- **All 55 pages converted, none failed.** The smallest outputs were checked by
  hand against their source HTML rather than assumed to be failures.
- **Idempotent** — a second run reports `0 written, 55 unchanged`. Only
  `INDEX.md` carries the fetch date, so an unchanged re-run rewrites one file
  rather than 56.
- **Clean conversion** — a sweep of all 55 files for leftover tags, raw
  entities, empty links, broken table rows and stray Pygments classes came back
  empty. The only four hits were literal `|` and `class="` inside code blocks,
  i.e. correct output.
- **The index resolves real lookups** — `createButton`, `editButton`,
  `takeObject`, `onSave`, `positionToWorld`, `setXml`, `getObjectsWithTag` and
  `onObjectEnterContainer` each land on exactly one page.

Two decisions worth knowing:

- **Type tags are restored, not dropped.** The docs express every parameter and
  return type as an empty `<span class="tag str">` that only CSS renders. Strip
  them naively and every signature loses its types. The mapping is taken from
  the site's own `css/type_icons.css`, so `collect(...)` comes out as
  `collect(*table* expected_ids, *func* on_finished, …)` rather than
  `collect(expected_ids, on_finished, …)`.
- **`INDEX.md` has two halves.** A per-page table for orientation, then **every
  documented function, one per line, 264 of them**. The first draft truncated
  each page's list to 14 names, which silently broke the one workflow the index
  exists for — `createButton` was in `object.md` but not findable in the index.
  Nothing in the function list is truncated.

**This resolves one of the brief's open questions.** `object.md` on `editButton`
states: *"Indexes start at 0. The first button on any given Object has an index
of 0, the next button on it has an index of 1, etc. Each Object has its own
indexes."* The index base is **0**, from the primary source — so RotLA and Arcs
read it correctly and Rurik's `index = 1` is either a deliberate edit of the
second button or a bug in Rurik, which phase 3 should check per call site rather
than treating the base as unsettled. The *component-tag case-sensitivity*
question is untouched by this and still needs a test in TTS.

The original specification follows.

`scripts/fetch_api_docs.py`, stdlib only — **verified on this machine: no
pandoc, no bs4, no html2text, no markdownify, no requests.** Use
`urllib.request` plus a small `html.parser` subclass targeting MkDocs' content
div, emitting one markdown file per page.

- 55 pages, enumerated from the nav at `https://api.tabletopsimulator.com/`
  (its `sitemap.xml` is empty, so the nav is the source of truth). `object/` is
  355 KB of HTML, `base/` 150 KB.
- Write `reference/api/INDEX.md`: one line per page plus the function names it
  documents, so an agent greps the index and then reads exactly one page.
- Re-runnable and idempotent; record the fetch date.

## Phase 3 — Documentation — DONE

**Delivered 2026-09-20.** `docs/critique.md` (C1–C10, the five live bugs, a
method note), `docs/cookbook/` (README + 10 recipes), `docs/mods/` (README + 5
profiles), and the `save-format.md` `Nickname`/`Description` correction.
`CLAUDE.md` now points at all of it.

Verified:

- **Every citation opened and checked.** A two-pass proofer reads each doc, opens
  the cited `file:line` and compares it against the quoted text: **183 anchored
  code-block citations, 0 mismatches**, plus every short-form `path:line`
  resolved and printed for review. The first pass found 17 wrong line numbers —
  all off-by-one or off-by-two from `sed -n 'X,+Np'` arithmetic — and 2 quotes
  that had drifted from the source. All fixed.
- **Internal links resolve**, including anchors. The only broken link left is
  `critique.md → framework.md`, which phase 4 creates.
- **The brief's own infrastructure table was wrong in three ways**, corrected in
  `docs/mods/README.md#corrections-to-earlier-figures`: its "tags" column was
  the *declared label* count, not tags in use (31/88/147 declared vs 14/72/61
  used); its "decals" column mixed `DecalPallet`, `AttachedDecals` and their sum
  across different rows; and RotLA was missing entirely (0 table snaps, 119
  object snaps).

Two resolutions and one new open question:

- **Rurik's `editButton({index = 1})` is correct, not a bug.** All 48 call sites
  are in one copy-pasted inventory-bag script whose `onLoad` creates an invisible
  click target first and the counter label second, so index 1 *is* the label
  (`rurik/objects/064e16/script.lua:38`, `:49`, `:72`). Checked per call site.
- **Arcs' `Global.call` bus is 13 distinct names and 60 real call sites.** The
  brief said 62 and critique.md said 63; both were counting text, 2 occurrences
  of which sit inside comments. The brief's original "13-function bus" was right.
  The same distinction applies to the Arcs `pcall` figure: 256 mentions, 255 call
  sites.
- **A third case-sensitivity question surfaced, of the same family as the tag
  one.** Almoravid calls `.SetRotationSmooth(` — capital S — **630 times**
  against 231 documented-casing calls in the same file, and **four of the five
  mods** declare a lowercase `onload`; RotLA's Global declares *only* that
  spelling. All three are now collected with a runnable test each in
  `docs/cookbook/10-antipatterns.md#open-questions-test-these-in-tts`. None is
  asserted either way.

The tag question itself is now much better evidenced, and still open: Arcs'
**live power scoring** queries `getObjectsWithTag("power")` and `hasTag("power")`
against nine objects tagged `Power`, and `hasTag("Lock")` against 376 tagged
`lock`; Rurik hedges with `hasTag("Deed") or hasTag("deed")` in four places; and
TTS stores a lowercased `normalized` form beside every `displayed` label in
`ComponentTags.labels`. Suggestive, not conclusive — it still needs the test.

The original specification follows.

**`docs/critique.md`** — C1–C10 with full quoted evidence from the corpus and
the framework's answer to each. Written to stand on its own.

**`docs/cookbook/`** — index plus ten task-keyed files. Every recipe cites a
real exemplar by mod, object nickname and GUID, and states whether `ttslib`
supersedes it:

| File | Covers |
| --- | --- |
| `README.md` | Decision tables: which architecture, which UI mechanism, which async primitive; index of all recipes |
| `01-architecture.md` | Monolith vs logic-on-objects vs luabundle vs the `ttslib` layout; the vendored-engine boundary; tags-vs-GUIDs as the central fork |
| `02-lifecycle.md` | `onLoad` ordering, coroutine boot, `return 1`, `Wait.*`, spawn-callback timing, `onPlayerConnect` rebuild for late joiners |
| `03-buttons.md` | Idempotent rebuild, `function_owner` semantics, index bookkeeping vs named buttons, zero-size labels, `alt_click`, `setVar` closures, scale compensation |
| `04-xmlui.md` | Global vs object-attached; `Defaults`+`class`; `CustomUIAssets` name binding; `setXml` replaces the root; handler signature `(player, value, id)`; object-XML local space and `rotation="0 0 180"` |
| `05-state.md` | `onSave`/`onLoad` + `JSON.encode`, guard styles, why `LuaScriptState` must not be hand-edited, stale-key and GUID-rot hazards |
| `06-objects-tags-containers.md` | The self-filter, `filterObjectEnter` veto, `GMNotes` back-pointers, self-returning supply bags, `getObjectsWithTag` |
| `07-placement.md` | Coordinate strategies worst to best: 925 literals → named tables → `positionToWorld` anchor-relative → snap points; Y-as-stacking-layer; the bulk-placement idiom |
| `08-players-turns.md` | Guarded `Player[c].seated`, `getSeatedPlayers()`, `lookAt` cameras, `broadcastToColor` vs `broadcastToAll`, `Turns.*`, hand transforms |
| `09-decks-cards.md` | `deal`/`takeObject`/`putObject`/`shuffle`, draw-by-name, and the `CardID`/`DeckIDs` invariants |
| `10-antipatterns.md` | The live bugs listed above, each as a named trap with its code |

**`docs/save-format.md` correction** — it currently lists `Nickname` and
`Description` as "safe to edit freely". That holds only for unscripted saves. In
Arcs, `reach_board`'s `Description == "in progress"` is the save/restore flag
the whole `onLoad` branches on; zone `Nickname`/`Description` route scoring for
25 zones; object `Nickname` is the supply-return lookup key. Add the caveat and
the rule: grep the Lua for the field before editing it.

**`docs/mods/`** — `README.md` ("consult *this* mod for *that* question") plus
one profile per mod: architecture, entry points, conventions, notable idioms,
what breaks if you edit it, and links into `reference/mods/<slug>/`. Cover
**non-Lua infrastructure** too, since that is exactly what the owner's
prototypes lack:

| | table snaps | object snaps | States | tags | decals |
| --- | --- | --- | --- | --- | --- |
| Politik | 4 | 1562 | 0 | 31 | 0 |
| Arcs: Celestial | 320 | 245 | 194 | 88 | 208 |
| Rurik | 108 | 655 | 5 | 147 | 8 |
| Almoravid | 0 | 11 | 2 | 0 | 259 |
| *owner's prototypes* | 0 | 0 | 0 | 0 | 0 |

## Phase 4 — Build `ttslib` — DONE

**Delivered 2026-09-21.** Seven modules in `reference/framework/ttslib/` (none of
them long; run `wc -l` for the current figures), a commented starter `Global.lua`, an
`ObjectScript.lua` template for architectural rule 1, and `docs/framework.md`.
`CLAUDE.md` points at all of it.

Verified:

- **The build path works end to end.** `cat ttslib/*.lua Global.lua` concatenates
  the library and the game; `lua inject` puts it into a save, `validate` comes back clean, and
  `lua extract` returns the same bytes. Written to the scratchpad, not to a save
  slot — `TS_Save_126` stays reserved for phase 6.
- **45 cases, 131 checks, 0 failures**, run outside TTS against a stub
  (`test/harness.lua`) with a manual frame scheduler. The last case loads
  `Global.lua` itself, boots it against a tagged table, clicks its button, moves
  a token through a container event and reloads from its own `onSave` output.
- **The suite is mutation-checked, once per module.** Breaking `log.attempt`'s
  reporting, `async`'s debounce, `store`'s version check, `ui`'s index lookup,
  `events`' subject selection, `registry`'s deferred invalidation or `layout`'s
  anchor transform each makes it fail — 3, 3, 4, 9, 3, 1 and 7 checks
  respectively. The first pass caught five of six; the registry case was
  untested until a case was written for it.
- **The tests found one real bug in the library**, which is the point of having
  them: `layout.place` passed `collide` into `setPositionSmooth`'s `fast` slot
  (`setPositionSmooth(vector, collide, fast)`). Fixed, and pinned by a check.

Decisions the plan did not specify:

- **No `require` shim, no bundler.** TTS has no module system and luabundle's
  output is what C5 is about, so a build is `cat` in filename order and the
  files are numbered `00-`…`06-` to make that order explicit. Each file opens
  with an `assert` naming its predecessor, so a bad concatenation fails at load
  with a sentence.
- **`events` declares the thirteen `onObject*` handlers itself**, statically,
  rather than assigning them to `_G` at install time. Whether TTS resolves event
  handlers dynamically is not attested anywhere in the corpus; a static
  declaration is what every mod does and needs no such assumption.
  `events.check()` then reports if anything has redefined one — RotLA's
  double-definition bug, turned into a message.
- **`ui` caches no indexes at all.** The button's name *is* its
  `click_function`, so the index is read back out of `getButtons()` on every
  call. Confirmed while building it: no save or mod JSON in this folder contains
  button data, so scripted buttons never survive a reload and every `onLoad`
  rebuilds them.
- **A test harness was not in the brief.** C10 is "no source tree, no build, no
  tests", and a framework answering it cannot ship untested. The harness is
  explicit about the line it cannot cross: it proves the library's own logic,
  never TTS's semantics.

One correction to phase 3, found while documenting the build:
`docs/cookbook/01-architecture.md` gave the build command as
`lua inject <save> src/`, which fails — `lua inject` takes a file, or a slot
directory carrying an `_index.json` from `lua extract`. Corrected to the `cat`
form, with the recommended `src/` layout renumbered to match.

The original specification follows.

Implement the seven modules in `reference/framework/`, plus a commented starter
`Global.lua` wiring them together, and write `docs/framework.md`: the
architecture, each module's API, a migration note for adding `ttslib` to an
existing unscripted prototype, and the C-number each decision answers.

Keep it small. If a module cannot be explained in a paragraph, it is too big for
a library whose users are prototyping a board game.

## Phase 5 — Skills and agent — DONE

**Delivered 2026-09-21.** Three skills and one agent under `.claude/`, 450 lines
in total — `tts-mod-surgery` (124), `tts-prototype` (103), `tts-scripting` (117)
and the `tts-reference` agent (106). `CLAUDE.md` lists them.

Verified:

- **All three skills register.** Claude Code picked them up from
  `.claude/skills/<name>/SKILL.md` and listed them with their descriptions, so
  the frontmatter parses and the triggers are visible to the model that has to
  choose between them.
- **Every link and anchor resolves** — 0 problems across the four files,
  including the `../../../` hops out of `.claude/skills/<name>/` to `docs/`.
- **The strongest claims were re-checked against the files**, not carried over
  from the brief: Arcs' `Setup` object `7299d7` carries 250 KB of Lua in
  `Mods/Workshop/3683918449.json` and is **absent** from `Saves/TS_Save_125.json`;
  RotLA's vendored-engine boundary is still line 258 of its Global.
- **Both smoke-test lookups land where the agent routes them.** "How does Rurik
  show its setup menu?" resolves to `UI.show("setupMenu")` at
  `rurik/global/script.lua:175` with `UIShowSetupMenu` at `:1299`; "what breaks
  if I delete an object from Almoravid?" resolves through
  `tts.py refs Mods/Workshop/2804149704.json 607a04` to 11 call sites plus the
  object itself at `ObjectStates[197]`.

Decisions worth knowing:

- **The agent gets `Bash`, not a hand-rolled read-only tool.** It needs
  `tts.py refs`/`validate`/`tree`, which are the point of it. The prompt names
  the permitted subcommands and forbids the writing ones (`lua inject`,
  `xml inject`, `corpus`, `inventory`) and any redirection.
- **The skills route rather than restate.** Each is a procedure plus links; the
  evidence stays in `docs/`. That keeps them small enough to load without
  crowding out the task, and means a correction to a doc does not leave a stale
  copy in a skill.
- **Three skills, one axis.** They split by *what you are editing* — someone
  else's mod, the owner's own game, or the Lua itself — because that is the
  distinction that changes how freely you may restructure, which is the
  distinction `CLAUDE.md` already draws.

The remaining verification is deliberately **not** done from this session: a
cold-context smoke test of the agent and skills is a better test run from a
fresh session than from the one that wrote them.

The original specification follows.

**`.claude/skills/tts-mod-surgery/SKILL.md`** — modify a published mod or save.
Encode the CLAUDE.md rules as a procedure: check whether TTS is live
(`ls -lt Saves | head`), locate via `tree`/`get`, extract, make the smallest
possible change, never reformat, inject to a **new** numbered save, `validate`,
report. Four pre-flight checks:

1. **Shared module?** If it appears in more than one bundle slot, apply the edit
   to every copy (C5).
2. **Vendored engine?** If the file declares an upstream boundary, changes below
   it are lost on upgrade (RotLA line 258).
3. **Mod JSON or play-state?** Objects destroyed at game start — Arcs' `Setup`
   (`7299d7`) and its two siblings — exist only in `Mods/Workshop/`, so their
   scripts cannot be edited through a save.
4. **Who references this?** `refs`, plus a grep of `Nickname`/`Description`,
   before touching or deleting anything.

**`.claude/skills/tts-prototype/SKILL.md`** — start or extend one of the owner's
own games, on `ttslib` by default: scaffolding a save, decks from art sheets,
snap points and component tags, and adding scripting to a prototype that has
none.

**`.claude/skills/tts-scripting/SKILL.md`** — write and debug Lua + XML UI. A
thin routing skill: decision tables inline, everything else by reference to
`docs/framework.md`, `docs/cookbook/` and `reference/api/`, so it stays small
enough to always load.

**`.claude/agents/tts-reference.md`** — read-only lookup agent (Read, Grep,
Glob, read-only `tts.py`). Answers "how does Arcs handle turn order?" with
file:line citations into `reference/mods/` without pulling 11 MB of JSON into
the caller's context. Its prompt states the corpus layout and requires
citations.

## Phase 6 — Authoring commands and the demo save — DONE

**Delivered 2026-09-21.** `scripts/tts.py` grew `diff`, `new`, `deck build` and
`object add` (1,279 → 2,028 lines), and `Saves/TS_Save_126.json` is the
**Woodcutter** demo, built from source by
[`reference/framework/demo/build.sh`](../reference/framework/demo/README.md)
using nothing but those commands plus `lua inject`, `xml inject` and `validate`.

Verified, outside TTS:

- **The demo validates clean**, and `selftest` now round-trips **186** files
  byte-identically — the demo save included, which means it is written in exactly
  the bytes TTS itself would write, not merely in loadable JSON.
- **Round-trip holds on generated JSON too.** `lua extract` then `xml extract`
  then both injects reproduces `TS_Save_126.json` byte for byte, and the
  extracted Lua is `cmp`-identical to what `build.sh` concatenated.
- **The build is deterministic.** GUIDs are derived from a sha256 of (source,
  path, old GUID) rather than drawn at random, so two builds of the demo differ
  only in `EpochTime`/`Date`. A generated save can therefore be `diff`ed against
  its predecessor and show only the changes you made.
- **19 more test cases, 46 checks, 0 failures** (`test/demo_spec.lua`), booting
  the demo's own `Global.lua` against the phase 4 stub: a missing role stops
  setup, a wrong-case tag is diagnosed, the layout follows the board when the
  board moves, the badge tracks cubes through one subscription, ten container
  events cost one redraw, a triple `onObjectDrop` counts once, and round and
  drop count survive a reload. Six independent mutations of `Global.lua` each
  make it fail.
- **The five mods still validate to exactly the phase 1 baseline** (Politik 1,
  RotLA 13, Arcs 16, Rurik 2, Almoravid 54 — all WARN, all their own bugs), and
  `Mods/` is untouched: `find Mods -newermt <start>` is empty.

What the plan did not anticipate:

- **`deck build` writes a Saved Object, not a save.** Composing
  `deck build` → `object add` beat a `--into` flag: a Saved Object is a
  first-class TTS artifact (`docs/save-format.md`), it drops straight into TTS's
  own Objects > Saved Objects menu, and it keeps the "every writer takes an
  explicit `-o`" invariant intact.
- **`object add` does three things the brief only implied.** Besides minting
  GUIDs it **repoints the inserted subtree's own GUID references** in
  `LuaScript`, `XmlUI`, `GMNotes` and `Description` — without that, a Saved
  Object that scripts its own children, or carries a RotLA-style `GMNotes`
  back-pointer, arrives broken — and it **declares the objects' tags in
  `ComponentTags.labels`**, without which the tags exist but TTS's tag UI cannot
  see them. The rewrite is bounded by "not a hex digit" rather than `\b`, so a
  GUID sitting inside a longer hex literal (a colour, a hash) is left alone.
- **`diff` had to descend into the settings blocks.** "ComponentTags changed" is
  no answer to "what did that checkbox do"; it now reports
  `Turns.Enable false -> true`, three levels deep, which is what makes the
  learn-by-changing-it workflow actually work.
- **`diff` needed a jitter floor.** TTS re-records every position a few
  thousandths off on each save, so an unfiltered comparison calls every object
  changed. `--epsilon` defaults to 0.001, and rotation deltas are wrapped into
  ±180° so 359.99 → 0.01 reads as a hundredth of a degree rather than 359.98.
- **The demo carries no asset URL at all.** Every component is a TTS built-in
  (`BlockRectangle`, `BlockSquare`, `Bag`), so it loads offline on any machine
  and cannot rot when an image host goes away. That is also why it has no deck —
  `deck build` is verified separately, below.
- **A test harness bug turned up**, found by the first demo case that counted
  objects: `H.object` spawns by default and the harness's `takeObject` spawned
  again, so every taken object was on the fake table twice and fired
  `onObjectSpawn` twice. Fixed; phase 4's 45 cases still pass unchanged.

`deck build`, verified against a sheet of the owner's own that is already in the
cache (`cards_1.png`, 3×3, from `TS_Save_111`): nine `CardCustom` in a
`DeckCustom`, `CardID` 100–108 on `CustomDeck` key `1`, `DeckIDs` matching
`ContainedObjects` in order, nicknames applied from a names file, `validate`
clean, and the face art resolving to a real file under `Mods/Images/`. It refuses
a `--count` past the sheet's slots, a one-card deck (TTS collapses that back into
a `Card`), a non-positive sheet key, and more names than cards.

**One finding for the docs:** a `CustomDeck` sheet key is unique **per object**,
not per save. `TS_Save_100` reuses 12 of its 74 keys across different objects
(11 pointing at two different `FaceURL`s, `"4072"` at three), and `TS_Save_125`
reuses 2 of 196 — so `deck build` does
not need to negotiate a free key with the target save. Recorded in
`docs/cookbook/09-decks-cards.md`.

**The remaining step needs TTS.** Verification item 4 — load `TS_Save_126`, click
the buttons, move a cube through the supply, save and reload — is the only real
test of generated JSON and of `ttslib`, and cannot be run from here. The demo's
[README](../reference/framework/demo/README.md) lists the six things to try, in
order. Everything a test can prove without TTS is proved.

The original specification follows.

Second `tts.py` batch, for creating rather than reading:

- `diff <a> <b>` — structural diff of two saves, making "change it by hand in
  TTS, then learn the JSON delta" a workflow.
- `deck build` — a `Deck` from a sheet image URL + grid dimensions, honouring
  `CardID = sheet*100 + index`. The biggest prototype accelerator; the owner's
  saves are card-heavy (157 `Card`, 95 `CardCustom`).
- `object add` / `new` — insert a Saved Object with regenerated GUIDs; create an
  empty save skeleton.

**`Saves/TS_Save_126.json`** — a small loadable demo **built on `ttslib`**,
exercising every module: a tag-routed component supply with a live count badge
(one registration, not 51 scripts), a named button, an XML panel with
`Defaults`, versioned `store` state, anchor-relative placement, and snap points.
This is the framework's real test. 126 is the next free slot — highest in use is
125, verified.

## Verification

1. **Round-trip is byte-identical** — `lua extract` then `lua inject` with no
   edit already holds for the 550 KB Arcs bundle; hold `xml extract`/`inject` to
   the same standard across all five mods.
2. **`validate` is clean on untouched input** — run it over all five mods and
   the owner's saves. Anything it flags is either a real mod bug (several are
   known, listed above) or a false positive to fix.
3. **`corpus` is faithful** — reassemble each extracted module set and compare
   against the source JSON's Lua field.
4. **The demo save loads in TTS.** The only real test of generated JSON, and of
   `ttslib`. Confirm TTS is not running, load `TS_Save_126`, click the button,
   move a component into the supply and watch the badge, save, reload, confirm
   state survived.
5. **The agent answers with citations** — smoke-test with "how does Rurik show
   its setup menu?" and "what breaks if I delete an object from Almoravid?";
   check the cited file:line actually says that.
6. **Nothing under `Mods/` changed** — `find Mods -newermt "<start time>"`
   returns nothing.
7. Re-run `python3 scripts/tts.py inventory`.

## Constraints

- `Mods/` is read-only (CLAUDE.md rule 3). The corpus is written to
  `reference/`, never back.
- New saves go to `TS_Save_126.json` and up; nothing is overwritten (rule 1).
- **Check TTS is not live before any write under `Saves/`** (rule 5):
  `ls -lt Saves | head`. When this brief was written TTS had last written at
  21:02 and was idle — re-check, do not assume.
- `tts.py` and `fetch_api_docs.py` stay stdlib-only.
- Docs cite mod, object and GUID. Where the exploration was inconclusive —
  `editButton`'s index base reads 0-based in RotLA and Arcs but is captured as a
  1-based count in Rurik, and TTS appears to match component tags
  case-insensitively — resolve it by **testing in TTS**, not by asserting.

## Working notes

- **Never `Read` a save or mod JSON directly** (CLAUDE.md rule 2); they are
  single-line and up to 4.7 MB, and one will consume an entire context window.
  Use `scripts/tts.py`, or read-only Python heredocs (`python3 - <<'PY' … PY`)
  that print slices.
- To regenerate the scan behind this brief's numbers: load each mod with `json`,
  walk `ObjectStates` recursively through both `ContainedObjects` **and**
  `States` (a dict keyed by stringified state number), concatenate `LuaScript`
  and `XmlUI` at save and object level, and count with regexes. `tts.py`'s
  `walk` already does the traversal correctly.
- Counts taken over concatenated bundles **over-count**, because Arcs duplicates
  15 modules. Deduplicate module bodies by hash before counting anything about
  Arcs — an earlier pass reported 114 `Global.call` sites where the deduplicated
  figure is 62, resolving to 13 distinct function names.
- The corpus from phase 1 is the cheap place to do detailed reading: grep real
  `.lua` files instead of re-parsing 11 MB of JSON.
- Where to look first, per topic:

| Topic | Start here |
| --- | --- |
| luabundle layout, module bus, GUID registry | Arcs `src/Global`, `src/GUIDs`, `src/ArcsPlayer` |
| Setup automation, data-driven placement | Arcs `src/BaseGame` (~line 1876), `src/SetupControl` |
| Async patterns worth stealing | Arcs `src/events/DropActionEvents`, `src/Timer` |
| Global XML panels | Rurik save-level `XmlUI` + `UIShowSetupMenu`/`UIHideSetupMenu` |
| Tag-based object resolution | Rurik Global `rebuildTagCache`, `getByTag`, `waitByTag` |
| Object-attached XML UI | Politik object `1efc34` and its 5 byte-identical siblings |
| Container tracking, supply bags | RotLA object `54bdb7` (997 chars, ×51) and sorter `93c2a0` |
| Dynamic button widgets | RotLA `bd69bd` "Flex Table Control" |
| Bulk placement | Almoravid Global, the 537 `takeObject` blocks |

- Suggested order: phases 1 and 2 are independent and can run together; 3 needs
  the corpus from 1; 4 needs the critique from 3; 5 needs 3 and 4; 6 is
  separable and can be deferred, with the demo save last since it exercises both
  the authoring commands and `ttslib`.
