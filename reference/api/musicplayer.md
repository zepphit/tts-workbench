<!-- vendored from https://api.tabletopsimulator.com/musicplayer/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Music Player

`MusicPlayer` is a static global class which allows you to control the in-game music playback i.e. the in-game "Music" menu.

## Member Variables

| Variable | Description | Type |
| --- | --- | --- |
| loaded | If all players loaded the current audioclip. Read only. | *bool* |
| player_status | The current state of the music player. Read only. Options: "Stop", "Play", "Loading", "Ready". | *string* |
| playlistIndex | *deprecated* *Use [playlist_index](#playlist_index)*.Current index of the playlist. `-1` if no playlist audioclip is playing. | *int* |
| playlist_index | Current index of the playlist. `-1` if no playlist audioclip is playing. | *int* |
| repeat_track | If the current audioclip should be repeated. | *bool* |
| shuffle | If the playlist should play shuffled. | *bool* |

## Function Summary

Functions that interact with the in-game music player.

| Function Name | Description | Return |
| --- | --- | --- |
| getCurrentAudioclip() | Gets the currently loaded audioclip. | *returns table* |
| getPlaylist() | Gets the current playlist. | *returns table* |
| pause() | Pauses currently playing audioclip. Returns true if the music player is paused, otherwise returns false. | *returns bool* |
| play() | Plays currently loaded audioclip. Returns true if the music player is playing, otherwise returns false. | *returns bool* |
| setCurrentAudioclip() | Sets the audioclip to be loaded. | *returns bool* |
| setPlaylist() | Sets the current playlist. | *returns bool* |
| skipBack() | Skips to the beginning of the audioclip or if the play time is less than 3 seconds to the previous audioclip in playlist if possible. Returns true if skip was successful, otherwise returns false. | *returns bool* |
| skipForward() | Skips to the next audioclip in playlist if possible. Returns true if skip was successful, otherwise returns false. | *returns bool* |

---

## Function Details

#### getCurrentAudioclip()

*returns table*  Gets the currently loaded audioclip.

> **Returned table**
>
> - *table*  Table describing the current audioclip.
>
>   - *string* **url**: The URL of the current audioclip.
>
>   - *string* **title**: The title of the current audioclip.
>
> **Example**
>
> Print the title of the current audioclip.

```lua
local clip = MusicPlayer.getCurrentAudioclip()
print("Currently playing '" .. clip.title .. "'")
```

---

#### getPlaylist()

*returns table*  Gets the current playlist.

> **Returned table**
>
> - *table*  Playlist table, consisting of zero or more audioclip sub-tables.
>
>   - *table*  Sub-table describing each audioclip.
>
>     - *string* **url**: The URL of the current audioclip.
>
>     - *string* **title**: The title of the current audioclip.
>
> **Example**
>
> Print the track number and title of each audioclip making up the playlist.

```lua
local playlist = MusicPlayer.getPlaylist()
for i, clip in ipairs(playlist) do
    print(i .. " - " .. clip.title)
end
```

---

#### pause()

*returns bool*  Pause the current audioclip.

Returns `true` if the music player is/was paused, otherwise `false`.

> **Example**
>
> Pause the current track.

```
MusicPlayer.pause()
```

---

#### play()

*returns bool*  Plays the current audioclip.

Returns `true` if the music player is/was playing, otherwise `false`.

> **Example**
>
> Play the current track.

```
MusicPlayer.play()
```

---

#### setCurrentAudioclip(...)

*returns bool*  .Sets/loads the specified audioclip.

> **setCurrentAudioclip(parameters)**
>
> - *table* **parameters**: A table describing an audioclip.
>
>   - *string* **url**: The URL of the audioclip.
>
>   - *string* **title**: The title of the audioclip.
>
> **Example**
>
> Set the current track.

```
MusicPlayer.setCurrentAudioclip({
    url = "https://domain.example/path/to/clip.mp3",
    title = "Example"
})
```

---

#### setPlaylist(...)

*returns bool*  Sets the current playlist.

> **setPlaylist(parameters)**
>
> - *table* **parameters**: A table containing zero or more audioclip sub-tables.
>
>   - *table*  Sub-table describing each audioclip.
>
>     - *string* **parameters.url**: The URL of an audioclip.
>
>     - *string* **parameters.title**: The title of an audioclip.
>
> **Example**
>
> Set the current playlist to include three pieces of music.

```
MusicPlayer.setCurrentAudioclip({
    {
        url = "https://domain.example/path/to/clip.mp3",
        title = "Example"
    },
    {
        url = "https://domain.example/path/to/clip2.mp3",
        title = "Example #2"
    },
    {
        url = "https://domain.example/path/to/clip3.mp3",
        title = "Example #3"
    }
})
```

---

#### skipBack()

*returns bool*  Skips to the beginning of the audioclip or if the play time is less than 3 seconds to the previous audioclip in playlist if possible.

Returns `true` if skip was successful, otherwise returns `false`.

> **Example**
>
> Skip backwards to either the beginning of the audioclip, or the prior audioclip in the playlist.

```
MusicPlayer.skipBack()
```

---

#### skipForward()

*returns bool*  Skips to the next audioclip in the current playlist. If the current audioclip is the last of the playlist, loops around to the first audioclip in the playlist.

Returns `true` if skip was successful, otherwise returns `false`.

> **Example**
>
> Skip to the next audioclip.

```
MusicPlayer.skipForward()
```

---
