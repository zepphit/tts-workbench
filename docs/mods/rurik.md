# Rurik: Second Edition

**Read this mod for:** tag-based object resolution, coroutine boot with a bounded
wait, and global XML panels toggled with `UI.show`/`UI.hide`.

Rurik is the mod that got the **central fork** right: it resolves objects by tag,
not GUID — 86 tag call sites against only 4 `getObjectFromGUID` in its entire
Global script. Everything else about it is ordinary.

| | |
| --- | --- |
| Corpus | [`reference/mods/rurik/`](../../reference/mods/rurik/) |
| Source | `Mods/Workshop/3663650077.json`, 1.1 MB, TTS v14.2.1, saved 2026-03-04 |
| Architecture | one Global script + thin object scripts, resolved by tag |
| Global Lua | 58,213 chars, 1,834 lines |
| Global XML | **3,702 chars** — the only real global `XmlUI` in the corpus |
| Object scripts | 52 — **24 + 24 near-identical**, 4 unique |
| Objects | 418 (252 at table level) |
| `validate` | 0 errors, 2 warnings (duplicate GUIDs inside containers) |

---

## Tag resolution

```lua
local function rebuildTagCache()
    TAG_MULTI = {}
    for _, o in ipairs(getAllObjects()) do
        local tags = o.getTags()
```
— `reference/mods/rurik/global/script.lua:34`

```lua
function getByTag(tag)
    local list = TAG_MULTI and TAG_MULTI[tag] or nil
    if not list or #list == 0 then return nil end
    return list[1]
end
```
— `reference/mods/rurik/global/script.lua:47`

Tags name roles — `bag_coins`, `tracker_player_count`, `deck_characters`,
`deck_schemes`, `Trash` — and the cache maps each to a list of objects. 147 tag
labels are declared in `ComponentTags.labels`; 61 are actually in use on 330
objects.

**Two flaws not to copy:**

- `rebuildTagCache` is called by hand at **six** sites and is **never invalidated
  on spawn or destroy**. Take something out of a bag and the cache is stale until
  something else happens to rebuild it.
- `waitByTag` rebuilds the **entire** cache on every frame of its wait loop:

```lua
function waitByTag(tag, timeoutSeconds)
    local start = Time.time
    while true do
        rebuildTagCache()
```
— `reference/mods/rurik/global/script.lua:53`

That is a full `getAllObjects()` sweep over 419 objects per frame. Poll the one
thing you are waiting for. `ttslib`'s `registry` fixes both (C1).

---

## Coroutine boot — the pattern to copy

```lua
function onLoad()
    rebuildTagCache()
    startLuaCoroutine(Global, "bootCoroutine")
```
— `reference/mods/rurik/global/script.lua:150`

```lua
function bootCoroutine()
    rebuildTagCache()

    local coinsBag = waitByTag("bag_coins", 10)
    if not coinsBag then
        broadcastToAll("ERROR: Missing tag bag_coins on coins bag.", {r=1,g=0.2,b=0.2})
        return 1
    end
```
— `reference/mods/rurik/global/script.lua:163`

Three things right here, and they are the framework's architectural rule 4 in
miniature:

- **The wait is bounded.** Ten seconds, then it gives up.
- **The failure is loud**, naming the exact tag that is missing, in red.
- **Every path `return 1`s**, including the failure branch. A TTS coroutine that
  does not is an error.

Compare Arcs, which wraps the equivalent in a `pcall` and says nothing (C8).

`waitAmount` (`global/script.lua:73`) is the yield helper; `safeCall`
(`:80`) names a missing function in chat rather than failing silently.

**Entry points.** `onLoad` at `:150` (which starts `bootCoroutine` at `:152`),
`onPlayerConnect` at `:183`, and two setup coroutines —
`selectedSetupCoRoutine` at `:197` and `setupCoRutine` at `:203`.

---

## Global XML panels

The only real global `XmlUI` in the corpus, and the simplest possible pattern:
declare two panels inactive, toggle them.

