<!-- vendored from https://api.tabletopsimulator.com/backgrounds/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Backgrounds

`Backgrounds` is a global which provides the ability to interact with the background.

Example Usage:`Backgrounds.getBackground()`.

## Function Summary

| Function Name | Description | Return |
| --- | --- | --- |
| getBackground() | Returns the current background name. | *returns string* |
| getCustomURL() | Returns the image URL of the current custom background, or `nil` if the current background is not custom. | *returns string* |
| setBackground(*string* name) | Replaces the current background with the background matching the specified `name`. | *returns bool* |
| setCustomURL(*string* url) | Replaces the current background with a custom background loaded from the specified `url`. | *returns bool* |

---
