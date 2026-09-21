<!-- vendored from https://api.tabletopsimulator.com/ui/layoutgrouping/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Layout/Grouping

By nesting elements within layouts/groupings, you are able to easily group elements together in-game. It allows for adjusting/moving them together, uniform padding and additional visual flair possibilities.

Each layout element has its own attributes specific to its type. Additionally, elements within a layout are subject to common [common layout element attributes](ui__attributes.md#layout-element-attributes).

## Element Summary

### Layout Summary

| Element Name | Description |
| --- | --- |
| `<Panel></Panel>` | A "window" in which elements can be confined. |
| `<HorizontalLayout></HorizontalLayout>` | A horizontal row of elements. |
| `<VerticalLayout></VerticalLayout>` | A vertical column of elements. |
| `<GridLayout></GridLayout>` | A grid of elements. |
| `<TableLayout></TableLayout>` | A layout element based on HTML tables, allowing you to specify the position of elements in specific rows/columns. |
| `<Row></Row>` | A row within a TableLayout. |
| `<Cell></Cell>` | A cell within a TableLayout. |

### Scroll View Summary

| Element Name | Description |
| --- | --- |
| `<HorizontalScrollView></HorizontalScrollView>` | A scrollable horizontal row of elements. |
| `<VerticalScrollView></VerticalScrollView>` | A scrollable vertical column of elements. |

---

## Layout Element Details

### Layout Details

#### Panel

A "window" in which elements can be confined.

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| padding | Specifies the padding for this panel. Please note that if padding is specified, the panel will function as a LayoutGroup (which it does not do by default). | float(left) float(right) float(top) float(bottom) | *(none)* |

```
<Panel>
    <Text>Text contained within Panel</Text>
</Panel>
```

---

#### HorizontalLayout

A horizontal row of elements.

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
| padding |  | float(left) float(right) float(top) float(bottom) | `0 0 0 0` |
| spacing | Spacing between child elements. | float | `0` |
| childAlignment |  | UpperLeftUpperCenterUpperRightMiddleLeftMiddleCenterMiddleRightLowerLeftLowerCenterLowerRight | `UpperLeft` |
| childForceExpandWidth |  | *bool* | `true` |
| childForceExpandHeight |  | *bool* | `true` |

```
<HorizontalLayout>
    <Button>Button One</Button>
    <Button>Button Two</Button>
    <Button>Button Three</Button>
</HorizontalLayout>
```

---

#### VerticalLayout

A vertical column of elements.

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
| padding |  | float(left) float(right) float(top) float(bottom) | `0 0 0 0` |
| spacing | Spacing between child elements. | float | `0` |
| childAlignment |  | UpperLeftUpperCenterUpperRightMiddleLeftMiddleCenterMiddleRightLowerLeftLowerCenterLowerRight | `UpperLeft` |
| childForceExpandWidth |  | *bool* | `true` |
| childForceExpandHeight |  | *bool* | `true` |

```
<VerticalLayout>
    <Button>Button One</Button>
    <Button>Button Two</Button>
    <Button>Button Three</Button>
</VerticalLayout>
```

---

#### GridLayout

A grid of elements.

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

-

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| padding |  | float(left) float(right) float(top) float(bottom) | `0 0 0 0` |
| spacing | Spacing between child elements | float(x) float(y) | `0 0` |
| cellSize |  | float(x) float(y) | `100 100` |
| startCorner |  | UpperLeftUpperRightLowerLeftLowerRight | `UpperLeft` |
| startAxis |  | HorizontalVertical | `Horizontal` |
| childAlignment |  | UpperLeftUpperCenterUpperRightMiddleLeftMiddleCenterMiddleRightLowerLeftLowerCenterLowerRight | `UpperLeft` |
| constraint |  | FlexibleFixedColumnCountFixedRowCount | `Flexible` |
| constraintCount |  | integer | `2` |

```
<GridLayout>
    <Button>Button One</Button>
    <Button>Button Two</Button>
    <Button>Button Three</Button>
</GridLayout>
```

---

#### TableLayout

A layout element based on HTML tables, allowing you to specify the position of elements in specific rows/columns.

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| padding |  | float(left) float(right) float(top) float(bottom) | `0 0 0 0` |
| cellSpacing | Spacing between each cell. | float | `0` |
| columnWidths | (Optional) Explicitly set the width of each column. Use a value of 0 to auto-size a specific column. | float list - e.g. '32 0 0 32' | *(none)* |
| automaticallyAddColumns | If more cells are added to a row than are accounted for by columnWidths, should this TableLayout automatically add one or more new auto-sized entries (0) to columnWidths? | *bool* | `true` |
| automaticallyRemoveEmptyColumns | If there are more entries in columnWidths than there are cells in any row, should this TableLayout automatically remove entries from columnWidths until their are no 'empty' columns? | *bool* | `true` |
| autoCalculateHeight | If set to true, then the height of this TableLayout will automatically be calculated as the sum of each rows preferredHeight value. This option cannot be used without explicitly sized rows. | *bool* | `false` |
| useGlobalCellPadding | If set to true, then all cells will use this TableLayout's cellPadding value. | *bool* | `true` |
| cellPadding | Padding for each cell. | float(left) float(right) float(top) float(bottom) | `0 0 0 0` |
| cellBackgroundImage | Image to use as the background for each cell. | string |  |
| cellBackgroundColor | Color for each cells background. | *color* | `rgba(1,1,1,0.4)` |
| rowBackgroundImage | Image to use as the background for each row. | string |  |
| rowBackgroundColor | Color to use for each rows background. | *color* | `clear` |

```
<TableLayout>
    <!-- Row 1 -->
    <Row>
        <Cell><Button>Button One</Button></Cell>
        <Cell><Button>Button Two</Button></Cell>
    </Row>
    <!-- Row 2 -->
    <Row>
        <Cell><Button>Button One</Button></Cell>
        <Cell><Button>Button Three</Button></Cell>
    </Row>
</TableLayout>
```

##### Row

A row within a TableLayout.

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| preferredHeight | Sets the height for this row. Use a value of '0' to specify that this row should be auto-sized. | float | `0` |
| dontUseTableRowBackground | If set to true, then this row will ignore the tables' *rowBackgroundImage* and *rowBackgroundColor* values, allowing you to override those values for this row. | *bool* | `false` |

##### Cell

A cell within a TableLayout.

| Attribute Name | Description | Type / Options | Default Value |
| --- | --- | --- | --- |
| columnSpan | __ | int | `1` |
| dontUseTableCellBackground | If set to true, then this cell will ignore the tables' *cellBackgroundImage* and values, allowing you to override those values for this cell. | *bool* | `false` |
| overrideGlobalCellPadding | If set to true, then this cell will ignore the tables' *cellPadding* value, allowing you to set unique cell padding for this cell. | *bool* | `false` |
| padding | Padding values to use for this cell if *overrideGlobalCellPadding* is set to true. | float(left) float(right) float(top) float(bottom) | `0 0 0 0` |
| childForceExpandWidth |  | *bool* | `true` |
| childForceExpandHeight |  | *bool* | `true` |

---

### Scroll View Details

#### HorizontalScrollView

A scrollable horizontal row of elements. This is an [input element](ui__inputelements.md).

A layout element such as a Panel, HorizontalLayout, GridLayout, or TableLayout can be used to position child elements within the Scroll View.

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
| onValueChanged | When a selection is made, its name is sent to a function with this name. | string | *(none)* |
| horizontal |  | *bool* | `true` |
| vertical |  | *bool* | `false` |
| movementType |  | UnrestrictedElasticClamped | `Clamped` |
| elasticity |  | float | `0.1` |
| inertia |  | *bool* | `true` |
| decelerationRate |  | float | `0.135` |
| scrollSensitivity |  | float | `1` |
| horizontalScrollbarVisibility |  | PermanentAutoHideAutoHideAndExpandViewport | `AutoHide` |
| verticalScrollbarVisibility |  | PermanentAutoHideAutoHideAndExpandViewport | *(none)* |
| noScrollbars | If set to true, then this scroll view will have no visible scrollbars. | *bool* | `false` |
| scrollbarBackgroundColor |  | *color* | `#FFFFFF` |
| scrollbarColors |  | *colorblock* | `#FFFFFF\|#FFFFFF\|#C8C8C8\|rgba(0.78,0.78,0.78,0.5)` |
| scrollbarImage |  | string |  |

```
<HorizontalScrollView>
    <HorizontalLayout>
        <Panel>
            <Text>1</Text>
        </Panel>
        <Panel>
            <Text>2</Text>
        </Panel>
        <Panel>
            <Text>3</Text>
        </Panel>
        <Panel>
            <Text>4</Text>
        </Panel>
    </HorizontalLayout>
</HorizontalScrollView>
```

---

#### VerticalScrollView

A scrollable vertical column of elements. This is an [input element](ui__inputelements.md).

A layout element such as a Panel, HorizontalLayout, GridLayout, or TableLayout can be used to position child elements within the Scroll View.

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
| onValueChanged | When a selection is made, its name is sent to a function with this name. | string | *(none)* |
| horizontal |  | *bool* | `false` |
| vertical |  | *bool* | `true` |
| movementType |  | UnrestrictedElasticClamped | `Clamped` |
| elasticity |  | float | `0.1` |
| inertia |  | *bool* | `true` |
| decelerationRate |  | float | `0.135` |
| scrollSensitivity |  | float | `1` |
| horizontalScrollbarVisibility |  | PermanentAutoHideAutoHideAndExpandViewport | *(none)* |
| verticalScrollbarVisibility |  | PermanentAutoHideAutoHideAndExpandViewport | `AutoHide` |
| noScrollbars | If set to true, then this scroll view will have no visible scrollbars. | *bool* | `false` |
| scrollbarBackgroundColor |  | *color* | `#FFFFFF` |
| scrollbarColors |  | *colorblock* | `#FFFFFF\|#FFFFFF\|#C8C8C8\|rgba(0.78,0.78,0.78,0.5)` |
| scrollbarImage |  | string |  |

```
<VerticalScrollView>
    <VerticalLayout>
        <Panel>
            <Text>1</Text>
        </Panel>
        <Panel>
            <Text>2</Text>
        </Panel>
        <Panel>
            <Text>3</Text>
        </Panel>
        <Panel>
            <Text>4</Text>
        </Panel>
    </VerticalLayout>
</VerticalScrollView>
```

---
