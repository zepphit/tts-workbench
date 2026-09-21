<!-- vendored from https://api.tabletopsimulator.com/behavior/counter/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Counter

The Counter behavior is present on the Counter object.

## Functions

######

######

######

######

######

| Function Name | Return | Description |
| --- | --- | --- |
| clear()clear() | *returns bool* | Resets Counter to 0. |
| decrement()decrement() | *returns bool* | Reduces Counter's value by 1. |
| getValue()getValue() | *returns int* | Returns Counter's current value. This function behaves the same as [Object's getValue()](object.md#getvalue). |
| increment()increment() | *returns bool* | Increases Counter's value by 1. |
| setValue()setValue() | *returns bool* | Sets the current value of the Counter. This function behaves the same as [Object's setValue()](object.md#setvalue). |

> **Example**
>
> Increment a counter's value.

```
object.Counter.increment()
```
