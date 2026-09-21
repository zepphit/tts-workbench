<!-- vendored from https://api.tabletopsimulator.com/behavior/browser/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Browser

The Browser behavior is present on the Tablet Object.

> **Example**
>
> Instruct a Tablet Object to load the Tabletop Simulator homepage.

```
object.Browser.url = "https://tabletopsimulator.com"
```

## Member Variables

| Variable | Type | Description |
| --- | --- | --- |
| url | *string* | URL which currently wants to display. |
| pixel_width | *int* | The pixel width the browser is virtually rendering to. |
