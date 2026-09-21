# The `Mods/` asset cache

Saves and mods never embed art. They store **URLs**, and TTS downloads each one
into `Mods/` the first time it is needed. The folder is ~8.7 GB and entirely
TTS-managed — treat it as read-only.

## Layout

| Folder | Size | Holds | Fed by |
| --- | --- | --- | --- |
| `Images/` | 2.3 GB | Downloaded textures, as-is (`.png`, `.jpg`) | `ImageURL`, `FaceURL`, `BackURL`, `DiffuseURL`, `NormalURL`, `TableURL`, `SkyURL` |
| `Images Raw/` | 5.1 GB | Decoded/resized textures (`.rawt`) | derived from `Images/`, not downloaded |
| `Models/` | 46 MB | Meshes (`.obj`) | `MeshURL`, `ColliderURL` |
| `Models Raw/` | 26 MB | Preprocessed meshes | derived |
| `PDF/` | 783 MB | Rulebooks (`.pdf`) | `PDFUrl` |
| `Assetbundles/` | 99 MB | Unity bundles (`.unity3d`) | `AssetbundleURL` |
| `Audio/` | 105 MB | Music and SFX (`.mp3`, `.wav`) | `CurrentAudioURL` |
| `Text/` | 4 KB | Downloaded text files | — |
| `Translations/` | empty | — | — |
| `Workshop/` | 246 MB | Subscribed mods: `<steamid>.json` + `<steamid>.png`, plus `WorkshopFileInfos.json` | Steam Workshop |

`Images Raw/` is the biggest thing in the folder and it is **derived**. Every
`.rawt` can be regenerated from the corresponding entry in `Images/`.

## URL → filename

TTS names each cached file after the URL with **every non-alphanumeric
character removed**, then appends the real file extension:

```python
stem = re.sub(r"[^A-Za-z0-9]", "", url)
```

```
https://steamusercontent-a.akamaihd.net/ugc/11573588086081577367/52344325DB78FDC9AF12CD185AAFFDEA2CD2D3F7/
→ Mods/Images/httpssteamusercontentaakamaihdnetugc1157358808608157736752344325DB78FDC9AF12CD185AAFFDEA2CD2D3F7.png
```

Two consequences:

- **The extension is whatever was served, not what the folder implies.**
  `Images/` holds both `.png` and `.jpg` for structurally identical URLs, so any
  lookup must glob `stem + ".*"` rather than assume.
- **Nothing is greppable by intent.** You cannot find "the player board image"
  by filename. Go through the save that references it.

## Resolving assets

```bash
# every asset a save uses, and where each one cached to
python3 scripts/tts.py urls Saves/TS_Save_123.json

# just the ones TTS never downloaded
python3 scripts/tts.py urls Saves/TS_Save_123.json --missing-only --paths

# one URL -> its cache path
python3 scripts/tts.py find-asset "https://steamusercontent-a.akamaihd.net/ugc/.../"

# a cache filename -> which saves and mods reference it
python3 scripts/tts.py find-asset httpssteamusercontentaakamaihdnetugc1157...png
```

### `MISSING` is normal

`MISSING` means the URL is referenced but not in the cache — usually because TTS
never had to fetch it. In `TS_Save_123.json`, 2 of 39 assets are missing: card
art belonging to an alternate `States` entry that was never flipped to. That is
not corruption. It matters only if you plan to play offline or re-upload.

## `.rawt` format

A small binary container, not an image format:

```
offset 0   4 bytes   magic "rawt"
offset 4   uint32    length of the JSON header (little-endian)
offset 8   N bytes   JSON header
offset 8+N ...       raw pixel data
```

The header records the decode TTS performed:

```json
{
  "format": 10, "width_original": 2016, "height_original": 3078,
  "width_new": 2016, "height_new": 3080, "mip_maps": true,
  "normal_map": false, "max_size": 8192, "linear": false, "transparency": 0
}
```

Useful for reading original image dimensions without decoding anything — note
`height_new` is padded to a multiple of 4 for GPU compression.

## Local assets and the prototype workflow

Most URLs point at Steam. The prototype saves point at the local disk instead:

```
file:///Users/artur/Desktop/wyrmspan/pocket/teste1.png
→ Mods/Images Raw/fileUsersarturDesktopwyrmspanpocketteste1png.rawt
```

The same mangling rule applies, with `file` standing in for the scheme. Saves
using local assets:

| Save | Name | `file:///` refs |
| --- | --- | --- |
| `Saves/ProjStdw/TS_Save_10.json` | ProjStdwOverhaulV1LOCK | 479 |
| `Saves/ProjStdw/TS_Save_9.json` | ProjStdwOverhaulV2 | 495 |
| `Saves/ProjStdw/TS_Save_4.json` | ProjStdwV1-3p | 398 |
| `Saves/ProjStdw/TS_Save_5.json` | ProjStdwV2-3p | 344 |
| `Saves/ProjStdw/TS_Save_8.json` | ProjStdwOverhaulSETUPV1 | 304 |
| `Saves/ProjStdw/TS_Save_7.json` | ProjStdwOverhaulV1 | 242 |
| `Saves/ProjStdw/TS_Save_3.json` | ProjStdwV1 | 162 |
| `Saves/TS_Save_1.json`, `TS_Save_2.json` | ProjStdwV1 | 88 each |

What this means in practice:

- **A save using `file:///` URLs only works on this machine.** Anyone else
  loading it sees blank components. It is fine for solo iteration, fatal for
  sharing.
- **The source art may be gone.** These point at `~/Desktop/...` from 2023. The
  `.rawt` cache may be the only surviving copy.
- **Publishing rewrites them.** Uploading to Steam Workshop replaces every local
  URL with a `steamusercontent` one. Before then, moving or renaming a file on
  the Desktop breaks the save.

If a prototype needs to leave this machine, the URLs must be swapped for hosted
ones — that is a save-JSON edit across every `ImageURL`/`FaceURL`/`BackURL`, not
something TTS does for you outside of a Workshop upload.
