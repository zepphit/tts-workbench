# 09 — Decks and cards

The owner's saves are card-heavy — `TS_Save_111` is 157 `Card` objects in 8
decks, `ProjStdwFinal/TS_Save_22` is 95 `CardCustom` in 12 — so this recipe
covers both the runtime API and the JSON invariants that make a hand-built deck
load.

---

## The runtime API

| Call | Does |
| --- | --- |
| `deck.deal(n)` | n cards to every seated player |
| `deck.deal(n, color)` | n cards to one player's hand |
| `deck.deal(n, color, index)` | ...from a specific position |
| `deck.dealToColorWithOffset(offset, flip, color)` | to a spot near a hand zone |
| `deck.shuffle()` | shuffle |
| `deck.randomize()` | shuffle, **and** fire `onObjectRandomized` |
| `deck.takeObject({...})` | one card out, asynchronously |
| `deck.putObject(card)` | one card in |
| `deck.getObjects()` | list the contents without taking them |
| `#deck.getObjects()` | how many are left |

Signatures in [`reference/api/object.md:375`](../../reference/api/object.md)
onward.

### Dealing

```lua
    for _, c in ipairs(colorsForSelectedCount()) do
        deckA.deal(1, c)
        deckB.deal(1, c)
    end
```
— `reference/mods/rurik/global/script.lua:501`

with `deckA.shuffle()` two lines above (`:498`). Deal to a **list of colours you
computed**, not to `getSeatedPlayers()` directly, if your game has a notion of
player count separate from seats ([08](08-players-turns.md)).

`deal(n)` with no colour deals to everyone seated:

```lua
    local deck = ActionCards.get_action_deck()
    deck.randomize()
    Wait.time(function()
        deck.deal(num)
    end, 1)
```
— `reference/mods/arcs/global/src__ActionCards.lua:148`

Note the one-second `Wait.time` between randomize and deal. `randomize()` starts
a *physical* shuffle animation; dealing into the middle of it is unreliable.

`shuffle()` and `randomize()` differ in one way that matters: `randomize(color)`
fires `onObjectRandomized` with that player's colour, so other scripts can
react. Use `shuffle()` for setup, `randomize()` when a player did it.

### Counting before you deal

```lua
function ActionCards.check_deck()
    local deck = ActionCards.get_action_deck()
    local deck_size = #getSeatedPlayers() >= 4 and 28 or 20
    return deck_size <= #deck.getObjects()
end
```
— `reference/mods/arcs/global/src__ActionCards.lua:155`

`getObjects()` on a container is cheap and does not disturb it. Check before
dealing rather than discovering an empty deck mid-setup.

### Taking a specific card

`takeObject` is asynchronous and takes the top card unless told otherwise:

```lua
    self.takeObject({
        position = self.getPosition() + Vector(0,2,0),
        smooth = false,
        callback_function = function(obj)
```
— `reference/mods/rurik/objects/064e16/script.lua:97`

