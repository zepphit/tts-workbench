<!-- vendored from https://api.tabletopsimulator.com/behavior/rpgfigurine/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# RPGFigurine

The RPGFigurine behavior is present on Objects that are figurines with built-in animations i.e. RPG Kit objects.

## Callback Members

These are `RPGFigurine` member variable which can be assigned a function that will be executed in response to an even occurring.

| Member Name | Description |
| --- | --- |
| onAttack(*table* hitObjects) | Executed when an attack is performed by the RPGFigurine Object. |
| onHit(*object* attacker) | Executed when the RPGFigurine Object is attacked. |

## Functions

######

######

######

| Function Name | Return | Description |
| --- | --- | --- |
| attack()attack() | *returns bool* | Plays a random attack animation. |
| changeMode()changeMode() | *returns bool* | Changes the figurine's current mode. What the mode represents is based on the figurine. |
| die()die() | *returns bool* | Plays the death animation or causes it to return to life. |

> **Example**
>
> Make an RPG figurine attack.

```
object.RPGFigurine.attack()
```

---

## Callback Member Details

### onAttack(...)

Executed when an attack is performed by the RPGFigurine Object.

An attack is triggered via the context menu or by pressing the appropriate number key. If another RPGFigurine is within its attack arc, then [onHit](#onhit) will be executed on the other figurine.

> **onAttack(hitObjects)**
>
> - *table* **hitObjects**: A table of RPGFigurine Objects within the reach of the attack.
>
> **Example**
>
> Assign an `onAttack` callback that prints the name of each object attacked.

```lua
function object.RPGFigurine.onAttack(hitObjects)
    for _, v in ipairs(hitObjects) do
        print(v.getName() .. " was hit!")
    end
end
```

---

### onHit(...)

Executed when the RPGFigurine Object is hit by another attacking RPGFigure Object.

An attack is triggered via the context menu or by pressing the appropriate number key. If this RPGFigurine Object is within the attack radius of an attacker, this function will be executed.

> **onHit(attacker)**
>
> - *object* **attacker**: The RPGFigurine Object performing the attack.
>
> **Example**
>
> Assign an `onHit` callback that prints the name of the object that performed the attack.

```lua
function object.RPGFigurine.onHit(attacker)
    print(attacker.getName() .. " attacked the Cyclops!")
end
```
