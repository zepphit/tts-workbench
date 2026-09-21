<!-- vendored from https://api.tabletopsimulator.com/physics/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Physics

Physics, a static global class, allows access to casts and gravity. Physics casts are a way to detect Objects. You call these functions like this: `Physics.getGravity()`. This class also allows you to access elements of the environment.

For more information on physics casts in Unity, [refer to the Unity documentation](https://docs.unity3d.com/ScriptReference/Physics.html) under BoxCast/RayCast/SphereCast.

## Member Variable Summary

### Member Variables

These are variables that affect elements of the environment. It allows you to both read and write values.

Read example: `print(Physics.play_area)` Write Example = `Physics.play_area = 0.5`

| Variable | Description | Type |
| --- | --- | --- |
| play_area | The play area being used (ie. how far from middle you can get). Values from 0 - 1. Default is 0.5 | *float* |

---

## Function Summary

### Functions

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| cast(*table* parameters) | Returns Table containing information on hit Objects. | *returns table* |
| getGravity()getGravity() | Returns directional Vector of the direction gravity is pulling. | *returns vector* |
| setGravity(setGravity(...)*vector* direction) | Sets the direction gravity pulls. | *returns bool* |

---

## Function Details

### cast(...)

*returns table*  Returns Table containing information on hit Objects. There are three kinds of casts:

| Type | Description |
| --- | --- |
| Ray | A line. |
| Box | A cube, rectangle, plane. |
| Sphere | A round ball. You cannot make ovals. |

It draws the imaginary cast, then moves the rap/box/sphere along that path instantly. The debug Bool in the parameters allows you to see this shape, to aid in setup, but the visual is not instant (due to that making it pointless, if you can't see it).

> **Warning**
>
> Physics casts are somewhat expensive. When running 30+ at once it will cause your game to stutter and/or crash. Do not overuse.
>
> **cast(parameters)**
>
> - *table* **parameters**: A Table of parameters used to guide the function.
>
>   - *vector* **parameters.origin**: Position of the starting point.
>
>   - *vector* **parameters.direction**: A direction for the cast to move in.
>
>   - *int* **parameters.type**: The type of cast. 1 = Ray, 2 = Sphere, 3= Box
>
>   - *vector* **parameters.size**: Size of the cast shape. Sphere/Box only.
>
>   - *vector* **parameters.orientation**: Rotation of the cast shape. Box only.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *float* **parameters.max_distance**: How far the cast will travel.
>
>     - Optional, defaults to infinity. Won't move without direction.
>
>   - *bool* **parameters.debug**: If the cast is visualized for the user.
>
>     - Optional, defaults to false.
>
> **Returned Table of Hit Objects**
>
> - *table* **table**: A numerically indexed Table, one entry for each hit Object. Entries are in the order of being hit.
>
>   - *vector* **table.point**: Position the cast impacted the Object.
>
>   - *vector* **table.normal**: The surface normal of the impact point.
>
>   - *float* **table.distance**: Distance between cast origin and impact point.
>
>   - *object* **table.hit_object**: An Object reference to the Object hit by the cast.

```lua
-- Example usage
-- This function, when called, returns a table of hit data
function findHitsInRadius(pos, radius)
    local radius = (radius or 1)
    local hitList = Physics.cast({
        origin       = pos,
        direction    = {0,1,0},
        type         = 2,
        size         = {radius,radius,radius},
        max_distance = 0,
        debug        = true,
    })

    return hitList
end
```

```
-- Example returned Table
{
    {
        point = {x=0,y=0,z=0},
        normal = {x=1,0,0},
        distance = 4,
        hit_object = objectreference1,
    },
    {
        point = {x=1,y=0,z=0},
        normal = {x=2,0,0},
        distance = 5,
        hit_object = objectreference2,
    },
}
```
