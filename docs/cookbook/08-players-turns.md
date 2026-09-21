# 08 — Players and turns

Seats, colours, cameras, chat and turn order.

---

## Players are colours, and most colours are empty

`Player` is a table keyed by colour name — `Player["Blue"]`, `Player[player.color]`.
An entry exists for every colour TTS supports whether or not anyone is sitting
there, so **`.seated` is the only thing that tells you a human is present.**

Two ways to ask, both in Rurik's Global, thirty lines apart.

The guarded form:

```lua
local function seatedPlayableColors()
    local seated = {}
    for _, c in ipairs(PLAYABLE_COLORS) do
        if Player[c] and Player[c].seated then table.insert(seated, c) end
    end
    return seated
end
```
— `reference/mods/rurik/global/script.lua:96`

and the unguarded form, in the same file:

```lua
function setPlayerAmount()
    local playerAmount = 0
    if Player["Blue"].seated   then playerAmount = playerAmount + 1 end
    if Player["Yellow"].seated then playerAmount = playerAmount + 1 end
```
— `reference/mods/rurik/global/script.lua:128`

The second works only because Blue, Yellow, Red and Purple are always-present
colours. Point it at a colour your table does not have and it is a nil index —
an error, not a `false`. Write `Player[c] and Player[c].seated`.

The built-in shortcut is `getSeatedPlayers()`, which returns a list of colour
strings:

```lua
    local deck_size = #getSeatedPlayers() >= 4 and 28 or 20
```
— `reference/mods/arcs/global/src__ActionCards.lua:157`

```lua
    PLAYER_COUNT = math.min(math.max(#getSeatedPlayers(), 1),7)
```
— `reference/mods/rotla/global/script.lua:488`

RotLA's clamp is worth copying: `math.max(..., 1)` means a solo test does not
divide by zero, and `math.min(..., 7)` caps at the supported count.

**Seats are not your player count.** Rurik keeps a *selected* count in a tracker
object's `GMNotes` and refuses to start when the two disagree:

```lua
    local forcedAmount = selectedPlayerCount()
    if forcedAmount ~= playerAmount then return -1 end
```
— `reference/mods/rurik/global/script.lua:135`

That check is right; storing the count in `GMNotes` is not ([05](05-state.md)).

---

## Colour is the identity

The colour string is the key for everything — `Player[color]`, tags like
`RedPiece`, `broadcastToColor`, and TTS's own turn system.

```lua
    local color_tag = self.color .. "Piece"
```
— `reference/mods/arcs/global/src__ArcsPlayer.lua:317`

Arcs builds its per-player component tag by concatenation, then intersects it
with a role tag ([06](06-objects-tags-containers.md)). Rurik tags components with
the bare colour — `Blue`, `Yellow`, `Red`, `Purple`:

```lua
        if o and o.type=="Bag" and o.hasTag and o.hasTag("Coin") and o.hasTag(playerColor) then
```
— `reference/mods/rurik/global/script.lua:1364`

Either convention works. Pick one and keep it: a mod that uses both `Blue` and
`BluePiece` has two vocabularies to get wrong.

Player fields worth knowing: `.color`, `.seated`, `.steam_name`. Arcs caches
`steam_name` behind a `Global.call` because reading it is not always cheap or
available — `get_cached_steam_name`, 5 call sites.

---

## Telling players things

| Call | Reaches |
| --- | --- |
| `broadcastToAll(msg, color)` | everyone, big on-screen text |
| `broadcastToColor(msg, playerColor, msgColor)` | one player |
| `printToAll(msg, color)` | everyone, chat only |
| `printToColor(msg, playerColor, color)` | one player, chat only |

Use counts, deduplicated: Arcs 163 `broadcastToAll`, RotLA 37, Rurik 37,
Almoravid 14, Politik 4.

**Prefer `broadcastToColor` for anything that is one player's problem.** Rurik's
advisor tokens do this well — a private refusal rather than an announcement:

```lua
        broadcastToColor("That Advisor belongs to "..owner..".", playerColor, {1,0.6,0.2})
```
— `reference/mods/rurik/objects/7856d0/script.lua:45`

Note the argument order: **message, target colour, message colour.**
`broadcastToAll` takes only two. Getting these the wrong way round is a common
silent no-op.

Colour arguments accept `{r,g,b}`, `{1,0.6,0.2}` positional, or a colour string.
Rurik's boot error uses the named form, `{r=1,g=0.2,b=0.2}`
(`rurik/global/script.lua:168`). Politik converts a colour name for chat:

```lua
        broadcastToAll(message, stringColorToRGB(colorString))
```
— `reference/mods/politik/global/script.lua:95`

so a player's message appears in that player's colour. `printToAll` with a
`Color(...)` works the same way
(`reference/mods/politik/objects/1efc34/script.lua:119`).

---

## Cameras

`Player[color].lookAt{...}` moves one player's camera. It is per-player — there
is no global camera.

```lua
function onCourtClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=22.26, y=1.49, z=0.0},
        pitch = 70,
        yaw = 90,
        distance = 10
    })
end
```
— `reference/mods/arcs/global/src__Camera.lua:7`

`position` is where to look, `pitch` the angle above the table, `yaw` the
compass bearing, `distance` how far back. Arcs has nine of these, one per region
of the table; Politik has seven, one per player seat:

```lua
function onCameraRedClick(player)
    Player[player.color].lookAt({position = {0, -3, -22.00}, pitch = 90, yaw = 0, distance = 25})
end
```
— `reference/mods/politik/global/script.lua:156`

