# 07 — Placement

Four strategies for putting a component somewhere, worst to best. The corpus
contains all four, and the difference between them is what happens when you move
the board.

| Strategy | Corpus example | Survives moving the board? |
| --- | --- | --- |
| 1. Absolute literals | Almoravid, 925 of them | **No** — all 925 wrong at once |
| 2. Named coordinate tables | RotLA `gameEntities` | No, but they are edited in one place |
| 3. Anchor-relative via `positionToWorld` | Arcs `src/AmbitionMarkers` | **Yes** |
| 4. Snap points | Politik (1,562), Arcs (565) | **Yes**, and players can place by hand |

---

## 1. Absolute literals — what not to do (C2)

Almoravid's Global makes **925 `setPosition`/`setPositionSmooth` calls** and
contains **zero** calls to `positionToWorld`.

```lua
                obj.setPositionSmooth({3.74,6.66,3.66}, false, false)
```
— `reference/mods/almoravid/global/script.lua:483`

Every destination is a table-space coordinate anchored to a board that happens to
sit at a fixed transform. Move it, rescale it, or rebuild the table, and all 925
are wrong simultaneously. There is no transform to adjust — each must be
re-authored by hand.

For contrast across the same corpus:

| Mod | `positionToWorld` calls |
| --- | --- |
| Arcs | 21 |
| Rurik | 4 |
| Politik | 1 |
| RotLA | 1 |
| **Almoravid** | **0** |

*(Deduplicated. Counting every Arcs bundle slot inflates this to 65, and counting
`_bundle.lua` on top of the slots it duplicates inflates it to 130.)*

---

## 2. Named coordinate tables

Still absolute, but at least addressable. RotLA keeps its world in one literal
table:

```lua
gameEntities = {
    OTHER_ACTORS = {
            ['BANK'] = {
                moneyLabelGUID = 'bf2867',
```
— `reference/mods/rotla/global/script.lua:18`

237 lines, 119 GUID literals. It is a better shape than Almoravid's 925 inline
statements — one place to edit — but it is still absolute, and it is still
addressing objects by GUID (C1).

**Verdict.** A strict improvement over literals scattered through code. Use it as
a stepping stone, not a destination.

---

## 3. Anchor-relative — the right answer

Write the coordinate in the **board's local space** and resolve it through the
board:

```lua
        local target_pos = reach_board.positionToWorld(high_marker.column_pos + this_ambition.row_pos)
```
— `reference/mods/arcs/global/src__AmbitionMarkers.lua:1037`

This is the best placement code in the corpus, and it is worth reading closely.
The position is composed from two data tables — a column per marker:

```lua
        column_pos = Vector({-0.83, 0.2, -1.07}),
```
— `reference/mods/arcs/global/src__AmbitionMarkers.lua:15`

and a row per ambition:

```lua
        row_pos = Vector({0, 0, -0.01})
```
— `reference/mods/arcs/global/src__AmbitionMarkers.lua:103`

Six columns × six rows = 36 positions from 12 numbers. `Vector` supports `+`, so
composition is one operator. Then `positionToWorld` applies the board's position,
rotation **and scale**.

That last part matters here: `reach_board` (`bb7d21`) is scaled **6.015×** on X
and Z. Its 50 attached snap points run −1.034…1.014 on local X and
−1.283…1.277 on local Z — a world-space span of 12.3 × 15.4 units. Writing those
positions as world coordinates would have meant recomputing every one of them if
anyone nudged the board.

The simple form, for a fixed offset:

```lua
        zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
```
— `reference/mods/arcs/global/src__AmbitionMarkers.lua:910`

And for a player's own board, which is exactly the case where absolute
coordinates cannot work:

```lua
                Resource:take(name, self.board.positionToWorld(slot_pos))
```
— `reference/mods/arcs/global/src__ArcsPlayer.lua:298`

Each player's board is at a different transform; one table of `slot_pos` values
serves all of them.

**`positionToWorld` has an inverse**, `positionToLocal` — useful for converting a
position you measured by dragging an object in TTS back into a table you can
check in.

### Y is a stacking layer, not a coordinate

Notice `0.2` in every `column_pos` above, and `0.21` in two of them
(`arcs/global/src__AmbitionMarkers.lua:41` and `:84`). That is "just above the board
surface", repeated by hand — and the two that differ by 0.01 are a
hand-adjustment nobody can now explain.

Name your layers once:

```lua
local LAYER = { board = 0.20, marker = 0.30, card = 0.40, held = 2.00 }
```

Almoravid's Y values run from 6.66 to 7.50 in the block quoted above — those are
world coordinates over a raised board, and there are 925 of them.

---

## 4. Snap points — the one the prototypes are missing

A snap point is **data on the table or on an object**, not code. It makes a
position exist for the *player*, not just for a script. This is the single
biggest gap between the reference mods and the owner's prototypes:

| | table snaps | object snaps | of those, tagged |
| --- | --- | --- | --- |
| Politik | 4 | 1,562 | 1,130 |
| Rurik | 108 | 655 | 28 |
| Arcs | 320 | 245 | 234 |
| Almoravid | 0 | 11 | 0 |
| **owner's prototypes** | **0** | **0** | **0** |

*(`TS_Save_111` "playtest_final_3" and `ProjStdwFinal/TS_Save_22`: zero of
everything.)*

### Table snap points

Top-level `SnapPoints`, in **world space**:

```json
{
  "Position": { "x": -5.43917036, "y": 0.986911833, "z": 1.77675509 },
  "Rotation": { "x": 0.0003196252, "y": 179.991, "z": -0.000820595829 },
  "Tags": ["City", "Starport"]
}
```

