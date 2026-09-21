<!-- vendored from https://api.tabletopsimulator.com/json/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# JSON

The static global JSON class provides the ability to encode/decode data into JSON strings. This is largely used by the [onSave()](events.md#onsave) event function, but has other potential applications as well. The JSON class can be used on any String, Int, Float or Table. You call these functions like this: `JSON.encode(...)`.

> **Warning**
>
> This class **does not** work with Object references. Use the Object's GUID instead.

## Function Summary

| Function Name | Description | Return |
| --- | --- | --- |
| decode(*string* json_string) | Value obtained from the encoded string. Can return a number, string or Table. | *returns var* |
| encode(*var* data) | Encodes data from a number, string or Table into a JSON string. | *returns string* |
| encode_pretty(*var* data) | Same as encode(...) but this version is slightly less efficient but is easier to read. | *returns string* |

---

## Function Details

### decode(...)

*returns var*  Value obtained from the encoded string. Can return a number, string or Table.

> **decode(json_string)**
>
> - *string* **json_string**: A String that is decoded, generally created by encode(...) or encode_pretty(...).

```
coded = JSON.encode("Test")
print(coded) --Prints "Test"
decoded = JSON.decode(coded)
print(decoded) --Prints Test
```

---

### encode(...)

*returns string*  Encodes data from a number, string or Table into a JSON string.

> **encode(data)**
>
> - *var* **data**: A Var, either String, Int, Float or Table, to encode as a string.

---

### encode_pretty(...)

*returns string*  Encodes data from a number, string or Table into a JSON string. This version is slightly less efficient but is easier to read.

> **encode_pretty(data)**
>
> - *var* **data**: A Var, either String, Int, Float or Table, to encode as a string.