**Always `player.color`, never a hardcoded colour** — otherwise one player's
click moves someone else's camera.

Politik shows the pattern worth copying: generate the *buttons* from the seated
players so nobody gets a jump-to-seat button for an empty chair.

```lua
function createCameraButtons()
    local seatedPlayers = getSeatedPlayers()
    local seatedColors = {}
```
— `reference/mods/politik/global/script.lua:165`

```lua
        if btn.alwaysShow or seatedColors[btn.playerColor] then
```
— `reference/mods/politik/global/script.lua:189`

Its camera-button table is also where the `#1E87FFF` seven-digit hex bug lives,
at `:179` ([10](10-antipatterns.md)).

---

## Hands

Each seat has a hand zone, addressed through its player:

```lua
    local hand_zone = Player[player_color].getHandTransform()
```
— `reference/mods/arcs/global/src__ActionCards.lua:521`

Returns a transform table — `position`, `rotation`, `scale` — which is how you
deal to a place rather than to a player:

```lua
                    position = Player[color].getHandTransform().position,
```
— `reference/mods/arcs/global/src__Control.lua:181`

`getHandObjects()` returns what is in the hand:

```lua
        if #Player[player.color].getHandObjects() > 0 then
```
— `reference/mods/arcs/global/src__ActionCards.lua:164`

Arcs guards the call itself, having been bitten by version differences:

```lua
    -- Try Player[color].getHandObjects() (works in many TTS versions)
```
— `reference/mods/arcs/global/src__SheetsSenderOverlay.lua:79`

```lua
        if pl.getHandObjects then
```
— `reference/mods/arcs/global/src__SheetsSenderOverlay.lua:83`

A hand zone is an ordinary `HandTrigger` object in `ObjectStates`, so the owner's
prototypes already have them: `TS_Save_111` has 8, `ProjStdwFinal/TS_Save_22`
has 8. See [`reference/api/hands.md`](../../reference/api/hands.md).

---

## Turns

TTS has a built-in turn system. Arcs drives it rather than reimplementing it — 25
`Turns.*` references across its modules.

Configure it once:

```lua
    Turns.type = 2
    Turns.order = active_player_colors
    Turns.turn_color = active_players[1].color
```
— `reference/mods/arcs/objects/7299d7/src__BaseGame.lua:1049`

```lua
  Turns.enable = true
  Turns.pass_turns = true
```
— `reference/mods/arcs/global/src__Global.lua:2666`

| Field | Meaning |
| --- | --- |
| `Turns.enable` | the system is on |
| `Turns.type` | `1` = seat order, `2` = custom (`Turns.order`) |
| `Turns.order` | list of colours, for `type = 2` |
| `Turns.turn_color` | whose turn it is — **read and write** |
| `Turns.pass_turns` | players may pass |
| `Turns.getTurnOrder()` | the resolved order |

**Advance the turn by assigning to `Turns.turn_color`:**

```lua
    Turns.turn_color = next_turn_color
```
— `reference/mods/arcs/objects/6e21fe/src__RoundManager.lua:100`

and Arcs seizes initiative the same way at `arcs/global/src__Control.lua:346`.

**Read it, but guard it.** `Turns.turn_color` is `""` before the first turn:

```lua
    if not Turns.turn_color or Turns.turn_color == "" then
        broadcastToAll("No active turn - please use the turn system", {1, 0, 0})
        return
    end
```
— `reference/mods/arcs/global/src__Timer.lua:24`

Both halves of that check are needed, and refusing loudly is better than
proceeding with a nil colour. Arcs' per-player timer keys its accumulator by
`Turns.turn_color` (`arcs/global/src__Timer.lua:72`), which is exactly what the built-in
system is for.

React to turn changes with `onPlayerTurn(player, previous_player)` —
`reference/mods/arcs/global/src__Global.lua:906`. Full reference:
[`reference/api/turns.md`](../../reference/api/turns.md).

---

## Ordered player lists

Turn order and seat order are not the same thing, and neither is the order
`getSeatedPlayers()` returns. Arcs makes this a service on its `Global.call` bus
— `getOrderedPlayers` (13 call sites) and `getOrderedPlayersStartingWith` (6),
defined at `reference/mods/arcs/global/src__Global.lua:1193`.

That bus is 13 named functions and 60 call sites across the deduplicated corpus.
It is the right idea — one owner for cross-script logic — undermined by the fact
that `Global.call` takes a **string**, so nothing checks the name exists. A typo
is a nil return, silently. Rurik at least reports:

```lua
function safeCall(fnName, ...)
    local fn = _G[fnName]
    if type(fn) ~= "function" then
        broadcastToAll("MISSING FUNCTION: "..tostring(fnName), {r=1,g=0.6,b=0.2})
        return false
    end
```
— `reference/mods/rurik/global/script.lua:80`

---

## Checklist

- [ ] Every `Player[c]` guarded, or obtained from `getSeatedPlayers()`.
- [ ] `player.color` from the handler, never a hardcoded colour.
- [ ] One player's problem uses `broadcastToColor`, not `broadcastToAll`.
- [ ] `broadcastToColor(msg, targetColor, msgColor)` — argument order checked.
- [ ] Per-player UI regenerated on `onPlayerConnect` ([02](02-lifecycle.md)).
- [ ] `Turns.turn_color` guarded against `""`.
- [ ] Turn order comes from `Turns`, not a hand-rolled list.

**Next:** [09 — Decks and cards](09-decks-cards.md).
