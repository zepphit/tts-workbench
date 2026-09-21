# Tabletop Simulator API — vendored reference

One markdown file per page of <https://api.tabletopsimulator.com/>, fetched 2026-09-20 by `scripts/fetch_api_docs.py`. 55 pages, 455 KB.

**Grep [the function list](#every-documented-function) for a name, then read that one page.** The pages are large — `object.md` is the whole Object class — so opening the right one matters.

## Pages

| Page | File | Covers |
| --- | --- | --- |
| Atom | [`atom.md`](atom.md) | Features, Installing Atom, Atom Console, User Customization |
| Backgrounds | [`backgrounds.md`](backgrounds.md) | Function Summary |
| Base | [`base.md`](base.md) | 30 functions — Function Summary, Function Details |
| AssetBundle | [`behavior__assetbundle.md`](behavior__assetbundle.md) | 2 functions — Function Summary, Function Details |
| Book | [`behavior__book.md`](behavior__book.md) | 3 functions — Member Variables, Function Summary, Function Details |
| Browser | [`behavior__browser.md`](behavior__browser.md) | Member Variables |
| Clock | [`behavior__clock.md`](behavior__clock.md) | 1 functions — Clock Modes, Member Variables, Function Summary, Function Details |
| Container | [`behavior__container.md`](behavior__container.md) | 1 functions — Function Summary, Function Details |
| Counter | [`behavior__counter.md`](behavior__counter.md) | Functions |
| LayoutZone | [`behavior__layoutzone.md`](behavior__layoutzone.md) | Functions, Options |
| RPGFigurine | [`behavior__rpgfigurine.md`](behavior__rpgfigurine.md) | 2 functions — Callback Members, Functions, Callback Member Details |
| TextTool | [`behavior__texttool.md`](behavior__texttool.md) | Functions |
| Built-in | [`built-in-object.md`](built-in-object.md) | Object Types, Spawnable Names |
| Color | [`color.md`](color.md) | 12 functions — Constructors summary, Element access summary, Arithmetics summary, Methods summary, Constructors details, Element access details |
| Component | [`components__component.md`](components__component.md) | Member Variables, Functions |
| Examples | [`components__examples.md`](components__examples.md) | — |
| GameObject | [`components__gameobject.md`](components__gameobject.md) | Member Variables, Functions |
| Introduction | [`components__introduction.md`](components__introduction.md) | GameObjects, Components, Vars, Materials |
| Material | [`components__material.md`](components__material.md) | Member Variables, Functions |
| Custom | [`custom-game-objects.md`](custom-game-objects.md) | Custom AssetBundle, Custom Board, Custom Card, Custom Deck, Custom Dice, Custom Figurine |
| Events | [`events.md`](events.md) | 67 functions — Event Handlers, Event Handler Execution, Event Summary, Universal Event Handler Details, Global Event Handler Details, Object Event Handler Details |
| External Editor API | [`externaleditorapi.md`](externaleditorapi.md) | Atom as the Server, Tabletop Simulator as the Server |
| Grid | [`grid.md`](grid.md) | Member Variables |
| Hands | [`hands.md`](hands.md) | Member Variables, Member Variable Details, Function Summary |
| Info | [`info.md`](info.md) | Member Variables |
| Introduction | [`intro.md`](intro.md) | Using the API Documentation, Improving the Documentation, Tabletop Simulator Terminology, Deprecated APIs |
| JSON | [`json.md`](json.md) | 3 functions — Function Summary, Function Details |
| Lighting | [`lighting.md`](lighting.md) | Member Variables, Function Summary |
| Lua in Tabletop Simulator | [`lua-in-tabletop-simulator.md`](lua-in-tabletop-simulator.md) | Learning Lua, Lua Version, Lua Standard Libraries, Lua Additions |
| Music Player | [`musicplayer.md`](musicplayer.md) | 8 functions — Member Variables, Function Summary, Function Details |
| Notes | [`notes.md`](notes.md) | 5 functions — Function Summary, Function Details |
| Object | [`object.md`](object.md) | 63 functions — Member Variables, Function Summary, Function Details |
| Overview | [`overview.md`](overview.md) | Available scripting methods, Example Mods |
| Physics | [`physics.md`](physics.md) | 1 functions — Member Variable Summary, Function Summary, Function Details |
| Player Colors | [`player__colors.md`](player__colors.md) | — |
| Player Instance | [`player__instance.md`](player__instance.md) | 20 functions — Member Variables, Function Summary, Function Details |
| Player Manager | [`player__manager.md`](player__manager.md) | 2 functions — Function Summary, Actions, Function Details |
| System Console | [`systemconsole.md`](systemconsole.md) | Controls, Commands & Variables, Scripts, Some useful commands, All Console Commands |
| Tables | [`tables.md`](tables.md) | 1 functions — Function Summary, Table Names, Function Details |
| Time | [`time.md`](time.md) | Member Variables |
| Timer *deprecated* | [`timer.md`](timer.md) | 2 functions — Function Summary, Function Details |
| Turns | [`turns.md`](turns.md) | Member Variables, Function Summary |
| Types | [`types.md`](types.md) | Common Standards, Special Standards |
| UI | [`ui.md`](ui.md) | 14 functions — Global and Object, Inputs, Member Variable Summary, Function Summary, Function Details |
| Attributes | [`ui__attributes.md`](ui__attributes.md) | 1 functions — Attribute types, Common Attributes, Usage |
| Basic Elements | [`ui__basicelements.md`](ui__basicelements.md) | Element Summary, Element Details |
| Defaults | [`ui__defaults.md`](ui__defaults.md) | — |
| Input Elements | [`ui__inputelements.md`](ui__inputelements.md) | Targeting Triggers, Element Summary, Element Details |
| Introduction | [`ui__introUI.md`](ui__introUI.md) | Core Features, Getting Started |
| Layout/Grouping | [`ui__layoutgrouping.md`](ui__layoutgrouping.md) | Element Summary, Layout Element Details |
| Vector | [`vector.md`](vector.md) | 33 functions — Constructors summary, Element access summary, Arithmetics summary, Methods summary, Constructors details, Element access details |
| VR Beta | [`vr.md`](vr.md) | Reverting to original controls, v11.1 VR changes, VR settings, Current VR Controls*, Editting autoexec, VR commands |
| Wait | [`wait.md`](wait.md) | 6 functions — Function Summary, Function Details |
| Web Request Instance | [`webrequest__instance.md`](webrequest__instance.md) | Member Variables, Functions |
| Web Request Manager | [`webrequest__manager.md`](webrequest__manager.md) | 4 functions — Function Summary, Function Details |

## Every documented function

264 names. A name documented on more than one page lists them all.

| Function | Page |
| --- | --- |
| `add` | [`vector.md`](vector.md) |
| `addContextMenuItem` | [`base.md`](base.md), [`object.md`](object.md) |
| `addDecal` | [`object.md`](object.md) |
| `addForce` | [`object.md`](object.md) |
| `addHotkey` | [`base.md`](base.md) |
| `addNotebookTab` | [`notes.md`](notes.md) |
| `addTorque` | [`object.md`](object.md) |
| `allowRewindStore` | [`base.md`](base.md) |
| `angle` | [`vector.md`](vector.md) |
| `attachCameraToObject` | [`player__instance.md`](player__instance.md) |
| `attachHider` | [`object.md`](object.md) |
| `attachInvisibleHider` | [`object.md`](object.md) |
| `broadcast` | [`player__instance.md`](player__instance.md) |
| `broadcastToAll` | [`base.md`](base.md) |
| `broadcastToColor` | [`base.md`](base.md) |
| `call` | [`object.md`](object.md) |
| `cast` | [`physics.md`](physics.md) |
| `changeColor` | [`player__instance.md`](player__instance.md) |
| `chooseInHand` | [`base.md`](base.md) |
| `chooseInHandOrCancel` | [`base.md`](base.md) |
| `clamp` | [`vector.md`](vector.md) |
| `clearChooseInHand` | [`base.md`](base.md) |
| `clone` | [`object.md`](object.md) |
| `collect` | [`wait.md`](wait.md) |
| `Color.Add` | [`color.md`](color.md) |
| `Color.fromString` | [`color.md`](color.md) |
| `Color.new` | [`color.md`](color.md) |
| `condition` | [`wait.md`](wait.md) |
| `Containers` | [`object.md`](object.md) |
| `copy` | [`base.md`](base.md), [`color.md`](color.md), [`player__instance.md`](player__instance.md), [`vector.md`](vector.md) |
| `create` | [`timer.md`](timer.md) |
| `createButton` | [`object.md`](object.md) |
| `createInput` | [`object.md`](object.md) |
| `cross` | [`vector.md`](vector.md) |
| `currentChooseInHand` | [`base.md`](base.md) |
| `custom` | [`webrequest__manager.md`](webrequest__manager.md) |
| `cut` | [`object.md`](object.md) |
| `deal` | [`object.md`](object.md) |
| `dealToColorWithOffset` | [`object.md`](object.md) |
| `decode` | [`json.md`](json.md) |
| `destroy` | [`timer.md`](timer.md) |
| `destroyObject` | [`base.md`](base.md) |
| `distance` | [`vector.md`](vector.md) |
| `dot` | [`vector.md`](vector.md) |
| `drawHandStash` | [`player__instance.md`](player__instance.md) |
| `dump` | [`color.md`](color.md) |
| `editButton` | [`object.md`](object.md) |
| `editInput` | [`object.md`](object.md) |
| `editNotebookTab` | [`notes.md`](notes.md) |
| `encode` | [`json.md`](json.md) |
| `encode_pretty` | [`json.md`](json.md) |
| `equals` | [`color.md`](color.md), [`vector.md`](vector.md) |
| `frames` | [`wait.md`](wait.md) |
| `get` | [`color.md`](color.md), [`vector.md`](vector.md), [`webrequest__manager.md`](webrequest__manager.md) |
| `getAttribute` | [`ui.md`](ui.md) |
| `getAttributes` | [`ui.md`](ui.md) |
| `getBounds` | [`object.md`](object.md) |
| `getBoundsNormalized` | [`object.md`](object.md) |
| `getButtons` | [`object.md`](object.md) |
| `getCurrentAudioclip` | [`musicplayer.md`](musicplayer.md) |
| `getCustomAssets` | [`ui.md`](ui.md) |
| `getCustomObject` | [`object.md`](object.md) |
| `getDecals` | [`object.md`](object.md) |
| `getFogOfWarReveal` | [`object.md`](object.md) |
| `getHandObjects` | [`player__instance.md`](player__instance.md) |
| `getHandTransform` | [`player__instance.md`](player__instance.md) |
| `getInputs` | [`object.md`](object.md) |
| `getJoints` | [`object.md`](object.md) |
| `getLoopingEffects` | [`behavior__assetbundle.md`](behavior__assetbundle.md) |
| `getNotebookTabs` | [`notes.md`](notes.md) |
| `getObjectFromGUID` | [`base.md`](base.md) |
| `getObjects` | [`base.md`](base.md), [`object.md`](object.md) |
| `getObjectsWithAllTags` | [`base.md`](base.md) |
| `getObjectsWithAnyTags` | [`base.md`](base.md) |
| `getObjectsWithTag` | [`base.md`](base.md) |
| `getPage` | [`behavior__book.md`](behavior__book.md) |
| `getPlayers` | [`player__manager.md`](player__manager.md) |
| `getPlaylist` | [`musicplayer.md`](musicplayer.md) |
| `getRotationValue` | [`object.md`](object.md) |
| `getRotationValues` | [`object.md`](object.md) |
| `getScale` | [`object.md`](object.md) |
| `getSnapPoints` | [`object.md`](object.md) |
| `getSpectators` | [`player__manager.md`](player__manager.md) |
| `getStates` | [`object.md`](object.md) |
| `getTransformForward` | [`object.md`](object.md) |
| `getTransformRight` | [`object.md`](object.md) |
| `getTransformUp` | [`object.md`](object.md) |
| `getTriggerEffects` | [`behavior__assetbundle.md`](behavior__assetbundle.md) |
| `getValue` | [`object.md`](object.md), [`ui.md`](ui.md) |
| `getVisualBoundsNormalized` | [`object.md`](object.md) |
| `getXmlTable` | [`ui.md`](ui.md) |
| `getZones` | [`object.md`](object.md) |
| `group` | [`base.md`](base.md) |
| `heading` | [`vector.md`](vector.md) |
| `hide` | [`ui.md`](ui.md) |
| `inverse` | [`vector.md`](vector.md) |
| `jointTo` | [`object.md`](object.md) |
| `lerp` | [`color.md`](color.md), [`vector.md`](vector.md) |
| `log` | [`base.md`](base.md) |
| `logString` | [`base.md`](base.md) |
| `logStyle` | [`base.md`](base.md) |
| `lookAt` | [`player__instance.md`](player__instance.md) |
| `magnitude` | [`vector.md`](vector.md) |
| `moveToHandStash` | [`object.md`](object.md) |
| `moveTowards` | [`vector.md`](vector.md) |
| `normalize` | [`vector.md`](vector.md) |
| `normalized` | [`vector.md`](vector.md) |
| `onAttack` | [`behavior__rpgfigurine.md`](behavior__rpgfigurine.md) |
| `onBlindfold` | [`events.md`](events.md) |
| `onChat` | [`events.md`](events.md) |
| `onCollisionEnter` | [`events.md`](events.md) |
| `onCollisionExit` | [`events.md`](events.md) |
| `onCollisionStay` | [`events.md`](events.md) |
| `onDestroy` | [`events.md`](events.md) |
| `onDrop` | [`events.md`](events.md) |
| `onExternalMessage` | [`events.md`](events.md) |
| `onFixedUpdate` | [`events.md`](events.md) |
| `onFlick` | [`events.md`](events.md) |
| `onGroupSort` | [`events.md`](events.md) |
| `onHit` | [`behavior__rpgfigurine.md`](behavior__rpgfigurine.md) |
| `onHover` | [`events.md`](events.md) |
| `onLoad` | [`events.md`](events.md) |
| `onNumberTyped` | [`events.md`](events.md) |
| `onObjectCollisionEnter` | [`events.md`](events.md) |
| `onObjectCollisionExit` | [`events.md`](events.md) |
| `onObjectCollisionStay` | [`events.md`](events.md) |
| `onObjectDestroy` | [`events.md`](events.md) |
| `onObjectDrop` | [`events.md`](events.md) |
| `onObjectEnterContainer` | [`events.md`](events.md) |
| `onObjectEnterZone` | [`events.md`](events.md) |
| `onObjectFlick` | [`events.md`](events.md) |
| `onObjectHover` | [`events.md`](events.md) |
| `onObjectLeaveContainer` | [`events.md`](events.md) |
| `onObjectLeaveZone` | [`events.md`](events.md) |
| `onObjectLoopingEffect` | [`events.md`](events.md) |
| `onObjectNumberTyped` | [`events.md`](events.md) |
| `onObjectPageChange` | [`events.md`](events.md) |
| `onObjectPeek` | [`events.md`](events.md) |
| `onObjectPickUp` | [`events.md`](events.md) |
| `onObjectRandomize` | [`events.md`](events.md) |
| `onObjectRotate` | [`events.md`](events.md) |
| `onObjectSearchEnd` | [`events.md`](events.md) |
| `onObjectSearchStart` | [`events.md`](events.md) |
| `onObjectSpawn` | [`events.md`](events.md) |
| `onObjectStateChange` | [`events.md`](events.md) |
| `onObjectTriggerEffect` | [`events.md`](events.md) |
| `onPageChange` | [`events.md`](events.md) |
| `onPeek` | [`events.md`](events.md) |
| `onPickUp` | [`events.md`](events.md) |
| `onPlayerAction` | [`events.md`](events.md) |
| `onPlayerChangeColor` | [`events.md`](events.md) |
| `onPlayerChangeTeam` | [`events.md`](events.md) |
| `onPlayerChatTyping` | [`events.md`](events.md) |
| `onPlayerConnect` | [`events.md`](events.md) |
| `onPlayerDisconnect` | [`events.md`](events.md) |
| `onPlayerHandChoice` | [`events.md`](events.md) |
| `onPlayerPing` | [`events.md`](events.md) |
| `onPlayerTurn` | [`events.md`](events.md) |
| `onRandomize` | [`events.md`](events.md) |
| `onRotate` | [`events.md`](events.md) |
| `onSave` | [`events.md`](events.md) |
| `onScriptingButtonDown` | [`events.md`](events.md) |
| `onScriptingButtonUp` | [`events.md`](events.md) |
| `onSearchEnd` | [`events.md`](events.md) |
| `onSearchStart` | [`events.md`](events.md) |
| `onStateChange` | [`events.md`](events.md) |
| `onUpdate` | [`events.md`](events.md) |
| `onZoneGroupSort` | [`events.md`](events.md) |
| `orthoNormalize` | [`vector.md`](vector.md) |
| `paste` | [`base.md`](base.md), [`player__instance.md`](player__instance.md) |
| `pause` | [`musicplayer.md`](musicplayer.md) |
| `play` | [`musicplayer.md`](musicplayer.md) |
| `Position/Size Attributes` | [`ui__attributes.md`](ui__attributes.md) |
| `positionToLocal` | [`object.md`](object.md) |
| `positionToWorld` | [`object.md`](object.md) |
| `post` | [`webrequest__manager.md`](webrequest__manager.md) |
| `print` | [`base.md`](base.md), [`player__instance.md`](player__instance.md) |
| `printToAll` | [`base.md`](base.md) |
| `printToColor` | [`base.md`](base.md) |
| `project` | [`vector.md`](vector.md) |
| `projectOnPlane` | [`vector.md`](vector.md) |
| `put` | [`webrequest__manager.md`](webrequest__manager.md) |
| `putObject` | [`object.md`](object.md) |
| `reflect` | [`vector.md`](vector.md) |
| `registerCollisions` | [`object.md`](object.md) |
| `reload` | [`object.md`](object.md) |
| `removeButton` | [`object.md`](object.md) |
| `removeInput` | [`object.md`](object.md) |
| `removeNotebookTab` | [`notes.md`](notes.md) |
| `rotate` | [`object.md`](object.md) |
| `rotateOver` | [`vector.md`](vector.md) |
| `rotateTowards` | [`vector.md`](vector.md) |
| `rotateTowardsUnit` | [`vector.md`](vector.md) |
| `scale` | [`object.md`](object.md), [`vector.md`](vector.md) |
| `search` | [`behavior__container.md`](behavior__container.md) |
| `set` | [`color.md`](color.md), [`vector.md`](vector.md) |
| `setAt` | [`color.md`](color.md), [`vector.md`](vector.md) |
| `setAttribute` | [`ui.md`](ui.md) |
| `setAttributes` | [`ui.md`](ui.md) |
| `setCameraMode` | [`player__instance.md`](player__instance.md) |
| `setClass` | [`ui.md`](ui.md) |
| `setCurrentAudioclip` | [`musicplayer.md`](musicplayer.md) |
| `setCustomAssets` | [`ui.md`](ui.md) |
| `setCustomObject` | [`object.md`](object.md) |
| `setDecals` | [`object.md`](object.md) |
| `setFogOfWarReveal` | [`object.md`](object.md) |
| `setHandStashLocation` | [`player__instance.md`](player__instance.md) |
| `setHandTransform` | [`player__instance.md`](player__instance.md) |
| `setHiddenFrom` | [`object.md`](object.md) |
| `setHighlight` | [`behavior__book.md`](behavior__book.md) |
| `setInvisibleTo` | [`object.md`](object.md) |
| `setNotes` | [`notes.md`](notes.md) |
| `setPage` | [`behavior__book.md`](behavior__book.md) |
| `setPlaylist` | [`musicplayer.md`](musicplayer.md) |
| `setPositionSmooth` | [`object.md`](object.md) |
| `setRotationSmooth` | [`object.md`](object.md) |
| `setRotationValue` | [`object.md`](object.md) |
| `setRotationValues` | [`object.md`](object.md) |
| `setSnapPoints` | [`object.md`](object.md) |
| `setTable` | [`tables.md`](tables.md) |
| `setUITheme` | [`player__instance.md`](player__instance.md) |
| `setValue` | [`behavior__clock.md`](behavior__clock.md), [`object.md`](object.md), [`ui.md`](ui.md) |
| `setVectorLines` | [`object.md`](object.md) |
| `setXml` | [`ui.md`](ui.md) |
| `setXmlTable` | [`ui.md`](ui.md) |
| `show` | [`ui.md`](ui.md) |
| `showColorDialog` | [`player__instance.md`](player__instance.md) |
| `showConfirmDialog` | [`player__instance.md`](player__instance.md) |
| `showInfoDialog` | [`player__instance.md`](player__instance.md) |
| `showInputDialog` | [`player__instance.md`](player__instance.md) |
| `showMemoDialog` | [`player__instance.md`](player__instance.md) |
| `showOptionsDialog` | [`player__instance.md`](player__instance.md) |
| `skipBack` | [`musicplayer.md`](musicplayer.md) |
| `skipForward` | [`musicplayer.md`](musicplayer.md) |
| `spawnObject` | [`base.md`](base.md) |
| `spawnObjectData` | [`base.md`](base.md) |
| `spawnObjectJSON` | [`base.md`](base.md) |
| `split` | [`object.md`](object.md) |
| `spread` | [`object.md`](object.md) |
| `sqrDistance` | [`vector.md`](vector.md) |
| `sqrMagnitude` | [`vector.md`](vector.md) |
| `startLuaCoroutine` | [`base.md`](base.md) |
| `stop` | [`wait.md`](wait.md) |
| `stopAll` | [`wait.md`](wait.md) |
| `storeRewindState` | [`base.md`](base.md) |
| `string` | [`vector.md`](vector.md) |
| `stringColorToRGB` | [`base.md`](base.md) |
| `sub` | [`vector.md`](vector.md) |
| `takeObject` | [`object.md`](object.md) |
| `time` | [`wait.md`](wait.md) |
| `toHex` | [`color.md`](color.md) |
| `toString` | [`color.md`](color.md) |
| `tryObjectEnter` | [`events.md`](events.md) |
| `tryObjectEnterContainer` | [`events.md`](events.md) |
| `tryObjectRandomize` | [`events.md`](events.md) |
| `tryObjectRotate` | [`events.md`](events.md) |
| `tryObjectStateChange` | [`events.md`](events.md) |
| `tryRandomize` | [`events.md`](events.md) |
| `tryRotate` | [`events.md`](events.md) |
| `tryStateChange` | [`events.md`](events.md) |
| `unregisterCollisions` | [`object.md`](object.md) |
| `Vector.between` | [`vector.md`](vector.md) |
| `Vector.max` | [`vector.md`](vector.md) |
| `Vector.min` | [`vector.md`](vector.md) |

Re-run `python3 scripts/fetch_api_docs.py` to refresh; pages whose content has not changed are left untouched.
