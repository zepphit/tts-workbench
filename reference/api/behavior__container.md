<!-- vendored from https://api.tabletopsimulator.com/behavior/container/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Container

The Container behavior is present on Container objects such as Bags, Stacks and Decks.

---

## Function Summary

| Function Name | Return | Description |
| --- | --- | --- |
| search(*player* player, *int* max_card) | Activate search window for player, optionally limited to top N cards | *returns bool* |

---

## Function Details

### search(...)

*returns bool*  Show the Search window for the container to `player`. If you specify `max_cards` then the search will be limited to that many cards from the top of the deck.

> **search(player, max_cards)**
>
> - *player* **player**: The player to show the Search window to.
>
> - *int* **max_cards**: Optional maximum number of cards to show.

```
deck.Container.search(Player.Blue, 3)
```
