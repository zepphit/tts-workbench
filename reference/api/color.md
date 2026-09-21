<!-- vendored from https://api.tabletopsimulator.com/color/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Color

Color is a type of Table that is used to define RGBA values for tinting. R for red, G for green, B for blue and A for alpha (transparency)

Besides the functions listed below, other classes can be used to manipulate colors as well.

Example Usage: `orange = Color(1, 0, 0):lerp(Color(1, 1, 0), 0.5)`

Check [Manipulation examples](#manipulation-examples) for more detailed usage.

> **Tip**
>
> Vector and Color are the first classes to be defined in pure Lua. This means you **have** to use colon operator (e.g. `col:lerp()`) to call member functions, not the dot operator. Failing to do so will fail with cryptic error messages displayed.

## Constructors summary

> **Tip**
>
> Every place that returns a coordinate table, like `obj.getColorTint()`, serves a Color class instance already - you do not have to explicitly construct it. When constructing Color instances, the `.new` part can be omitted, making e.g. `Color(1, 0.5, 0.75)` equivalent to `Color.new(1, 0.5, 0.75)`.

| Function Name | Description | Return |
| --- | --- | --- |
| Color(*float* r, *float* g, *float* b) | Return a color with specified (r, g, b) components. | *returns color* |
| Color(*float* r, *float* g, *float* b, *float* a) | Return a color with specified (r, g, b, a) components. | *returns color* |
| Color(*table* t) | Return a color with r/g/b/a components from source table. | *returns color* |
| Color.new(...) | Same as Color(...). | *returns color* |
| Color.fromString(*string* colorStr) | Return a color from a color string ('Red', 'Green' etc), capitalization ignored. | *returns color* |
| Color.Blue | Shorthand for Color.fromString('Blue'), works for all [Player](player__colors.md) and [added colors](#coloradd), capitalization ignored. Also return the color name. | *returns color* *returns string* |

### Constructors examples

```lua
function onLoad()
    local red = Color.new(1, 0, 0)
    local green = Color(0, 1, 0) -- same as Color.new(0, 1, 0)

    local orangePlayer = Color.fromString("Orange")
    local purplePlayer = Color.Purple
end
```

---

## Element access summary

In addition to accessing color components by their numeric indices (1, 2, 3, 4) and textual identifiers (r, g, b, a), the following methods may also be utilized.

| Function Name | Description | Return |
| --- | --- | --- |
| setAt(*string* k, *float* value) | Sets a component to value and returns self. | *returns self* |
| set(*float* r, *float* g, *float* b, *float* a) | Sets `r`, `g`, `b`, `a` components to given values and returns self, alpha is optional | *returns self* |
| get() | Returns `r`, `g`, `b`, `a` components as four separate values. | *returns float* *returns float* *returns float* *returns float* |
| copy() | Returns a separate Color with identical component values. | *returns color* |

> **Tip**
>
> Before `Color` was introduced, color tables contained separate values under 1, 2, 3, 4 and r, g, b, a keys, with letter keys taking precedence when they were different. This is no longer the case, and using letter and numerical keys is equivalent. However, when iterating over Color components you have to use `pairs` and only letter keys will be read there.

### Element access examples

```lua
function onLoad()
    local col = Color(0, 0.5, 0.75)
    col.r = 1 -- set the first component
    col[2] = 0.25 -- set the second component
    col:setAt('b', 1) -- set the third component

    print(col:get()) --> same as print(col.r, col.g, col.b, col.a)

    for colorCode, value in pairs(col) do
        print(colorCode .. "="..value) --> r=1 then g=0.25 then b=1 and finally a=1
    end

    col:copy():setAt('a', 0.5)
    print(col.a) --> 1, because we only changed 'a' on a copy
end
```

---

## Arithmetics summary

Color also allows you to use arithmetic operators to performs basic operations:

| Operator | Description | Return |
| --- | --- | --- |
| *color* one == *color* two | Return true if both colors identical or within a small margin of each other, false otherwise. See also [color:equals()](#equals). | *bool* |
| tostring(*color* col) | Return a string description of a color. | *string* |

### Arithmetics examples

```lua
function onLoad()
    local col = Color({r = 0.118, g = 0.53, b = 1})
    print(col == Color.blue) --> true

    -- Color : Blue { r = 0.118, g = 0.53, b = 1, a = 1}
    tostring(Color(0.118, 0.53, 1))

    --> Color : { r = 0.3, g = 0.5, b = 1, a = 1}
    tostring(Color({r = 0.3, g = 0.5, b = 1}))
end
```

---

## Methods summary

### Methods not modifying self

| Method Name | Description | Return |
| --- | --- | --- |
| col:toHex(*bool* includeAlpha) | Returns a hex string for `col`, boolean parameter `includeAlpha`. | *returns string* |
| col:toString(*float* tolerance) | Returns a color string if matching this instance, nil otherwise, optional numeric `tolerance` param. | *returns string* |
| col:equals(*color* otherCol, *float* num) | Returns true if `otherCol` same as `col`, false otherwise, optional numeric tolerance param. | *returns bool* |
| col:lerp(*color* otherCol, *float* num) | Return a color some part of the way between `col` and `otherCol`, numeric arg [0, 1] is the fraction. | *returns color* |
| col:dump(*string* prefix) | Return a string description of a color with an optional `prefix`. | *returns string* *returns float* |

### Other methods

| Method Name | Description | Return |
| --- | --- | --- |
| Color.list | Returns a table of all color strings. | *returns table* |
| Color.Add(*string* name, *color* yourColor) | Add your own color definition to the class. | *returns nil* |

---

## Constructors details

### Color.new(...)

*returns color*  Return a color with specified components.

> **Color.new(r, g, b)**
>
> - *float* **r**: Red component between 0 and 1.
>
> - *float* **g**: Green component between 0 and 1.
>
> - *float* **b**: Blue component between 0 and 1.
>
> **Color.new(r, g, b, a)**
>
> - *float* **r**: Red component between 0 and 1.
>
> - *float* **g**: Green component between 0 and 1.
>
> - *float* **b**: Blue component between 0 and 1.
>
> - *float* **a**: Alpha component between 0 and 1.
>
> **Color.new(t)**
>
> - *table* **t**: The table should use the `r`, `g`, `b` and `a` index.  By default the value is 0 for color and 1 for alpha.

```lua
local red = Color.new(1, 0, 0)
local green = Color(0, 1, 0) -- same as Color.new(0, 1, 0)
local river = Color(52 / 255, 152 / 255, 219 / 255, 160 / 255)
local teal = Color({ r = 0.129, g = 0.694, b = 0.607})
```

> **Info**
>
> If you want to use value between 0 and 255 you should divide them by 255 before construct the object.

### Color.fromString(...)

*returns color*  Return a color from a color string ('Red', 'Green' etc), capitalization ignored.

> **Color.fromString(colorStr)**
>
> - *string* **colorStr**: Any [Player Color](player__colors.md) or color added with [Color.Add](#coloradd).

```lua
local col = Color.fromString("Blue")
print(col) --> Color: Blue { r = 0.118, g = 0.53, b = 1, a = 1 }
```

### Color.Blue

*returns color* *returns string*  Return a color from a color string ('Red', 'Green' etc).

Any [Player Color](player__colors.md) or color added with [Color.Add](#coloradd).

```lua
local color, name = Color.Blue
print(color) -- Color: Blue { r = 0.118, g = 0.53, b = 1, a = 1 }
print(name) -- Blue

local color, name = Color.Red
print(color) -- Color: Red { r = 0.856, g = 0.1, b = 0.094, a = 1 }
print(name) -- Red
```

---

## Element access details

### setAt(...)

*returns self*  Update one component of the color and returning self.

> **setAt(key, num)**
>
> - *int* **key**: Index of component (1, 2, 3 or 4 for r, g, b or a).
>
> - *float* **num**: New value.

```
col = Color.Blue
col:setAt(1, 128 / 255):setAt('a', 0.5)
print(col) --> Color: { r = 0.501961, g = 0.53, b = 1, a = 0.5 }
```

### set(...)

*returns self*  Update all components of the vector and returning self.

Providing a nil value makes it ignore that argument.

> **set(r, g, b)**
>
> - *float* **r**: New value of Red component.
>
> - *float* **g**: New value of Green component.
>
> - *float* **b**: New value of Blue component.
>
> **set(r, g, b, a)**
>
> - *float* **r**: New value of Red component.
>
> - *float* **g**: New value of Green component.
>
> - *float* **b**: New value of Blue component.
>
> - *float* **a**: New value of Alpha component.

```
col = Color.black
col:set(41 / 255, 128 / 255, 185 / 255)
print(col) --> Color: { r = 0.160784, g = 0.501961, b = 0.72549, a = 1 }
```

### get()

*returns float* *returns float* *returns float* *returns float*  Returns `r`, `g`, `b`, `a` components as four separate values.

```
col = Color.Blue
r, g, b, a = col:get()
print(r + g + b + a) --> 2.648
```

### copy()

*returns color*  Copy self into a new Color and return it.

```
col1 = Color(1, 0.5, 0.75)
col2 = col1:copy()
col1:set(0.75, 1, 0.25)
print(col1) --> Color: { r = 0.75, g = 1, b = 0.25, a = 1 }
print(col2) --> Color: { r = 1, g = 0.5, b = 0.75, a = 1 }
```

## Methods details

### Methods not modifying self

#### toHex(...)

*returns string*  Returns a hex string representation of self.

> **toHex(includeAlpha)**
>
> - *bool* **includeAlpha**: Include or not the `a` value. (Default true)

```
print(Color.blue:toHex()) -- 1e87ffff
print(Color.blue:toHex(true)) -- 1e87ffff
print(Color.blue:toHex(false)) -- 1e87ff
```

#### toString(...)

*returns string*  Returns a color string if matching this instance, nil otherwise, optional numeric `tolerance` param.

> **toString(tolerance)**
>
> - *float* **tolerance**: Numeric `tolerance`, by default 0.01.

```
print(Color( 0.118, 0.53, 1):toString()) -- Blue
```

#### equals(...)

*returns bool*  Returns true if `otherCol` same as self, false otherwise, optional numeric `tolerance` param.

> **equals(otherCol, tolerance)**
>
> - *color* **otherCol**: The color to compare with.
>
> - *float* **tolerance**: Numeric `tolerance`, by default 0.01.

```
print(Color( 0.118, 0.53, 1):equals(Color.Blue:copy())) -- true
print(Color( 0.118, 0.53, 1) == Color.Blue) -- true

print(Color( 0.118, 0.53, 1):equals(Color.Blue)) -- Throw errors
```

#### lerp(...)

*returns color*  Return a color some part of the way between self and `otherCol`, numeric arg [0, 1] is the fraction.

> **lerp(otherCol, fraction)**
>
> - *color* **otherCol**: The color to compare with.
>
> - *float* **fraction**: Numeric `fraction`.

```lua
local pink = Color.Red:lerp(Color.White, 0.5)
print(pink) -- Color: { r = 0.928, g = 0.55, b = 0.547, a = 1 }
```

#### dump(...)

*returns string* *returns float*  Return string describing self, optional string prefix.

> **dump(prefix)**
>
> - *string* **prefix**: The prefix of return string.
>
> **Warning**
>
> This function returns one extra float that will be displayed in print function. This value is returned by the last gsub used in internal function.

```
col = Color.Blue
str = col:dump('Prefix')
print(str) --> Prefix: Blue { r = 0.118, g = 0.53, b = 1, a = 1 }
print(col:dump('Prefix')) --> Prefix: Blue { r = 0.118, g = 0.53, b = 1, a = 1 } 2
print(Color.dump(col, 'Prefix')) --> Prefix: Blue { r = 0.118, g = 0.53, b = 1, a = 1 } 2
```

### Other methods

#### Color.list

*returns table*  Returns a table of all color strings.

```
data = Color.list
-- Same as
data = {
    [1] => "White",
    [2] => "Brown",
    [3] => "Red",
    [4] => "Orange",
    [5] => "Yellow",
    [6] => "Green",
    [7] => "Teal",
    [8] => "Blue",
    [9] => "Purple",
    [10] => "Pink",
    [11] => "Grey",
    [12] => "Black"
}
```

#### Color.Add(...)

*returns nil*  Add your own color definition to the class.

> **dump(name, yourColor)**
>
> - *string* **name**: The name of the color.
>
> - *color* **yourColor**: The color value.

```lua
Color.Add("River", Color(52 / 255, 152 / 255, 219 / 255))
local color, name = Color.River
print(color) -- Color: River { r = 0.203922, g = 0.596078, b = 0.858824, a = 1 }
print(name) -- River
```

---

## Manipulation examples

Tint all object in scene in orange.

```lua
function onLoad()
    local red = Color.Red
    local green = Color.Green

    -- Get a color between red and green
    local yellow = red:lerp(green, 0.5)

    -- Make the color brighter
    yellow:set(yellow.r * 1.5, yellow.g * 1.5, yellow.b * 1.5)

    -- Get a color between yellow and red
    local orange = yellow:lerp(Color.Red, 0.5)

    -- Iterate through all scene objects and set the color tint to orange
    for k, obj in pairs(getObjects()) do
        obj.setColorTint(orange)
    end
end
```

Tint all object in a random color.

```lua
function onLoad()
    -- Iterate through all scene objects and generate a random color
    for k, obj in pairs(getObjects()) do
        local colorA = getRandomColor()
        local colorB = getRandomColor()

        color = colorA:lerp(colorB, math.random(0, 1))

        -- Make the color darker or brighter
        local factor = math.random(1, 2)
        color:set(color.r * factor, color.g * factor, color.b * factor)

        -- Apply the color to object
        obj.setColorTint(color)
    end
end

function getRandomColor()
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    return Color(r / 255, g / 255, b / 255)
end
```
