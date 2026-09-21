<!-- vendored from https://api.tabletopsimulator.com/components/material/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Material

The Material of a Renderer [component](components__component.md) is the primary method of controlling that object's appearance.

## Member Variables

| Name | Type | Description | Return |
| --- | --- | --- | --- |
| game_object | [GameObject](components__gameobject.md) | The GameObject the Material is attached to. |  |
| shader | *string* | The name of the Shader used by the Material. |  |

## Functions

######

######

######

| Name | Return | Description |
| --- | --- | --- |
| get(get(...)*string* name) | *returns var* | Obtains the value of a given Variable on a Material. |
| getVars()getVars() | *returns table* | Returns a table mapping Var names (*string* ) to their type, which is also represented as a *string* . |
| set(set(...)*string* name, *var* value) | *returns bool* | Sets the Var of the specified `name` to the provided `value`. |
