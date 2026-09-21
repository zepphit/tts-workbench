<!-- vendored from https://api.tabletopsimulator.com/time/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Time

`Time`, not to be confused with the deprecated [Timer](timer.md) class, is a static global class which provides access to Unity's time information.

> **Example Usage**

```
Time.time
```

## Member Variables

| Function Name | Description | Return |
| --- | --- | --- |
| time | The current time. Works like `os.time()` but is more accurate. Read only. | *returns float* |
| delta_time | The amount of time since the last frame. Read only. | *returns float* |
| fixed_delta_time | The interval (in seconds) between physics updates. Read only. | *returns float* |
