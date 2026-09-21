---
name: tts-scripting
description: Write or debug Tabletop Simulator Lua and XML UI — buttons, onLoad/onSave, containers and component tags, snap points and placement, decks, turns and players, XML panels, Wait/async timing, or a script that "works the second time". Use whenever the task is TTS scripting itself, whichever save the code ends up in. Routes to the cookbook, the vendored API and ttslib rather than restating them.
---

# TTS scripting

A router. The material is in this folder; this file tells you which page.

- **How do I do X?** → [docs/cookbook/](../../../docs/cookbook/README.md), ten
  task-keyed recipes, each citing a real exemplar by mod, GUID and file:line.
- **What does this API call take?** → grep
  [`reference/api/INDEX.md`](../../../reference/api/INDEX.md); its second half
  lists all 264 documented functions one per line. **Do not fetch the web.**
- **How should I structure it?** → [docs/framework.md](../../../docs/framework.md)
  (`ttslib`) and [docs/critique.md](../../../docs/critique.md) (why).
- **How does a shipped mod do it?** → ask the **tts-reference** agent, so 11 MB
  of JSON stays out of context.

Where the code lands decides the other skill: **tts-prototype** for the owner's
own games, **tts-mod-surgery** for a published mod.

## Decision tables

### Which architecture?

| Situation | Use |
| --- | --- |
| A prototype still being designed | One Global script, objects unscripted |
| Genuinely local behaviour, ≤ 3 kinds | Global + **thin** object scripts that delegate in a line or two |
| Many components of the same kind | Global + **component tags**, zero object scripts |
| Patching a published mod | Whatever it already is — match the local idiom |

Never: shared library code compiled into many object scripts (C5), or the same
script pasted onto N components (C6).

### Which UI mechanism?

| You want | Use | Recipe |
| --- | --- | --- |
| A label or counter on a component | `createButton` with `width=0, height=0` | [03](../../../docs/cookbook/03-buttons.md) |
| A click target on a component | `createButton` | [03](../../../docs/cookbook/03-buttons.md) |
| A right-click alternative | one button, branch on `alt_click` | [03](../../../docs/cookbook/03-buttons.md) |
| A screen-space panel or dialog | global `XmlUI` + `UI.show`/`UI.hide` | [04](../../../docs/cookbook/04-xmlui.md) |
| A control surface stuck to a component | object-level `XmlUI` | [04](../../../docs/cookbook/04-xmlui.md) |
| A rarely used action | `addContextMenuItem` | [06](../../../docs/cookbook/06-objects-tags-containers.md) |

Object buttons live in **world space** and scale with the object; XML lives in
**screen space** (global) or **object-local space** (attached). Their handler
signatures differ: button `(object, colour, alt_click)`, XML `(player, value, id)`.

### Which async primitive?

| You need | Use |
| --- | --- |
| After the current frame settles | `Wait.frames(fn)` — the spawn-callback idiom |
| In N seconds | `Wait.time(fn, seconds)` |
| Every N seconds | `Wait.time(fn, seconds, -1)` — **keep the id and stop it** |
| When an object stops moving | `Wait.condition(fn, function() return obj.resting end)` |
| A long multi-step setup | `startLuaCoroutine(Global, "name")`, `coroutine.yield(0)`, **`return 1` on every path** |
| Retry until something spawns | bounded counter + `Wait.time`, with a ceiling |

Never an unbounded retry, and never a `Wait.condition` whose condition cannot
become true — both hang silently. `ttslib.async` has all of these named, bounded
and loud on give-up.

## The seven house rules

1. Tags are identity; GUIDs are a cache (C1).
2. Coordinates are anchor-relative via `positionToWorld`, never absolute (C2).
3. Buttons are named, not numbered — indexes are 0-based and shift (C3).
4. One versioned state object per script; nothing else persists. No flags in
   `Description`, `GMNotes` or `Nickname` (C4).
5. One bundle; thin object scripts (C5).
6. Component variation is data — tags and a config table, not 51 copies (C6).
7. Fail loudly at boot; degrade only at declared boundaries. A blanket `pcall`
   is how Arcs hid a feature that has never worked (C8).

`ttslib` implements all seven ([docs/framework.md](../../../docs/framework.md)).
Use it for new code; in a published mod, follow rule 0 — match what is there.

## Things that bite

- **Object `onLoad` runs before Global `onLoad`.** An object script calling into
  Global at load time waits a frame first.
- **Objects inside containers do not exist** — no Object, no script, no
  `getObjectFromGUID`. Not a race you can wait out.
- **Scripted buttons are not saved.** No save in this folder contains button
  data; `onLoad` rebuilds them, and so must `onPlayerConnect` for late joiners.
- **`getButtons()` returns nil, not `{}`,** when there are none.
- **`click_function` is a string** looked up in `function_owner`'s environment.
  Get it wrong and the button is inert with no error — four of Rurik's are.
- **TTS delivers container events to every script** that defines the handler, so
  a per-object handler needs `if container ~= self then return end`. Subscribe
  once in Global and route by tag instead.
- **Argument order**: `setPositionSmooth(vector, collide, fast)`. Check the
  vendored page rather than recalling it.
- **A handler defined twice** silently keeps the second. RotLA has two
  `onPlayerChangeColor` bodies.

## Three questions nobody has settled

Each needs a two-minute test in TTS, collected with its test in
[10-antipatterns.md](../../../docs/cookbook/10-antipatterns.md#open-questions-test-these-in-tts):
whether component tags match case-insensitively, whether Object members do
(Almoravid calls `.SetRotationSmooth(` 630 times), and whether `onload` is still
an alias for `onLoad`. **Until tested, write the conservative form** — documented
casing, exact tag case. Do not assert an answer.

Plain Lua table indexing is *not* in question: `Log.warning` and `LOG.WARNING`
are different keys, which is a live crash in Arcs.

## Before you say it works

`python3 scripts/tts.py validate <save>` on anything you generated or edited —
it reports without rewriting. Then load it in TTS, because that is the only real
test. Say which it was.
