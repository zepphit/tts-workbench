<!-- vendored from https://api.tabletopsimulator.com/hands/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Hands

The static global `Hands` class allows you to control the behavior of Hand Zones.

## Member Variables

### Member Variable Summary

| Variable | Description | Type |
| --- | --- | --- |
| enable | Whether hand zones are enabled i.e. hold objects. | *bool* |
| disable_unused | Whether hands zones belonging to a color without a seated player should be disabled. | *bool* |
| hiding | Determines which hand contents are hidden from which players. | *int* |

## Member Variable Details

#### hiding

*int*  Determines which hands are hidden from which players.

| Value | Description |
| --- | --- |
| 1 | Default. The contents of a player's hands are only visible to the owner. |
| 2 | Reverse. The contents of a player's hands are visible to all other players, but not the owner. |
| 3 | Disable. Contents of all player hands are visible to all players. |

> **Example**
>
> Make all hand contents visible to everyone.

```
Hands.hiding = 3
```

---

## Function Summary

| Function Name | Description | Return |
| --- | --- | --- |
| getHands() | Returns a table of all Hand Zone Objects in the game. | *returns table* |

---
