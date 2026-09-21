<!-- vendored from https://api.tabletopsimulator.com/turns/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Turns

Turns, a static global class, is the in-game turns system. It allows you to modify the player turns in the same way that the in-game Turns menu does.

Example usage: `Turns.reverse_order = true`.

## Member Variables

| Variable | Description | Type |
| --- | --- | --- |
| enable | Enable/disable the turns system. | *bool* |
| type | If the turn order is automatic or custom. 1=auto, 2=custom. | *int* |
| order | A table of strings, representing the player turn order. | *table* |
| reverse_order | Enable/disable reversing turn rotation direction. | *bool* |
| skip_empty_hands | Enable/disable skipping empty hands. | *bool* |
| disable_interactations | Enable/disable the blocking of players ability to interact with Objects when it is not their turn. | *bool* |
| pass_turns | Enable/disable a player's ability to pass their turn to another. | *bool* |
| turn_color | The color of the Player whose turn it is. | *string* |

## Function Summary

### Functions

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| endTurn()endTurn() | Ends the current turn. | *returns bool* |
| getNextTurnColor()getNextTurnColor() | Returns the Player Color string of the next player in the turn order. | *returns string* |
| getPreviousTurnColor()getPreviousTurnColor() | Returns the Player Color string of the previous player in the turn order. | *returns string* |
| getTurnOrder()getTurnOrder() | Returns the current turn order. | *returns table* |

---