`Rotation` is optional — a snap point with one also orients what lands on it,
which is how Arcs gets every card the same way up. 257 of Arcs' 320 carry a
rotation; all 108 of Rurik's do.

`Tags` is optional and is the good part: **only a component carrying a matching
tag will snap there.** 245 of Arcs' 320 table snaps are tagged, with the same
vocabulary the scripts use (`Agent`, `Power`, `Resource`, `Court`, `Edict`,
`Law`, `Doctrine`). One piece of data does double duty — it constrains the
player's drag *and* answers "what is in this slot?" for the script.

> **Snap points are not the only magnet, and usually not the one you are
> fighting (2026-09-21).** TTS has a second, completely separate snapping
> system: the table grid, Options > Grid > Snapping, `Grid.snapping` in the API.
> It is **global** — not per object, not per tag — and at 3 (Centre) on a hex
> grid it pulls every object to the nearest cell centre.
>
> When something snaps that should not, check that first, and **check it live**:
> Amazonia's save file said `"Grid": { "Snapping": false }` while the running
> game reported `Grid.snapping = 3`. A whole afternoon went on the tagged snap
> points, which were innocent. `print(Grid.snapping)` would have settled it in
> ten seconds.
>
> Whether a *tagged* snap point also spares an object carrying **no** tags is
> still not established — every piece in every mod here is tagged, so the corpus
> never exercises it. Until it is, the conservative form is to clear the object's
> own `use_snap_points` (and `use_grid`) on anything that must not snap, which
> does not depend on the answer. Amazonia does that for every non-tile object as
> it spawns, and keeps its own lattice on so tri-hexes still interlock.

### Object snap points

`AttachedSnapPoints` on an object, in **object-local space** — so they move,
rotate and scale with it. This is strategy 3 expressed as data:

```json
{ "Position": { "x": -1.00472736, "y": 0.2093062, "z": 0.0536040142 },
  "Tags": ["Ambition"] }
```

That is one of the **50** snap points attached to Arcs' `reach_board` (`bb7d21`)
— the same board its `positionToWorld` calls resolve against, carrying tags from
the same vocabulary (`City` ×26, `Starport` ×26, `planet` ×25, `Ambition` ×10).
Politik's biggest holder is `3a55e6`, a `Custom_Tile` with **239**.

Note that every one of those 50 sits at local Y 0.209 — one stacking layer,
written once per point. The board is scaled 6.015×, so that is ~1.26 in world
space: local snap points are scaled along with everything else.

**Verdict.** Anything a player places by hand should have a snap point, and if
only one kind of component belongs there, that snap point should be tagged.
Anything a script places should go through `positionToWorld` on an anchor.

---

## The bulk-placement idiom

Setting up 100 components is a loop over data, not 537 statements. Almoravid's
shape is right and its expression is wrong:

```lua
bagSiegeC.takeObject({
    callback_function = function(obj)
        Wait.frames(function()
            if not obj.isDestroyed() then
                obj.setPositionSmooth({3.74,6.66,3.66}, false, false)
				obj.SetRotationSmooth({0,180,0}) 
            end
        end)
    end, 
})
```
— `reference/mods/almoravid/global/script.lua:479`

538 lines of that file mention `takeObject`. Written as data:

```lua
local SETUP = {
  { role = "siege",  at = {-0.20, LAYER.board,  0.55}, facing = 180 },
  { role = "jihad",  at = {-0.25, LAYER.board,  0.17}, facing = 225 },
}

for _, spec in ipairs(SETUP) do
  local bag = reg.one("supply." .. spec.role)          -- by tag, not GUID
  bag.takeObject({ callback_function = function(obj)
    Wait.frames(function()
      if obj.isDestroyed() then return end
      obj.setPositionSmooth(board.positionToWorld(spec.at), false, false)
      obj.setRotationSmooth({0, spec.facing, 0})
    end)
  end })
end
```

Same behaviour, one copy of the mechanism, coordinates that follow the board, and
a table you can print, diff and edit.

**⚠ Note the casing.** Almoravid writes `.SetRotationSmooth(` — capital S —
**630 times**, and `.setRotationSmooth(` 231 times, interleaved through the same
file. The API documents only `setRotationSmooth`
([`reference/api/object.md:172`](../../reference/api/object.md)), and it is the
only capitalised member call anywhere in the five mods. Whether TTS resolves the
capitalised form is
[open question 2](10-antipatterns.md#open-questions-test-these-in-tts). **Write
`setRotationSmooth`.**

---

## Moving things

| Call | Use |
| --- | --- |
| `setPosition(v)` | instant; setup before players look |
| `setPositionSmooth(v, collide, fast)` | animated; what players should see |
| `setRotation(v)` / `setRotationSmooth(v)` | same pair for rotation |
| `obj.isSmoothMoving()` | true while a smooth move is running |
| `obj.resting` | true once physics has settled |

`collide = false` is right for setup — you do not want a piece bouncing off
another mid-placement. See [02](02-lifecycle.md) for waiting on `resting`.

---

## Checklist

- [ ] No world-space coordinate literal in a script.
- [ ] Every placement resolved through an anchor's `positionToWorld`.
- [ ] Positions live in a table, not in statements.
- [ ] Y values come from a named layer constant.
- [ ] Every hand-placed position has a snap point.
- [ ] Snap points that accept one kind of component are tagged.
- [ ] `setRotationSmooth`, lowercase.

**Next:** [08 — Players and turns](08-players-turns.md).
