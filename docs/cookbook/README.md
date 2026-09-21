# TTS scripting cookbook

Ten task-keyed recipes, mined from five shipped mods in `reference/mods/` and
checked against the vendored API in `reference/api/`.

Read [critique.md](../critique.md) first if you want the argument. This is the
reference you open mid-task: *"I need a counter badge on a bag"* → §3. Every
recipe cites a real exemplar by mod, object nickname and GUID, and a file:line
you can open.

**The mods are references for their thoroughness, not their design.** Where a
recipe shows you what a mod does and then tells you not to do it, that is the
point. Each recipe ends with a **Verdict** naming the better approach and the
critique item (C1–C10) it answers.

## Index

| File | Covers |
| --- | --- |
| [01-architecture.md](01-architecture.md) | Monolith vs logic-on-objects vs luabundle; the vendored-engine boundary; tags vs GUIDs as the central fork |
| [02-lifecycle.md](02-lifecycle.md) | `onLoad` ordering, coroutine boot, `return 1`, the `Wait.*` family, spawn-callback timing, late joiners |
| [03-buttons.md](03-buttons.md) | Idempotent rebuild, `function_owner`, index bookkeeping, zero-size labels, `alt_click`, `setVar` closures, scale |
| [04-xmlui.md](04-xmlui.md) | Global vs object-attached; `Defaults`+`class`; `CustomUIAssets`; `setXml` replaces the root; handler signature; `rotation="0 0 180"` |
| [05-state.md](05-state.md) | `onSave`/`onLoad` + `JSON.encode`, guard styles, why `LuaScriptState` must not be hand-edited, stale keys and GUID rot |
| [06-objects-tags-containers.md](06-objects-tags-containers.md) | The self-filter, `filterObjectEnter` veto, `GMNotes` back-pointers, self-returning supply bags, `getObjectsWithTag` |
| [07-placement.md](07-placement.md) | Coordinates worst to best: literals → named tables → `positionToWorld` → snap points; Y as stacking layer; bulk placement |
| [08-players-turns.md](08-players-turns.md) | Guarded `Player[c]`, `getSeatedPlayers()`, `lookAt`, `broadcastToColor`, `Turns.*`, hand transforms |
| [09-decks-cards.md](09-decks-cards.md) | `deal`/`takeObject`/`putObject`/`shuffle`, draw-by-name, and the `CardID`/`DeckIDs` invariants |
| [10-antipatterns.md](10-antipatterns.md) | Named traps, each with the live code in a shipped mod that demonstrates it |

## Decision tables

### Which architecture?

| Your situation | Use | Why |
| --- | --- | --- |
| A prototype you are still designing | **One Global script**, objects unscripted | Nothing to keep in sync; every rule is in one greppable place |
| Components with genuinely local behaviour, ≤ 3 kinds | Global + **thin** object scripts that delegate | An object script of 2 lines cannot drift |
| Many components of the same kind | Global + **component tags**, zero object scripts | One registration covers 51 bags. See [06](06-objects-tags-containers.md) |
| A published mod you are patching | Whatever it already is | Match the local idiom; make the smallest change (CLAUDE.md, "owner's work vs downloaded mods") |
| Real module structure | luabundle, source under `src/`, `tts.py lua inject` | The only option that can be diffed. See [01](01-architecture.md) |

Never: shared library code compiled into many object scripts (C5), or the same
script pasted onto N components (C6).

### Which UI mechanism?

| You want | Use | Recipe |
| --- | --- | --- |
| A label or counter floating on a component | `createButton` with `width=0, height=0` | [03](03-buttons.md) |
| A click target on a component | `createButton` | [03](03-buttons.md) |
| A right-click alternative | one button, branch on `alt_click` | [03](03-buttons.md) |
| A screen-space panel, menu or dialog | global `XmlUI` + `UI.show`/`UI.hide` | [04](04-xmlui.md) |
| A text input | XML `<InputField>` (there is no `createInput` worth using) | [04](04-xmlui.md) |
| A control surface stuck to one component | object-level `XmlUI` | [04](04-xmlui.md) |
| A rarely used action, no screen space | `addContextMenuItem` | [06](06-objects-tags-containers.md) |

Object buttons live in **world space** and scale with the object; XML lives in
**screen space** (global) or **object-local space** (object-attached). That is
the fork.

### Which async primitive?

| You need | Use | Note |
| --- | --- | --- |
| Run after the current frame settles | `Wait.frames(fn)` | Default 1 frame. The spawn-callback idiom |
| Run in N seconds | `Wait.time(fn, seconds)` | |
| Run every N seconds forever | `Wait.time(fn, seconds, -1)` | Keep the id; `Wait.stop(id)` to cancel |
| Run when an object stops moving | `Wait.condition(fn, function() return obj.resting end)` | See [02](02-lifecycle.md) |
| Cancel a pending wait | `Wait.stop(id)`, id keyed by object GUID | Arcs' pattern, [02](02-lifecycle.md) |
| A long multi-step setup | `startLuaCoroutine(Global, "name")` + `coroutine.yield(0)`, **must `return 1`** | Rurik's boot, [02](02-lifecycle.md) |
| Retry until something spawns | bounded counter + `Wait.time`, **with a ceiling** | [02](02-lifecycle.md) |

Never an unbounded retry, and never a `Wait.condition` whose condition can never
become true — both hang silently.

## House rules these recipes assume

1. **Tags are identity; GUIDs are a cache** (C1).
2. **Coordinates are anchor-relative**, not absolute (C2).
3. **Buttons are named, not numbered** (C3).
4. **One versioned state object per script**; nothing else persists (C4).
5. **One bundle; thin object scripts** (C5).
6. **Component variation is data, not 51 copies of a file** (C6).
7. **Fail loudly at boot; degrade only at declared boundaries** (C8).

## Three things the corpus cannot settle

Each needs a two-minute test in TTS. Until then, write code that works either
way. They are collected in
[10-antipatterns.md § Open questions](10-antipatterns.md#open-questions-test-these-in-tts).

1. **Are component tags matched case-insensitively?** Arcs' power scoring
   queries `"power"` against objects tagged `Power`.
2. **Are Object members resolved case-insensitively?** Almoravid calls
   `.SetRotationSmooth(` 630 times; the API documents `setRotationSmooth`.
3. **Is `onload` still accepted as an alias for `onLoad`?** RotLA's Global
   defines only the lowercase form.

Plain Lua table indexing is *not* in question — `Log.warning` and `LOG.WARNING`
are different keys and always will be. That one is a real bug in Arcs
([10](10-antipatterns.md)).

## Conventions in these files

- `reference/mods/<slug>/global/script.lua` — an unbundled global script.
- `reference/mods/arcs/global/src__Global.lua` — bundled module `src/Global`.
  The `__` is the corpus's encoding of `/`.
- Counts over Arcs are **deduplicated by module hash** and **exclude
  `_bundle.lua`**; otherwise every Arcs figure inflates 2–4×. See
  [critique.md § Method](../critique.md#method).
- Citations are `file:line` against the corpus as extracted on 2026-09-20. If a
  Steam update has moved them, `manifest.json` records the source sha256 —
  re-run `tts.py corpus` and the line numbers move with it.
