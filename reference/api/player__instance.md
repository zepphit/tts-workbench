<!-- vendored from https://api.tabletopsimulator.com/player/instance/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Player Instance

Player instances can be retrieved from the [Player Manager](player__manager.md) and are also frequently passed to callbacks.

## Member Variables

| Variable | Type | Description |
| --- | --- | --- |
| admin | *bool* | If the player is promoted or the host of the game. Read only. |
| blindfolded | *bool* | If the player is blindfolded. |
| color | *string* | The player's [Player Color](player__colors.md). Read only. |
| host | *bool* | If the player is the host. Read only. |
| lift_height | *float* | The lift height for the player. This is how far an object is raised when held in a player's hand. Value is ranged 0 to 1. |
| promoted | *bool* | If the current player is promoted. |
| seated | *bool* | If a player is currently seated at this color. Read only. |
| steam_id | *string* | The Steam ID of the player. This is unique to each player's Steam account. Read only. |
| steam_name | *string* | The Steam name of the player. Read only. |
| team | *string* | The team of the player. Options: `"None", "Clubs", "Diamonds", "Hearts", "Spades", "Jokers"`. |

---

## Function Summary

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

| Function Name | Return | Description |
| --- | --- | --- |
| attachCameraToObject(*table* parameters) | *returns bool* | Makes a Player's camera follow an Object. |
| broadcast(*string* message, *color* message_color) | *returns bool* | Print message on Player's screen and their game chat log. |
| changeColor(*string* player_color) | *returns bool* | Changes player to this [Player Color](player__colors.md). |
| clearSelectedObjects()clearSelectedObjects() | *returns bool* | Clears a player's current selection. |
| copy(*table* objects) | *returns bool* | Makes the Player take the Copy action with the specified Objects. |
| drawHandStash() | *returns bool* | Draws all the cards in the players hand stash into their hand. |
| getHandCount()getHandCount() | *returns int* | Number of [hand zones](https://kb.tabletopsimulator.com/host-guides/player-hands/) owned by this color. |
| getHandObjects(*int* hand_index) | *returns table* | Objects that are in this [hand zone](https://kb.tabletopsimulator.com/host-guides/player-hands/). |
| getHandTransform(*int* hand_index) | *returns table* | Returns a Table of data on this [hand zone](https://kb.tabletopsimulator.com/host-guides/player-hands/). |
| getHoldingObjects()getHoldingObjects() | *returns table* | Objects a Player is holding in their hand. |
| getHoverObject()getHoverObject() | *returns object* | Object that the Player's pointer is hovering over. |
| getPointerPosition()getPointerPosition() | *returns vector* | Player's pointer coordinates. |
| getPointerRotation()getPointerRotation() | *returns float* | Player's pointer rotation on Y axis. |
| getSelectedObjects()getSelectedObjects() | *returns table* | Objects that the Player has selected with an area selection. |
| kick()kick() | *returns bool* | Kicks Player out of the room. |
| lookAt(*table* parameters) | *returns bool* | Moves a Player's camera, forcing 3'rd person camera mode. |
| mute()mute() | *returns bool* | Mutes or unmutes Player, preventing/allowing voice chat. |
| paste(*vector* position) | *returns bool* | Makes the Player take the Paste action at the specified position |
| pingTable(pingTable(...)*vector* position) | *returns bool* | Emulates the player using the ping tool at the given position (tapping Tab). |
| print(*string* message, *color* message_color) | *returns bool* | Prints a message into the Player's game chat. |
| promote()promote() | *returns bool* | Promotes/demotes a Player. Promoted players have access to most host privileges. |
| setCameraMode(*string* camera_mode) | *returns bool* | Sets the player's camera mode. Camera modes available: "ThirdPerson", "FirstPerson", "TopDown". |
| setHandStashLocation(*vector* position, *int* rotation) | *returns bool* | Sets the location of the hand stash within the players primary hand. |
| setHandTransform(*table* parameters, *int* hand_index) | *returns bool* | Sets transform elements of a hand zone. |
| setUITheme(*string* theme) | *returns bool* | Sets the UI theme for the player. |
| showInfoDialog(*string* info) | *returns bool* | Displays `info` string to player in the message box dialog. |
| showConfirmDialog(*string* info, *func* callback) | *returns bool* | Displays `info` string to player in the message box dialog, and executes `callback` if they click `OK`. |
| showInputDialog(*string* description, *string* default_text, *func* callback) | *returns bool* | Shows the text input dialog to the player, and executes `callback` if they click `OK`. |
| showMemoDialog(*string* description, *string* default_text, *func* callback) | *returns bool* | Shows the memo input dialog (large text input) to the player, and executes `callback` if they click `OK`. |
| showOptionsDialog(*string* description, *table* options, *int* default_value, *func* callback) | *returns bool* | Shows the dropdown options dialog to the player, and executes `callback` if they click `OK`. |
| showColorDialog(*color* default_color, *func* callback) | *returns bool* | Shows the color picker dialog to the player with optional `default_color`, and executes `callback` if they click `OK`. |

---

## Function Details

### attachCameraToObject(...)

*returns bool*  Makes a Player's camera follow an Object.

> **attachCameraToObject(parameters)**
>
> - *table* **parameters**: A Table with parameters which guide the function.
>
>   - *object* **parameters.object**: The Object to attach the camera to.
>
>   - *vector* **parameters.offset**: A Vector to offset the camera by.
>
>     - Optional, defaults to {x=0, y=0, z=0}.

```
self.attachCameraToObject({object=self})
```

---

### broadcast(...)

*returns bool*  Print message on Player's screen and their game chat log.

> **broadcast(message, message_color)**
>
> - *string* **message**: The message to be displayed.
>
> - *color* **message_color**: Tint of the message text.
>
>   - Optional, defaults to {r=1, g=1, b=1}.

---

### changeColor(...)

*returns bool*  Changes player to this [Player Color](player__colors.md) (seat).

> **changeColor(player_color)**
>
> - *string* **player_color**: The [Player Color](player__colors.md) seat to move the Player to.

```
Player["White"].changeColor("Red")
```

---

### copy(...)

*returns bool*  Makes the Player take the Copy action with the specified Objects.

> **copy(objects)**
>
> - *table* **objects**: A Table of Objects.

```
Player.Green.copy({the_dice, the_deck})
```

---

### drawHandStash(...)

*returns bool*  Draws all cards in the player's hand stash into their hand.

See [Wait.collect](wait.md#collect) for an example of using the hand stash.

---

### getHandObjects(...)

*returns table*  Returns a Table of Objects that are in this [hand zone](https://kb.tabletopsimulator.com/host-guides/player-hands/).

> **getHandObjects(hand_index)**
>
> - *int* **hand_index**: An index, representing which hand zone to return Objects for.
>
>   - Optional, defaults to 1.
>
> **Indexing**
>
> Hand indexes start at 1 and are numbered in the order of their creation. Each Player color has its own indexes.

---

### getHandTransform(...)

*returns table*  Returns a Table of data on this [hand zone](https://kb.tabletopsimulator.com/host-guides/player-hands/).

> **getHandTransform(hand_index)**
>
> - *int* **hand_index**: An index, representing which hand zone to return data on.
>
>   - Optional, defaults to 1.
>
> **Return Data Table**
>
> - *table* **data**: The Table the data is returned in.
>
>   - *vector* **data.position**: Position of the hand zone.
>
>   - *vector* **data.rotation**: Rotation of the hand zone.
>
>   - *vector* **data.scale**: Scale of the hand zone.
>
>   - *vector* **data.forward**: Forward direction of the hand zone.
>
>   - *vector* **data.right**: Right direction of the hand zone.
>
>   - *vector* **data.up**: Up direction of the hand zone.
>
> **Indexing**
>
> Hand indexes start at 1 and are numbered in the order of their creation. Each Player color has its own indexes.

---

### lookAt(...)

*returns bool*  Moves a Player's camera, forcing 3'rd person camera mode.

> **lookAt(parameters)**
>
> - *table* **parameters**: A Table of controlling parameters to point the player camera.
>
>   - *vector* **parameters.position**: Position to center the camera on.
>
>   - *float* **parameters.pitch**: Pitch angle of the camera. 0 to 90.
>
>     - Optional, defaults to 0.
>
>   - *float* **parameters.yaw**: Yaw angle of the camera. 0 to 360.
>
>     - Optional, defaults to 0.
>
>   - *float* **parameters.distance**: Distance the camera is from the position Vector.
>
>     - Optional, defaults to 40.

```
-- Assuming someone is in the White seat
Player["White"].lookAt({
    position = {x=0,y=0,z=0},
    pitch    = 25,
    yaw      = 180,
    distance = 20,
})
```

---

### paste(...)

*returns bool*  Makes the Player take the Paste action at the specified position.

> **paste(position)**
>
> - *vector* **position**: The position to paste at.

```
Player.Green.paste({0, 1, 0})
```

---

### print(...)

*returns bool*  Prints a message into the Player's game chat.

> **print(message, message_color)**
>
> - *string* **message**: The text to be displayed.
>
> - *color* **message_color**: Color for the message text to be tinted.
>
>   - Optional, defaults to {r=1, g=1, b=1}.

---

### setCameraMode(...)

*returns bool*  Sets the player's camera mode. Camera modes available: "ThirdPerson", "FirstPerson", "TopDown".

> **changeColor(camera_mode)**
>
> - *string* **camera_mode**: The Camera Mode to set the Player's Camera to.

```
Player["White"].setCameraMode("FirstPerson")
```

---

### setHandStashLocation(...)

*returns bool*  Sets the location of the player's hand stash inside their primary hand zone.

> **setHandStashLocation(position, rotation)**
>
> - *vector* **position**: The position of the stash inside the hand zone. Each ordinal is in the range (**-1.0**..**+1.0**).
>
> - *int* **rotation_index**: The rotation index of the hand stash.

---

### setHandTransform(...)

*returns bool*  Sets transform elements of a [hand zone](https://kb.tabletopsimulator.com/host-guides/player-hands/).

> **setHandTransform(parameters, hand_index)**
>
> - *table* **parameters**: The Table of data to transform the hand zone with.
>
>   - *vector* **parameters.position**: Position of the hand zone.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *vector* **parameters.rotation**: Rotation of the hand zone.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
>   - *vector* **parameters.scale**: Scale of the hand zone.
>
>     - Optional, defaults to {x=0, y=0, z=0}.
>
> - *int* **hand_index**: Index, representing which hand zone to modify.
>
>   - Optional, defaults to 1.
>
> **Indexing**
>
> Hand indexes start at 1 and are numbered in the order of their creation. Each Player color has its own indexes.

```
-- Example of moving/rotating/scaling hand zone
params = {
    position = {x=0, y=5, z=0},
    rotation = {x=0, y=45, z=0},
    scale    = {x=2, y=2, z=2},
}
Player["White"].setHandTransform(params, 2)
```

### setUITheme(...)

*returns bool*  Sets the UI theme for the player.

> **setUITheme(theme)**
>
> - *string* **theme**: A string representing a theme.
>
> **Theme Format**
>
> You can view the expected theme format by in-game going to Menu -> Configuration -> Interface -> Theme. Select a theme then press "Import/Export".
>
> **Example**
>
> Set the White player's default button background to pink.

```
Player.white.setUITheme("button_normal #FFC0C0")
```

### showInfoDialog(...)

*returns bool*  Shows the info dialog to the player.

> **showInfoDialog(info)**
>
> - *string* **info**: Information to display.
>
> **Example**

```
Player.white.showInfoDialog("Only active players may floop!")
```

### showConfirmDialog(...)

*returns bool*  Shows the confirm dialog to the player and executes the callback if they click OK.

> **showConfirmDialog(info, callback)**
>
> - *string* **info**: Information to display.
>
> - *func* **callback**: Callback to execute if they click OK. Will be called as `callback(player_color)`
>
> **Example**

```lua
chosen_player.showConfirmDialog("Really roll the dice?",
    function (player_color)
        dice.roll()
        log(player_color .. " rolled the dice.")
    end
)
```

### showInputDialog(...)

*returns bool*  Shows the text input dialog to the player and executes the callback if they click OK.

> **showInputDialog(description, default_text, callback)**
>
> - *string* **description**: Optional description of what the player should input.
>
> - *string* **default_text**: Optional default value.
>
> - *func* **callback**: Callback to execute if they click OK. Will be called as `callback(text, player_color)`
>
> **Example**

```lua
chosen_player.showInputDialog("Set Name",
    function (text, player_color)
        chosen_object.setName(text)
    end
)
```

### showMemoDialog(...)

*returns bool*  Shows the memo input dialog (large text input) to the player and executes the callback if they click OK.

> **showMemoDialog(description, default_text, callback)**
>
> - *string* **description**: Optional description of what the player should input.
>
> - *string* **default_text**: Optional default value.
>
> - *func* **callback**: Callback to execute if they click OK. Will be called as `callback(text, player_color)`
>
> **Example**

```lua
chosen_player.showMemoDialog("Set Description",
    function (text, player_color)
        chosen_object.setDescription(text)
    end
)
```

### showOptionsDialog(...)

*returns bool*  Shows the options dropdown dialog to the player and executes the callback if they click OK.

> **showOptionsDialog(description, options, default_value, callback)**
>
> - *string* **description**: Description of what the player is choosing.
>
> - *table* **options**: Table of string options.
>
> - *int* **default_value**: Optional default value, an integer index into the options table. Note you may alternatively use the option string itself.
>
> - *func* **callback**: Callback to execute if they click OK. Will be called as `callback(selected_text, selected_index, player_color)`
>
> **Example**

```lua
chosen_player.showOptionsDialog("Choose Value", {"1", "2", "3", "4", "5", "6"}, dice.getValue(),
    function (text, index, player_color)
        dice.setValue(index)
    end
)
```

### showColorDialog(...)

*returns bool*  Shows the color picker dialog to the player and executes the callback if they click OK.

> **showColorDialog(default_color, callback)**
>
> - *colt* **default_color**: Optional default color.
>
> - *func* **callback**: Callback to execute if they click Apply. Will be called as `callback(color, player_color)`
>
> **Example**

```lua
chosen_player.showColorDialog(dice.getColorTint(),
    function (color, player_color)
        dice.setColorTint(color)
    end
)
```
