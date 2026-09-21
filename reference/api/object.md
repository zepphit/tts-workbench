<!-- vendored from https://api.tabletopsimulator.com/object/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Object

The Object class represents any entity within tabletop simulator. Once you have a reference to an object in your script you can call functions on it directly. Example: `obj.getPosition(...)`. You can get a reference to an object multiple ways;

- Using the `self` property if your script is on an Object and referring to that Object.

- Using [`getObjectFromGUID(...)`](base.md#getobjectfromguid) with the object's GUID (found by right clicking it with the pointer).

- Getting it as a return from another function, like with [`spawnObject(...)`](base.md#spawnobject).

## Member Variables

### Common Variables

These are variables that are common to all objects. Some variables are read-only, which means you can query the property, but are unable to assign a new value to it.

> **Example**
>
> Locking/freezing an object by assigning `true` to [locked](#locked).

```
object.locked = true
```

> **Example**
>
> Printing whether or not object is [locked](#locked).

```lua
if object.locked then
    print("Object is locked")
else
    print("Object is not locked")
end
```

| Variable | Description | Type |
| --- | --- | --- |
| alt_view_angle | When non-zero, the Alt view will use the specified Euler angle to look at the object. | *vector* |
| angular_drag | Angular drag. [Unity rigidbody property](https://docs.unity3d.com/2019.1/Documentation/Manual/class-Rigidbody.html). | *float* |
| auto_raise | If the object should be lifted above other objects to avoid collision when held by a player. | *bool* |
| bounciness | Bounciness, value of 0-1. [Unity physics material](https://docs.unity3d.com/2019.1/Documentation/Manual/class-PhysicMaterial.html). | *float* |
| drag | Drag. [Unity rigidbody property](https://docs.unity3d.com/2019.1/Documentation/Manual/class-Rigidbody.html). | *float* |
| drag_selectable | When `false`, the object will not be selected by regular (click and drag) selection boxes that are drawn around the object.Players may proceed to override this behavior by holding the "Shift" modifier whilst drag selecting. | *bool* |
| dynamic_friction | Dynamic friction, value of 0-1. [Unity physics material](https://docs.unity3d.com/2019.1/Documentation/Manual/class-PhysicMaterial.html). | *float* |
| gizmo_selectable | When `false`, the object cannot be selected with the Gizmo tool. | *bool* |
| grid_projection | If grid lines can appear on the Object if visible grids are turned on. | *bool* |
| guid | The 6 character unique Object identifier within Tabletop Simulator. It is assigned correctly once the `spawning` member variable becomes false. | *string* |
| held_by_color | The Color of the Player that is holding the object. | *string* |
| held_flip_index | 0-23 value. Changes when a Player hits flip or alt + rotate. | *int* |
| held_position_offset | Position offset from pointer. | *vector* |
| held_reduce_force | When the Object collides with something while moving this is automatically enabled and reduces the movement force. | *bool* |
| held_rotation_offset | Rotation offset from pointer. | *vector* |
| held_spin_index | 0-23 value. Changes when a Player rotates the Object. | *int* |
| hide_when_face_down | Hide the Object when face-down as if it were in a hand zone. The face is the "top" of the Object, the direction of its positive Y coordinate. Cards/decks default to `true`. | *bool* |
| ignore_fog_of_war | Makes the object not be hidden by [Fog of War](https://kb.tabletopsimulator.com/game-tools/zone-tools/#fog-of-war-zone). | *bool* |
| interactable | If the object can be interacted with by Players. Other object will still be able to interact with it. | *bool* |
| is_face_down | If the Object is roughly face-down (like with cards). The face is the "top" of the Object, the direction of its positive Y coordinate. Read only. | *bool* |
| loading_custom | If the Object's custom elements (images/models/etc) are loading. Read only. | *bool* |
| locked | If the object is frozen in place (preventing physics interactions). | *bool* |
| mass | Mass. [Unity rigidbody property](https://docs.unity3d.com/2019.1/Documentation/Manual/class-Rigidbody.html). | *float* |
| max_typed_number | Determines the maximum number of digits which a user may type whilst hovering over the object.If typing another digit would exceed the value assigned here, the corresponding behavior (e.g. [onObjectNumberTyped](events.md#onobjectnumbertyped)/[onNumberTyped](events.md#onnumbertyped)) is triggered immediately, improving responsiveness. | *int* |
| measure_movement | Measure Tool will automatically be used when moving the Object. | *bool* |
| memo | A string where you may persist user-data associated with the object. Tabletop Simulator saves this field, but otherwise does not use it. Store whatever information you see fit. | *string* |
| name | Internal resource name for this Object. Read only, and only useful for [spawnObjectData()](base.md#spawnobjectdata). Generally, you want [getName()](#getname). | *string* |
| pick_up_position | The position the Object was picked up at. Read only. | *vector* |
| pick_up_rotation | The rotation the Object was picked up at. Read only. | *vector* |
| remainder | If this object is a container that cannot exist with less than two contained objects (e.g. a deck), [taking out](#takeobject) the second last contained object will result in the container being destroyed. In its place the last remaining object in the container will be spawned.This variable provides a reference to the remaining object when it is being spawned. Otherwise, it's `nil`. Read only. | *object* |
| resting | If the Object is at rest. [Unity rigidbody property](https://docs.unity3d.com/2019.1/Documentation/Manual/RigidbodiesOverview.html). | *bool* |
| script_code | The Lua Script on the Object. | *string* |
| script_state | The saved data on the object. See [onSave()](events.md#onsave). | *string* |
| spawning | If the Object is finished spawning. Read only. | *bool* |
| static_friction | Static friction, value of 0-1. [Unity physics material](https://docs.unity3d.com/2019.1/Documentation/Manual/class-PhysicMaterial.html). | *float* |
| sticky | If other Objects on top of this one are also picked up when this Object is. | *bool* |
| tag | *deprecated* *Use [type](#type)*.This object's type. Read only. | *string* |
| tooltip | If the tooltip opens when a pointer hovers over the object. Tooltips display name and description. | *bool* |
| type | This object's type. Read only. | *string* |
| use_gravity | If gravity affects this object. | *bool* |
| use_grid | If snapping to grid is enabled or not. | *bool* |
| use_hands | If this object can be held in a hand zone. | *bool* |
| use_rotation_value_flip | Switches the axis the Object rotates around when flipped. | *bool* |
| use_snap_points | If snap points are used or ignored. | *bool* |
| value | A numeric value associated with the object, which when non-zero, will be displayed when hovering over the object.In the case of stacks, the value shown in the UI will be multiplied by the stack size i.e. you can use `value` to create custom stackable chips.When multiple objects are selected, values will be summed together with objects sharing overlapping [object tags](#tag-functions). | *int* |
| value_flags | *deprecated* *Use [object tags](#tag-functions)*. A [bit field](https://en.wikipedia.org/wiki/Bit_field). When objects with overlapping `value_flags` are selected and hovered over, their [values](#value) will be summed together. | *int* |

### Behavior Variables

Some objects provide additional behavior. This functionality is accessible as Object member variables, but will be `nil` unless the Object includes the behavior.

> **Example**
>
> The "Counter" Object has a `Counter` member variable. We'll use it to increment and retrieve the counter's value.

```
object.Counter.increment()
print("The counter value is now " .. object.Counter.getValue())
```

| Variable | Type | Available On |
| --- | --- | --- |
| AssetBundle | [AssetBundle](behavior__assetbundle.md) | Custom "AssetBundle" objects. |
| Book | [Book](behavior__book.md) | "Custom PDF" objects. |
| Browser | [Browser](behavior__browser.md) | "Tablet" objects. |
| Clock | [Clock](behavior__clock.md) | "Digital Clock" objects. |
| Counter | [Counter](behavior__counter.md) | "Counter" objects. |
| LayoutZone | [LayoutZone](behavior__layoutzone.md) | Layout zones. |
| RPGFigurine | [RPGFigurine](behavior__rpgfigurine.md) | "RPG Kit" animated figurine objects i.e. [type](#type) "rpgFigurine". |
| TextTool | [TextTool](behavior__texttool.md) | 3D Text objects e.g. text created with the in-game Text tool. |

---

## Function Summary

### Transform Functions

These functions handle the physical attributes of an Object: Position, Rotation, Scale, Bounds, Velocity. In other words, moving objects around as well as getting information on how they are moving.

######

######

######

######

######

######

######

######

######

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| addForce(*vector* vector, *int* force_type) | Adds force to an object in a directional Vector. | *returns bool* |
| addTorque(*vector* vector, *int* force_type) | Adds torque to an object in a rotational Vector. | *returns bool* |
| getAngularVelocity()getAngularVelocity() | Returns a Vector of the current angular velocity. | *returns vector* |
| getBounds() | Returns a Vector describing the size of an object in Global terms. | *returns vector* |
| getBoundsNormalized() | Returns a Vector describing the size of the merged colliders on an object in Global terms, as if it was rotated to {0,0,0}. | *returns vector* |
| getPosition()getPosition() | Returns a Vector of the current [World Position](types.md#position). | *returns vector* |
| getPositionSmooth()getPositionSmooth() | Returns a Vector of the current smooth move target if the object is smooth moving, otherwise returns `nil`. | *returns vector* |
| getRotation()getRotation() | Returns a Vector of the current rotation. | *returns vector* |
| getRotationSmooth()getRotationSmooth() | Returns a Vector of the current smooth rotation target if the object is smooth moving, otherwise returns `nil`. | *returns vector* |
| getScale() | Returns a Vector of the current scale. | *returns vector* |
| getTransformForward() | Returns a Vector of the forward direction of this object. | *returns vector* |
| getTransformRight() | Returns a Vector of the right direction of this object. | *returns vector* |
| getTransformUp() | Returns a Vector of the up direction of this object. | *returns vector* |
| getVelocity()getVelocity() | Returns a Vector of the current velocity. | *returns vector* |
| getVisualBoundsNormalized() | Returns a Vector describing the size of the merged renderers on an object in Global terms, as if it was rotated to {0,0,0}. | *returns vector* |
| isSmoothMoving()isSmoothMoving() | Indicates if an object is traveling as part of a Smooth move. Smooth moving is performed by setPositionSmooth and setRotationSmooth. | *returns bool* |
| positionToLocal(*vector* vector) | Returns a Vector after converting a world Vector (World Position) to a local Vector ([Local Position](types.md#position)). | *returns vector* |
| positionToWorld(*vector* vector) | Returns a Vector after converting a local Vector (Local Position) to a world Vector ([World Position](types.md#position)). | *returns vector* |
| rotate(*vector* vector) | Rotates Object smoothly in the direction of the given Vector. | *returns bool* |
| scale(*vector* vector or *float* ) | Scales Object by a multiple. | *returns bool* |
| setAngularVelocity(setAngularVelocity(...)*vector* vector) | Sets a Vector as the current angular velocity. | *returns bool* |
| setPosition(setPosition(...)*vector* vector) | Instantly moves an Object to the given Vector. The Vector is interpreted as [World Position](types.md#position). | *returns bool* |
| setPositionSmooth(*vector* vector, *bool* collide, *bool* fast) | Moves the Object smoothly to the given Vector. The Vector is interpreted as [World Position](types.md#position). | *returns bool* |
| setRotation(setRotation(...)*vector* vector) | Instantly rotates an Object to the given Vector. | *returns bool* |
| setRotationSmooth(*vector* vector, *bool* collide, *bool* fast) | Rotates the Object smoothly to the given Vector. | *returns bool* |
| setScale(setScale(...)*vector* vector) | Sets a Vector as the current scale. | *returns bool* |
| setVelocity(setVelocity(...)*vector* vector) | Sets a Vector as the current velocity. | *returns bool* |
| translate(translate(...)*vector* vector) | Smoothly moves Object by the given Vector offset. | *returns bool* |

### Tag Functions

These functions deal with the [tags](https://kb.tabletopsimulator.com/game-tools/object-tags/) associated with the object. An individual tag is a *string*  and is case-insensitive.

######

######

######

######

######

######

######

######

| Function NameTag Function Details | Description | Return |
| --- | --- | --- |
| addTag(addTag(...)*string* tag) | Adds the specified tag to the object. | *returns bool* |
| getTags()getTags() | Returns a table of tags (*string* ) that have been added to the object. | *returns table* |
| hasAnyTag()hasAnyTag() | Returns whether the object has any tags. | *returns bool* |
| hasMatchingTag(hasMatchingTag(...)*object* other) | Returns whether the object and the specified `other` object share at least one tag in common. | *returns bool* |
| hasTag(hasTag(...)*string* tag) | Returns whether the object has the specified tag. | *returns bool* |
| removeTag(removeTag(...)*string* tag) | Removes the specified tag from the object. | *returns bool* |
| setTags(setTags(...)*table* tags) | Replaces all tags on the object with those contained in the specified table (containing *string* ). | *returns bool* |

If you want to create your own system in which object tags govern the interactions, the canonical logic is that if the system has no tags it interacts with everything, but if it has any tags then it only interacts with objects which share one of them. i.e. (assuming the system is represented by an in-game object):

```
allow_interaction = not system.hasAnyTag() or system.hasMatchingTag(object)
```

### UI Functions

A new UI system was added to Tabletop Simulator which allows for more flexibility in the creation of UI elements on Objects. The old system (Classic UI) and new system (Custom UI) both work, and each has its own strengths.

#### Classic UI

These functions allow for the creation/editing/removal of functional buttons and text inputs which themselves trigger code within your scripts. These buttons/inputs are attached to the object they are created on.

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| clearButtons()clearButtons() | Removes all scripted buttons. | *returns bool* |
| clearInputs()clearInputs() | Removes all scripted inputs. | *returns bool* |
| createButton(*table* parameters) | Creates a scripted button attached to the Object. | *returns bool* |
| createInput(*table* parameters) | Creates a scripted input attached to the Object. | *returns bool* |
| editButton(*table* parameters) | Modify an existing button. | *returns bool* |
| editInput(*table* parameters) | Modify an existing input. | *returns bool* |
| getButtons() | Returns a Table of all buttons on this Object. | *returns table* |
| getInputs() | Returns a Table of all inputs on this Object. | *returns table* |
| removeButton(*int* index) | Removes a specific button. | *returns bool* |
| removeInput(*int* index) | Removes a specific button. | *returns bool* |

#### Custom UI

Custom UI gives you a wide variety of element types, not just buttons and inputs, to place onto an Object. It is an extension of the UI class, and details on its use can be found [on the UI page](ui.md).

### Get Functions

These functions obtain information from an object.

######

######

######

######

######

######

######

######

######

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| getAttachments()getAttachments() | Returns a table in the same format as [getObjects()](#getobjects) for containers. | *returns table* |
| getColorTint()getColorTint() | Color tint. | *returns color* |
| getCustomObject() | Returns a Table with the Custom Object information of a Custom Object. | *returns table* |
| getData()getData() | Returns a table data structure representation of the object. Works with [spawnObjectData(...)](base.md#spawnobjectdata). | *returns table* |
| getDescription()getDescription() | Description, also shows as part of Object's tooltip. | *returns string* |
| getFogOfWarReveal() | Settings impacting [Fog of War](https://kb.tabletopsimulator.com/game-tools/zone-tools/#fog-of-war-zone) being revealed. | *returns table* |
| getGMNotes()getGMNotes() | Game Master Notes only visible for [Player Color](player__colors.md) Black. | *returns string* |
| getGUID()getGUID() | String of the Object's unique identifier. | *returns string* |
| getJoints() | Returns information on any joints attached to this object. | *returns table* |
| getJSON(getJSON(...)*bool* indented) | Returns a JSON string representation of the object. Works with [spawnObjectJSON(...)](base.md#spawnobjectjson).`indented` is optional and defaults to `true`. | *returns string* |
| getLock()getLock() | If the Object is locked. | *returns bool* |
| getName()getName() | Name, also shows as part of Object's tooltip. | *returns string* |
| getObjects() | Returns data describing the objects contained within in the zone/bag/deck. | *returns var* |
| getQuantity()getQuantity() | Returns the number of objects contained within (if the Object is a bag, deck or stack), otherwise -1. | *returns int* |
| getRotationValue() | Returns the current rotationValue. Rotation values are used to give value to different rotations (like dice). | *returns var* |
| getRotationValues() | Returns a Table of rotation values. Rotation values are used to give value to different rotations (like dice). | *returns table* |
| getSelectingPlayers()getSelectingPlayers() | Returns a table of the player colors currently selecting the object. | *returns table* |
| getStateId()getStateId() | Current [state](https://kb.tabletopsimulator.com/host-guides/creating-states/) ID (index) an object is in. Returns -1 if there are no other states. State ids (indexes) start at 1. | *returns int* |
| getStates() | Returns a Table of information on the [states](https://kb.tabletopsimulator.com/host-guides/creating-states/) of an Object. | *returns table* |
| getValue() | Returns the Object's value. This represents something different depending on the Object's [type](#type). | *returns var* |
| getZones() | Returns a list of zones that the object is currently occupying. | *returns table* |
| isDestroyed()isDestroyed() | Returns true if the Object is (or will be) destroyed. | *returns bool* |

### Set Functions

These functions apply action to an object. They take some property in order to work.

######

######

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| setColorTint(setColorTint(...)*color* Color) | Sets the Color tint. | *returns bool* |
| setCustomObject(*table* parameters) | Sets a custom Object's properties. | *returns bool* |
| setDescription(setDescription(...)*string* description) | Sets a description for an Object. Shows in tooltip after delay. | *returns bool* |
| setFogOfWarReveal(*table* fog_settings) | Establish the settings and enable/disable an Object's revealing of [Fog of War](https://kb.tabletopsimulator.com/game-tools/zone-tools/#fog-of-war-zone). | *returns bool* |
| setGMNotes(setGMNotes(...)*string* notes) | Sets Game Master Notes only visible for [Player Color](player__colors.md) Black. | *returns bool* |
| setLock(setLock(...)*bool* lock) | Sets if an object is locked in place. | *returns bool* |
| setName(setName(...)*string* name) | Sets a name for an Object. Shows in tooltip. | *returns bool* |
| setRotationValue(*var* rotation_value) | Sets the Object's rotation value i.e. physically rotates the object. |  |
| setRotationValues(*table* rotation_values) | Sets rotation values of an object. Rotation values are used to give value to different rotations (like dice). | *returns bool* |
| setState(setState(...)*int* state_id) | Sets [state](https://kb.tabletopsimulator.com/host-guides/creating-states/) of an Object. State ids (indexes) start at 1. | *returns object* |
| setValue(*var* value) | Sets the Object's value. This represents something different depending on the Object's [type](#type). | *returns bool* |

### Action Function

These functions perform general actions on objects.

######

######

######

######

######

######

######

######

######

######

######

######

######

######

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| addAttachment(addAttachment(...)*object* Object) | The Object supplied as param is destroyed and becomes a dummy Object child. | *returns bool* |
| addContextMenuItem(*string* label, *func* callback, *bool* keep_open) | Adds a menu item to the objects right-click context menu. | *returns bool* |
| addToPlayerSelection(addToPlayerSelection(...)*string* player_color) | Adds object to player's selection. | *returns bool* |
| clearContextMenu()clearContextMenu() | Clears all menu items added by function [addContextMenuItem(...)](#addcontextmenuitem). | *returns bool* |
| clone(*table* parameters) | Copy/Paste this Object, returning a reference to the new Object. | *returns object* |
| cut(*int* count) | Cuts (splits) a deck at the given card count. | *returns table* |
| deal(*int* number, *string* player_color, *int* index, *bool* deal_from_bottom) | Deals Objects. Will deal from decks/bags/stacks/individual items. | *returns bool* |
| dealToColorWithOffset(*vector* offset, *bool* flip, *string* player_color) | Deals from a deck to a position relative to the hand zone. | *returns object* |
| destroyAttachment(destroyAttachment(...)*int* index) | Destroys an attachment with the given index. | *returns bool* |
| destroyAttachments()destroyAttachments() | Destroys all attachments. | *returns bool* |
| destruct()destruct() | Destroys Object. Allows for `self.destruct()`. | *returns bool* |
| drop()drop() | Forces an Object, if held by a player, to be dropped. | *returns bool* |
| flip()flip() | Flips Object over. | *returns bool* |
| highlightOff(highlightOff(...)*color* color) | Removes a highlight from around an Object. | *returns bool* |
| highlightOn(highlightOn(...)*color* color, *float* duration) | Creates a highlight around an Object. `duration` is optional and specified in seconds, when omitted the Object remains highlighted. | *returns bool* |
| jointTo(*object* object, *table* parameters) | Joints objects together, in the same way the Joint tool does. | *returns bool* |
| moveToHandStash() | Moves a card in hand into the player's hand stash. | *returns bool* |
| putObject(*object* put_object, *int* index) | Places an object into a container (chip stacks/bags/decks). | *returns object* |
| randomize(randomize(...)*string* color) | Shuffles deck/bag, rolls dice/coin, lifts other objects into the air. Same as pressing ``R`` by default. If the optional parameter `color` is used, this function will trigger `onObjectRandomized()`, passing that player color. | *returns bool* |
| registerCollisions(*bool* stay) | Registers this object for Global collision events. | *returns bool* |
| reload() | Returns Object reference of itself after it respawns itself. | *returns object* |
| removeAttachment(removeAttachment(...)*int* index) | Removes a child with the given index. Use [getAttachments()](#getattachments) to find out the index property. | *returns object* |
| removeAttachments()removeAttachments() | Detaches the children of this Object. Returns a table of object references | *returns table* |
| removeFromPlayerSelection(removeFromPlayerSelection(...)*string* player_color) | Removes object from player's selection. | *returns bool* |
| reset()reset() | Resets this Object. Resetting a Deck brings all the Cards back into it. Resetting a Bag clears its contents (works for both Loot and Infinite Bags). | *returns bool* |
| roll()roll() | Rolls dice/coins. | *returns bool* |
| shuffle()shuffle() | Shuffles/shakes up contents of a deck or bag. | *returns bool* |
| shuffleStates()shuffleStates() | Returns an Object reference to a new [state](https://kb.tabletopsimulator.com/host-guides/creating-states/) after randomly selecting and changing to one. | *returns object* |
| split(*int* piles) | Splits a deck, as evenly as possible, into a number of piles. | *returns table* |
| spread(*float* distance) | Uses the spread action on a deck. | *returns table* |
| takeObject(*table* parameters) | Takes an object out of a container (bag/deck/chip stack), returning a reference to the object that was taken out. | *returns object* |
| unregisterCollisions() | Unregisters this object for Global collision events. | *returns bool* |

### Component Functions

Component APIs are an advanced feature. An **understanding of how Unity works is required** to utilize them. See the [Introduction to Components](components__introduction.md) for more information.

######

######

######

######

######

######

######

| NameComponent Function Details | Return | Description |
| --- | --- | --- |
| getChild(getChild(...)*string* name) | [GameObject](components__gameobject.md) | Returns a child GameObject matching the specified `name`. |
| getChildren()getChildren() | *returns table* | Returns the list of children GameObjects. |
| getComponent(getComponent(...)*string* name) | [Component](components__component.md) | Returns a Component matching the specified `name` from the Object's list of Components. |
| getComponentInChildren(getComponentInChildren(...)*string* name) | [Component](components__component.md) | Returns a Component matching the specified `name`. Found by searching the Components of the Object and its [children](#getchildren) recursively (depth first). |
| getComponents(getComponents(...)*string* name) | *returns table* | Returns the Object's list of Components. `name` is optional, when specified only Components with specified `name` will be included. |
| getComponentsInChildren(getComponentsInChildren(...)*string* name) | *returns table* | Returns a list of Components found by searching the Object and its [children](#getchildren) recursively (depth first). `name` is optional, when specified only Components with specified `name` will be included. |

### Hide Functions

These functions can hide Objects, similar to how hand zones or hidden zones do.

| Function Name | Description | Return |
| --- | --- | --- |
| setHiddenFrom(*table* players) | Hides the Object from the specified players, as if it were in a hand zone. | *returns bool* |
| setInvisibleTo(*table* players) | Hides the Object from the specified players, as if it were in a hidden zone. | *returns bool* |
| attachHider(*string* id, *bool* hidden, *table* players) | A more advanced version of `setHiddenFrom(...)`. | *returns bool* |
| attachInvisibleHider(*string* id, *bool* hidden, *table* players) | A more advanced version of `setInvisibleTo(...)`. | *returns bool* |

### Global Function

The functions can be used on Objects, but can also be used on the game world using `Global`.

> **Examples of Using Global and Object**
>
> - `self.getSnapPoints()` gets snap points attached to that Object.
>
> - `Global.getSnapPoints()` gets snap points not attached to any specific Object but instead are attached to the game world.

######

######

######

######

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| addDecal(*table* parameters) | Add a Decal onto an object or the game world. | *returns bool* |
| call(*string* func_name, *table* func_params) | Used to call a Lua function on another entity. | *returns var* |
| getDecals() | Returns information on all decals attached to this object or the world. | *returns table* |
| getLuaScript()getLuaScript() | Get a Lua script as a string from the entity. | *returns string* |
| getSnapPoints() | Returns a table representing a list of snap points. | *returns table* |
| getTable(getTable(...)*string* table_name) | Data value of a variable in another Object's script. Can only return a table. | *returns table* |
| getVar(getVar(...)*string* var_name) | Data value of a variable in another entity's script. Cannot return a table. | *returns var* |
| getVectorLines()getVectorLines() | Returns Table of data representing the current Vector Lines on this entity. See [setVectorLines](#setvectorlines) for table format. | *returns table* |
| setDecals(*table* parameters) | Sets which decals are on an object. This removes other decals already present, and can remove all decals as well. | *returns bool* |
| setLuaScript(setLuaScript(...)*string* script) | Input a string as an entity's Lua script. Generally only used after spawning a new Object. | *returns bool* |
| setSnapPoints(*table* snap_points) | Replaces existing snap points with the specified list of snap points. | *returns bool* |
| setTable(setTable(...)*string* func_name, *table* data) | Creates/updates a variable in another entity's script. Only used for tables. | *returns bool* |
| setVar(setVar(...)*string* func_name, *var* data) | Creates/updates a variable in another entity's script. Cannot set a table. | *returns bool* |
| setVectorLines(*table* parameters) | Spawns Vector Lines from a list of parameters on this entity. | *returns bool* |

---

## Function Details

### Transform Function Details

#### addForce(...)

*returns bool*  Adds force to an object in a directional Vector.

> **addForce(vector, force_type)**
>
> - *vector* **vector**: A Vector of the direction and magnitude of force.
>
> - *int* **force_type**: An Int representing the force type to apply. Options below.
>
>   - Optional, defaults to 3.
>
>   - **1**: Continuous force, uses mass. *(Force)*
>
>   - **2**: Continuous acceleration, ignores mass. *(Acceleration)*
>
>   - **3**: Instant force impulse, uses mass. *(Impulse)*
>
>   - **4**: Instant velocity change, ignores mass. *(Velocity Change)*

---

#### addTorque(...)

*returns bool*  Adds torque to an object in a rotational Vector.

> **addTorque(vector, force_type)**
>
> - *vector* **vector**: A Vector of the direction and magnitude of rotational force.
>
> - *int* **force_type**: An Int representing the force type to apply. Options below.
>
>   - Optional, defaults to 3.
>
>   - **1**: Continuous force, uses mass. *(Force)*
>
>   - **2**: Continuous acceleration, ignores mass. *(Acceleration)*
>
>   - **3**: Instant force impulse, uses mass. *(Impulse)*
>
>   - **4**: Instant velocity change, ignores mass. *(Velocity Change)*

---

#### getBounds()

*returns vector*  Returns a Table of Vector information describing the size of an object in Global terms. [Bounds](https://docs.unity3d.com/2019.1/Documentation/ScriptReference/Bounds.html) are part of Unity, and represent an imaginary square box that can be drawn around an object. Unlike scale, it can help indicate the size of an object in in-game units, not just relative model size.

> **Return Table**
>
> - *table* **center**: The Vector of the center of the bounding box.
>
> - *table* **size**: The Vector of the size of the bounding box.
>
> - *table* **offset**: The Vector of the offset of the center of the bounding box from the middle of the Object model.

```
-- Example returned Table
{
    center = {x=0, y=3, z=0, 0, 3, 0},
    size = {x=5, y=5, z=5}, 5, 5, 5},
    offset = {x=0, y=-1, z=0, 0, -1, 0}
}
```

---

#### getBoundsNormalized()

*returns vector*  Returns a Table of Vector information describing the size of the merged colliders on an object in Global terms, as if it was rotated to {0,0,0}. [Bounds](https://docs.unity3d.com/2019.1/Documentation/ScriptReference/Bounds.html) are part of Unity, and represent an imaginary square box that can be drawn around an object. Unlike scale, it can help indicate the size of an object in in-game units, not just relative model size.

> **Return Table**
>
> - *table* **center**: The Vector of the center of the bounding box.
>
> - *table* **size**: The Vector of the size of the bounding box.
>
> - *table* **offset**: The Vector of the offset of the center of the bounding box from the middle of the Object model.

```
-- Example returned Table
{
    center = {x=0, y=3, z=0, 0, 3, 0},
    size = {x=5, y=5, z=5}, 5, 5, 5},
    offset = {x=0, y=-1, z=0, 0, -1, 0}
}
```

---

#### getScale()

*returns vector*  Returns a Vector of the current scale. Scale is not an absolute measurement, it is a multiple of the Object's default model size. So {x=2, y=2, z=2} would be a model twice its default size, not 2 units large.

---

#### getTransformForward()

*returns vector*  Returns a Vector of the forward direction of this Object. The direction is relative to how the object is facing.

```lua
-- Example of moving forward 5 units
function onLoad()
    distance = 5
    pos_target = self.getTransformForward()
    pos_current = self.getPosition()
    pos = {
        x = pos_current.x + pos_target.x * distance,
        y = pos_current.y + pos_target.y * distance,
        z = pos_current.z + pos_target.z * distance,
    }
    self.setPositionSmooth(pos)
end
```

---

#### getTransformRight()

*returns vector*  Returns a Vector of the forward direction of this object. The direction is relative to how the object is facing.

```lua
-- Example of moving right 5 units
function onLoad()
    distance = 5
    pos_target = self.getTransformRight()
    pos_current = self.getPosition()
    pos = {
        x = pos_current.x + pos_target.x * distance,
        y = pos_current.y + pos_target.y * distance,
        z = pos_current.z + pos_target.z * distance,
    }
    self.setPositionSmooth(pos)
end
```

---

#### getTransformUp()

*returns vector*  Returns a Vector of the up direction of this Object. The direction is relative to how the object is facing.

```lua
-- Example of moving up 5 units
function onLoad()
    distance = 5
    pos_target = self.getTransformUp()
    pos_current = self.getPosition()
    pos = {
        x = pos_current.x + pos_target.x * distance,
        y = pos_current.y + pos_target.y * distance,
        z = pos_current.z + pos_target.z * distance,
    }
    self.setPositionSmooth(pos)
end
```

---

#### getVisualBoundsNormalized()

*returns vector*  Returns a Table of Vector information describing the size of the merged renderers on an object in Global terms, as if it was rotated to {0,0,0}. [Bounds](https://docs.unity3d.com/2019.1/Documentation/ScriptReference/Bounds.html) are part of Unity, and represent an imaginary square box that can be drawn around an object. Unlike scale, it can help indicate the size of an object in in-game units, not just relative model size.

> **Return Table**
>
> - *table* **center**: The Vector of the center of the bounding box.
>
> - *table* **size**: The Vector of the size of the bounding box.
>
> - *table* **offset**: The Vector of the offset of the center of the bounding box from the middle of the Object model.

```
-- Example returned Table
{
    center = {x=0, y=3, z=0, 0, 3, 0},
    size = {x=5, y=5, z=5}, 5, 5, 5},
    offset = {x=0, y=-1, z=0, 0, -1, 0}
}
```

---

#### positionToLocal(...)

*returns vector*  Returns a Vector after converting a world vector to a local Vector. A world Vector is a positional Vector using the world's coordinate system. A Local Vector is a positional Vector that is relative to the position of the given object.

> **Object Scale**
>
> This function takes the Object's scale into account, as the Object is the key relative point.
>
> **positionToLocal(vector)**
>
> - *vector* **vector**: The world position to convert into a local position.

---

#### positionToWorld(...)

*returns vector*  Returns a Vector after converting a local Vector to a world Vector. A world Vector is a positional Vector using the world's coordinate system. A Local Vector is a positional Vector that is relative to the position of the given object.

> **Object Scale**
>
> This function takes the Object's scale into account, as the Object is the key relative point.
>
> **positionToLocal(vector)**
>
> - *vector* **vector**: The local position to convert into a world position.

---

#### rotate(...)

*returns bool*  Rotates Object smoothly in the direction of the given Vector. This does not set the Object to face a specific rotation, it rotates the Object around by the number of degrees given for x/y/z.

> **rotate(vector)**
>
> - *vector* **vector**: The amount of x/y/z to rotate by.

```
--Rotates object 90 degrees around its Y axis
self.rotate({x=0, y=90, z=0})
```

---

#### scale(...)

*returns bool*  Scales Object by a multiple. This does not set the Object to a specific scale, it scales the Object by the given multiple.

> **scale(scale)**
>
> - *vector* **scale**: Multiplier for scale.
>
>   - {x=1, y=1, z=1} would not change the scale.
>
> **scale(scale)**
>
> - *float* **scale**: Multiplier for scale which is applied to the X/Y/Z.
>
>   - 1 would not change the scale.

```
-- Both examples work to scale an object to be twice its current scale
self.scale({x=2, y=2, z=2})
self.scale(2)
```

---

#### setPositionSmooth(...)

*returns bool*  Moves the Object smoothly to the given Vector.

> **setPositionSmooth(vector, collide, fast)**
>
> - *vector* **vector**: A positional Vector.
>
> - *bool* **collide**: If the Object will collide with other Objects while moving.
>
> - *bool* **fast**: If the Object is moved quickly.

---

#### setRotationSmooth(...)

*returns bool*  Rotates the Object smoothly to the given Vector.

> **setRotationSmooth(vector, collide, fast)**
>
> - *vector* **vector**: A rotational Vector.
>
> - *bool* **collide**: If the Object will collide with other Objects while rotating.
>
> - *bool* **fast**: If the Object is rotated quickly.

---

### UI Function Details

#### createButton(...)

*returns bool*  Creates a scripted button attached to the Object. Scripted buttons are buttons that can be clicked while in-game that trigger a function in a script.

Button Tips

- Buttons can not be clicked from their back side.

- Buttons can not be clicked if there is another object between the pointer and the button. This does not include the Object the button is attached to.

- Buttons are placed relative to the Object they are attached to.

- The maximum font size is capped at 1000.

- The minimum width/height is 60. Any lower number (besides 0) will appear to be 60. This prevents visual glitches involving the corner rounding.

- A button width/height of 0 will cause the button not to be drawn, but its label will be. This can be a way to attach text to an Object.

- You cannot assign an index to a button. It is given one automatically.

> **createButton(parameters)**
>
> - *table* **parameters**: A Table containing the information used to spawn the button.
>
>   - *string* **parameters.click_function**: A String of the function's name that will be run when button is clicked.
>
>   - *string* **parameters.function_owner**: The Object which contains the click_function function.
>
>     - Optional, Defaults to Global.
>
>   - *string* **parameters.label**: Text that appears on the button.
>
>     - Optional, defaults to an empty string.
>
>   - *vector* **parameters.position**: Where the button appears, relative to the Object's center.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *vector* **parameters.rotation**: How the button is rotated, relative to the Object's rotation.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *vector* **parameters.scale**: Scale of the button, relative to the Object's scale.
>
>     - Optional, defaults to {x=1, y=1, z=1}.
>
>   - *float* **parameters.width**: How wide the button will be, relative to the Object.
>
>     - Optional, defaults to 100.
>
>   - *float* **parameters.height**: How tall the button will be, relative to the Object.
>
>     - Optional, defaults to 100.
>
>   - *float* **parameters.font_size**: Size the label font will be, relative to the Object.
>
>     - Optional, defaults to 100.
>
>   - *color* **parameters.color**: A Color for the clickable button.
>
>     - Optional, defaults to {r=1, g=1, b=1}.
>
>   - *color* **parameters.font_color**: A Color for the label text.
>
>     - Optional, defaults to {r=0, g=0, b=0}.
>
>   - *color* **parameters.hover_color**: A Color for the background during mouse-over.
>
>     - Optional.
>
>   - *color* **parameters.press_color**: A Color for the background when clicked.
>
>     - Optional.
>
>   - *string* **parameters.tooltip**: Popup of text, similar to how an Object's name is displayed on mouseover.
>
>     - Optional, defaults to an empty string.
>
> **click_function(obj, player_clicker_color, alt_click)**
>
> *The click function which is activated by clicking this button has its own parameters it is passed automatically.*
>
> - *object* **obj**: The Object the button is attached to.
>
> - *string* **player_clicker_color**: [Player Color](player__colors.md) of the player that pressed the button.
>
> - *bool* **alt_click**: True if a button other than left-click was used to click the button.

```lua
function onLoad()
    params = {
        click_function = "click_func",
        function_owner = self,
        label          = "Test",
        position       = {0, 1, 0},
        rotation       = {0, 180, 0},
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = {0.5, 0.5, 0.5},
        font_color     = {1, 1, 1},
        tooltip        = "This text appears on mouseover.",
    }
    self.createButton(params)
end

function click_func(obj, color, alt_click)
    print(obj)
    print(color)
    print(alt_click)
end
```

> **Bug**
>
> Button scale currently distorts button height and width if the button is rotated at anything besides `{0,0,0}`.

---

#### createInput(...)

*returns bool*  Creates a scripted input attached to the Object. Scripted inputs are boxes you can click inside of in-game to input/edit text. Every letter typed triggers the function. The bool that is returned as part of the input_function allows you to determine when a player has finished editing the input.

Input Tips

- Inputs can not be clicked from their back side.

- Inputs can not be clicked if there is another object between the pointer and the inputs. This does not include the Object the input is attached to.

- Inputs are placed relative to the Object they are attached to.

- The maximum font size is capped at 1000.

- The minimum width/height is 60. Any lower number (besides 0) will appear to be 60. This prevents visual glitches involving the corner rounding.

- Font that does not fit in the input window's width/height does NOT display. To know how much height you need for each line, the formula is `(font_size * # of lines) + 23`. In other words, multiply how many lines of text you want to display by your font_size and add 23. That is your height value.

- You cannot assign an index to an input. It is given one automatically.

> **createInput(parameters)**
>
> - *table* **parameters**: A Table containing the information used to spawn the input.
>
>   - *string* **parameters.input_function**: A String of the function's name that will be run when a key is used or when it is deselected.
>
>   - *object* **parameters.function_owner**: The Object which contains the input_function function.
>
>     - Optional, Defaults to Global.
>
>   - *string* **parameters.label**: Text that appears as greyed out text when there is no value in the input.
>
>     - Optional, defaults to an empty string.
>
>   - *vector* **parameters.position**: Where the input appears, relative to the Object's center.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *vector* **parameters.rotation**: How the input is rotated, relative to the Object's rotation.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *vector* **parameters.scale**: Scale of the input, relative to the Object's scale.
>
>     - Optional, defaults to {x=1, y=1, z=1}.
>
>   - *float* **parameters.width**: How wide the input will be, relative to the Object.
>
>     - Optional, defaults to 100.
>
>   - *float* **parameters.height**: How tall the input will be, relative to the Object.
>
>     - Optional, defaults to 100.
>
>   - *float* **parameters.font_size**: Size the label/value font will be, relative to the Object.
>
>     - Optional, defaults to 100.
>
>   - *color* **parameters.color**: A Color for the input's background.
>
>     - Optional, defaults to {r=1, g=1, b=1}.
>
>   - *color* **parameters.font_color**: A Color for the value text.
>
>     - Optional, defaults to {r=0, g=0, b=0}.
>
>   - *string* **parameters.tooltip**: A popup of text, similar to how an Object's name is displayed on mouseover.
>
>     - Optional, defaults to an empty string.
>
>   - *int* **parameters.alignment**: How text is aligned in the input box.
>
>     - Optional, defaults to 1.
>
>     - **1**: Automatic
>
>     - **2**: Left
>
>     - **3**: Center
>
>     - **4**: Right
>
>     - **5**: Justified
>
>   - *string* **parameters.value**: Text entered into the input.
>
>     - Optional, defaults to an empty string.
>
>   - *int* **parameters.validation**: What characters can be input into the input value field.
>
>     - Optional, defaults to 1.
>
>     - **1**: None
>
>     - **2**: Integer
>
>     - **3**: Float
>
>     - **4**: Alphanumeric
>
>     - **5**: Username
>
>     - **6**: Name
>
>   - *int* **parameters.tab**: How the pressing of "tab" is handled when inputting.
>
>     - Optional, defaults to 1.
>
>     - **1**: None
>
>     - **2**: Select Next Input
>
>     - **3**: Indent
>
> **input_function(obj, player_clicker_color, input_value, selected)**
>
> *The click function which is activated by editing the text in this input has its own parameters it is passed automatically.*
>
> - *object* **obj**: The Object the input is attached to.
>
> - *string* **player_clicker_color**: [Player Color](player__colors.md) of the player that has selected/edited the input.
>
> - *string* **input_value**: Text currently in the input.
>
> - *bool* **selected**: If the value box is still being edited or not.

```lua
function onLoad()
    self.createInput({
        input_function = "input_func",
        function_owner = self,
        label          = "Gold",
        alignment      = 4,
        position       = {x=0, y=1, z=0},
        width          = 800,
        height         = 300,
        font_size      = 323,
        validation     = 2,
    })
end

function input_func(obj, color, input, stillEditing)
    print(input)
    if not stillEditing then
        print("Finished editing.")
    end
end
```

---

#### editButton(...)

*returns bool*  Modify an existing button. The only parameter that is required is the index. The rest are optional, and not using them will cause the edited button's element to remain. Indexes start at 0. The first button on any given Object has an index of 0, the next button on it has an index of 1, etc. Each Object has its own indexes.

> **editButton(parameters)**
>
> - *table* **parameters**: A Table containing the information used to spawn the button.
>
>   - *int* **parameters.index**: Index of the button you want to edit.
>
>   - *string* **parameters.click_function**: Function's name that will be run when button is clicked.
>
>   - *object* **parameters.function_owner**: The Object which contains the click_function function.
>
>   - *string* **parameters.label**: Text that appears on the button.
>
>   - *vector* **parameters.position**: Where the button appears, relative to the Object's center.
>
>   - *vector* **parameters.rotation**: How the button is rotated, relative to the Object's rotation.
>
>   - *vector* **parameters.scale**: Scale of the button, relative to the Object's scale.
>
>   - *float* **parameters.width**: How wide the button will be, relative to the Object.
>
>   - *float* **parameters.height**: How tall the button will be, relative to the Object.
>
>   - *float* **parameters.font_size**: Size the label font will be, relative to the Object.
>
>   - *color* **parameters.color**: A Color for the clickable button.
>
>   - *color* **parameters.font_color**: A Color for the label text.
>
>   - *color* **parameters.hover_color**: A Color for the background during mouse-over.
>
>   - *color* **parameters.press_color**: A Color for the background when clicked.
>
>   - *string* **parameters.tooltip**: Text of a popup of text, similar to how an Object's name is displayed on mouseover.

```
self.editButton({index=0, label="New Label"})
```

---

#### editInput(...)

*returns bool*  Modify an existing input. The only parameter that is required is the index. The rest are optional, and not using them will cause the edited input's element to remain. Indexes start at 0. The first input on any given Object has an index of 0, the next input on it has an index of 1, etc. Each Object has its own indexes.

> **editInput(parameters)**
>
> *All fields besides `index` are optional. If not used, the element will default to the element's current setting.*
>
> - *table* **parameters**: A Table containing the information used to spawn the input.
>
>   - *int* **parameters.index**: Index of the input you want to edit.
>
>   - *string* **parameters.input_function**: The function's name that will be run when the input is selected.
>
>   - *object* **parameters.function_owner**: The Object which contains the input_function function.
>
>   - *string* **parameters.label**: Text that appears as greyed out text when there is no value in the input.
>
>   - *vector* **parameters.position**: Where the input appears, relative to the Object's center.
>
>   - *vector* **parameters.rotation**: How the input is rotated, relative to the Object's rotation.
>
>   - *vector* **parameters.scale**: Scale of the input, relative to the Object's scale.
>
>   - *float* **parameters.width**: How wide the input will be, relative to the Object.
>
>   - *float* **parameters.height**: How tall the input will be, relative to the Object.
>
>   - *float* **parameters.font_size**: Size the label/value font will be, relative to the Object.
>
>   - *color* **parameters.color**: A Color for the input's background.
>
>   - *color* **parameters.font_color**: A Color for the value text.
>
>   - *string* **parameters.tooltip**: A popup of text, similar to how an Object's name is displayed on mouseover.
>
>   - *int* **parameters.alignment**: How text is aligned in the input box.
>
>     - **1**: Automatic
>
>     - **2**: Left
>
>     - **3**: Center
>
>     - **4**: Right
>
>     - **5**: Justified
>
>   - *string* **parameters.value**: A String of the text entered into the input.
>
>   - *int* **parameters.validation**: An Int which determines what characters can be input into the value.
>
>     - **1**: None
>
>     - **2**: Integer
>
>     - **3**: Float
>
>     - **4**: Alphanumeric
>
>     - **5**: Username
>
>     - **6**: Name
>
>   - *int* **parameters.tab**: An Int which determines how pressing tab is handled when inputting.
>
>     - **1**: None
>
>     - **2**: Select Next Input
>
>     - **3**: Indent

```
self.editInput({index=0, value="New Value"})
```

---

#### getButtons()

*returns table*  Returns a Table of all buttons on this Object. The Table contains parameters tables with the same keys as seen in the [createButton](#createbutton) section, except each Table of parameters also contains an **index** entry. This is used to identify each button, used by [editButton](#editbutton) and [removeButton](#removebutton).

Indexes start at 0.

---

#### getInputs()

*returns table*  Returns a Table of all inputs on this Object. The Table contains parameters tables with the same keys as seen in the [createInput](#createinput) section, except each Table of parameters also contains an **index** entry. This is used to identify each input, used by [editInput](#editinput) and [removeInput](#removeinput).

Indexes start at 0.

---

#### removeButton(...)

*returns bool*  Removes a specific button. Indexes start at 0. The first button on any given Object has an index of 0, the next button on it has an index of 1, etc. Each Object has its own indexes.

Removing an index instantly causes all other higher indexes to shift down 1.

> **removeButton(index)**
>
> - *int* **index**: Button index to remove.

---

#### removeInput(...)

*returns bool*  Removes a specific input. Indexes start at 0. The first input on any given Object has an index of 0, the next input on it has an index of 1, etc. Each Object has its own indexes.

Removing an index instantly causes all other higher indexes to shift down 1.

> **removeInput(index)**
>
> - *int* **index**: Input index to remove.

---

### Get Function Details

#### getCustomObject()

*returns table*  Returns a Table with the Custom Object information of a Custom Object. See the [Custom Game Objects](custom-game-objects.md) page for the kind of information returned.

```
-- Example returned Table for a custom token
{
    image = "SOME URL HERE",
    thickness = 0.2,
    merge_distance = 15,
    stackable = false,
}
```

> **Jigsaw Puzzles**
>
> If you use getCustomObject() on a puzzle piece, it will also return `desired_position`, which is its position if the puzzle is "solved". You can use this to determine where to put the piece.

---

#### getFogOfWarReveal()

*returns table*  Settings impacting [Fog of War](https://kb.tabletopsimulator.com/game-tools/zone-tools/#fog-of-war-zone) being revealed. In the example returned table, these are the default values of any object.

> **Color Selection**
>
> "Black" and "All" are synonymous for Fog of War. Either means that all players can see the revealed area when `reveal = true`.

```
-- Example returned Table for a custom token
{
    reveal = false,
    color = 'All',
    range = 5
}
```

---

#### getJoints()

*returns table*  Returns information on any joints attached to this object. This information included the GUID of the other objects attached via the joints.

This function returns a table of sub-tables, each sub-table representing one joint.

Example of a return table of an object with 2 joints:

```
{
    {
        type              = "Spring",
        joint_object_guid = "555555",
        collision         = false,
        break_force       = 1000,
        break_torgue      = 1000,
        axis              = {0,0,0},
        anchor            = {0,0,0},
        connector_anchor  = {0,0,0},
        motor_force       = 0,
        motor_velocity    = 0,
        motor_free_spin   = false,
        spring            = 50,
        damper            = 0.1
        max_distance      = 10
        min_distance      = 0
    },
    {
        type              = "Spring",
        joint_object_guid = "888888",
        collision         = false,
        break_force       = 1000,
        break_torgue      = 1000,
        axis              = {0,0,0},
        anchor            = {0,0,0},
        connector_anchor  = {0,0,0},
        motor_force       = 0,
        motor_velocity    = 0,
        motor_free_spin   = false,
        spring            = 50,
        damper            = 0.1
        max_distance      = 10
        min_distance      = 0
    },
}
```

Example of printing the first sub-table's information:

```lua
local jointsInfo = self.getJoints()
for k, v in pairs(jointsInfo[1]) do
    print(k, ":  ", v)
end
```

---

#### getObjects(...)

*returns var*  Returns data describing the objects contained within in the zone/bag/deck.

The format of the data returned depends on the kind of object.

##### Containers (Bags/Decks)

Containers return a (numerically indexed) table consisting of sub-tables that each have the following properties:

| Name | Type | Description |
| --- | --- | --- |
| description | *string* | [Description](#getdescription) of the contained object. |
| gm_notes | *string* | [GM Notes](#getgmnotes) on the contained object. |
| guid | *string* | [GUID](#guid) of the contained object. |
| index | *int* | Index of the contained object, represents the item's order in the container. |
| lua_script | *string* | [Lua script](#script_code) on the contained object. |
| lua_script_state | *string* | [Lua script saved state](#script_state) of the contained object. |
| memo | *string* | [Memo](#memo) on the contained object. |
| name | *string* | Name of the contained object.Will correspond with [getName()](#getname), unless it's blank, in which case it'll be the [internal resource name](#name). |
| nickname | *string* | *deprecated* *Use `name`*.[Name](#getname) of the item. |
| tags | *table* | A table of *string* representing the [tags](https://kb.tabletopsimulator.com/game-tools/object-tags/) on the contained object. |

> **Example**
>
> Find a contained object with the name "Super Card" (within the Bag/Deck `object`), and use its index to [take the object out](#takeobject) of the container.

```lua
-- Iterate through each contained object
for _, containedObject in ipairs(object.getObjects()) do
    if containedObject.name == "Super Card" then
        object.takeObject({
            index = containedObject.index
        })
        break -- Stop iterating
    end
end
```

##### Zones

Zones return a (numerically indexed) table of game Objects occupying the zone.

> **getObjects(ignore_tags=false)**
>
> - *bool* **ignore_tags**: If `true` then all objects in the zone will be returned, regardless of tags.
>
> **Important**
>
> If the zone has [tags](#tag-functions), then only objects with compatible tags will occupy the zone (unless `ignore_tags` is true).
>
> **Example**
>
> [Highlight](#highlighton) red all cards occupying a zone (`object`), regardless of tag.

```lua
-- Iterate through object occupying the zone
for _, occupyingObject in ipairs(object.getObjects(true)) do
    if occupyingObject.type == "Card" then
        occupyingObject.highlightOn('Red')
    end
end
```

---

#### getRotationValue()

*returns var*  Returns the current rotationValue. Rotation values are used to give value to different rotations (like dice) and are set using scripting or the Gizmo tool. The value returned is for the rotation that is closest to being pointed "up".

The returned value will either be a number or a string, depending on the value that was given to that rotation.

```lua
local value = self.getRotationValue()
print(value)
```

---

#### getRotationValues()

*returns table*  Returns a Table of rotation values. Rotation values are used to give value to different rotations (like dice) based on which side is pointed "up". It works by checking all of the rotation values assigned to an object and determining which one of them is closest to pointing up, and then displaying the value associated with that rotation.

You can manually assign rotation values to objects using the Rotation Value Gizmo tool (in the left side Gizmo menu) or using [setRotationValues(...)](#setrotationvalues).

> **Return Table**
>
> The returned Table contains sub-Tables, each sub-Table containing these 2 key/value pairs.
>
> - *var* **value**: What value is associated with a given rotation. Often a String or Int.
>
>   - Starting a value with a # will cause it not to show in the Object's tooltip.
>
> - *vector* **rotation**: Rotation of the Object that best represents the given value pointing up.

```
-- Example returned Table for a coin
{
    {value="Heads", rotation={x=0, y=0, z=0}},
    {value="Tails", rotation={x=180, y=0, z=0}},
}
```

---

#### getStates()

*returns table*  Returns a Table of information on the [states](https://kb.tabletopsimulator.com/host-guides/creating-states/) of an Object. Stated Objects have ids (indexes) starting with 1.

> **The returned table will **NOT** include data on the current state.**
>
> **Return Table**
>
> Returns a table of sub-tables. Each sub-table represents one other state.
>
> - *string* **name**: Name of the item.
>
> - *string* **description**: Description of the item.
>
> - *string* **guid**: GUID of the item.
>
> - *int* **id**: Index of the item, represents the item's order in the states.
>
> - *string* **lua_script**: Any Lua scripting saved on the item.
>
> - *string* **lua_script_state**: Any JSON save data on this item.
>
> - nickname: A duplicate of the "name" field.
>
>   - This is for backwards compatibility purposes only.

```
-- Example returned Table
{
    {
        name             = "First State",
        description      = "",
        guid             = "AAA111",
        id               = 1,
        lua_script       = "",
        lua_script_state = "",
    },
    {
        name             = "Second State",
        description      = "",
        guid             = "BBB222",
        id               = 2,
        lua_script       = "",
        lua_script_state = "",
    },
}
```

---

#### getValue()

*returns var*  Returns the Object's value. This represents something different depending on the Object's [type](#type).

> **Important**
>
> If the Object has [rotation values](#getrotationvalues), then this method will return the rotation value i.e. behave the same as [getRotationValue()](#getrotationvalue).

See [setValue(...)](#setvalue) for more information.

---

#### getZones()

*returns table*  Returns a list of zones that the object is currently occupying.

> **Important**
>
> If the object has [tags](object.md#tag-functions), then the object will only occupy zones with compatible tags.
>
> **Example**
>
> Print a comma separated list of GUIDs belonging to zones an object is currently occupying.

```lua
local guids = {}

for _, zone in ipairs(object.getZones()) do
    table.insert(guids, zone.guid)
end

if #guids > 0 then
    print("Object is contained within " .. table.concat(guids, ", "))
else
    print("Object is not contained within any zones")
end
```

### Set Function Details

#### setCustomObject(...)

*returns bool*  Sets a custom Object's properties. It can be used after [spawnObject](base.md#spawnobject) or on an already existing custom Object. If used on an already existing custom Object, you must use [reload](#reload) on the object after setCustomObject for the changes to be displayed.

> **setCustomObject(parameters)**
>
> The Table of parameters varies, depending on which type of custom Object it is. See the [Custom Game Objects](custom-game-objects.md) page for the parameters needed.

```
-- Example of a custom token
params = {
    image = "SOME URL HERE",
    thickness = 0.2,
    merge_distance = 15,
    stackable = false,
}
obj.setCustomObject(params)
```

---

#### setFogOfWarReveal(...)

*returns bool*  Establish the settings and enable/disable an Object's revealing of [Fog of War](https://kb.tabletopsimulator.com/game-tools/zone-tools/#fog-of-war-zone).

> **setFogOfWarReveal(fog_settings)**
>
> - *table* **fog_settings**: A Table containing information on if/how this Object should reveal Fog of War.
>
>   - *bool* **reveal**: Can the Object currently
>
>     - If this is not used, the current setting for this Object is kept.
>
>   - *string* **color**: The rotation Vector of the Object that best represents the given value pointing up.
>
>     - If this is not used, the current setting for this Object is kept.
>
>     - "Black" means "visible to all players."
>
>     - "All" means "visible to all players."
>
>   - *float* **range**: How far from the Object the reveal effect reaches (radius, inches).
>
>     - If this is not used, the current setting for this Object is kept.

```
-- Example of enabling reveal for all players at 3 units of radius.
params = {
    reveal = true,
    color  = "Black",
    range  = 3,
}
self.setFogOfWarReveal(params)
```

---

#### setRotationValue(...)

Sets the Object's rotation value i.e. physically rotates the object.

> **setRotationValue(rotation_value)**
>
> - *var* **rotation_value**: A [rotation value](#getrotationvalues). Should be a *int* , *string*  or *float* .

The Object will be elevated (smooth moved upward), smoothly rotated to the rotation corresponding with the specified `rotation_value` and then released to fall back into place.

> **Example**
>
> Rotate a die to show the value 6.

```
die.setRotationValue(6)
```

---

#### setRotationValues(...)

*returns bool*  Sets rotation values of an object. Rotation values are used to give value to different rotations (like dice). It works by checking all of the rotation values assigned to an object and determining which one of them is closest to pointing up, and then displaying the value associated with that rotation.

> **setRotationValues(rotation_values)**
>
> - *table* **rotation_values**: A Table containing Tables with the following values. 1 sub-Table per "face".
>
>   - *var* **value**: Value associated with the rotation. Should be a *int* , *string*  or *float* .
>
>     - If `value` is a string starting with "#", then it will not be displayed in the Object's tooltip.
>
>   - *vector* **rotation**: The rotation of the Object that corresponds with the provided `value`.
>
> **Example**
>
> Set the two different sides (rotations) of a coin to have the values "Heads" and "Tails".

```
self.setRotationValues({
    {
        value="Heads",
        rotation={x=0, y=0, z=0}
    },
    {
        value="Tails",
        rotation={x=180, y=0, z=0}
    },
})
```

---

#### setValue(...)

*returns bool*  Sets the Object's value. This represents something different depending on the Object's [type](#type).

> **Important**
>
> If the Object has [rotation values](#getrotationvalues), then this method will set the rotation value i.e. behave the same as [setRotationValue(...)](#setrotationvalue).
>
> **setValue(value)**
>
> - *var* **value**: The value to set. Represents something different depending on the Object's [type](#type). Refer to the [value type table](#setvalue-types).

| [Object Type](#type) | Value Type | Description |
| --- | --- | --- |
| `3D Text` | *string* | Replaces the 3D Text's content. |
| `Clock` | *int* | Sets the remaining "Stopwatch" time (in seconds) on the Clock. |
| `Counter` (Digital Counter) | *int* | Sets the counter's value. |
| `Fog` (Hidden Zone) | *string* | Changes the hidden zone owner to the specified [Player Color](player__colors.md). |
| `Hand` (Hand Zone) | *string* | Changes the hand owner to the specified [Player Color](player__colors.md). |
| `Tablet` | *string* | Loads the specified URL in the tablet's browser. |

---

### Action Function Details

#### addContextMenuItem(...)

*returns bool*  Adds a menu item to the objects right-click context menu.

> **addContextMenuItem(label, callback, keep_open)**
>
> - *string* **label**: Label for the menu item.
>
> - *func* **callback**: Execute if menu item is selected. Called as `callback(player_color, object_position, object)`
>
>   - *string* **player_color** [Player Color](player__colors.md) who selected the menu item.
>
>   - *vector* **object_position** Position of object.
>
>   - *string* **object** Object in question.
>
> - *bool* **keep_open**: Keep context menu open after menu item was selected.
>
>   - Optional, Default: keep_open = false. Close context menu after selection.

```lua
function onLoad()
    self.addContextMenuItem("doStuff", itemAction)
end

function itemAction(player_color, position, object)
    log({player_color, position, object})
end
```

---

#### clone(...)

*returns object*  Copy/Paste this Object.

> **clone(parameters)**
>
> - *table* **parameters**: A Table with information used when pasting.
>
>   - *vector* **parameters.position**: Where the Object is placed.
>
>     - Optional, defaults to {x=0, y=3, z=0}.
>
>   - *bool* **parameters.snap_to_grid**: If the Object snaps to grid.
>
>     - Optional, defaults to false.

---

#### cut(...)

*returns table*  Cuts (splits) a deck down to a given card. In other words, it counts down from the top of the deck and makes a new deck of that size and puts the remaining cards in the other pile.

After the cut, the resulting decks much each have at least 2 cards. This means the parameter used must be between **2** and **totalNumberOfCards - 2**.

> **Important**
>
> New decks take a frame to be created. This means trying to act on them immediately will not work. Use a coroutine or timer to add a delay.
>
> **cut(count)**
>
> - *int* **count**: How many cards down to cut the deck.
>
>   - Optional, if no value is provided the deck is cut in half.
>
> **Returned table**
>
> - *table*  The table that is returned
>
>   - *object* **1**: The lower deck, containing the remaining cards in the deck.
>
>   - *object* **2**: The upper deck, containing *count* number of cards.

```
newDecks = deck.cut(5)
--A delay would be required here for these next two lines to work.
--The decks haven't been fully created yet.
newDecks[1].deal(1)
newDecks[2].deal(1)
```

#### deal(...)

*returns bool*  Deals Objects to hand zones. Will deal from decks/bags/stacks as well as individual items. If dealing an individual item to a hand zone, it is a good idea to make sure that its [Member Variable](#member-variables) for `use_hands` is `true`.

> **deal(number, player_color, index)**
>
> - *int* **number**: How many to deal.
>
> - *string* **player_color**: The [Player Color](player__colors.md) to deal to.
>
>   - Optional, defaults to an empty string. If not supplied, it will attempt to deal to all seated players.
>
> - *int* **index**: Index of hand zone to deal to.
>
>   - Optional, defaults to the first created hand zone.
>
> - *bool* **deal_from_bottom**: Deal the card from the bottom of the deck instead of the top.
>
>   - Optional, defaults to the top card of the deck.

---

#### dealToColorWithOffset(...)

*returns object*  Deals from a deck to a position relative to the hand zone.

> **dealToColorWithOffset(offset, flip, player_color)**
>
> - *vector* **offset**: The x/y/z offset to deal to around the given hand zone.
>
> - *bool* **flip**: If the card is flipped over when dealt.
>
> - *string* **player_color**: Hand zone [Player Color](player__colors.md) to offset dealing to.

```
-- Example of dealing 2 cards in front of the White player, face up.
self.dealToColorWithOffset({-2,0,5}, true, "White")
self.dealToColorWithOffset({ 2,0,5}, true, "White")
```

---

#### jointTo(...)

*returns bool*  Joints objects together, in the same way the Joint tool does.

**Using obj.jointTo(), with no object or parameter used as arguments, will remove all joints from that Object.**

> **jointTo(object, parameters)**
>
> - *object* **object**: The Object that the selected object will be jointed to.
>
> - *table* **parameters**: A table of parameters. Which parameters depends on the joint type. See below for more.
>
> - All parameters have defaults, the same as the Joint Tool.

Example of Fixed:

```
self.jointTo(obj, {
    ["type"]        = "Fixed",
    ["collision"]   = true,
    ["break_force"]  = 1000.0,
    ["break_torgue"] = 1000.0,
})
```

Example of Spring:

```
self.jointTo(obj, {
    ["type"]        = "Spring",
    ["collision"]   = false,
    ["break_force"]  = 1000.0,
    ["break_torgue"] = 1000.0,
    ["spring"]      = 50,
    ["damper"]      = 0.1,
    ["max_distance"] = 10,
    ["min_distance"] = 1
})
```

Example of Hinge:

```
self.jointTo(obj, {
    ["type"]        = "Hinge",
    ["collision"]   = true,
    ["axis"]        = {1,1,1},
    ["anchor"]      = {1,1,1},
    ["break_force"]  = 1000.0,
    ["break_torgue"] = 1000.0,
    ["motor_force"]  = 100.0,
    ["motor_velocity"] = 10.0,
    ["motor_free_spin"] = true
})
```

---

#### moveToHandStash(...)

*returns bool*  Can be called on card objects held in the player's hand; will move the card into the player's hand stash. The stash is a temporary holding area for cards, useful when implementing drafting mechanics. The stash is not generally interactable by players (though they can dislodge it by using the gizmo tool).

> **Retrieving cards from the hand stash**
>
> You should always use [Player.drawHandStash()](player__instance.md#drawhandstash) to retreive cards from the hand stash.

See [Wait.collect](wait.md#collect) for an example of using the hand stash.

---

#### putObject(...)

*returns object*  Places an object into a container (chip stacks/bags/decks). If neither Object is a container, but they are able to be combined (like with 2 cards), then they form a deck/stack.

> **putObject(put_object, index)**
>
> - *object* **put_object**: An Object to place into the container.
>
> - *int* **index**: Target index inside the container.
>
>   - Optional
>
> **Returned Object**
>
> The container is returned as the Object reference. Either this is the container/deck/stack the other Object was placed into, or the deck/stack that was formed by the putObject action.
>
> **Putting Cards into Decks**
>
> When you call this `putObject()` to put a card into a deck, the card goes into the end of the deck which is closest to it in Y elevation. So, if both the card and the deck are resting on the table, the card will be put at the bottom of the deck. if the card is hovering above the deck, it will be put at the top."

```lua
-- Example of a script on a bag that places Object into itself
local obj = getObjectFromGUID("AAA111")
self.putObject(obj)
```

---

#### registerCollisions(...)

*returns bool*  Registers this object for Global collision events, such as [onObjectCollisionEnter](events.md#onobjectcollisionenter). Always returns `true`.

> **registerCollision(stay)**
>
> - *bool* **stay**: Whether we should register for [onObjectCollisionStay](events.md#onobjectcollisionstay). Stay events may negatively impact performance, only set this to `true` if absolutely necessary.
>
>   - Optional, defaults to `false`.

---

#### reload()

*returns object*  Returns Object reference of itself after it respawns itself. This function causes the Object to be deleted and respawned instantly to refresh it, so its old Object reference will no longer be valid.

Most often this is used after using [setCustomObject(...)](#setcustomobject) to modify a custom object.

---

#### split(...)

*returns table*  Splits a deck, as evenly as possible, into a number of piles.

> **Important**
>
> New decks take a frame to be created. This means trying to act on them immediately will not work. Use a coroutine or timer to add a delay.
>
> **split(piles)**
>
> - *int* **piles**: How many piles to split the deck into.
>
>   - Optional, if no value is provided, it is split into two piles.
>
>   - Minimum Value: 2
>
>   - Maximum Value: Number-Of-Cards-In-Deck / 2
>
> **Returned table**
>
> The number of Objects in the table is equal to the number of decks created by the split. They are ordered so any larger decks come first.
>
> - *table*  The table that is returned
>
>   - *object* **1**: The first deck created
>
>   - *object* **2**: The second deck created
>
>   - *object* **3**: The third deck created (etc)

```
newDecks = deck.split(4)
--A delay would be required here for these next four lines to work.
--The decks haven't been fully created yet.
newDecks[1].deal(1)
newDecks[2].deal(1)
newDecks[3].deal(1)
newDecks[4].deal(1)
```

---

#### spread(...)

*returns table*  Spreads the cards of a deck out on the table.

> **Important**
>
> Cards take a frame to be created. This means trying to act on them immediately will not work. Use a coroutine or timer to add a delay.
>
> **spread(distance)**
>
> - *float* **distance**: How far apart should the cards be.
>
>   - Optional, if no value is provided, they will be 0.6 inches apart.
>
>   - Negative values will spread to the left instead of the right.
>
> **Returned table**
>
> The number of Objects in the table is equal to the number of cards in the deck. They are returned in the order they were in the deck.
>
> - *table*  The table that is returned
>
>   - *object* **1**: The first card in the deck
>
>   - *object* **2**: The second card in the deck
>
>   - *object* **3**: The third card in the deck (etc)

---

#### takeObject(...)

*returns object*  Takes an object out of a container (bag/deck/chip stack), returning a reference to the object that was taken.

Objects that are taken out of a container will take one or more frames to spawn. Certain interactions (e.g. physics) will not be able to take place until the object has finished spawning.

> **takeObject(parameters)**
>
> - *table* **parameters**: A Table of parameters used to determine how takeObject will act.
>
>   - *vector* **parameters.position**: A Vector of the position to place Object.
>
>     - Optional, defaults to container's position + 2 on the x axis.
>
>   - *vector* **parameters.rotation**: A Vector of the rotation of the Object.
>
>     - Optional, defaults to the container's rotation.
>
>   - *bool* **parameters.flip**: If the Object is flipped over.
>
>     - Optional, defaults to false. Only used with decks, not bags/stacks.
>
>     - If rotation is used, flip's Bool will be ignored.
>
>   - *string* **parameters.guid**: GUID of the Object to take.
>
>     - Optional, no default. Only use index or guid, never both.
>
>   - *int* **parameters.index**: Index of the Object to take.
>
>     - Optional, no default. Only use index or guid, never both.
>
>   - *bool* **parameters.top**: If an object is taken from the top (vs bottom).
>
>     - Optional, defaults to true.
>
>   - *bool* **parameters.smooth**: If the taken Object moves smoothly or instantly.
>
>     - Optional, defaults to true.
>
>   - *func* **parameters.callback_function**: Callback which will be called when the taken object has finished spawnning.
>
>     - Optional, no default.
>
>     - This function takes a single parameter: the object that was taken.
>
> **Caution**
>
> Certain containers only exist whilst they have more than one object contained within them (e.g. decks). Once you remove the second last object from a container, the container will be destroyed and the remaining contained object will spawn in its place. After calling `takeObject(...)` you can check for a [remainder](#remainder).
>
> **Example**
>
> Take an object out of a container. As we take it out we'll instruct the object to smooth move (default positioning behavior) to coordinates (0, 5, 0). Additionally, we're going to add a blue highlight on the object we've taken out.

```lua
local takenObject = container.takeObject({
    position = {x = 0, y = 5, z = 0},
})
takenObject.highlightOn('Blue')
```

> **Advanced example**
>
> Take an object out of a container, and then apply an upward force (impulse) shooting it into the air.
>
> We can only [apply an impulse](#addforce) to an object once its (underlying rigid body) has finished spawning Additionally, freshly spawned objects are frozen in place for a single frame. So we need to wait for the taken object to finish spawning (i.e. `callback_function`) *then* [wait one more frame](wait.md#frames) before applying the impulse.

```lua
container.takeObject({
    callback_function = function(spawnedObject)
        Wait.frames(function()
            -- We've just waited a frame, which has given the object time to unfreeze.
            -- However, it's also given the object time to enter another container, if
            -- it spawned on one. Thus, we must confirm the object is not destroyed.
            if not spawnedObject.isDestroyed() then
                spawnedObject.addForce({0, 30, 0})
            end
        end)
    end,
    smooth = false, -- Smooth moving objects cannot have forces applied to them.
})
```

---

#### unregisterCollisions(...)

*returns bool*  Unregisters this object for Global collision events. Returns `true` if the object was previously registered, `false` otherwise.

> **unregisterCollision()**

---

### Hide Function Details

#### setHiddenFrom(...)

*returns bool*  Hides the Object from the specified players, as if it were in a hand zone.

Using an empty table will cause the Object to remove the hiding effect.

> **setHiddenFrom(players)**
>
> - *table* **players**: A table containing colors to hide the Object from.
>
>   - *string* **(color_name)**: Strings of the color name of each player.

```lua
function onLoad()
    self.setHiddenFrom({"Blue", "White"})
end
```

> **Tip**
>
> Just like Objects in a hand zone, the player/s the object is hidden from can still interact/move the hidden Object. It still exists to them, but is shown as a question mark or as a hidden card.

---

#### setInvisibleTo(...)

*returns bool*  Hides the Object from the specified players, as if it were in a hidden zone.

Using an empty table will cause the Object to remove the hiding effect.

> **setInvisibleTo(players)**
>
> - *table* **players**: A table containing colors to hide the Object from.
>
>   - *string* **(color_name)**: Strings of the color name of each player.

```lua
function onLoad()
    self.setInvisibleTo({"Blue", "White"})
end
```

> **Tip**
>
> Just like Objects in a hidden zone, the player/s the object is hidden from can still interact/move the hidden Object. It still exists to them, just invisibly so.

---

#### attachHider(...)

*returns bool*  A more advanced version of `setHiddenFrom(...)`, this function is also used to hide objects as if they were in a hand zone. It allows you to identify multiple sources of "hiding" by an ID and toggle the effect on/off easily.

This function is slightly more complicated to use for basic hiding, but allows for much easier hiding in complex situations.

> **attachHider(id, hidden, players)**
>
> - *string* **id**: The unique name for this hiding effect.
>
>   - Tip: You can use descriptive tag names like "fog" or "blindness"
>
> - *bool* **hidden**: If the hiding effect is enabled or not.
>
> - *table* **players**: A table containing colors to hide the Object from.
>
>   - Optional, an empty table (or no table) hides for everyone.
>
>   - *string* **(color_name)**: Strings of the color name of each player.

```lua
function onLoad()
    --Enable hide
    self.attachHider("hide", true, {"Blue", "White"})
    --Disable hide
    --self.attachHider("hide", false, {"Blue", "White"})
end
```

> **Tip**
>
> Just like Objects in a hand zone, the player/s the object is hidden from can still interact/move the hidden Object. It still exists to them, but is shown as a question mark or as a hidden card.

---

#### attachInvisibleHider(...)

*returns bool*  A more advanced version of `setInvisibleTo(...)`, this function is also used to hide objects as if they were in a hidden zone. It allows you to identify multiple sources of "hiding" by an ID and toggle the effect on/off easily.

This function is slightly more complicated to use for basic hiding, but allows for much easier hiding in complex situations.

> **attachInvisibleHider(id, hidden, players)**
>
> - *string* **id**: The unique name for this hiding effect.
>
>   - Tip: You can use descriptive tag names like "fog" or "blindness"
>
> - *bool* **hidden**: If the hiding effect is enabled or not.
>
> - *table* **players**: A table containing colors to hide the Object from.
>
>   - Optional, an empty table (or no table) hides for everyone.
>
>   - *string* **(color_name)**: Strings of the color name of each player.

```lua
function onLoad()
    --Enable hide
    self.attachInvisibleHider("hide", true, {"Blue", "White"})
    --Disable hide
    --self.attachInvisibleHider("hide", false, {"Blue", "White"})
end
```

> **Tip**
>
> Just like Objects in a hidden zone, the player/s the object is hidden from can still interact/move the hidden Object. It still exists to them, just invisibly so.

---

### Global Function Details

#### addDecal(...)

*returns bool*  Add a Decal onto an object or the game world.

> **Relative Vectors**
>
> When using this function, the vector parameters (position, rotation) are relative to what the decal is being placed on. For example, if you put a decal at `{0,0,0}` on Global, it will attach to the center of the game room. If you do the same to an object, it will place the decal on the origin point of the object.
>
> **addDecal(parameters)**
>
> - *table* **parameters**: A Table of parameters used to determine how the function will act.
>
>   - *string* **parameters.name**: The name of the decal being placed.
>
>   - *string* **parameters.url**: The file path or URL for the image to be displayed.
>
>   - *vector* **parameters.position**: Position to place Object.
>
>   - *vector* **parameters.rotation**: Rotation of the Object.
>
>   - *vector* **parameters.scale**: How the image is scaled.
>
>     - 1 is normal scale, 0.5 would be half sized, 2 would be twice as large, etc.

```lua
function onLoad()
    local params = {
        name     = "API Icon",
        url      = "https://api.tabletopsimulator.com/img/TSIcon.png",
        position = {0, 5, 0},
        rotation = {90, 0, 0},
        scale    = {1, 1, 1},
    }
    Global.addDecal(params)
end
```

---

#### call(...)

*returns var*  Used to call a Lua function on another entity.

*Var is only returned if the function called has a `return`. Otherwise return is `nil`. See example.*

This function can also be used directly on the game world using Global.

> **call(func_name, func_param)**
>
> - *string* **func_name**: Function name you want to activate.
>
> - *var* **func_param**: A single parameter you want to pass to that function (can be a table).
>
>   - Optional, will not be sent by default.

```lua
-- Call, used from an entity's script
params = {
    msg   = "Hello world!",
    color = {r=0.2, g=1, b=0.2},
}
-- Success would be set to true by the return value in the function
success = Global.call("testFunc", params)
```

```lua
-- Function in Global
function testFunc(params)
    broadcastToAll(params.msg, params.color)
    return true
end
```

> **Tip**
>
> Since `.call()` can only pass a single parameter, it's often necessary to bundle multiple variables into a single table to pass all of them at once.

---

#### getDecals()

*returns table*  Returns a table of sub-tables, each sub-table representing one decal.

> **Sub-table elements**
>
> - *string* **parameters.name**: The name of the decal being placed.
>
> - *string* **parameters.url**: The file path or URL for the image to be displayed.
>
> - *vector* **parameters.position**: Position to place Object.
>
> - *vector* **parameters.rotation**: Rotation of the Object.
>
> - *vector* **parameters.scale**: How the image is scaled.
>
>   - 1 is normal scale, 0.5 would be half sized, 2 would be twice as large, etc.

Example returned table:

```
-- If this object had 2 of the same decal on it
decalTable = self.getDecals()

--[[ This is what the table would look like
{
    {
        name     = "API Icon",
        url      = "https://api.tabletopsimulator.com/img/TSIcon.png",
        position = {0, 5, 0},
        rotation = {90, 0, 0},
        scale    = {5, 5, 5}
    },
    {
        name     = "API Icon",
        url      = "https://api.tabletopsimulator.com/img/TSIcon.png",
        position = {0, 5, 0},
        rotation = {90, 0, 0},
        scale    = {5, 5, 5}
    },
}
]]--

-- Accessing the name of of the second entry would look like this
print(decalTable[2].name)
```

---

#### getSnapPoints()

*returns table*  Returns a table representing a list of snap points.

> **Tip**
>
> This function may be called on `Global` in order to return a list of global snap points (i.e. snap points on the table).

##### Return value

The returned value is a list (numerically indexed table) of sub-tables, where each sub-table represents a snap point and has the following properties:

| Name | Type | Description |
| --- | --- | --- |
| position | [Vector](vector.md) | [Local Position](types.md#position) of the snap point. When attached to an object, position is relative to the object's center. |
| rotation | [Vector](vector.md) | [Local Rotation](types.md#rotation) of the snap point. When attached to an object, rotation is relative to the object's rotation. |
| rotation_snap | *bool* | Whether the snap point is a [rotation snap point](https://kb.tabletopsimulator.com/game-tools/snap-point-tool/#rotation-snap). |
| tags | *table* | Table of *string* representing the [tags](https://kb.tabletopsimulator.com/game-tools/object-tags/) associated with the snap point. |

> **Example**
>
> Log the list of global snap points:

```
log(Global.getSnapPoints())
```

---

#### setDecals(...)

*returns bool*  Sets which decals are on an object. This removes other decals already present, and can remove all decals as well.

> **Removing decals**
>
> Using this function with an empty table will remove all decals from Global or the object it is used on. `Global.setDecals({})`
>
> **setDecals(parameters)**
>
> - *table* **parameters**: The main table, which will contain all of the sub-tables.
>
>   - *table* **subtable**: The sub-table containing each individual decal's information. The sub-tables are unnamed.
>
>     - *string* **parameters.subtable.name**: The name of the decal being placed.
>
>     - *string* **parameters.subtable.url**: The file path or URL for the image to be displayed.
>
>     - *vector* **parameters.subtable.position**: A Vector of the position to place Object.
>
>     - *vector* **parameters.subtable.rotation**: A Vector of the rotation of the Object.
>
>     - *vector* **parameters.subtable.scale**: How the image is scaled.
>
>       - 1 is normal scale, 0.5 would be half sized, 2 would be twice as large, etc.

```lua
function onLoad()
    local parameters = {
        {
            name     = "API Icon",
            url      = "https://api.tabletopsimulator.com/img/TSIcon.png",
            position = {-2, 5, 0},
            rotation = {90, 0, 0},
            scale    = 5,
        },
        {
            name     = "API Icon",
            url      = "https://api.tabletopsimulator.com/img/TSIcon.png",
            position = {2, 5, 0},
            rotation = {90, 0, 0},
            scale    = 5,
        },
    }

    Global.setDecals(parameters)
end
```

---

#### setSnapPoints(...)

*returns bool*  Replaces existing snap points with the specified list of snap points.

> **Tip**
>
> This function can also be called on `Global` in order to create snap points directly within the scene, which are not attached to any other Object.
>
> **setSnapPoints(snap_points)**
>
> - *table* **snap_points**: A list (numerically indexed table) of [snap points](#setsnappoints-snap-points).

##### Snap Points

`snap_points` must be provided as a list (numerically indexed table) of sub-tables, where each sub-table represents a snap point and may have the following properties:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| position | *vector* | `{0, 0, 0}` | [Local Position](types.md#position) of the snap point. When attached to an object, position is relative to the object's center. |
| rotation | *vector* | `{0, 0, 0}` | [Local Rotation](types.md#position) of the snap point. When attached to an object, rotation is relative to the object's rotation. |
| rotation_snap | *bool* | `false` | Whether the snap point is a [rotation snap point](https://kb.tabletopsimulator.com/game-tools/snap-point-tool/#rotation-snap). |
| tags | *table* | `{}` | Table of *string* representing the [tags](https://kb.tabletopsimulator.com/game-tools/object-tags/) associated with the snap point. |

All properties are optional. When a property is omitted, it will be given the corresponding default value (above).

> **Example**
>
> Give an object 3 snap points. A regular snap point, a rotation snap point, and a rotation snap point with a tag.

```
object.setSnapPoints({
    {
        position = {5, 2, 5}
    },
    {
        position = {5, 2, 5},
        rotation = {0, 180, 0},
        rotation_snap = true
    },
    {
        position = {-3, 2, 0},
        rotation = {0, 45, 0},
        rotation_snap = true,
        tags = {"meeple"}
    }
})
```

---

#### setVectorLines(...)

*returns bool*  Spawns Vector Lines from a list of parameters.

This function can also be used on the game world itself using Global.

> **setVectorLines(parameters)**
>
> - *table* **parameters**: The table containing each "line's" data. Each contiguous line has its own sub-table.
>
>   - *table* **points**: Table containing [Vector positions](types.md#vector) for each "point" on the line.
>
>   - *color* **color**: Color the line will be.
>
>     - Optional, defaults to {1,1,1}.
>
>   - *float* **thickness**: How thick the line is (in Unity units).
>
>     - Optional, defaults to default line size (0.1).
>
>   - *vector* **rotation**: Rotation Vector for the line to be angled.
>
>     - Optional, defaults to {0,0,0}.

```lua
function onLoad()
    --Make an X above the middle of the table
    Global.setVectorLines({
        {
            points    = { {5,1,5}, {-5,1,-5} },
            color     = {1,1,1},
            thickness = 0.5,
            rotation  = {0,0,0},
        },
        {
            points    = { {-5,1,5}, {5,1,-5} },
            color     = {0,0,0},
            thickness = 0.5,
            rotation  = {0,0,0},
        },
    })
end
```

---
