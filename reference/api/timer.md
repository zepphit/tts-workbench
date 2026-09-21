<!-- vendored from https://api.tabletopsimulator.com/timer/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Timer *deprecated*

> **Deprecated**
>
> Use [Wait.frames(...)](wait.md#time) instead.

`Timer` is a static global class which provides methods for executing other functions after a delay and/or repeatedly. Each Timer is tracked by a unique "identifier" string.

> **Warning**
>
> The "identifiers" are shared between Global and all Object scripts, so each Timer must have a unique name.

## Function Summary

| Function Name | Description | Return |
| --- | --- | --- |
| create(*table* parameters) | Creates a Timer. It will auto-delete once its repetitions have been completed. | *returns bool* |
| destroy(*string* identifier) | Destroys a Timer. | *returns bool* |

---

## Function Details

### create(...)

*returns bool*  Creates a Timer. It will auto-delete once its repetitions have been completed.

> **create(parameters)**
>
> - **parameters**: A Table containing the information used to start the Timer.
>
>   - *string* **identifier**: Timer's name, used to destroy it. Must be unique within all other scripts.
>
>   - *string* **function_name**: Name of function to trigger when time is reached.
>
>   - *object* **function_owner**: Where the function from function_name exists.
>
>     - Optional, defaults to the calling Object.
>
>   - *table* **parameters**: Table containing any data that will be passed to the function.
>
>     - Optional, will not be used by default.
>
>   - *float* **delay**: Length of time in seconds before the function is triggered.
>
>     - Optional, defaults to 0.
>
>     - 0 results in a delay of 1 frame before the triggered function activates.
>
>   - *int* **repetitions**: Number of times the countdown repeats.
>
>     - Optional, defaults to 1.
>
>     - Use 0 for infinite repetitions.

```lua
function onLoad()
    dataTable = {welcome="Hello World!"}
    Timer.create({
        identifier     = "A Unique Name",
        function_name  = "fiveAfterOne",
        parameters     = dataTable,
        delay          = 1,
        repetitions    = 5,
    })
end

function fiveAfterOne(params)
    print(params.welcome)
end
```

> **Tip**
>
> If your timer is on an Object, a good way to establish a unique identifier for it is to use the item's GUID!

---

### destroy(...)

*returns bool*  Destroys a Timer. A timer, if it completes its number of repetitions, will automatically destroy itself.

> **destroy(identifier)**
>
> - *string* **identifier**: The unique identifier for the timer you want to destroy.