```xml
<Panel
    id="setupMenu"
    height="951"
    width="989"
    image="Menu"
    rectAlignment="Center"
    allowDragging="true"
    showAnimation="Grow"
    hideAnimation="FadeOut"
    returnToOriginalPositionWhenReleased="false"
    outline="#000000" outlineSize="1 -1"
    active="false"
>
```
— `reference/mods/rurik/global/ui.xml:4`

`active="false"` keeps it off screen at load. `setupMenuClosed` (`ui.xml:113`) is
the 140×64 reopen button, and the two swap:

```lua
    UI.hide("setupMenu")
    UI.show("setupMenuClosed")
```
— `reference/mods/rurik/global/script.lua:1295`

with the inverse at `:1300`. **No `setXml` anywhere** — the structure is static
and only visibility changes. That is the right default
([cookbook/04](../cookbook/04-xmlui.md)).

The layout nests `<VerticalLayout>` inside `<Panel>` inside `<HorizontalLayout>`,
with `color="#00000000"` panels as transparent spacers (8 of them), and a
`<Dropdown>` for player count at `ui.xml:70`.

**`CustomUIAssets`.** Six declared: `Button_Main_Blue`, `Button_Square_Blue`,
`Inset_Grey`, `Menu`, `PlayerCount`, `Gamefound`. The XML references four;
`Inset_Grey` and `Gamefound` are unused. An `image=` name that does not resolve
renders a blank box with no error, which is why `tts.py validate` checks it.

---

## Buttons

Rurik has the corpus's two best index-avoidance idioms.

**Capture the count before creating:**

```lua
    TOTAL_INDEX = #self.getButtons()
```
— `reference/mods/rurik/objects/8e05ed/script.lua:68`

immediately before the `createButton` at `:71`, used at `:116`. `#getButtons()`
is the index the *next* button will receive.

**Search by `click_function`:**

```lua
local function hasBribeButton()
    local btns = self.getButtons()
    if not btns then return false end
    for _,b in ipairs(btns) do
        if b and b.click_function == "Advisor_onBribePressed" then
            return true
        end
    end
    return false
end
```
— `reference/mods/rurik/objects/7856d0/script.lua:1`

`getButtons()` returns the parameter tables, so any field set at creation is a
lookup key. This is a name→button map with extra steps — exactly `ttslib`'s `ui`
module (C3).

