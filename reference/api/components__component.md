<!-- vendored from https://api.tabletopsimulator.com/components/component/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Component

> **Danger**
>
> Component APIs are an advanced feature. An **understanding of how Unity works is required** to utilize them.

## Member Variables

| Name | Type | Description | Return |
| --- | --- | --- | --- |
| game_object | [GameObject](components__gameobject.md) | The GameObject the Component composes. |  |
| name | *string* | The name of the Component. |  |

## Functions

######

######

######

| Name | Return | Description |
| --- | --- | --- |
| get(get(...)*string* name) | *returns var* | Obtains the value of a given Variable on a Component. |
| getVars()getVars() | *returns table* | Returns a table mapping Var names (*string* ) to their type, which is also represented as a *string* . |
| set(set(...)*string* name, *var* value) | *returns bool* | Sets the Var of the specified `name` to the provided `value`. |
