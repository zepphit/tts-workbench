<!-- vendored from https://api.tabletopsimulator.com/vector/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Vector

Representation of 3D vectors and points.

This structure is used to pass 3D positions and directions around. It also contains functions for doing common vector operations.

Besides the functions listed below, other classes can be used to manipulate vectors and points as well.

Example Usage: `target = Vector(1, 0, 0) + Vector(0, 2, 0):normalized()`

Check [Manipulation examples](#manipulation-examples) for more detailed usage.

> **Tip**
>
> Vector and Color are the first classes to be defined in pure Lua. This means you **have** to use colon operator (e.g. `pos:angle()`) to call member functions, not the dot operator. Failing to do so will fail with cryptic error messages displayed.

## Constructors summary

> **Tip**
>
> Every place that returns a coordinate table, like `obj.getPosition()`, serves a Vector class instance already - you do not have to explicitly construct it. When constructing Vector instances, the `.new` part can be omitted, making e.g. `Vector(1, 2, 3)` equivalent to `Vector.new(1, 2, 3)`.

| Function Name | Description | Return |
| --- | --- | --- |
| Vector(*float* x, *float* y, *float* z) | Return a vector with specified (x, y, z) components. | *returns vector* |
| Vector(*table* v) | Return a vector with x/y/z or 1/2/3 components from source table (x/y/z first). | *returns vector* |
| Vector.new(...) | Same as Vector(...). | *returns vector* |
| Vector.min(*vector* vec1, *vector* vec2) | Returns a vector that is made from the smallest components of two vectors. | *returns vector* |
| Vector.max(*vector* vec1, *vector* vec2) | Returns a vector that is made from the largest components of two vectors. | *returns vector* |
| Vector.between(*vector* vec1, *vector* vec2) | Return a vector pointing from vec1 to vec2. | *returns vector* |

### Constructors examples

```lua
function onLoad()
    local vec1 = Vector.new(0.5, 1, 1.5)
    local vec2 = Vector(1, -1, 0) -- same as Vector.new(1, -1, 0)

    print(Vector.between(vec1, vec2)) --> Vector: {0.5, -2, -1.5}
    print(Vector.max(vec1, vec2)) --> Vector: {1, 1, 1.5}
    print(Vector.min(vec1, vec2)) --> Vector: {0.5, -1, -0}
end
```

---

## Element access summary

In addition to accessing vector components by their numeric indices (1, 2, 3) and textual identifiers (x, y, z), the following methods may also be utilized.

| Function Name | Description | Return |
| --- | --- | --- |
| setAt(*string* k, *float* value) | Sets a component to value and returns self. | *returns self* |
| set(*float* x, *float* y, *float* z) | Sets `x`, `y`, `z` components to given values and returns self. | *returns self* |
| get() | Returns `x`, `y`, `z` components as three separate values. | *returns float* *returns float* *returns float* |
| copy() | Returns a separate Vector with identical component values. | *returns vector* |

> **Tip**
>
> Before `Vector` was introduced, coordinate tables contained separate values under 1, 2, 3 and x, y, z keys, with letter keys taking precedence when they were different. This is no longer the case, and using letter and numerical keys is equivalent. However, when iterating over Vector components you have to use `pairs` and only letter keys will be read there.

### Element access examples

```lua
function onLoad()
    local vec = Vector(1, 2, 3)
    vec.x = 2 -- set the first component
    vec[2] = 4 -- set the second component
    vec:setAt('z', 6) -- set the third component

    print(vec:get()) --> same as print(vec.x, vec.y, vec.z)

    for axis, value in pairs(vec) do
        print(axis .. "="..value) --> x=2 then y=4 and finally z=6
    end

    vec:copy():setAt('x', - 11)
    print(vec.x) --> 2, because we only changed 'x' on a copy
end
```

---

## Arithmetics summary

Vector also allows you to use arithmetic operators to performs basic operations:

| Operator | Description | Return |
| --- | --- | --- |
| *vector* one + *vector* two | Returns a new Vector that is a sum of `one` and `two` | *returns vector* |
| *vector* one - *vector* two | Returns a new Vector that is a difference of `one` and `two` | *returns vector* |
| *vector* one * *float* factor | Returns a new Vector that is `one` with each component multiplied by the factor. | *returns vector* |
| *vector* one == *vector* two | Returns a boolean whether `one` and `two` are very similar to each other (less than ~0.03 difference in magnitude) | *returns bool* |

### Arithmetics examples

```lua
function onLoad()
    local vec = Vector(1, 2, 3)
    vec:add(Vector(3, 2, 1)) --> vec is now {4, 4, 4}
    vec:sub(Vector(1, 0, 1)) --> vec is now {3, 4, 3}

    local another = vec + Vector(-1, -2, -1) --> another is {2, 2, 2}, vec remains unchanged

    print(another:equals(Vector(1, 2, 3))) --> false
    print(another == Vector(2, 2, 2)) --> true
    print(another == Vector(1.99, 2.01, 2)) --> true, small differences are tolerated
end
```

---

## Methods summary

> **Tip**
>
> Numerous methods of Vector will return the *self*  instance to allow easy "chaining". That way you can do more complex processing without saving an intermediate result in a variable, like e.g. `vec:setAt('y', 0):scale(0.5):rotateOver('y', 90)`.

### Methods modifying self

| Method Name | Description | Return |
| --- | --- | --- |
| vec:add(*vector* otherVec) | Adds components of otherVec to self. | *returns self* |
| vec:sub(*vector* otherVec) | Subtracts components of otherVec from self. | *returns self* |
| vec:scale(*vector* otherVec) | Multiplies self-components by corresponding components from otherVec. | *returns self* |
| vec:scale(*float* num) | Multiplies self-components by a numeric factor. | *returns self* |
| vec:clamp(*float* num) | If self-magnitude is higher than provided limit, scale self-down to match it. | *returns self* |
| vec:normalize() | Makes self-have a magnitude of 1. | *returns self* |
| vec:project(*vector* otherVec) | Make self into projection on another vector. | *returns self* |
| vec:projectOnPlane(*vector* otherVec) | Project self on a plane defined through a normal vector arg. | *returns self* |
| vec:reflect(*vector* otherVec) | Reflect self over a plane defined through a normal vector arg. | *returns self* |
| vec:inverse() | Multiply self-components by -1. | *returns self* |
| vec:moveTowards(*vector* otherVec, *float* num) | Move self towards another vector, but only up to a provided distance limit. | *returns self* |
| vec:rotateTowards(*vector* target, *float* maxAngle) | Rotate self towards another vector, but only up to a provided angle limit. | *returns self* |
| vec:rotateTowardsUnit(*vector* target, *float* maxAngle) | Same as rotateTowards, but only works correctly if `target` Vector is normalized. Less expensive than `rotateTowards`. | *returns self* |
| vec:rotateOver(*string* axis, *float* angle) | Rotate a Vector `angle` degrees over given `axis` (can be `'x'`, `'y'`, `'z'`). | *returns self* |

### Methods not modifying self

| Method Name | Description | Return |
| --- | --- | --- |
| vec1:dot(*vector* vec2) | Return a dot product of two vectors. | *returns float* |
| vec:magnitude() | Returns the length of this vector. | *returns float* |
| vec:sqrMagnitude() | Returns the squared length of this vector. | *returns float* |
| p1:distance(*vector* p2) | Returns distance between two points. | *returns float* |
| p1:sqrDistance(*vector* p2) | Returns squared distance between two points. | *returns float* |
| vec1:equals(*vector* vec2, *float* margin) | Returns true if two vectors are approximately equal. The `margin` argument is optional and defaults to tolerating a difference of ~0.03 in both vector magnitude. | *returns bool* |
| vec:string(*string* prefix) | Return string describing self, optional string prefix. | *returns string* *returns float* |
| vec1:angle(*vector* vec2) | Return an angle between two vectors, in degrees [0, 180]. | *returns float* |
| vec1:cross(*vector* vec2) | Return a cross-product vector of two vectors. | *returns vector* |
| p1:lerp(*vector* p2, *float* t) | Linearly interpolates between two points. Numeric arg [0, 1] is the fraction. | *returns vector* |
| vec:normalized() | Return a new vector that is normalized (length 1) version of self. | *returns vector* |
| vec:orthoNormalize() | Return three normalized vectors perpendicular to each other, first one being in the same dir as self. Return `base`, `normal`, `binormal` vectors. | *returns vector* *returns vector* *returns vector* |
| vec:orthoNormalize(*vector* binormalPlanar) | Same as vec:orthoNormalize(), but second vector is guranteed to be on a self-binormalPlanar plane. | *returns vector* *returns vector* *returns vector* |
| vec:heading() | Returns an angle (In degrees) of rotation of Vector over all axis (`'x'`, `'y'`, `'z'`). | *returns float* *returns float* *returns float* |
| vec:heading(*string* axis) | Returns an angle (In degrees) of rotation of Vector over a given `axis` (can be `'x'`, `'y'`, `'z'`). | *returns float* |

---

## Constructors details

### Vector.min(...)

*returns vector*  Returns a vector that is made from the smallest components of two vectors.

> **Vector.min(vec1, vec2)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.

```
vec1 = Vector(1, 2, 3)
vec2 = Vector(4, 3, 2)
print(Vector.min(vec1, vec2)) --> Vector: { 1, 2, 2 }
```

### Vector.max(...)

*returns vector*  Returns a vector that is made from the largest components of two vectors.

> **Vector.max(vec1, vec2)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.

```
vec1 = Vector(1, 2, 3)
vec2 = Vector(4, 3, 2)
print(Vector.max(vec1, vec2)) --> Vector: { 4, 3, 3 }
```

### Vector.between(...)

*returns vector*  Return a vector pointing from vec1 to vec2.

> **Vector.between(vec1, vec2)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.

```
vec1 = Vector(1, 2, 3)
vec2 = Vector(4, 3, 2)
print(Vector.between(vec1, vec2)) --> Vector: { 3, 1, -1 }
```

---

## Element access details

### setAt(...)

*returns vector*  Update one component of the vector and returning self.

> **setAt(key, num)**
>
> - *int* **key**: Index of component (1, 2 or 3 for x, y or z).
>
> - *float* **num**: New value.

```
vec = Vector(1, 2, 3)
vec:setAt(1, 4):setAt('y', 3)
print(vec) --> Vector: { 4, 3, 3 }
```

### set(...)

*returns vector*  Update all components of the vector and returning self.

Providing a nil value makes it ignore that argument.

> **set(x, y, z)**
>
> - *float* **x**: New value of X component.
>
> - *float* **y**: New value of Y component.
>
> - *float* **z**: New value of Z component.

```
vec = Vector(1, 2, 3)
vec:set(4, 3, 2)
print(vec) --> Vector: { 4, 3, 2 }
```

### get()

*returns float* *returns float* *returns float*  Returns `x`, `y`, `z` components as three separate values.

```
vec = Vector(1, 2, 3)
x, y, z = vec:get()
print(x + y + z) --> 6
```

### copy()

*returns vector*  Copy self into a new vector and return it.

```
vec1 = Vector(1, 2, 3)
vec2 = vec1:copy()
vec1:set(4, 3, 2)
print(vec1) --> Vector { 4, 3, 2 }
print(vec2) --> Vector { 1, 2, 3 }
```

---

## Methods details

### Methods modifying self details

#### add(...)

*returns self*  Adds components of otherVec to self and returning self.

> **add(otherVec)**
>
> - *vector* **otherVec**: The vector to add.

```
vec = Vector(1, 2, 3)
otherVec = Vector(4, 5, 6)
vec:add(otherVec)
print(vec) --> Vector: { 5, 7, 9 }

-- Same as
vec = Vector(1, 2, 3)
otherVec = Vector(4, 5, 6)
vec = vec + otherVec
print(vec) --> Vector: { 5, 7, 9 }
```

#### sub(...)

*returns self*  Subtracts components of otherVec from self and returning self.

> **sub(otherVec)**
>
> - *vector* **otherVec**: The vector to subtracts.

```
vec = Vector(1, 2, 3)
otherVec = Vector(6, 5, 4)
vec:sub(otherVec)
print(vec) --> Vector: { -5, -3, -1 }

-- Same as
vec = Vector(1, 2, 3)
otherVec = Vector(6, 5, 4)
vec = vec - otherVec
print(vec) --> Vector: { -5, -3, -1 }
```

#### scale(...)

*returns self*  Multiplies self-components by corresponding components from otherVec and returning self.

Every component in the result is a component of vec multiplied by the same component of otherVec or by a number factor.

> **scale(otherVec)**
>
> - *vector* **otherVec**: The vector to scale.
>
> **scale(num)**
>
> - *float* **num**: The numeric factor.

```
vec = Vector(1, 2, 3)
otherVec = Vector(2, 3, 4)
vec:scale(otherVec)
print(vec) --> Vector: { 2, 6, 12 }
vec:scale(2)
print(vec) --> Vector: { 4, 12, 24 }
```

#### clamp(...)

*returns self*  If self-magnitude is higher than provided limit, scale self-down to match it and returning self.

> **clamp(num)**
>
> - *float* **num**: The numeric max magnitude.

```
vec = Vector(1, 2, 3)
vec:clamp(2)
print(vec) --> Vector: { 0.53, 1.07, 1.60 }
```

#### normalize()

*returns self*  Makes this vector have a magnitude of 1 and returning self.

When normalized, a vector keeps the same direction but its length is 1.0.

Note that this function will change the current vector. If you want to keep the current vector unchanged, use [normalized()](#normalized) method.

```
vec = Vector(1, 2, 3)
vec:normalize()
print(vec) --> Vector: { 0.27, 0.53, 0.80 }
```

#### project(...)

*returns self*  Make self into projection on another vector and return self.

To understand vector projection, imagine that `otherVec` is resting on a line pointing in its direction. Somewhere along that line will be the nearest point to the tip of vector. The projection is just `otherVec` rescaled so that it reaches that point on the line.

> **project(otherVec)**
>
> - *vector* **otherVec**: The normal vector.

```
vec = Vector(2, 1, 4)
vec:project(Vector(1, -2, 1))
print(vec) --> Vector: { 0.67, -1.3, 0.67 }
```

#### projectOnPlane(...)

*returns self*  Projects a vector onto a plane defined by a normal orthogonal to the plane and return self.

A Vector stores the position of the given `vec` in 3d space. A second Vector is given by `otherVec` and defines a direction from a plane towards vector that passes through the origin. Vector.projectOnPlane uses the two Vector values to generate the position of vector in the `otherVec` direction, and return the location of the Vector on the plane.

> **projectOnPlane(otherVec)**
>
> - *vector* **otherVec**: The plane normal vector.

```
vec = Vector(2, 1, 4)
vec:projectOnPlane(Vector(1, -2, 1))
print(vec) --> Vector: { 1.33, 2.33, 3.33 }
```

#### reflect(...)

*returns self*  Make self into reflection on another vector and return self.

The `otherVec` vector defines a plane (a plane's normal is the vector that is perpendicular to its surface). The `vec` vector is treated as a directional arrow coming in to the plane. The returned value is a vector of equal magnitude to `vec` but with its direction reflected.

> **reflect(otherVec)**
>
> - *vector* **otherVec**: The normal vector.

```
vec = Vector(1, 2, 3)
vec:reflect(Vector(4, 3, 2))
print(vec) --> Vector: { -3.41, -1.31, 0.79 }
```

#### inverse()

*returns self*  Multiply self-components by -1.

```
vec = Vector(1, 2, 3)
vec:inverse()
print(vec) --> Vector: { -1, -2, -3 }
```

#### moveTowards(...)

*returns self*  Move self towards another vector, but only up to a provided distance limit and return self.

> **moveTowards(otherVec, num)**
>
> - *vector* **target**: The position to move towards.
>
> - *float* **num**: The distance limit.

```
vec = Vector(1, 2, 3)
vec:moveTowards(Vector(4, 3, 2), 0.5)
print(vec) --> Vector: { 1.45, 2.15, 2.85 }
```

#### rotateTowards(...)

*returns self*  Rotate self towards another vector, but only up to a provided angle limit and return self.

This function is similar to [moveTowards()](#movetowards) except that the vector is treated as a direction rather than a position. The current vector will be rotated round toward the target direction by an angle of `maxAngle`, although it will land exactly on the target rather than overshoot. If the magnitudes of current and target are different, then the magnitude of the result will be linearly interpolated during the rotation. If a negative value is used for `maxAngle`, the vector will rotate away from target until it is pointing in exactly the opposite direction, then stops.

> **rotateTowards(target, maxAngle)**
>
> - *vector* **target**: The position to rotate towards.
>
> - *float* **maxAngle**: The maximum angle in **degree** allowed for this rotation.

```
vec = Vector(1, 2, 3)
vec:rotateTowards(Vector(4, 3, 2), 45)
print(vec) --> Vector: { 2.78, 2.08, 1.39 }
```

#### rotateTowardsUnit(...)

*returns self*  Same as [rotateTowards()](#rotatetowards), but only works correctly if `target` Vector is normalized and return self. Less expensive than `rotateTowards()`.

> **rotateTowardsUnit(target, maxAngle)**
>
> - *vector* **target**: The position to rotate towards.
>
> - *float* **maxAngle**: The maximum angle in **degree** allowed for this rotation.

```
vec = Vector(1, 2, 3)
vec:rotateTowardsUnit(Vector(4, 3, 2):normalized(), 45)
print(vec) --> Vector: { 3.29, 0.87, -1.55 }
```

#### rotateOver(...)

*returns self*  Rotate a Vector `angle` degrees over given `axis` (can be `'x'`, `'y'`, `'z'`) and return self.

> **rotateOver(axis, angle)**
>
> - *string* **axis**: The axis to rotate around.
>
> - *float* **angle**: The angle in **degree** for this rotation.

```
vec = Vector(3, 2, 3)
vec:rotateOver('y', 45)
print(vec) --> Vector: { 4.24, 2, 0 }
```

---

### Methods not modifying self details

#### dot(...)

*returns float*  Return the dot product of two vectors.

The dot product is a float value equal to the magnitudes of the two vectors multiplied together and then multiplied by the cosine of the angle between them.

For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions and zero if the vectors are perpendicular.

> **vec1:dot(vec2)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.

```
vec1 = Vector(0, 1, 2)
vec2 = Vector(0, 2, 4)
print(vec1:dot(vec2)) --> 10
print(Vector.dot(vec1:normalized(), vec2:normalized())) --> 1
```

#### magnitude()

*returns float*  Returns the length of this vector.

```
vec = Vector(1, 2, 3)
print(vec:magnitude()) --> 3.74 (sqrt of 14)
print(Vector.magnitude(vec)) --> 3.74 (sqrt of 14)
```

#### sqrMagnitude()

*returns float*  Returns the squared length of this vector.

```
vec = Vector(1, 2, 3)
print(vec:sqrMagnitude()) --> 14
print(Vector.sqrMagnitude(vec)) --> 14
```

#### distance(...)

*returns float*  Returns distance between two points.

> **p1:distance(p2)**
>
> - *vector* **p1**: First point.
>
> - *vector* **p2**: Second point.

```
p1 = Vector(1, 2, 3)
p2 = Vector(4, 3, 2)
print(p1:distance(p2)) --> 3.32
print(Vector.distance(p1, p2)) --> 3.32
print((p1 - p2):magnitude())  --> 3.32
```

#### sqrDistance(...)

*returns float*  Returns squared distance between two points.

> **p1:sqrDistance(p2)**
>
> - *vector* **p1**: First point.
>
> - *vector* **p2**: Second point.

```
p1 = Vector(1, 2, 3)
p2 = Vector(4, 3, 2)
print(p1:sqrDistance(p2)) --> 11
print(Vector.sqrDistance(p1, p2)) --> 11
```

#### equals(...)

*returns bool*  Returns true if two vectors are approximately equal. The `margin` argument is optional and defaults to tolerating a difference of `~0.03` in both vector magnitude.

> **vec1:equals(vec2, margin)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.
>
> - *float* **margin**: (Optional) Numeric tolerance.

```
vec1 = Vector(1, 2, 3.10)
vec2 = Vector(1, 2, 3.15)
print(vec1:equals(vec2)) --> false
print(Vector.equals(vec1, vec2, 0.01)) --> true
```

#### string(...)

*returns string* *returns float*  Return string describing self, optional string prefix.

> **string(prefix)**
>
> - *string* **prefix**: The prefix of return string.

```
vec = Vector(1, 2, 3)
str = vec:string('Prefix')
print(str) --> Prefix: { 1, 2, 3 }
print(vec:string('Prefix')) --> Prefix: { 1, 2, 3 }
print(Vector.string(vec, 'Prefix')) --> Prefix: { 1, 2, 3 }
```

> **Warning**
>
> This function returns one extra float that will be displayed in print function. This value is returned by the last gsub used in internal function.

#### angle(...)

*returns float*  Returns the angle in degrees between two vectors.

The angle returned is the unsigned angle between the two vectors. This means the smaller of the two possible angles between the two vectors is used. The result is never greater than 180 degrees.

> **vec1:angle(vec2)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.

```
vec1 = Vector(1, 2, 3)
vec2 = Vector(4, 3, 2)
print(vec1:angle(vec2)) --> 37.43
print(Vector.angle(vec1, vec2)) --> 37.43
```

#### cross(...)

*returns vector*  Return a cross-product vector of two vectors.

The cross product of two vectors results in a third vector which is perpendicular to the two input vectors. The result's magnitude is equal to the magnitudes of the two inputs multiplied together and then multiplied by the sine of the angle between the inputs. You can determine the direction of the result vector using the "left hand rule".

> **vec1:cross(vec2)**
>
> - *vector* **vec1**: First vector.
>
> - *vector* **vec2**: Second vector.

```
vec1 = Vector(1, 2, 3)
vec2 = Vector(4, 3, 2)
print(vec1:cross(vec2)) --> Vector: { -5, 10, -5 }
print(vec2:cross(vec1)) --> Vector: { -5, -10, 5 }
print(Vector.cross(vec1, vec2)) --> Vector: { -5, 10, -5 }
print(Vector.cross(vec2, vec1)) --> Vector: { -5, -10, 5 }
```

#### lerp(...)

*returns vector*  Linearly interpolates between two points.

Interpolates between the points a and b by the interpolant t. The parameter t is clamped to the range [0, 1]. This is most commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).

The value returned equals (b - a) * t. When t = 0 returns a. When t = 1 returns b. When t = 0.5 returns the point midway between a and b.

> **p1:lerp(p2, t)**
>
> - *vector* **p1**: First point.
>
> - *vector* **p2**: Second point.
>
> - *float* **t**: Fraction.

```
p1 = Vector(1, 2, -4)
p2 = Vector(1, 2, 4)
print(p1:lerp(p2, 0.25)) --> Vector: { 1, 2, -2 }
print(Vector.lerp(p1, p2, 0.25)) --> Vector: { 1, 2, -2 }
```

#### normalized()

*returns vector*  Return a new vector that is normalized (length 1) version of self.

```
vec = Vector(1, 2, 3)
print(vec:normalized()) --> Vector: { 0.27, 0.53, 0.80}
print(Vector.normalized(vec)) --> Vector: { 0.27, 0.53, 0.80}
```

#### orthoNormalize(...)

*returns vector* *returns vector* *returns vector*  Return three normalized vectors perpendicular to each other, first one being in the same direction as self. If `binormalPlaner` is provided, the second vector is guaranteed to be on a self-binormalPlanar plane.

> **orthoNormalize(binormalPlanar)**
>
> - *vector* **binormalPlanar**: (optional) The vector for binormal planar.

```
vec = Vector(0, 0, 2)
base, normal, binormal = vec:orthoNormalize(Vector(0, 1, 0))
print(base) --> Vector: { 0, 0, 1}
print(normal) --> Vector: { -1, 0, 0}
print(binormal) --> Vector: { 0, -1, 0}
```

#### heading(...)

*returns float*  Returns an angle (In degrees) of rotation of Vector over a given `axis` (can be `'x'`, `'y'`, `'z'`).

> **heading(axis)**
>
> - *string* **axis**: Can be `'x'`, `'y'`, `'z'`.

```
vec = Vector(1, 2, 3)
angle = vec:heading('z')
print(angle) --> 26.57
```

---

## Manipulation examples

Moving an object towards a target position in small steps

```lua
function onLoad()
    local obj = assert(getObjectFromGUID('555555'), 'Object not found!')
    obj.lock()

    local current =  Vector(10, 5, 0) -- obj starting position
    local target =   Vector(-10, 5, 0) -- obj destination
    local movementType = 'linear' -- try with 'spherical' or 'asymptotic' to see how other methods work

    -- We want the movement stretched over time, a Wait will do it periodically
    local waitID
    waitID = Wait.time(
        function()
            -- move the current postion towards destination

            if movementType == 'linear' then
                -- simple linear movement, 1 unit at a time
                current:moveTowards(target, 1)
            elseif movementType == 'spherical' then
                -- rotate towards target, 10 degress at a time
                current:rotateTowards(target, 5)
            elseif movementType == 'asymptotic' then
                -- move quarter of the way towards target (take note that lerp does not modify current directly)
                current = current:lerp(target, 0.25)
            end

            obj.setPositionSmooth(current, true, true)

            -- if we reached the destination, stop this timer
            if current == target then
                Wait.stop(waitID)
                broadcastToAll('Finished!', {0, 1, 0})
            end
        end,
        0.5,  -- repeats every half second
        -1  -- indefinitely, until stopped because we reached destination
    )
end
```
