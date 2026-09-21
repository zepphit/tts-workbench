<!-- vendored from https://api.tabletopsimulator.com/components/gameobject/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# GameObject

> **Danger**
>
> Component APIs are an advanced feature. An **understanding of how Unity works is required** to utilize them.

## Member Variables

| Name | Type | Description |
| --- | --- | --- |
| name | *string* | The name of the GameObject. |

## Functions

######

######

######

######

######

######

######

######

| Name | Return | Description |
| --- | --- | --- |
| getChild(getChild(...)*string* name) | [GameObject](components__gameobject.md) | Returns a child GameObject matching the specified `name`. |
| getChildren()getChildren() | *returns table* | Returns the list of children GameObjects. |
| getComponent(getComponent(...)*string* name) | [Component](components__component.md) | Returns a Component matching the specified `name` from the GameObject's list of Components. |
| getComponentInChildren(getComponentInChildren(...)*string* name) | [Component](components__component.md) | Returns a Component matching the specified `name`. Found by searching the Components of the GameObject and its [children](#getchildren) recursively (depth first). |
| getComponents(getComponents(...)*string* name) | *returns table* | Returns the GameObject's list of Components. `name` is optional, when specified only Components with specified `name` will be included. |
| getComponentsInChildren(getComponentsInChildren(...)*string* name) | *returns table* | Returns a list of Components found by searching the GameObject and its [children](#getchildren) recursively (depth first). `name` is optional, when specified only Components with specified `name` will be included. |
| getMaterials()getMaterials() | *returns table* | Returns the GameObject's list of Materials. |
| getMaterialsInChildren()getMaterialsInChildren() | *returns table* | Returns a list of Materials found by searching the GameObject and its [children](#getchildren) recursively (depth first). |
