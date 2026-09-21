<!-- vendored from https://api.tabletopsimulator.com/behavior/book/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Book

The Book behavior is present on Custom PDF Objects. The Book behaviour allows you to manipulate the displayed PDF.

## Member Variables

| Variable | Type | Description |
| --- | --- | --- |
| page_offset | *int* | The page numbers displayed in the Custom PDF UI are offset by this amount. |

> **Info**
>
> For example, if `page_offset` were set to 10, the first page in the UI would be 11, rather than 1. Negative numbers are accepted, and useful if a rule book contains a front cover, index etc. within the PDF file.

## Function Summary

######

| Function Name | Return | Description |
| --- | --- | --- |
| clearHighlight()clearHighlight() | *returns bool* | Clears the current highlight. |
| getPage(*bool* offsetPageNumbering) | *returns int* | Gets the current page of the PDF. |
| setHighlight(*float* x1, *float* y1, *float* x2, *float* y2) | *returns bool* | Set highlight box on current page. |
| setPage(*int* page, *bool* offsetPageNumbering) | *returns bool* | Set current page. |

---

## Function Details

#### getPage(...)

*returns int*  Gets the current page of the PDF.

> **getPage(offsetPageNumbering)**
>
> - *bool* **offsetPageNumbering**: Indicates whether or not [page_offset](#page_offset) should be applied to the page number returned.
>
>   - Optional, defaults to `false`.

---

#### setHighlight(...)

*returns bool*  Draws a highlight rectangle on the popout mode of the PDF at the given coordinates. Coordinates (0,0) are the lower left corner of the PDF, while coordinates (1,1) are the upper right corner.

> **setHighlight(x1, y1, x2, y2)**
>
> - *float* **x1**: x coordinate of the rectangle's left side.
>
> - *float* **y1**: y coordinate of the rectangle's bottom side.
>
> - *float* **x2**: x coordinate of the rectangle's right side.
>
> - *float* **y2**: y coordinate of the rectangle's top side.
>
> **Example**
>
> Highlight the upper right quarter of a PDF.

```
object.Book.setHighlight(0.5, 0.5, 1, 1)
```

---

#### setPage(...)

*returns bool*  Sets the current page of the PDF. Returns true if the page was succesfully set, false if the page number was invalid.

> **setPage(page, offsetPageNumbering)**
>
> - *int* **page**: The new page number.
>
> - *bool* **offsetPageNumbering**: Indicates whether or not [page_offset](#page_offset) should be applied to the page number set.
>
>   - Optional, defaults to `false`.
