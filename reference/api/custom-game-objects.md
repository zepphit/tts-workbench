<!-- vendored from https://api.tabletopsimulator.com/custom-game-objects/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Custom

You can spawn [custom Objects](https://kb.tabletopsimulator.com/custom-content/about-custom-objects/) and then provide the custom content for them after spawning them by calling [setCustomObject()](object.md#setcustomobject). See setCustomObject for usage

You can also use setCustomObject along with [reload()](object.md#reload) to modify an existing custom Object.

## Custom AssetBundle

- Custom_Assetbundle

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **assetbundle**: The path/URL for the AssetBundle.
>
>   - *string* **assetbundle_secondary**: The path/URL for the secondary AssetBundle property.
>
>     - Optional, is not used by default.
>
>   - *int* **type**: An Int representing the Object's type.
>
>     - Optional, defaults to 0.
>
>       - **0**: Generic
>
>       - **1**: Figurine
>
>       - **2**: Dice
>
>       - **3**: Coin
>
>       - **4**: Board
>
>       - **5**: Chip
>
>       - **6**: Bag
>
>       - **7**: Infinite bag
>
>   - *int* **material**: An Int representing the Object's material.
>
>     - Optional, defaults to 0.
>
>       - **0**: Plastic
>
>       - **1**: Wood
>
>       - **2**: Metal
>
>       - **3**: Cardboard

## Custom Board

- Custom_Board

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **image**: The path/URL for the board.

## Custom Card

- CardCustom

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *int* **type**: The card shape.
>
>     - Optional, defaults to 0.
>
>       - **0**: Rectangle (Rounded)
>
>       - **1**: Rectangle
>
>       - **2**: Hex (Rounded)
>
>       - **3**: Hex
>
>       - **4**: Circle
>
>   - *string* **face**: The path/URL of the face image.
>
>   - *string* **back**: The path/URL of the back image.
>
>   - *bool* **sideways**: If the card is horizontal, instead of vertical.
>
>     - Optional, defaults to false.

## Custom Deck

- DeckCustom

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **face**: The path/URL of the face cardsheet.
>
>   - *string* **back**: The path/URL of the back cardsheet or card back.
>
>   - *bool* **unique_back**: If each card has a unique card back (via a cardsheet).
>
>     - Optional, defaults to false.
>
>   - *int* **width**: The number of columns on the cardsheet.
>
>     - Optional, defaults to 10.
>
>   - *int* **height**: The number of rows on the cardsheet.
>
>     - Optional, defaults to 7.
>
>   - *int* **number**: The number of cards on the cardsheet.
>
>     - Optional, defaults to 52.
>
>   - *bool* **sideways**: Whether the cards are horizontal, instead of vertical.
>
>     - Optional, defaults to false.
>
>   - *bool* **back_is_hidden**: Whether the card back should be used as the hidden image (instead of the last slot of the `face` image).
>
>     - Optional, defaults to false.

## Custom Dice

- Custom_Dice

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **image**: The path/URL for the [custom die](https://kb.tabletopsimulator.com/custom-content/custom-dice/).
>
>   - *int* **type**: The type of die, which determines its number of sides.
>
>     - Optional, defaults to 1.
>
>       - **0**: 4-sided
>
>       - **1**: 6-sided
>
>       - **2**: 8-sided
>
>       - **3**: 10-sided
>
>       - **4**: 12-sided
>
>       - **5**: 20-sided

## Custom Figurine

- Figurine_Custom

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **image**: The path/URL for the [custom figurine](https://kb.tabletopsimulator.com/custom-content/custom-figurine/).
>
>   - *string* **image_secondary**: The path/URL for the custom figurine's back.
>
>     - Optional, defaults to "image".

## Custom Model

- Custom_Model

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **mesh**: The path/URL for the .obj mesh used on the [custom model](https://kb.tabletopsimulator.com/custom-content/custom-model/).
>
>   - *string* **diffuse**: The path/URL for the diffuse image.
>
>   - *string* **normal**: The path/URL for the normals image.
>
>     - Optional, is not used by default.
>
>   - *string* **collider**: The path/URL for the collider mesh.
>
>     - Optional, defaults to a generic box collider.
>
>   - *bool* **convex**: Whether the object model is convex.
>
>     - Optional, defaults to false.
>
>   - *int* **type**: An Int representing the Object's type.
>
>     - Optional, defaults to 0.
>
>       - **0**: Generic
>
>       - **1**: Figurine
>
>       - **2**: Dice
>
>       - **3**: Coin
>
>       - **4**: Board
>
>       - **5**: Chip
>
>       - **6**: Bag
>
>       - **7**: Infinite bag
>
>   - *int* **material**: An Int representing the Object's material.
>
>     - Optional, defaults to 0.
>
>       - **0**: Plastic
>
>       - **1**: Wood
>
>       - **2**: Metal
>
>       - **3**: Cardboard
>
>   - *float* **specular_intensity**: The specular intensity.
>
>     - Optional, defaults to 0.1.
>
>   - *table* **specular_color**: The specular [Color](types.md#color).
>
>     - Optional, defaults to {r=1, g=1, b=1}.
>
>   - *float* **specular_sharpness**: The specular sharpness.
>
>     - Optional, defaults to 3.
>
>   - *float* **freshnel_strength**: The freshnel strength.
>
>     - Optional, defaults to 0.1.
>
>   - *bool* **cast_shadows**: Whether the Object casts shadows.
>
>     - Optional, defaults to true.

## Custom Tile

- Custom_Tile

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **image**: The path/URL for the [custom tile](https://kb.tabletopsimulator.com/custom-content/custom-tile/) image.
>
>   - *int* **type**: Determines the shape of the tile.
>
>     - Optional, defaults to 0.
>
>       - **0**: Square/Rectangle
>
>       - **1**: Hex
>
>       - **2**: Circle
>
>       - **3**: Square/Rectangle (Rounded)
>
>   - *string* **image_bottom**: The path/URL for the bottom-side image.
>
>     - Optional, uses the top image by default.
>
>   - *float* **thickness**: How thick the tile is.
>
>     - Optional, defaults to 0.5.
>
>   - *bool* **stackable**: Whether these tiles stack together into a pile.
>
>     - Optional, defaults to false.

## Custom Token

- Custom_Token

> **Custom Parameters**
>
> - *table* **parameters**: A Table of parameters which determine the properties of the Object.
>
>   - *string* **image**: The path/URL for the [custom token](https://kb.tabletopsimulator.com/custom-content/custom-token/) image.
>
>   - *float* **thickness**: How thick the token is.
>
>     - Optional, defaults to 0.2.
>
>   - *float* **merge_distance**: How accurately the token shape will trace image edge (in pixels).
>
>     - Optional, defaults to 15.
>
>   - *bool* **stackable**: Whether these tokens stack together into a pile.
>
>     - Optional, defaults to false.
