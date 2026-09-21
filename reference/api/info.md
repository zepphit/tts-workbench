<!-- vendored from https://api.tabletopsimulator.com/info/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Info

`Info` global allows you to manipulate the information about your game/mod, in the same way as the in-game Options -> Info menu.

This information helps players find your game/mod within Tabletop Simulator's server list and via Steam Workshop's search/filter capabilities.

> **Example Usage**

```
Info.name = "My Game"
```

## Member Variables

| Variable | Description | Type |
| --- | --- | --- |
| complexity | The complexity of the current game/mod. | *string* |
| name | Name of the current game/mod. | *string* |
| number_of_players | The number of players the current game/mod allows. | *table* |
| playing_time | The amount of time the current game/mod takes. | *table* |
| tags | The tags associated with the current game/mod. | *table* |
| type | The category of the current mod. | *string* |