Useful parameters: `position`, `rotation`, `smooth`, `flip`, `index`, `guid`,
`callback_function`, `callback_owner`. Pass `guid` to take a named card rather
than the top one — Arcs does this at
`reference/mods/arcs/objects/7299d7/src__BaseGame.lua:1646` ("Otherwise attempt
to take the specific GUID from the source deck").

**A card inside a deck has no Object.** `getObjectFromGUID` on it returns nil.
The GUID is usable as a `takeObject` parameter, but nothing else. This is the
single most common source of "the GUID is right and it still returns nil".

### Drawing by name

The nickname is the card's identity at runtime:

```lua
      if object.getName() == "SONG OF FREEDOM" and not object.is_face_down then
```
— `reference/mods/arcs/objects/7a33fa/src__CourtDiscard.lua:21`

`is_face_down` is a field, not a method. `getObjects()` entries also expose
`name`, `guid`, `description` and `tags` — enough to find a card without taking
it out:

```lua
      for _, v in ipairs(fud_discard_action_deck.getObjects()) do
```
— `reference/mods/arcs/objects/0289cb/src__ActionCards.lua:270`

**Prefer a tag over a nickname** where you can. Nicknames are player-visible and
editable; see [06](06-objects-tags-containers.md) and the `Nickname` caveat in
[`save-format.md`](../save-format.md#common-object-fields).

---

## The JSON invariants

If you build or edit a deck outside TTS, three rules decide whether it loads.

### `CardID = sheet × 100 + index`

A deck's art comes from sheet images in `CustomDeck`, keyed by sheet number as a
string. The card's `CardID` encodes both:

```
CardID = <CustomDeck sheet key> * 100 + <zero-based index on that sheet>
```

Verified in `Saves/TS_Save_125.json`: sheet `"993"` yields `99300, 99301, …`;
sheet `"478"` yields `47812, 47811, 47810, 47809`.

### `DeckIDs` mirrors `ContainedObjects`, in order

`DeckIDs` **is the draw order**. Reordering one list without the other corrupts
the deck. Removing a card means removing it from both; adding one means it must
land on a sheet with a free slot, or you add a sheet to `CustomDeck`.

```jsonc
{
  "Name": "Deck",
  "DeckIDs": [99300, 99301, 99302],
  "CustomDeck": { "993": { "FaceURL": "...", "NumWidth": 10, "NumHeight": 7, ... } },
  "ContainedObjects": [ { "Name": "Card", "CardID": 99300, "...": "..." } ]
}
```

`tts.py validate` checks both invariants:

```bash
python3 scripts/tts.py validate Saves/TS_Save_127.json
```

### ⚠ A contained card's own `CustomDeck` is stale

This one wastes hours. **Only the deck's `CustomDeck` is authoritative.** Each
card inside carries its own `CustomDeck` block, left over from whatever deck it
previously belonged to, and it is routinely wrong.

Live example in `Saves/TS_Save_125.json`: the card `SILVER TONGUES`, at
`ObjectStates[111].ContainedObjects[0]`, has `CardID` **97007** and its own
`CustomDeck` keyed **`"364"`** — while sitting in the deck `Campaign Court`,
whose `CustomDeck` is keyed **`"970"`**. 97007 is correct *for the deck*. The
card's own block is a fossil.

Check a card's `CardID` against its **parent deck's** sheet map. Checking it
against its own reports hundreds of non-problems — which is exactly why
`tts.py validate`'s `card-sheet-missing` check is scoped to the parent, and why
an unscoped version of it drowned the real findings across every mod.

To see it yourself:

```bash
python3 scripts/tts.py get Saves/TS_Save_125.json 'ObjectStates[111]' --no-children
```

---

## Deck and card types

| `Name` | What |
| --- | --- |
| `Deck` | a stack whose cards are in `ContainedObjects` |
| `DeckCustom` | same, with a custom sheet |
| `Card` | one card |
| `CardCustom` | one card from a custom sheet |

A deck of one card is not a thing: take the last card out and TTS replaces the
deck object with the card. Anything holding a reference to the deck now holds a
destroyed object, which is why Rurik checks the type before shuffling:

```lua
    if deck.type == "Deck" then deck.shuffle() end
```
— `reference/mods/rurik/global/script.lua:270`

That guard is the whole lesson. A "deck" variable can become a `Card` between one
call and the next.

---

## Building decks

`tts.py deck build` generates a deck from a sheet URL plus grid dimensions,
honouring the `CardID` rule, so you never write these ids by hand:

```bash
python3 scripts/tts.py deck build \
    --face <sheet-url> --back <back-url> --cols 10 --rows 7 --count 68 \
    --names cards.txt --tag action --name "Action Deck" -o parts/action.json

python3 scripts/tts.py object add Saves/TS_Save_127.json parts/action.json \
    -o Saves/TS_Save_128.json --at 0,1.5,-4
```

`--names` takes one card nickname per line, in reading order — which is what
makes `Deck.takeObject` findable by name later, and what Almoravid's
`DrawSpecificCard` depends on. The output is a **Saved Object**, so it also drops
straight into TTS's own Objects > Saved Objects menu.

It refuses the two mistakes that are hard to see afterwards: a `--count` larger
than the sheet has slots, and a one-card deck (TTS collapses that back into a
`Card`). Run `validate` on the save afterwards anyway.

The sheet fields: `NumWidth` × `NumHeight` is the grid, so index runs
left-to-right, top-to-bottom from 0. `BackIsHidden` hides the back from other
players; `UniqueBack` means the back image is itself a grid rather than one
shared image. `--sheet` picks the `CustomDeck` key, and it needs to be unique
only *within the deck object* — `TS_Save_100` reuses **12 of its 74 keys** across
different objects, 11 of them pointing at two different sheets and `"4072"` at
three, and it loads fine.

---

## Two traps

**A no-op `Wait` does not pace a loop.** Politik deals in a loop and tries to
space the deals out:

```lua
        for _, color in ipairs(seatedPlayers) do
            currentDeck.deal(1, color)
            Wait.time(function() end, 0.1)
        end
```
— `reference/mods/politik/objects/fb0a83/script.lua:35`

`Wait.time` schedules a callback; it does not block. The loop runs to completion
immediately and then one empty function per player fires 0.1 s later, doing
nothing. All the deals happened in the same frame regardless. If you need paced
deals, use a coroutine with `coroutine.yield(0)` ([02](02-lifecycle.md)) or deal
from inside each callback.

**Deleting a card breaks `DeckIDs`.** Removing an entry from `ContainedObjects`
in a text editor and leaving `DeckIDs` alone produces a deck TTS will load and
then behave strangely with. `validate` catches it; run it every time.

---

## Checklist

- [ ] `getObjects()` before dealing, to check the count.
- [ ] A pause between `randomize()` and `deal()`.
- [ ] `deck.type == "Deck"` checked before any deck-only call.
- [ ] Cards inside a deck addressed by `takeObject{guid=...}`, never
      `getObjectFromGUID`.
- [ ] `CardID` validated against the **parent deck's** `CustomDeck`.
- [ ] `DeckIDs` and `ContainedObjects` edited together.
- [ ] `validate` run before loading anything hand-built.

**Next:** [10 — Antipatterns](10-antipatterns.md).
