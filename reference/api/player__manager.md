<!-- vendored from https://api.tabletopsimulator.com/player/manager/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Player Manager

`Player` is a global which allows you to retrieve [Player instances](player__instance.md) and [Player colors](player__colors.md).

## Function Summary

######

######

| Function Name | Return | Description |
| --- | --- | --- |
| getAvailableColors()getAvailableColors() | *returns table* | Returns a table of strings of every valid seat color at the current table. Returned colors are in the default order. |
| getColors()getColors() | *returns table* | Returns a table of strings of every possible seat color. Returned colors are in the default order. |
| getPlayers() | *returns table* | Returns a table of all [Player instances](player__instance.md). |
| getSpectators() | *returns table* | Returns a table of all spectator (Grey) [Player instances](player__instance.md). |

---

## Actions

The [onPlayerAction](events.md#onplayeraction) event allows you to handle player actions. A list of player actions is available as `Player.Action`.

> **Example**
>
> Log all available player actions:

```
log(Player.Action)
```

For more details about these actions, please refer to the documentation for [onPlayerAction](events.md#onplayeraction).

---

## Function Details

### getPlayers()

*returns table*  Returns a table of all [Player instances](player__instance.md).

> **Example**
>
> Blindfold all players.

```lua
for _, player in ipairs(Player.getPlayers()) do
    player.blindfolded = true
end
```

---

### getSpectators()

*returns table*  Returns a table of all spectator (Grey) [Player instances](player__instance.md).

> **Example**
>
> Print the steam name of all spectators.

```lua
for _, spectator in ipairs(Player.getSpectators()) do
    print(spectator.steam_name)
end
```
