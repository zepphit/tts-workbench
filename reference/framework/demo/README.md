# Woodcutter — the `ttslib` demo

`Saves/TS_Save_126.json`. A table with a board, a supply bag, six wood cubes
inside it, four on the table and a round marker. Not a game — a harness with a
theme, built so that **every module in [`ttslib`](../ttslib/) is load-bearing**:
break any one of the seven and something here visibly stops working.

It is also the only end-to-end test of the authoring commands, since
[`build.sh`](build.sh) makes it out of nothing but `scripts/tts.py`.

## What it demonstrates

| Module | In the demo | What breaks if it is wrong |
| --- | --- | --- |
| `registry` | every object is found by tag — **not one GUID appears in [`Global.lua`](Global.lua)** | nothing is found; `check()` names each missing role at boot and setup stops |
| `layout` | the supply, the marker and a five-point snap row are placed relative to the board | drag the board anywhere, reload, and everything is still in the right place *on the board* |
| `ui` | two named buttons on the board, one named count badge on the bag | the badge stops tracking, or a reload stacks a second set of buttons |
| `store` | `round` and `dropped`, versioned, one generated `onSave` | the round resets on reload |
| `events` | one `enterContainer` subscription serves the supply | the badge stops following cubes in and out |
| `async` | a burst of container events coalesces into one redraw; `drop` is debounced | ten events cost ten redraws; one physical drop counts as three |
| `log` | every failure path names the role or the handler | failures become silent no-ops (critique C8) |

Things it deliberately does **not** have:

- **No object scripts.** All 13 objects carry an empty `LuaScript`. Behaviour
  that varies by component is a tag plus a table in Global, which is
  architectural rule 1 and the answer to C5 and C6.
- **No asset URLs.** Every component is a TTS built-in (`BlockRectangle`,
  `BlockSquare`, `Bag`), so the save loads offline on any machine and cannot rot
  when a host takes an image down. That is also why there is no deck here —
  `deck build` is exercised in [the brief's phase 6 record](../../../docs/deep-dive-brief.md#phase-6--authoring-commands-and-the-demo-save--done)
  instead.
- **No GUIDs in the source.** Deliberately, because C1 is the defect the whole
  framework is arranged around.

## Try it

Load `TS_Save_126` from Games > Save & Load, then:

1. **Click "Take wood."** One cube leaves the bag and lands in the clearing. The
   badge on the bag counts down — one subscription did that, not a script on the
   bag.
2. **Drag a cube back into the bag.** The badge counts up again.
3. **Drag a cube onto the table.** "Wood dropped" goes up by one, once, however
   many times TTS fires the event.
4. **Click "Next round."** The marker steps along the track. **Right-click** the
   same button to reset — one button, two actions.
5. **Unlock the board and drag it somewhere else**, then save and reload. The
   bag, the marker and the snap points have all followed it. That is C2, answered.
6. **Save and reload.** The round and the drop count come back.

Type `~` for the host console to see the `debug` lines; set
`LOG.level = "debug"` in `Global.lua` and rebuild for more of them.

## Build it

```bash
reference/framework/demo/build.sh              # -> Saves/TS_Save_126.json
reference/framework/demo/build.sh /tmp/x.json  # somewhere else
```

Check TTS is not running first. The script is the whole chain — `new`,
`object add` ×4, `lua inject`, `xml inject`, `validate` — and it is
deterministic: GUIDs are derived from the source rather than drawn at random, so
two builds differ only in the timestamp.

It has no `TS_Save_126.png` beside it, so it shows as a blank tile in TTS's load
menu until you save the game from inside TTS once. Only TTS can take that
screenshot.

## Test it

```bash
luajit reference/framework/test/demo_spec.lua
```

19 cases, 46 checks, against the same stub TTS the library's own suite uses. It
loads this exact `Global.lua`, boots it against a tagged table, clicks both
buttons, moves cubes through the bag, and reloads from its own `onSave` output.
Six independent mutations of `Global.lua` — dropping the debounce window,
redrawing without coalescing, removing `unscale`, removing the missing-role
guard, freezing the marker, naming the badge non-deterministically — each make it
fail.

What it cannot prove is TTS's own behaviour: whether a `BlockRectangle` is the
size we assume, whether the XML renders, whether a tag matches case-insensitively
(cookbook [open question 1](../../../docs/cookbook/10-antipatterns.md#open-questions-test-these-in-tts)).
Only loading the save answers those.

## Files

```
Global.lua        the game script, concatenated after ttslib/*.lua
ui.xml            the screen panel: <Defaults> with bare-tag and class forms
objects/          one Saved Object per component, tags included
build.sh          the build, as a sequence of tts.py commands
```

The positions in `objects/*.json` are where each piece starts; everything after
that is placed from the `SPACES` table at the top of `Global.lua`. If a piece
looks wrong on your table, drag it where it belongs, call
`ttslib.layout.capture(obj)` from the console, and paste the three numbers it
prints back into `SPACES` — that is the authoring loop the framework is for.
