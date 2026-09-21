<!-- vendored from https://api.tabletopsimulator.com/ui/basicelements/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Basic Elements

These are display-type elements for the UI. They cannot send information to any Lua scripts.

Each element has its own attributes specific to its type that work in addition to the [common attributes](ui__attributes.md#common-attributes).

## Element Summary

| Element Name | Description |
| --- | --- |
| `<Text></Text>` | Adds basic text. |
| `<Image></Image>` | Adds an image. |
| `<ProgressBar></ProgressBar>` | Displays a progress bar which can be updated dynamically via script. |

---

## Element Details

### Text

Adds basic text. This tag supports Rich Text as shown in the example below.

-

-

-

-

-

-

-

-

-

-

-

-

-

-

-

-

-

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| text | This can be used to determine the text that appears. It can also be modified externally by the script. | string | *(none)* |
| alignment |  | UpperLeftUpperCenterUpperRightMiddleLeftMiddleCenterMiddleRightLowerLeftLowerCenterLowerRight | MiddleCenter |
| color |  | *color* | `#323232` |
| fontStyle |  | NormalBoldItalicBoldItalic | `Normal` |
| fontSize |  | float | `14` |
| resizeTextForBestFit | Resize text to fit? | *bool* | `false` |
| resizeTextMinSize | Minimum font size | float | `10` |
| resizeTextMaxSize | Maximum font size | float | `40` |
| horizontalOverflow |  | WrapOverflow | `Overflow` |
| verticalOverflow |  | TruncateOverflow | `Truncate` |

> **Example**

```
<!-- Standard Text element -->
<Text>Some Text</Text>

<!-- Rich Text -->
<Text>
    This text is <b>Bold</b>, <i>Italic</i>, 
    and <textcolor color="#00FF00">Green</textcolor>.    
    This text is <textsize size="18">Larger</textsize>.
</Text>
```

---

### Image

Adds an image.

-

-

-

-

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| image | The name of the file in the asset manager (upper right corner of the scripting window in-game). | string | *(none)* |
| color |  | *color* | `#FFFFFF` |
| type | Image Type | SimpleSlicedFilledTiled | `Simple` |
| raycastTarget | Should this image block clicks from passing through it? | *bool* | `true` |

---

### ProgressBar

Displays a progress bar which can be updated dynamically via script.

-

-

-

-

-

-

-

-

-

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| image | Background Image | (path to image) | *(none)* |
| color | Background Color | *color* | `#FFFFFF` |
| fillImage | Fill Image | string | *(none)* |
| fillImageColor | Fill Color | *color* | `#FFFFFF` |
| percentage | Percentage to Display | float | `0` |
| showPercentageText | Is the percentage text displayed? | *bool* | `true` |
| percentageTextFormat | Format to use for the percentage text | string | `0.00` |
| textColor | Percentage Text Color | *color* | `#000000` |
| textShadow | Percentage Text Shadow Color | *color* | *(none)* |
| textOutline | Percentage Text Outline Color | *color* | *(none)* |
| textAlignment | Percentage Text Alignment | UpperLeftUpperCenterUpperRightMiddleLeftMiddleCenterMiddleRightLowerLeftLowerCenterLowerRight | `MiddleCenter` |

---
