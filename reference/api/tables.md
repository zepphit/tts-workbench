<!-- vendored from https://api.tabletopsimulator.com/tables/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Tables

`Tables` is a global which provides the ability to interact with the Table object.

## Function Summary

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| getCustomURL()getCustomURL() | Returns the image URL of the current [Custom Table](https://kb.tabletopsimulator.com/host-guides/tables/#custom-table), or `nil` if the current table is not a Custom Table. | *returns string* |
| getTable()getTable() | Returns the current Table's [name](object.md#name) i.e. equivalent to `getTableObject().name`. | *returns string* |
| getTableObject()getTableObject() | Returns the current Table object. | *returns object* |
| setCustomURL(setCustomURL(...)*string* url) | Sets the image URL for the current [Custom Table](https://kb.tabletopsimulator.com/host-guides/tables/#custom-table). Has no effect if the current Table is not a Custom Table. | *returns bool* |
| setTable(*string* name) | Replaces the current Table with the Table matching the specified `name`. | *returns bool* |

## Table Names

[getTable()](#gettable) will return one of the following table names. [setTable(...)](#settable) will also accept these names in addition to [human-readable names](#human-readable-names).

- Table_Circular

- Table_Custom

- Table_Custom_Square

- Table_Glass

- Table_Hexagon

- Table_None

- Table_Octagon

- Table_Plastic

- Table_Poker

- Table_RPG

- Table_Square

## Function Details

### setTable(...)

*returns bool*  Replaces the current Table with the Table matching the specified `name`.

> **setTable(name)**
>
> - *string* **name**: Table [name](#table-names) or [human-readable name](#human-readable-names).

#### Human-Readable Names

In addition to the table names [listed above](#table-names), `setTable(...)` will also accept the following human-readable names:

- Custom Rectangle

- Custom Square

- Hexagon

- None

- Octagon

- Poker

- Rectangle

- Round

- Round Glass

- Round Plastic

- Square

> **Example**
>
> Replace the current Table with the Poker Table.

```
Tables.setTable("Poker")
```
