<!-- vendored from https://api.tabletopsimulator.com/events/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Events

Games frequently need to execute code in response to some action, interaction, or change taking place in the game, collectively referred to as *events*.

## Event Handlers

Event handlers are **functions you define**, that Tabletop Simulator calls.

There are many event handlers that you can define. Each one gives you an opportunity to handle occurrences of a particular event.

When Tabletop Simulator calls your function, it will provide event-specific details as arguments to your event handler function.

In order for Tabletop Simulator to discover an event handler, it must be defined as a global variable with a specific name. The name that you use depends on which event you wish to handle. Event-specific details are covered below.

> **Note**
>
> Whilst event handler *names* corresponds with just one type of event. Each event may have multiple corresponding event handlers (i.e. event handler names) that Tabletop Simulator will look for and execute.

There are three types of event handlers:

- [Universal Event Handlers](#universal-event-handlers)

- [Global Event Handlers](#global-event-handlers)

- [Object Event Handlers](#object-event-handlers)

### Universal Event Handlers

Universal Event Handlers may be defined in the [Global script](intro.md#global-script) *and/or* [Object scripts](intro.md#object-scripts).

### Global Event Handlers

Global Event Handlers may *only* be defined in the [Global script](intro.md#global-script).

If you define a function using the name of a Global Event Handler in an [Object script](intro.md#object-scripts). It simply won't be called.

### Object Event Handlers

Object Event Handlers may *only* be defined in [Object scripts](intro.md#object-scripts).

If you define a function using the name of an Object Event Handler in your [Global script](intro.md#global-script). It simply won't be called.

## Event Handler Execution

*Typically*, if there are multiple event handlers for the one event i.e. in an Object script and Global Script *and/or* multiple Object scripts, then *all* of these event handlers will be executed.

> **Info**
>
> Some event handlers permit you to return a value in order to trigger an optional side effect. For example, returning `false` from a "try" event handler will prevent whatever action is being *tried*. If you return a value that triggers an optional side effect, then subsequent event handlers (for the same event occurrence) will *not* be executed.

## Event Summary

### Universal Event Handlers

As described above, you may declare these functions in the [Global script](intro.md#global-script) or in [Object scripts](intro.md#object-scripts).

######

######

| Function Name | Description |
| --- | --- |
| onBlindfold(*player* player, *bool* blindfolded) | Called when a player puts on or takes off their blindfold. |
| onChat(*string* message, *player* sender) | Called when a user sends an in-game chat message. |
| onExternalMessage(*table* data) | Called when a [custom message](externaleditorapi.md#custom-message) is received from an external process via the External Editor API. |
| onFixedUpdate() | Called **every physics tick** (90 times a second). This is a frame independent onUpdate(). |
| onLoad(*string* script_state) | Called when a save has completely finished loading. |
| onObjectCollisionEnter(*object* registered_object, *table* collision_info) | Called when an Object starts colliding with a [collision registered](object.md#registercollisions) Object. |
| onObjectCollisionExit(*object* registered_object, *table* collision_info) | Called when an Object stops colliding with a [collision registered](object.md#registercollisions) Object. |
| onObjectCollisionStay(*object* registered_object, *table* collision_info) | Called **every frame** that an Object is colliding with a [collision registered](object.md#registercollisions) Object. |
| onObjectDestroy(*object* object) | Called whenever an object is about to be destroyed. |
| onObjectDrop(*string* player_color, *object* object) | Called when an object is dropped by a player. |
| onObjectEnterContainer(*object* container, *object* object) | Called when an object enters a container. Includes decks |
| onObjectEnterScriptingZone(onObjectEnterScriptingZone(...)*object* zone, *object* object) | *deprecated* *Use [onObjectEnterZone(...)](#onobjectenterzone)*. Called when an object enters a *scripting* zone. |
| onObjectEnterZone(*object* zone, *object* object) | Called when an object enters a zone. |
| onObjectFlick(*object* object, *string* player_color, *vector* impulse) | Called when a player flicks an object. |
| onObjectHover(*string* player_color, *object* object) | Called when the object being hovered over by a player's pointer (cursor) changes. |
| onObjectLeaveContainer(*object* container, *object* object) | Called when an object leaves a container. |
| onObjectLeaveScriptingZone(onObjectLeaveScriptingZone(...)*object* zone, *object* object) | *deprecated* *Use [onObjectLeaveZone(...)](#onobjectleavezone)*. Called when an object leaves a *scripting* zone. |
| onObjectLeaveZone(*object* zone, *object* object) | Called when an object leaves a zone. |
| onObjectLoopingEffect(*object* object, *int* index) | Called whenever the looping effect of an [AssetBundle](behavior__assetbundle.md) is activated. |
| onObjectNumberTyped(*object* object, *string* player_color, *int* number, *bool* alt) | Called when a player types a number whilst hovering over an object. |
| onObjectPageChange(*object* object) | Called when a Custom PDF object changes page. |
| onObjectPeek(*object* object, *string* player_color) | Called when a player peeks at an Object. |
| onObjectPickUp(*string* player_color, *object* object) | Called whenever a Player picks up an Object. |
| onObjectRandomize(*object* object, *string* player_color) | Called when an Object is randomized. Like when shuffling a deck or shaking dice. |
| onObjectRotate(*object* object, *float* spin, *float* flip, *string* player_color, *float* old_spin, *float* old_flip) | Called when a player rotates an object. |
| onObjectSearchEnd(*object* object, *string* player_color) | Called when a search is finished on a container. |
| onObjectSearchStart(*object* object, *string* player_color) | Called when a search is started on a container. |
| onObjectSpawn(*object* object) | Called when an object is spawned/created. |
| onObjectStateChange(*object* object, *string* old_state_guid) | Called after an object changes state. |
| onObjectTriggerEffect(*object* object, *int* index) | Called whenever the trigger effect of an [AssetBundle](behavior__assetbundle.md) is activated. |
| onPlayerAction(*player* player, [Action](#onplayeraction-actions) action, *table* targets) | Called when a player attempts to perform an action. |
| onPlayerChangeColor(*string* player_color) | Called when a player changes color or selects it for the first time. It also returns `"Grey"` if they disconnect. |
| onPlayerChangeTeam(*string* player_color, *string* team) | Called when a player changes team. |
| onPlayerChatTyping(*player* player, *bool* typing) | Called when a player starts or stops typing. |
| onPlayerConnect(*player* player) | Called when a [Player](player__instance.md) connects to a game. |
| onPlayerDisconnect(*player* player) | Called when a [Player](player__instance.md) disconnects from a game. |
| onPlayerHandChoice(*string* player_color, *string* label, *table* objects, *bool* was_confirmed) | Called when a [Player](player__instance.md) makes a choice during a hand select mode. |
| onPlayerPing(*player* player, *vector* position, *object* object) | Called when a player [pings](https://kb.tabletopsimulator.com/game-tools/line-tool/#ping) a location. |
| onPlayerTurn(*player* player, *player* previous_player) | Called at the start of a player's turn. |
| onSave() | Called whenever a script needs to save its state. |
| onScriptingButtonDown(*int* index, *string* player_color) | Called when a scripting button (numpad by default) is pressed. The index range that is returned is 1-10. |
| onScriptingButtonUp(*int* index, *string* player_color) | Called when a scripting button (numpad by default) is released. The index range that is returned is 1-10. |
| onUpdate() | Called **every frame**. |

### Global Event Handlers

As described above, you may declare these functions in the [Global script](intro.md#global-script).

######

| Function Name | Description |
| --- | --- |
| filterObjectEnterContainer(filterObjectEnterContainer(...)*object* container, *object* object) | *deprecated* *Use [tryObjectEnterContainer(...)](#tryobjectentercontainer)*. Called when an object attempts to enter a container. |
| onZoneGroupSort(*object* zone, *table* group, *bool* reversed) | Called when sorting is required for a group of objects being laid out by a layout zone. |
| tryObjectEnterContainer(*object* container, *object* object) | Called when an object attempts to enter a container. |
| tryObjectRandomize(*object* object, *string* player_color) | Called when a player attempts to randomize an Object. |
| tryObjectRotate(*object* object, *float* spin, *float* flip, *string* player_color, *float* old_spin, *float* old_flip) | Called when a player attempts to rotate an object. |
| tryObjectStateChange(*object* object, *int* new_state_index, *string* player_color) | Called when an object is about to change state. |

### Object Event Handlers

As described [above](#object-event-handlers), you may declare these functions in [Object scripts](intro.md#object-scripts).

These events pertain to the script-owner Object (accessible as `self` within the script).

> **Important**
>
> These **cannot** declare these event handlers in the [Global script](intro.md#global-script).

| Function Name | Description |
| --- | --- |
| filterObjectEnter(*object* object) | *deprecated* *Use [tryObjectEnter(...)](#tryobjectenter)*. Called when an object attempts to enter the script-owner Object (container). |
| onCollisionEnter(*table* collision_info) | Called when an Object starts colliding with the script-owner Object. |
| onCollisionExit(*table* collision_info) | Called when an Object stops colliding with the script-owner Object. |
| onCollisionStay(*table* collision_info) | Called **every frame** that an Object is colliding with the script-owner Object. |
| onDestroy() | Called when the script-owner Object is about to be destroyed. |
| onDrop(*string* player_color) | Called when a player drops the script-owner Object. |
| onFlick(*string* player_color, *vector* impulse) | Called when a player flicks the script-owner Object |
| onGroupSort(*table* group, *bool* reversed) | Called when sorting is required for a group of objects being laid out by the script-owner layout zone. |
| onHover(*string* player_color) | Called when a player moves their pointer (cursor) over the script-owner Object. |
| onNumberTyped(*string* player_color, *int* number, *bool* alt) | Called when a player types a number whilst hovering over the script-owner Object. |
| onPageChange() | Called when the script-owner Custom PDF's page is changed. |
| onPeek(*string* player_color) | Called when a player peeks at the script-owner Object. |
| onPickUp(*string* player_color) | Called when a player picks up the script-owner Object. |
| onRandomize(*string* player_color) | Called when the script-owner Object is randomized. Like when shuffling a deck or shaking dice. |
| onRotate(*float* spin, *float* flip, *string* player_color, *float* old_spin, *float* old_flip) | Called when a player rotates the script-owner Object. |
| onSearchEnd(*string* player_color) | Called when a player finishes searches the script-owner Object. |
| onSearchStart(*string* player_color) | Called when a player starts searching the script-owner Object. |
| onStateChange(*string* old_state_guid) | Called when the script-owner Object spawned as a result of an Object state change. |
| tryObjectEnter(*object* object) | Called when another object attempts to enter the script-owner Object (container). |
| tryRandomize(*string* player_color) | Called when a player attempts to randomize the script-owner Object. |
| tryRotate(*float* spin, *float* flip, *string* player_color, *float* old_spin, *float* old_flip) | Called when a player attempts to rotate the script-owner Object. |
| tryStateChange(*int* new_state_index, *string* player_color) | Called when the object is about to change state. |

---

## Universal Event Handler Details

### onBlindfold(...)

Called when a player puts on or takes off their blindfold.

> **onBlindfold(player, blindfolded)**
>
> - *player* **player**: [Player](player__instance.md) who put on or took off their blindfold.
>
> - *bool* **blindfolded**: Whether the player is now blindfolded.
>
> **Example**
>
> Print a message indicating which player put on or took off their blindfold.

```lua
function onBlindfold(player, blindfolded)
    if blindfolded then
        print(player.color .. " put their blindfold on.")
    else
        print(player.color .. " took their blindfold off.")
    end
end
```

---

### onChat(...)

Called when a user sends an in-game chat message.

Return `false` to prevent the message appearing in the chat window.

> **onChat(message, sender)**
>
> - *string* **message**: Chat message which triggered the function.
>
> - *player* **sender**: Player which sent the chat message.
>
> **Example**
>
> Prevent the blue player from sending messages to other players. Instead print the message to the host. Permit chat from all other players.

```lua
function onChat(message, sender)
    if sender.color == "Blue" then
        print("Blue said: " .. message)
        return false
    end

    return true
end
```

---

### onExternalMessage(...)

Called when a [custom message](externaleditorapi.md#custom-message) is received from an external process via the External Editor API.

> **onExternalMessage(data)**
>
> - *table* **data**: The data sent by the external process.
>
> **Example**
>
> Log the contents of received custom external messages.

```lua
function onExternalMessage(data)
    log(data, "External Message")
end
```

---

### onFixedUpdate()

Called **every physics tick** (90 times a second). This is a frame independent onUpdate().

> **Danger**
>
> Due to the frequency at which this function is called, any implementation must be very simple/fast, in order to avoid slowing down your game.
>
> **Example**
>
> Print a message every 180 physics ticks.

```lua
local tick_count = 0
function onFixedUpdate()
    tick_count = tick_count + 1
    if tick_count >= 180 then
        print("180 physics ticks passed.")
        tick_count = 0
    end
end
```

### onLoad(...)

**Global Script**

Called when a saved game (and all Objects it contains) has finished loading. This includes manually loaded games/saves, as well as when a user rewinds.

**Object Script**

This will be called when a saved game finishes loading *or* when the script-owner Object has finished loading for some other reason e.g. if the script-owner Object was pulled out of a container mid-game.

> **onLoad(script_state)**
>
> - *string* **script_state**: The previously saved script state i.e. value returned from [onSave(...)](#onsave), or an empty string if there is no saved script state available.
>
> **Example**
>
> Decodes a JSON representation of a game state, consisting of nested tables, strings, numbers and object GUIDs. Then obtains an Object from the saved GUID.

```lua
local some_object -- We'll store an object reference to use later.

function onLoad(script_state)
    -- JSON decode our saved state
    local state = JSON.decode(script_state)

    -- In this example, we're assuming the existence of some specific saved state data.
    local questions = state.questions -- access a nested table

    for _, qa in ipairs(state.questions) do
        print("Question: " .. qa.question)
        print("Answer: " .. qa.answer)
    end

    some_object = getObjectFromGUID(state.guids.some_object)

    -- Let's highlight some_object a random color.
    -- Because why not.

    local colors = {'Blue', 'Yellow', 'Green'}
    some_object.highlightOn(colors[math.random(1, 3)])
end
```

Refer to [onSave(...)](#onsave) to see an example of how this same save state structure could be created. Subscribe to the [onSave/onLoad example mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2430471959) for a more functionally complete example.

---

### onObjectCollisionEnter(...)

Called when an Object starts colliding with a [collision registered](object.md#registercollisions) Object.

> **onObjectCollisionEnter(registered_object, collision_info)**
>
> - *object* **registered_object**: The object registered to receive collision events.
>
> - *table* **collision_info**: A table containing data about the collision.
>
>   - *object* **collision_info.*collision_object***: Object coming into contact with `registered_object`.
>
>   - *table* **collision_info.*contact_points***: Table/array full of contact points, where each 3D point is represented by a (number indexed) table, *not* a [Vector](vector.md).
>
>   - *table* **collision_info.*relative_velocity***: Table (number indexed) representation of a 3D vector (but *not* a [Vector](vector.md)) indicating the direction and magnitude of the collision.

```lua
-- Example Usage
function onObjectCollisionEnter(registered_object, info)
    print(tostring(info.collision_object) .. " collided with " .. tostring(registered_object))
end
```

```
-- Example collision_info table
{
    collision_object = objectReference,
    contact_points = {
        {5, 0, -2}
    },
    relative_velocity = {0, 20, 0}
}
```

---

### onObjectCollisionExit(...)

Called when an Object stops colliding with a [collision registered](object.md#registercollisions) Object.

> **onObjectCollisionExit(registered_object, collision_info)**
>
> - *object* **registered_object**: The object registered to receive collision events.
>
> - *table* **collision_info**: A table containing data about the collision.
>
>   - *object* **collision_info.*collision_object***: Object leaving contact with `registered_object`.
>
>   - *table* **collision_info.*contact_points***: Table/array full of contact points, where each 3D point is represented by a (number indexed) table, *not* a [Vector](vector.md).
>
>   - *table* **collision_info.*relative_velocity***: Table (number indexed) representation of a 3D vector (but *not* a [Vector](vector.md)) indicating the velocity of the object that has moved out of contact.

```lua
-- Example Usage
function onObjectCollisionExit(registered_object, info)
    print(tostring(info.collision_object) .. " stopped colliding with " .. tostring(registered_object))
end
```

```
-- Example collision_info table
{
    collision_object = objectReference,
    contact_points = {
        {5, 0, -2}
    },
    relative_velocity = {0, 20, 0}
}
```

---

### onObjectCollisionStay(...)

Called **every frame** that an Object is colliding with a [collision registered](object.md#registercollisions) Object.

> **Warning**
>
> Due to the frequency at which this function may be called, any implementation must be very simple/fast, in order to avoid slowing down your game.
>
> **onObjectCollisionStay(registered_object, collision_info)**
>
> - *object* **registered_object**: The object registered to receive collision events.
>
> - *table* **collision_info**: A table containing data about the collision.
>
>   - *object* **collision_info.*collision_object***: Object coming into contact with `registered_object`.
>
>   - *table* **collision_info.*contact_points***: Table/array full of contact points, where each 3D point is represented by a (number indexed) table, *not* a [Vector](vector.md).
>
>   - *table* **collision_info.*relative_velocity***: Table (number indexed) representation of a 3D vector (but *not* a [Vector](vector.md)) indicating the direction and magnitude of the collision.

```lua
-- Example Usage
function onObjectCollisionStay(registered_object, info)
    print(tostring(info.collision_object) .. " still colliding with " .. tostring(registered_object))
end
```

```
-- Example collision_info table
{
    collision_object = objectReference,
    contact_points = {
        {5, 0, -2}
    },
    relative_velocity = {0, 20, 0}
}
```

---

### onObjectDestroy(...)

Called whenever an object is about to be destroyed.

The Object reference (`object`) is valid in this callback, but won't be valid next frame (as the Object will be destroyed by then).

This event fires immediately before the Object’s [onDestroy()](#ondestroy).

> **onObjectDestroy(object)**
>
> - *object* **object**: The object that is about to be destroyed.
>
> **Example**
>
> Print the name of the Object which is about to be destroyed.

```lua
function onObjectDestroy(object)
    print(object.getName())
end
```

---

### onObjectDrop(...)

Called when an object is dropped by a player.

> **onObjectDrop(player_color, object)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the Player who dropped the Object.
>
> - *object* **object**: The Object in game which was dropped.

```lua
function onObjectDrop(colorName, object)
    print(colorName .. " dropped " .. object.getName())
end
```

---

### onObjectEnterContainer(...)

Called when an object enters a container.

> **onObjectEnterContainer(container, object)**
>
> - *object* **container**: Container that was entered.
>
> - *object* **object**: Object that entered the container.
>
> **Example**
>
> Each time an object enters a container, print the GUID of the object and the GUID of the container it entered.

```lua
function onObjectEnterContainer(container, object)
    print("Object " .. object.guid .. " entered container " .. container.guid)
end
```

---

### onObjectEnterZone(...)

Called when an object enters a zone.

> **Important**
>
> Objects with [tags](object.md#tag-functions) will only enter zones with compatible tags.
>
> **onObjectEnterZone(zone, object)**
>
> - *object* **zone**: Zone that was entered.
>
> - *object* **object**: Object that entered the zone.
>
> **Example**
>
> Each time an object enters a zone, print the GUID of the object and the GUID of the scripting zone it entered.

```lua
function onObjectEnterZone(zone, object)
    print("Object " .. object.guid .. " entered zone " .. zone.guid)
end
```

---

### onObjectFlick(...)

Called whenever a player [flicks](https://kb.tabletopsimulator.com/game-tools/flick-tool/) an object.

> **onObjectFlick(object, player_color, impulse)**

- *object* **object**: The object that was flicked.

- *string* **player_color**: [Player Color](player__colors.md) of the player who flicked an object.

- *vector* **impulse**: The impulse applied to the object.

> **Example**
>
> Print the player color, type of the flicked object, and magnitude of the flick:

```lua
function onObjectFlick(object, player_color, impulse)
    print(player_color .. " flicked a " .. object.type ..  " with impulse " .. impulse:magnitude())
end
```

---

### onObjectHover(...)

Called when the object being hovered over by a player's pointer (cursor) changes.

> **onObjectHover(player_color, object)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who moved their pointer over an object.
>
> - *object* **object**: Object the player's pointer is hovering over, or `nil` when a player moves their pointer such that it is no longer hovering over an object.
>
> **Example**
>
> Each time a player hovers over an object, print the player color and the GUID of the object being hovered over. If a player moves their cursor such that they're no longer hovering over an object, print "Nothing" instead of the object GUID.

```lua
function onObjectHover(player_color, object)
    local target = object and object.guid or "Nothing"
    print(player_color .. " hovered over " .. target)
end
```

---

### onObjectLeaveContainer(...)

Called when an object leaves a container.

> **onObjectLeaveContainer(container, object)**
>
> - *object* **container**: Container the object left.
>
> - *object* **object**: Object that left the container.
>
> **Example**
>
> Each time an object leaves a container, print the GUID of the object and the GUID of the container it left.

```lua
function onObjectLeaveContainer(container, object)
    print("Object " .. object.guid .. " left container " .. container.guid)
end
```

---

### onObjectLeaveZone(...)

Called when an object leaves a zone.

> **onObjectLeaveZone(zone, object)**
>
> - *object* **zone**: Zone that was left.
>
> - *object* **object**: The object that left.
>
> **Example**
>
> Each time an object leaves a zone, print the GUID of the object and the GUID of the zone it left.

```lua
function onObjectLeaveZone(zone, object)
    print("Object " .. object.guid .. " left zone " .. zone.guid)
end
```

---

### onObjectLoopingEffect(...)

Called whenever the looping effect of an [AssetBundle](behavior__assetbundle.md) is activated.

> **onObjectLoopingEffect(object, index)**
>
> - *object* **object**: AssetBundle which had its loop activated.
>
> - *int* **index**: Index number for the loop activated.

```lua
function onObjectLoopingEffect(object, index)
    print("Loop " .. index .. " activated.")
end
```

---

### onObjectNumberTyped(...)

Called when a player types a number whilst hovering over an object.

If you wish to prevent the default behavior (e.g. drawing a card) then you may return `true` to indicate you've handled the event yourself.

> **onObjectNumberTyped(object, player_color, number, alt)**
>
> - *object* **object**: The object the player was hovering over whilst typing a number.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that typed the number.
>
> - *int* **number**: The number typed.
>
> - *bool* **alt**: Whether the Alt key is held down.
>
> **Example**
>
> Print the player color, the number they entered and the type of object being hovered over:

```lua
function onObjectNumberTyped(object, player_color, number)
    print(player_color .. " typed " .. number .. " whilst hovering over a " .. object.type)
end
```

> **Example**
>
> Prevent players drawing more than 2 cards at a time:

```lua
function onObjectNumberTyped(object, player_color, number)
    if object.type == 'Deck' and number > 2 then
        print("Sorry. You can only draw a maximum of 2 cards.")
        return true
    end
end
```

---

### onObjectPageChange(...)

Called when an object's Custom PDF page is changed.

> **onObjectPageChange(object)**
>
> - *object* **object**: The object that's page changed.
>
> **Example**
>
> Print the name of the object and what page it changed to:

```lua
function onObjectPageChange(object)
    print(object.getName() .. " changed page to " .. object.Book.getPage())
end
```

---

### onObjectPeek(...)

Called when a player [peeks](https://kb.tabletopsimulator.com/player-guides/advanced-controls/#peek) at an Object.

> **onObjectPeek(object, player)**
>
> - *object* **object**: The Object that was peeked at.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that peeked.
>
> **Example**
>
> Print the color of the player that peeked at an object.

```lua
function onObjectPeek(object, player_color)
    print(player_color .. " peeked at an Object.")
end
```

---

### onObjectPickUp(...)

Called whenever a Player picks up an Object.

> **onObjectPickUp(player_color, object)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the Player who picked up the object.
>
> - *object* **object**: Object which was picked up.

```lua
function onObjectPickUp(colorName, object)
    print(colorName .. " picked up " .. object.getName())
end
```

---

### onObjectRandomize(...)

Called when an Object is randomized. Like when shuffling a deck or shaking dice.

> **onObjectRandomize(object, player_color)**
>
> - *object* **object**: The Object which triggered this function.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

```lua
function onObjectRandomize(object, color)
    print(object.getName() .. " was randomized by " .. color)
end
```

---

### onObjectRotate(...)

Called when a player rotates an object.

> **Warning**
>
> Only called in response to explicit player rotation actions. Will *not* be called when physics/collisions cause an object to rotate.
>
> **onObjectRotate(object, spin, flip, player_color, old_spin, old_flip)**
>
> - *object* **object**: The object the player is trying to rotate.
>
> - *float* **spin**: The object's target spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **flip**: The object's target flip rotation in degrees within the interval [0, 360).
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that performed the rotation.
>
> - *float* **old_spin**: The object's previous spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **old_flip**: The object's previous flip rotation in degrees within the interval [0, 360).
>
> **Example**
>
> When an object is rotated, print which player was responsible and what rotation was performed.

```lua
function onObjectRotate(object, spin, flip, player_color, old_spin, old_flip)
    if spin ~= old_spin then
        print(player_color .. " spun " .. tostring(object) .. " from " .. old_spin .. " degrees to " .. spin .. " degrees")
    end

    if flip ~= old_flip then
        print(player_color .. " flipped " .. tostring(object) .. " from " .. old_flip .. " degrees to " .. flip .. " degrees")
    end
end
```

---

### onObjectSearchEnd(...)

Called when a search is finished on a container.

> **onObjectSearchEnd(object, player_color)**
>
> - *object* **object**: The Object which was searched.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

---

### onObjectSearchStart(...)

Called when a search is started on a container.

> **onObjectSearchStart(object, player_color)**
>
> - *object* **object**: The Object which was searched.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

---

### onObjectSpawn(...)

Called when an object is spawned/created.

> **onObjectSpawn(object)**
>
> - *object* **object**: Object which was spawned.

```lua
function onObjectSpawn(object)
    print(object)
end
```

---

### onObjectStateChange(...)

Called after an object changes state.

> **onObjectStateChange(object, old_state_guid)**
>
> - *object* **object**: The new Object that spawned as a result of the state change.
>
> - *string* **old_state_guid**: The GUID of previous state/Object.
>
> **Example**
>
> Print the current and previous Object state GUIDs.

```lua
function onObjectStateChange(object, old_state_guid)
    print("New state GUID: " .. object.guid)
    print("Previous state GUID: " .. old_state_guid)
end
```

---

### onObjectTriggerEffect(...)

Called whenever the trigger effect of an [AssetBundle](behavior__assetbundle.md) is activated.

> **onObjectTriggerEffect(object, index)**
>
> - *object* **object**: AssetBundle object which had its trigger activated.
>
> - *int* **index**: Index number for the trigger activated.

```lua
function onObjectTriggerEffect(object, index)
    print("Loop " .. index .. " activated.")
end
```

---

### onPlayerAction(...)

*returns bool*  Called when a player attempts to perform an action.

Return `false` to prevent the action's default behavior.

> **onPlayerAction(player, action, targets)**
>
> - *player* **player**: [Player](player__instance.md) that is attempting the action.
>
> - [Action](#onplayeraction-actions) **action**: Action that is being attempted.
>
> - *table* **targets**: List of objects which are the target of the action being attempted.

#### Actions

The `action` parameter will be provided as an *int*  equal to a `Player.Action.*` property e.g. `Player.Action.FlipOver`.

Please refer to the examples [below](#onplayeraction-flip-example), for a demonstration of how you can check which action is being attempted.

| [Player.Action](player__manager.md#actions) | Player is attempting to... |
| --- | --- |
| Copy | Copy (or commence cloning) the targets. |
| Cut | Cut (copy and delete) the targets. |
| Delete | Delete the targets. |
| FlipIncrementalLeft | Incrementally rotate the targets counter-clockwise around their flip axes, typically the scene's Z-axis. |
| FlipIncrementalRight | Incrementally rotate the targets clockwise around their flip axes, typically the scene's Z-axis. |
| FlipOver | Rotate the targets 180 degrees around their flip axes, typically the scene's Z-axis i.e. toggle the targets between face up and face down. |
| Group | Group the targets. |
| Paste | Paste (spawn) the targets. |
| PickUp | Pick up the targets. |
| Randomize | Randomize the targets. |
| RotateIncrementalLeft | Rotate the targets incrementally, typically counter-clockwise around the scene's Y-axis. Instead of being rotated exclusively around the Y-axis, dice will be rotated to the previous rotation value. |
| RotateIncrementalRight | Rotate the targets incrementally, typically clockwise around the scene's Y-axis. Instead of being rotated exclusively around the Y-axis, dice will be rotated to the next rotation value. |
| RotateOver | Rotate the targets 180 degrees around the scene's Y-axis. |
| Select | Add the targets to the player's selection. |
| Under | Move the targets underneath objects below them on table. |

> **Example**
>
> Prevent more than 2 objects being flipped over at a time.

```lua
function onPlayerAction(player, action, targets)
    if action == Player.Action.FlipOver
        or action == Player.Action.FlipIncrementalLeft
        or action == Player.Action.FlipIncrementalRight
    then
        return #targets <= 2
    end

    return true
end
```

> **Example**
>
> Only allow the black player (Game Master) to delete cards and decks.

```lua
    function onPlayerAction(player, action, targets)
        if action == Player.Action.Delete and player.color ~= "Black" then
            for _, target in ipairs(targets) do
                if target.type ~= "Card" and target.type ~= "Deck" then
                    target.destroy()
                end
            end

            return false
        end

        return true
    end
```

---

### onPlayerChangeColor(...)

Called when a player changes color or selects it for the first time. It also returns `"Grey"` if they disconnect.

> **onPlayerChangeColor(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

```lua
function onPlayerChangeColor(color)
    print(color)
end
```

---

### onPlayerChangeTeam(...)

Called when a player changes team.

> **onPlayerChangeTeam(player_color, team)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.
>
> - *string* **team**: Team to which the player has changed. Options below.
>
>   - "" (empty string, if changed to None)
>
>   - Diamonds
>
>   - Hearts
>
>   - Jokers
>
>   - Clubs
>
>   - Spades

```lua
function onPlayerChangeTeam(player_color, team)
    print(player_color)
    print(team)
end
```

---

---

### onPlayerChatTyping(...)

Called when a player starts or stops typing.

> **onPlayerChatTyping(player, typing)**
>
> - *player* **player**: The player who started or stopped typing.
>
> - *bool* **typing**: True if they just started typing, False if they just stopped.

```lua
function onPlayerChatTyping(player, typing)
    print(player)
    print(typing)
end
```

---

### onPlayerConnect(...)

Called when a [Player](player__instance.md) connects to a game.

> **onPlayerConnect(player)**
>
> - *player* **player**: [Player](player__instance.md) that connected.

---

### onPlayerDisconnect(...)

Called when a [Player](player__instance.md) disconnects from a game.

> **onPlayerDisconnect(player)**
>
> - *player* **player**: [Player](player__instance.md) that disconnected.

---

### onPlayerHandChoice(...)

Called when a [Player](player__instance.md) makes a choice in hand selection mode.

> **onPlayerHandChoice(player)**
>
> - *string* **player_color**: The player color of the player who made the choice.
>
> - *string* **label**: The label of the hand select mode in question.
>
> - *table* **objects**: The list of objects (cards) selected by the player.
>
> - *bool* **was_confirmed**: True if the player confirmed the selection, false if they cancelled (Cancel option only appears if you use [chooseInHandOrCancel](base.md#chooseinhandorcancel)).

See [Wait.collect](wait.md#collect) for an example.

---

### onPlayerPing(...)

Called when a player [pings](https://kb.tabletopsimulator.com/game-tools/line-tool/#ping) a location.

> **onPlayerPing(player, position)**
>
> - *player* **player**: [Player](player__instance.md) who performed the ping.
>
> - *vector* **position**: The location that was pinged.
>
> - *object* **object**: If the player pinged on top of an object, that object.
>
> **Example**
>
> When a player pings a location, print a message with the player's color and the coordinates pinged.

```lua
function onPlayerPing(player, position, object)
    if object then
        print(player.color .. " pinged " .. object.getName() .. " at " .. position:string())
    else
        print(player.color .. " pinged " .. position:string())
    end
end
```

---

### onPlayerTurn(...)

Called at the start of a player's turn. [Turns](turns.md) must be enabled.

> **onPlayerTurn(player, previous_player)**
>
> - *player* **player**: [Player](player__instance.md) whose turn is starting.
>
> - *player* **previous_player**: [Player](player__instance.md) whose turn just finished, or `nil` if this is the first turn.
>
> **Example**
>
> When a new turn starts, print whose turn ended and whose turn it now is:

```lua
function onPlayerTurn(player, previous_player)
    if previous_player == nil then
        print(player.color .. " is going first. It's now their turn.")
    else
        print(previous_player.color .. "'s turn is over. It's now " .. player.color .. "'s turn.")
    end
end
```

---

### onSave()

Return a *string* .

This event handler provides you with an opportunity to persist your script's state, such that when a save game is loaded (or the user rewinds) the data you've persisted will be made available to [onLoad(...)](#onload).

A script's saved state is just a singular *string* . The convention for storing complex state is to create a Lua table, [JSON.encode(...)](json.md#encode) it, and return the JSON encoded string from this function.

**Global Script**

This event is called whenever the user manually saves game, when an auto-save is created *and* when a rewind checkpoint is created, by default, that's every 10 seconds. Due to the frequency at which this event handler is called, it's important that your function be fast.

**Object Script**

In addition to saves and rewind checkpoints, this event handler will also be called on an Object that requires its state be saved mid-game e.g. when the script-owner Object enters a container.

> **Tip**
>
> [JSON.encode(...)](json.md#encode) has limitations with regards to what data it can encode. It *cannot* encode references to Objects. If you wish to encode a reference to an object, encode the Object's [GUID](object.md#guid) and in [onLoad(...)](#onload) obtain a new Object reference via [getObjectFromGUID(...)](base.md#getobjectfromguid).
>
> **Warning**
>
> Pressing "Save & Play" (in either the in-game Scripting Editor or Atom) does *not* trigger the save event.
>
> In this context "Save" is referring to saving your script only. Save & Play will in fact reload your game, *discarding any non-scripting changes* made since the game was last (manually) loaded/saved.
>
> **Example**
>
> Returns a JSON encoding of a game state consisting of nested tables, strings, numbers and object references (encoded as GUIDs). In this example, `some_object` is an [Object](object.md).

```lua
function onSave()
    local state = {
        questions = { -- nested table
            {
                question = "What day comes after Saturday?", -- string
                answer = "Sunday",
            },
            {
                question = "Unknown",
                answer = 42, -- number
            }
        },
        guids = {
            some_object = some_object.guid -- GUID (a string)
        }
    }
    return JSON.encode(state)
end
```

Refer to [onLoad(...)](#onload) to see an example of this same save state structure being loaded. Subscribe to the [onSave/onLoad example mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2430471959) for a more functionally complete example.

---

### onScriptingButtonDown(...)

Called when a scripting button (numpad by default) is pressed. The index range that is returned is 1-10.

> **onScriptingButtonDown(index, player_color)**
>
> - *int* **index**: Index number, representing which key was pressed.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

```lua
function onScriptingButtonDown(index, color)
    print(index)
end
```

---

### onScriptingButtonUp(...)

Called when a scripting button (numpad by default) is released. The index range that is returned is 1-10.

> **onScriptingButtonUp(index, player_color)**
>
> - *int* **index**: Index number, representing which key was released.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

```lua
function onScriptingButtonUp(index, color)
    print(index)
end
```

---

### onUpdate()

Called **every frame**.

> **Danger**
>
> Due to the frequency at which this function is called, any implementation must be very simple/fast, in order to avoid slowing down your game.
>
> **Example**
>
> Print a message every 180 frames.

```lua
local frame_count = 0
function onFixedUpdate()
frame_count = frame_count + 1
    if frame_count >= 180 then
        print("180 frames passed.")
        frame_count = 0
    end
end
```

---

## Global Event Handler Details

### onZoneGroupSort(...)

*returns table*  Called when sorting is required for a group of objects being laid out by a layout zone.

Return a table of objects (those provided in `group`) to override the layout zone's ordering algorithm. Return `nil` to use the layout zone's default order.

> **onZoneGroupSort(zone, group, reversed)**
>
> - *object* **zone**: Layout zone which is laying out the group of objects.
>
> - *table* **group**: List of objects that are being grouped together in the layout zone.
>
> - *bool* **reversed**: Whether the layout zone has been configured to sort in reverse.
>
> **Example**
>
> Sort objects by [value](object.md#value). Please note that, by default, objects do not have a value. You'd have to assign your objects values first.

```lua
function onZoneGroupSort(zone, group, reversed)
    table.sort(group, function(a, b)
        return a.value < b.value
    end)
    return group
end
```

### tryObjectEnterContainer(...)

*returns bool*  Called when an object attempts to enter a container.

Return `false` to prevent the object entering.

> **tryObjectEnterContainer(container, object)**
>
> - *object* **container**: The container the Object is trying to enter.
>
> - *object* **object**: The Object entering the container.
>
> **Example**

```lua
function tryObjectEnterContainer(container, object)
    print(object.getName()) -- Print entering object's name
    return true -- Allows object to enter.
end
```

---

### tryObjectRandomize(...)

*returns bool*  Called when a player attempts to randomize an Object.

Return `false` to prevent the Object being randomized.

> **tryObjectRandomize(object, player_color)**
>
> - *object* **object**: The Object the player is trying to randomize.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that is attempting the randomization.
>
> **Example**
>
> Only allow the blue player to randomize objects.

```lua
function tryObjectRandomize(object, player_color)
    return player_color == "Blue"
end
```

---

### tryObjectRotate(...)

*returns bool*  Called when a player attempts to rotate an object.

Return `false` to prevent the object being rotated.

> **tryObjectRotate(object, spin, flip, player_color, old_spin, old_flip)**
>
> - *object* **object**: The object the player is trying to rotate.
>
> - *float* **spin**: The object's target spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **flip**: The object's target flip rotation in degrees within the interval [0, 360).
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that is attempting the rotation.
>
> - *float* **old_spin**: The object's current spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **old_flip**: The object's current flip rotation in degrees within the interval [0, 360).
>
> **Example**
>
> Only allow the blue player to rotate objects.

```lua
function tryObjectRotate(object, spin, flip, player_color, old_spin, old_flip)
    return player_color == "Blue"
end
```

---

### tryObjectStateChange(...)

Called before an object changes state. Return false to prevent the state change.

> **tryObjectStateChange(object, new_state_index, player_color)**
>
> - *object* **object**: The object in question.
>
> - *int* **new_state_index**: The state index the object is trying to change to.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that is attempting the change.
>
> **Example**
>
> Prevent White from changing object states.

```lua
function tryObjectStateChange(object, new_state_index, player_color)
    return player_color ~= "White"
end
```

---

## Object Event Handler Details

### onCollisionEnter(...)

Called when an Object starts colliding with the script-owner Object.

> **onCollisionEnter(collision_info)**
>
> - *table* **collision_info**: A table containing data about the collision.
>
>   - *object* **collision_info.*collision_object***: Object coming into contact with the script-owner Object.
>
>   - *table* **collision_info.*contact_points***: Table/array full of contact points, where each 3D point is represented by a (number indexed) table, *not* a [Vector](vector.md).
>
>   - *table* **collision_info.*relative_velocity***: Table (number indexed) representation of a 3D vector (but *not* a [Vector](vector.md)) indicating the direction and magnitude of the collision.

```lua
-- Example Usage
function onCollisionEnter(info)
    print(tostring(info.collision_object) .. " collided with " .. tostring(self))
end
```

```
-- Example collision_info table
{
    collision_object = objectReference,
    contact_points = {
        {5, 0, -2}
    },
    relative_velocity = {0, 20, 0}
}
```

---

### onCollisionExit(...)

Called when an Object stops colliding with the script-owner Object.

> **onCollisionExit(collision_info)**
>
> - *table* **collision_info**: A table containing data about the collision.
>
>   - *object* **collision_info.*collision_object***: Object leaving contact with the script-owner Object.
>
>   - *table* **collision_info.*contact_points***: Table/array full of contact points, where each 3D point is represented by a (number indexed) table, *not* a [Vector](vector.md).
>
>   - *table* **collision_info.*relative_velocity***: Table (number indexed) representation of a 3D vector (but *not* a [Vector](vector.md)) indicating the velocity of the object that has moved out of contact.

```lua
-- Example Usage
function onCollisionExit(info)
    print(tostring(info.collision_object) .. " stopped colliding with " .. tostring(self))
end
```

```
-- Example collision_info table
{
    collision_object = objectReference,
    contact_points = {
        {5, 0, -2}
    },
    relative_velocity = {0, 20, 0}
}
```

---

### onCollisionStay(...)

Called **every frame** that an Object is colliding with the script-owner Object.

> **Warning**
>
> Due to the frequency at which this function may be called, any implementation must be very simple/fast, in order to avoid slowing down your game.
>
> **onCollisionStay(collision_info)**
>
> - *table* **collision_info**: A table containing data about the collision.
>
>   - *object* **collision_info.*collision_object***: Object coming into contact with the script-owner Object.
>
>   - *table* **collision_info.*contact_points***: Table/array full of contact points, where each 3D point is represented by a (number indexed) table, *not* a [Vector](vector.md).
>
>   - *table* **collision_info.*relative_velocity***: Table (number indexed) representation of a 3D vector (but *not* a [Vector](vector.md)) indicating the direction and magnitude of the collision.

```lua
-- Example Usage
function onCollisionStay(info)
    print(tostring(info.collision_object) .. " still colliding with " .. tostring(self))
end
```

```
-- Example collision_info table
{
    collision_object = objectReference,
    contact_points = {
        {5, 0, -2}
    },
    relative_velocity = {0, 20, 0}
}
```

---

### onDestroy()

Called when the script-owner Object is about to be destroyed.

The `self` (the script-owner Object) is valid in this callback, but won't be valid next frame (as the Object will be destroyed by then).

This event fires immediately after [onObjectDestroy()](#onobjectdestroy).

> **Example**
>
> Print a message when the script-owner Object is destroyed.

```lua
function onDestroy()
    print("This object was destroyed!")
end
```

---

### onDrop(...)

Called when the script-owner Object is dropped.

> **onDrop(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the Player.

```lua
function onDrop(color)
    print(color)
end
```

---

### onFlick(...)

Called when a player [flicks](https://kb.tabletopsimulator.com/game-tools/flick-tool/) the script-owner Object.

> **onFlick(player_color, impulse)**

- *string* **player_color**: [Player Color](player__colors.md) of the player who flicked the script-owner Object.

- *vector* **impulse**: The impulse applied to the script-owner Object.

> **Example**
>
> Print the player color and magnitude of the flick:

```lua
function onFlick(player_color, impulse)
    print(player_color .. " flicked with impulse " .. impulse:magnitude())
end
```

---

### onGroupSort(...)

*returns table*  Called when sorting is required for a group of objects being laid out by the script-owner layout zone.

Return a table of objects (those provided in `group`) to override the layout zone's ordering algorithm. Return `nil` to use the layout zone's default order.

> **onGroupSort(group, reversed)**
>
> - *table* **group**: List of objects that are being grouped together in the layout zone.
>
> - *bool* **reversed**: Whether the layout zone has been configured to sort in reverse.
>
> **Example**
>
> Sort objects by [value](object.md#value). Please note that, by default, objects do not have a value. You'd have to assign your objects values first.

```lua
function onGroupSort(group, reversed)
    table.sort(group, function(a, b)
        return a.value < b.value
    end)
    return group
end
```

---

### onHover(...)

Called when a player moves their pointer (cursor) over the script-owner Object.

> **onHover(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who moved the pointer over the script-owner Object.

```lua
function onHover(player_color)
    print(player_color)
end
```

---

### onNumberTyped(...)

Called when a player types a number whilst hovering over the script-owner Object.

If you wish to prevent the default behavior (e.g. drawing a card, if the script-owner Object is a deck) then you may return `true` to indicate you've handled the event yourself.

> **onNumberTyped(player_color, number)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that typed the number.
>
> - *int* **number**: The number typed.
>
> - *bool* **alt**: Whether the Alt key us held down.
>
> **Example**
>
> Print the player color and the number they typed:

```lua
function onNumberTyped(player_color, number)
    print(player_color .. " typed " .. number)
end
```

> **Example**
>
> Prevent players drawing more than 2 cards at a time (from the script-owner Object):

```lua
function onNumberTyped(player_color, number)
    if self.type == 'Deck' and number > 2 then
        print("Sorry. You can only draw a maximum of 2 cards.")
        return true
    end
end
```

---

### onPageChange()

Called when the script-owner Custom PDF's page is changed.

> **Example**
>
> Print the script-owner Object's name and what page it changed to:

```lua
function onPageChange()
    print(self.getName() .. " changed page to " .. self.Book.getPage())
end
```

---

### onPeek(...)

Called when a player [peeks](https://kb.tabletopsimulator.com/player-guides/advanced-controls/#peek) at the script-owner Object.

> **onPeek(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that peeked.
>
> **Example**
>
> Print the color of the player that peeked at the script-owner Object.

```lua
function onPeek(player_color)
    print(player_color .. " peeked.")
end
```

---

### onPickUp(...)

Called when a player picks up the script-owner Object.

> **onPickUp(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the Player.

```lua
function onPickUp(color)
    print(color)
end
```

---

### onRandomize(...)

Called when the script-owner Object is randomized. Like when shuffling a deck or shaking dice.

> **onRandomize(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player who triggered the function.

```lua
function onRandomize(color)
    print(self.getName() .. " was randomized by " .. color)
end
```

---

### onRotate(...)

Called when a player rotates script-owner Object.

> **Warning**
>
> Only called in response to explicit player rotation actions. Will *not* be called when physics/collisions cause the script-owner Object to rotate.
>
> **onRotate(spin, flip, player_color, old_spin, old_flip)**
>
> - *float* **spin**: The script-owner Object's target spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **flip**: The script-owner Object's target flip rotation in degrees within the interval [0, 360).
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that performed the rotation.
>
> - *float* **old_spin**: The script-owner Object's previous spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **old_flip**: The script-owner Object's previous flip rotation in degrees within the interval [0, 360).
>
> **Example**
>
> When the script-owner Object is rotated, print which player was responsible and what rotation was performed.

```lua
function onRotate(spin, flip, player_color, old_spin, old_flip)
    if spin ~= old_spin then
        print(player_color .. " spun " .. tostring(self) .. " from " .. old_spin .. " degrees to " .. spin .. " degrees")
    end

    if flip ~= old_flip then
        print(player_color .. " flipped " .. tostring(self) .. " from " .. old_flip .. " degrees to " .. flip .. " degrees")
    end
end
```

---

### onSearchEnd(...)

Called when a player first searches the script-owner Object.

> **onSearchEnd(*string*  player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the Player.

---

### onSearchStart(...)

Called when a player finishes searching the script-owner Object.

> **onSearchStart(*string*  player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the Player.

---

### onStateChange(...)

Called when the script-owner Object spawned as a result of an Object state change.

> **onStateChange(old_state_guid)**
>
> - *string* **old_state_guid**: The GUID of previous state/Object.
>
> **Example**
>
> Print the current and previous Object state GUIDs.

```lua
function onStateChange(old_state_guid)
    print("New state GUID: " .. self.guid)
    print("Previous state GUID: " .. old_state_guid)
end
```

---

### tryObjectEnter(...)

Called when another object attempts to enter the script-owner Object (container).

Return `false` to prevent the object entering.

> **tryObjectEnter(object)**
>
> - *object* **object**: The object that has tried to enter the script-owner Object.
>
> **Example**
>
> Print the name of the object entering the script-owner container.

```lua
function tryObjectEnter(object)
    print(object.getName())
    return true -- Allows the object to enter.
end
```

---

### tryRandomize(...)

Called when a player attempts to randomize the script-owner Object.

Return `false` to prevent the randomization taking place.

> **tryRandomize(player_color)**
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that is attempting the randomization.
>
> **Example**
>
> Only allow the blue player to randomize the script-owner Object.

```lua
function tryRandomize(player_color)
    return player_color == "Blue"
end
```

---

### tryRotate(...)

Called when a player attempts to rotate the script-owner Object.

Return `false` to prevent the rotation taking place.

> **tryRotate(spin, flip, player_color, old_spin, old_flip)**
>
> - *float* **spin**: The script-owner Object's target spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **flip**: The script-owner Object's target flip rotation in degrees within the interval [0, 360).
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that is attempting the rotation.
>
> - *float* **old_spin**: The script-owner Object's current spin (around Y-axis) rotation in degrees within the interval [0, 360).
>
> - *float* **old_flip**: The script-owner Object's current flip rotation in degrees within the interval [0, 360).
>
> **Example**
>
> Only allow the blue player to rotate the script-owner Object.

```lua
function tryRotate(spin, flip, player_color, old_spin, old_flip)
    return player_color == "Blue"
end
```

---

### tryStateChange(...)

Called before an object changes state. Return false to prevent the state change.

> **tryStateChange(new_state_index, player_color)**
>
> - *int* **new_state_index**: The state index the object is trying to change to.
>
> - *string* **player_color**: [Player Color](player__colors.md) of the player that is attempting the change.
>
> **Example**
>
> Prevent White from changing object states.

```lua
function tryStateChange(new_state_index, player_color)
    return player_color ~= "White"
end
```

---
