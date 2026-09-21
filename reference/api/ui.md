<!-- vendored from https://api.tabletopsimulator.com/ui/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# UI

UI, a static global class AND an Object class. It is the method to interact with custom UI elements. It allows you to read/write attributes of elements defined in the XML of the UI. It also allows you to receive information from various inputs (like buttons) on-screen and on objects.

> **Attention**
>
> This class allows for the **manipulation** of UI **at runtime**. It does **NOT** modify or fetch **the original XML** in the editor, but rather what is displayed as it continues to run during a game. Just like with Lua, you can only get/set dynamic values during runtime. You can use [onSave](events.md#onsave) and [onLoad](events.md#onload) to record any data you want to persist through save/load/undo.
>
> For more information on how to build UI elements within XML, view the [UI API](ui__introUI.md).

## Global and Object

UI can either be placed on the screen by using the **Global UI** or placed on an Object using **Object UI**. Depending on which you are using, these commands are used differently.

```lua
Example of calling a function targeted at the Global UI:
    UI.getAttributes(id)
Example of calling a function targeted at an Object UI:
    object.UI.getAttributes(id)
```

## Inputs

[Input Elements](ui__inputelements.md) are able to trigger a function. By default, Global UI will trigger a function in Global and Object UI will trigger a function in the Object's script. To change the target script for an input, [view more details here](ui__inputelements.md#targeting-triggers).

When creating the input element in XML, you will select the name of the function it activates. Regardless of its name, it always will pass parameters

> **functionName(player, value, id)**
>
> - *player* **player**: A direct Player reference to the person that triggered the input.
>
> - *var* **value**: The value sent by the input. A numeric value or a string, generally.
>
>   - This is not used by buttons!
>
> - *string* **id**:
>
>   - This is only passed if the element was given an Id attribute in the XML.

```lua
function onButtonClick(player, value, id)
    print(player.steam_name)
    print(id)
end
```

---

## Member Variable Summary

| Variable | Description | Type |
| --- | --- | --- |
| loading | Indicates whether (the server) has finished loading all UI custom assets. | *bool* |

---

## Function Summary

######

| Function Name | Description | Return |
| --- | --- | --- |
| getAttribute(*string* id, *string* attribute) | Obtains the value of a specified attribute of a UI element. | *returns var* |
| getAttributes(*string* id) | Returns the attributes and their values of a UI element. | *returns table* |
| getCustomAssets() | Returns a table/array of [custom assets](#setcustomassets-custom-assets). | *returns table* |
| getValue(*string* id) | Obtains the value between elements tags, like: `<Text>ValueToGet</Text>` | *returns string* |
| getXml()getXml() | Returns the contents of the current UI formatted as XML. | *returns string* |
| getXmlTable() | Returns the contents of the current UI formatted as a table. | *returns table* |
| hide(*string* id) | Hides the given UI element. Unlike the "active" attribute, hide triggers animations. | *returns bool* |
| setAttribute(*string* id, *string* attribute, *var* value) | Sets the value of a specified attribute of a UI element. | *returns bool* |
| setAttributes(*string* id, *table* data) | Updates the value of the supplied attributes of a UI element. | *returns bool* |
| setClass(*string* id, *string* names) | Replaces all classes on a UI element. | *returns bool* |
| setCustomAssets(*table* assets) | Sets/replaces the custom assets which your UI may make use of. | *returns bool* |
| setValue(*string* id, *string* value) | Updates the value between elements tags, like: `<Text>ValueChanged</Text>` | *returns bool* |
| setXml(*string* xml, *table* assets) | Sets/replaces the UI with the contents of the provided XML. | *returns bool* |
| setXmlTable(*table* data, *table* assets) | Sets/replaces the UI with the contents of the provided UI table. | *returns bool* |
| show(*string* id) | Displays the given UI element. Unlike the "active" attribute, show triggers animations. | *returns bool* |

---

## Function Details

### getAttribute(...)

*returns var*  Obtains the value of a specified attribute of a UI element. What it returns will typically be a string or a number.

> **getAttribute(id, attribute)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.
>
> - *string* **attribute**: The name of the attribute you wish to get the value of.

```
self.UI.getAttribute("testElement", "fontSize")
```

---

### getAttributes(...)

*returns table*  Returns the attributes and their values of a UI element. It only returns the attributes (and values) for elements that have had those attributes set by the user.

> **getAttributes(id)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.
>
> **Return table**
>
> - *table* **parameters**: A Table with the attributes as keys and their XML value as the key's value.
>
>   - *string* **texture**: The name of the image element
>
>   - *string* **color**: The hex used for the color element's value.
>
> **IMPORTANT**: This return table is an example of one you may get back from using it on a RawImage element type. The attribute keys you get back and their values will depend on the element you use the function on as well as the attributes you, the user, have assigned to it.

---

### getCustomAssets()

*returns table*  Returns a table/array of [custom assets](#setcustomassets-custom-assets).

> **Example**
>
> Log the UI's current custom assets.

```
log(UI.getCustomAssets())
```

---

### getValue(...)

*returns string*  Obtains the value between elements tags, like: `<Text>ValueObtained</Text>`

> **getValue(id)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.

```
string = UI.getValue("testElement")
print(string)
```

---

### getXmlTable()

*returns table*  Returns the contents of the current UI formatted as a table.

Example Returned Table:

```
{
    {
        tag="HorizontalLayout",
        attributes={
            height=200,
            width=1000,
            color="rgba(0,0,0,0.7)",
        },
        children={
            {
                tag="Text",
                attributes={
                    fontSize=100,
                    color="red",
                },
                value="Example",
            },
            {
                tag="Text",
                attributes={
                    text="Message",
                    fontSize=100,
                    color="blue",
                },
            },
        }
    }
}
```

What the XML would look like which returns that table:

```
<HorizontalLayout height="200" width="1000" color="rgba(0,0,0,0.7)">
    <Text fontSize="100" color="red">Example</Text>
    <Text text="Message" fontSize="100" color="blue" />
</HorizontalLayout>
```

---

### hide(...)

*returns bool*  Hides the given UI element. Unlike the "active" attribute, hide triggers animations.

> **hide(id)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.

```
self.UI.hide("testElement")
```

---

### setAttribute(...)

*returns bool*  Sets the value of a specified attribute of a UI element.

> **Important**
>
> This will override the run-time value from the XML UI for all players, forcing them to see the same value.
>
> **setAttribute(id, attribute, value)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.
>
> - *string* **attribute**: The name of the attribute you want to set the value of.
>
> - *var* **value**: The value to set for the attribute.

```
self.UI.setAttribute("testElement", "fontSize", 200)
```

---

### setAttributes(...)

*returns bool*  Updates the value of the supplied attributes of a UI element. You do not need to set every attribute with the data table, an element will continue using any previous values you do not overwrite.

> **Important**
>
> This will override the run-time value from the XML UI for all players, forcing them to see the same value.
>
> **setAttributes(id, data)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.
>
> - *table* **data**: A Table with key/value pairs representing attributes and their values.
>
> **Example data table**
>
> - *table* **data**: A Table with parameters which guide the function.
>
>   - *float* **data.fontSize**: Attribute's desired value value
>
>   - *string* **data.color**: Attribute's desired value
>
> **IMPORTANT**: This table is an example of one you may use when setting a text UI element. The attribute keys you use and their values will depend on the element you use the function on.

```
attributeTable = {
    fontSize = 300,
    color = "#000000"
}
self.UI.setAttributes("exampleText", attributeTable)
```

---

### setClass(...)

*returns bool*  Replaces all classes on a UI element.

> **setClass(id, names)**
>
> - *string* **id**: The ID of the UI element that should have its classes replaced.
>
> - *string* **names**: Space separated class names.
>
> **Example**
>
> Replace all classes on the element with ID `someElementId` with two classes "important" and "large".

```
UI.setClass("someElementId", "important large")
```

---

### setCustomAssets(...)

*returns bool*  Sets/replaces the custom assets which your UI may make use of. Providing an empty table will remove all existing UI Assets.

> **Warning**
>
> This function will overwrite/replace any currently existing assets in Custom UI Assets, not add to them.
>
> **setCustomAssets(assets)**
>
> - *table* **assets**: A table/array containing sub-tables which each represent a [custom asset](#setcustomassets-custom-assets).

##### Custom Assets

Custom assets are represented as a table with the following properties:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| name | *string* | *Mandatory* | The name you'll use to refer to this asset in your XML UI. |
| url | *string* | *Mandatory* | The URL this asset will be loaded from. |

Currently, only images are supported as custom assets.

> **Example**
>
> Add two images which can be used within your XML UI.

```
UI.setCustomAssets({
    {
        name = "Image1",
        url = "http://placehold.it/120x120&text=image1"
    },
    {
        name = "Image2",
        url = "http://placehold.it/120x120&text=image2"
    },
})
```

---

### setValue(...)

*returns bool*  Updates the value between elements tags, like: `<Text>ValueChanged</Text>`

> **setValue(id, value)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.
>
> - *string* **value**: The value to put between the element tags.

```
UI.setValue("testElement", "New Text To Display")
```

---

### setXml(...)

*returns bool*  Sets/replaces the UI with the contents of the provided XML.

> **setXml(xml, assets)**
>
> - *string* **xml**: A string containing XML representing the desired UI.
>
> - *table* **assets**: A table/array containing sub-tables which each represent a [custom asset](#setcustomassets-custom-assets).
>
>   - Optional. When omitted existing custom assets will not be modified.
>
> **Warning**
>
> UI changes do not take effect immediately. Any attempt to query the contents of the XML will return stale results until [loading](#loading) returns to `false`.
>
> **Example**
>
> Display a single text label with the contents "Test".

```
UI.setXml("<Text>Test</Text>")
```

---

### setXmlTable(...)

*returns bool*  Sets/replaces the UI with the contents of the provided UI table.

> **setXmlTable(data, assets)**
>
> - *table* **data**: A table containing sub-tables. One sub-table for each element being created.
>
>   - *string* **tag**: The element type.
>
>   - *table* **attributes**: A table containing attribute names for keys. Available attribute types depend on tag's element type.
>
>     - Optional, defaults to not being used.
>
>     - Example key/value pairs: text="Test", color="black"
>
>   - *string* **value**: Text that appears `<Text>Here</Text>`, between the opening and closing tag.
>
>     - Optional, defaults to an empty string.
>
>   - *table* **children**: A table containing more sub-tables, formatted as above. This does mean the sub-tables can contain their own children as well, containing sub-sub tables, etc.
>
>     - Optional, defaults to not being used.
>
> - *table* **assets**: A table/array containing sub-tables which each represent a [custom asset](#setcustomassets-custom-assets).
>
>   - Optional. When omitted existing custom assets will not be modified.
>
> **Warning**
>
> UI changes do not take effect immediately. Any attempt to query the contents of the XML will return stale results until [loading](#loading) returns to `false`.
>
> **Example**
>
> Display two text labels within a horizontal layout.

```
UI.setXmlTable({
    {
        tag="HorizontalLayout",
        attributes={
            height=200,
            width=1000,
            color="rgba(0,0,0,0.7)",
        },
        children={
            {
                tag="Text",
                attributes={
                    fontSize=100,
                    color="red",
                },
                value="Example",
            },
            {
                tag="Text",
                attributes={
                    text="Message",
                    fontSize=100,
                    color="blue",
                },
            },
        }
    }
})
```

---

### show(...)

*returns bool*  Shows the given UI element. Unlike the "active" attribute, show triggers animations.

> **show(id)**
>
> - *string* **id**: The Id that was assigned, as an attribute, to the desired XML UI element.

```
self.UI.show("testElement")
```

---