**On `editButton({index = 1})`.** 48 call sites across 24 inventory bags read
`self.editButton({ index = 1, label = tostring(val) })`
(`objects/064e16/script.lua:72` and `:79`). These are **correct**: the same
script's `onLoad` creates an invisible 500×500 click target first (`:38`), then
the counter label (`:49`), so index 1 is the label. Checked per call site, as
[critique.md](../critique.md#corrections-to-earlier-figures) asked.

---

## C6, live: 48 near-identical scripts

| Group | Count | Size | Differs by |
| --- | --- | --- | --- |
| Advisor tokens | **24** | 1,702 B | nothing — byte-identical |
| Inventory bags | 20 + 4 | 2,824 / 2,825 B | **three numbers** |

The inventory bags' only difference:

```lua
        position = {0,-1,0},
        height = 500,
        width = 500,
```
— `reference/mods/rurik/objects/064e16/script.lua:41`

The 20-copy variant has `{0,0,0}` and `220`. The four 2,825-byte copies are
exactly the four bags nicknamed **Ore** (`064e16`, `8d8618`, `acb198`, `e884c1`);
the other twenty are Fur, Wood, Honey, Fish and five unnamed. So the "variant" is
per-resource — a config table wearing a disguise. A one-line fix to bag behaviour
is a 24-site edit.

---

## Conventions

- **Tags are the identity**, one axis each: a resource (`Coin`, `Fur`, `Wood`,
  `Fish`, `Honey`, `Ore`) plus a colour (`Blue`, `Yellow`, `Red`, `Purple`),
  intersected at the call site:

```lua
        if o and o.type=="Bag" and o.hasTag and o.hasTag("Coin") and o.hasTag(playerColor) then
```
— `reference/mods/rurik/global/script.lua:1364`

- **Numbers hidden in `GMNotes`.** The round counter and the selected player
  count live there, read through a regex:

```lua
local function gmNumberFromObject(obj, defaultVal)
    if not obj then return defaultVal end
    local n = tonumber(string.match(obj.getGMNotes() or "", "%d+"))
    return n or defaultVal
end
```
— `reference/mods/rurik/global/script.lua:67`

  Only 2 objects carry `GMNotes`, and the whole boot sequence branches on one of
  them. Do not copy this (C4).

- **`broadcastToColor` for one player's problem** — the advisor tokens refuse
  privately rather than announcing (`objects/7856d0/script.lua:45`).
- **655 object snap points, 108 table snap points** — but only 28 are tagged.
- **Decals declared but barely used**: 8 in `DecalPallet`, 0 attached to objects,
  2 on the table.
- **5 objects carry an alternate state.**

---

## Known bugs

**Four inert buttons.** `objects/8e05ed` (the advisor payment panel) creates 4
buttons with

```lua
            function_owner = Global, -- IMPORTANT: functions live on Global environment
```
— `reference/mods/rurik/objects/8e05ed/script.lua:41`

while defining the handlers in its **own** script (`:100` onward).
`AdvisorPayPanel_cancel` and `AdvisorPayPanel_pay` appear **zero times** in
Rurik's Global, so the buttons do nothing. Global builds its own working panel via
`AdvisorPay.buildPaymentPanel` (`global/script.lua:156`), which is presumably why
nobody noticed. The comment on the offending line asserts the opposite of what
the file does.

**Defensive double-casing.** Not a bug so much as a symptom — the author did not
know whether tags are matched case-insensitively:

```lua
        if o and (o.hasTag("Deed") or o.hasTag("deed")) then
```
— `reference/mods/rurik/global/script.lua:296`

and again for `Coin`/`coin` (`:816`) and `Character`/`character` (`:910`,
`:916`). See
[open question 1](../cookbook/10-antipatterns.md#open-questions-test-these-in-tts).

**An unguarded `Player[c]`.** `setPlayerAmount` (`global/script.lua:128`) indexes
`Player["Blue"].seated` directly, 30 lines after `seatedPlayableColors` (`:96`)
does the same thing with a guard. It works only because those four colours always
exist.

**One lowercase `onload`**, at `objects/8cb299/script.lua:1` — see
[open question 3](../cookbook/10-antipatterns.md#open-questions-test-these-in-tts).

---

## What breaks if you edit it

| If you change | Then |
| --- | --- |
| A component's **tags** | Object resolution breaks. Tags are Rurik's GUIDs — `getByTag`/`waitByTag` are the only way most objects are found |
| One of the 24 advisor scripts | The other 23 keep the old behaviour |
| One of the 24 inventory-bag scripts | Same, and the 20/4 split means "the other one" is easy to miss |
| The `bag_coins` tag | `bootCoroutine` times out after 10 s and refuses to start |
| A `GMNotes` value | The round counter and player count are stored there |
| A `CustomUIAssets` name | The XML renders a blank box, with no error. Run `validate` |
| An element `id` in `ui.xml` | `UI.show`/`UI.hide` address by id; 6 call sites |

```bash
python3 scripts/tts.py xml extract Mods/Workshop/3663650077.json -o /tmp/rurik-ui
python3 scripts/tts.py refs Mods/Workshop/3663650077.json 8e05ed
```

---

## Files

| Path | What |
| --- | --- |
| `global/script.lua` | 58 KB — tag cache, boot coroutine, setup, advisor pay |
| `global/ui.xml` | 3.7 KB — the setup menu and its reopen button |
| `objects/064e16/script.lua` | inventory bag, ×24 (two variants) |
| `objects/7856d0/script.lua` | advisor token, ×24 byte-identical |
| `objects/8e05ed/script.lua` | the advisor payment panel — 4 inert buttons |
| `manifest.json` | slot map + sha256 |
