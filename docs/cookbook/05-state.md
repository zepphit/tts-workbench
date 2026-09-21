# 05 — State

What survives a save/load, and the four ways the corpus gets it wrong.

---

## The mechanism

```lua
function onSave()
  return JSON.encode(data)
end
```
— `reference/mods/politik/objects/1efc34/script.lua:143`

`onSave` returns a **string**. TTS stores it in that script's `LuaScriptState`
field and hands it back to `onLoad(script_state)` on the next load. Global and
each object have their own independent pair.

Because it is a string inside a JSON document, `LuaScriptState` is
**double-encoded** — a JSON document escaped into a JSON string value. That is
also why it must never be hand-edited (below).

`JSON.encode` cannot encode an Object reference. Store the GUID and re-resolve on
load — [`reference/api/events.md:1114`](../../reference/api/events.md) says so
explicitly. Better, store a role tag and resolve that ([06](06-objects-tags-containers.md)).

---

## Guard styles

Two that work:

```lua
function onLoad(script_state)
  local i
  data = JSON.decode(script_state)
  if data == nil then
    data = {
      name="",
```
— `reference/mods/politik/objects/1efc34/script.lua:122`

`JSON.decode("")` returns nil on a fresh load, so the nil branch is your defaults.

```lua
function onLoad(saveinf)
    if saveinf and #saveinf > 0 then
        local t = JSON.decode(saveinf)
        val = tonumber(t.val) or 0
    else
        val = 0
    end
```
— `reference/mods/rurik/objects/064e16/script.lua:17`

Rurik checks the string first and re-coerces the value with `tonumber(...) or 0`.
That second half matters: JSON round-trips can hand you a string where you stored
a number.

Politik does the same coercion in its own loop, one line before it writes the UI:

```lua
    data[valId] = tonumber(data[valId])
```
— `reference/mods/politik/objects/1efc34/script.lua:139`

**Rule.** Never trust a decoded value's type. Coerce on load, at the boundary.

---

## Trap 1: `onSave` that serialises everything (C4)

```lua
function onSave()
  return JSON.encode(data)
end
```

`data` here is whatever the script happened to accumulate. Politik's six resource
tokens ship a `LuaScriptState` containing:

```json
{ "max1": 5, "max2": 5, "max3": 5,
  "statName1": "Stat 1", "statName2": "Stat 2", "statName3": "Stat 3",
  "val1": 0, "val2": 0, "val3": 0, ... }
```

`max1`, `max2`, `max3`, `statName1`, `statName2` and `statName3` appear **nowhere
in the object's script** — not in the defaults at
`politik/objects/1efc34/script.lua:126`, not anywhere else. They are fossils from
an older version, and because `onSave` blindly re-encodes `data`, they will be
re-saved forever.

There is a live cost. The current script's `plus()` reads `data[maxId]`, and
`maxId` is a nil global — so the cap it was meant to apply never fires
([10](10-antipatterns.md)). A schema would have caught both the fossil and the
missing binding.

**Fix.** Serialise a declared shape, not a bag:

```lua
local VERSION = 2
local defaults = { val1 = 0, val2 = 0, val3 = 0 }

function onSave()
  return JSON.encode({ v = VERSION, val1 = data.val1, val2 = data.val2, val3 = data.val3 })
end

function onLoad(s)
  local saved = (s ~= "" and JSON.decode(s)) or {}
  data = {}
  for k, d in pairs(defaults) do
    data[k] = tonumber(saved[k]) or d       -- unknown keys dropped, defaults applied
  end
end
```

Unknown keys are dropped because you only read the keys you declared. That is
`ttslib`'s `store` (C4).

---

## Trap 2: a kill switch instead of migration

RotLA needed one, and documented why:

```lua
USE_SAVES = true
--set this to false while editing your mod or treasuries will persist.
--set this to true, copy in the script, use "save and play" from the modding menu, and then actually save your mod to enable saves (TTS is dumb).
--WARNING: If you intend on modifying any gameOptions, turn use_saves to false first.
```
— `reference/mods/rotla/global/script.lua:6`

The problem it works around is real: **saved state silently overrides edited
source.** You change a default in the script, reload, and the old value comes
back from `LuaScriptState`.

RotLA's `onSave` honours the flag by returning an empty string:

```lua
function onSave()
    --saved_data = JSON.encode(gameEntities)
    if not USE_SAVES then
        saved_data = ''
```
— `reference/mods/rotla/global/script.lua:345`

It also carries a version number it never checks:

```lua
SAVE_STATE = {
    versionNumber = 2.95
}
```
— `reference/mods/rotla/global/script.lua:341`

`versionNumber` appears exactly once in the 2,453-line script. Nothing reads it
and nothing compares it — and the engine's own boundary comment at `:258` says
the version is **2.96**, so the constant is already stale by one release.

**Fix.** A version you actually branch on turns the kill switch into a migration:

```lua
function onLoad(s)
  local saved = (s ~= "" and JSON.decode(s)) or {}
  if saved.v ~= VERSION then saved = migrate(saved) end
  ...
end
```

Then editing a default is safe, because a version bump discards the stale value
by design rather than by remembering to flip a global.

---

## Trap 3: state in fields meant for humans

Arcs keeps its "is a game running" flag in an object's **Description**:

```lua
    reach_board.setDescription("in progress")
```
— `reference/mods/arcs/global/src__Global.lua:2411`

and branches its load path on reading it back:

```lua
    if (reach_board.getDescription() == "in progress") then
```
— `reference/mods/arcs/global/src__Global.lua:2521`

`reach_board` is `bb7d21`. Clear that description in the TTS UI — which looks
like tidying up — and Arcs forgets a game is in progress.

RotLA does the same with `GMNotes`, and there it is load-bearing in a second way:
a supply item's `GMNotes` holds the GUID of the bag it came from
([06](06-objects-tags-containers.md)).

This is why [`save-format.md`](../save-format.md#common-object-fields) no longer
lists `Nickname` and `Description` as freely editable. **Before editing either
field on a scripted save, grep the Lua for it:**

```bash
python3 scripts/tts.py refs Saves/TS_Save_125.json bb7d21
grep -rn "getDescription\|getName()\|getGMNotes" reference/mods/<slug>/
```

**Fix.** These fields are for humans. State goes in `onSave`.

---

## Trap 4: hand-editing `LuaScriptState`

It is runtime state, not configuration. TTS overwrites it on the next save, so an
edit there is lost the first time the mod saves — and because it is
double-encoded, a hand edit is also easy to corrupt.

If you want a different starting value, change the **defaults in the script** and
clear the saved state (or bump the version, above).

---

## Global state

Arcs has exactly one Global `onSave`, at
`reference/mods/arcs/global/src__Global.lua:2674`, for 18,067 lines of code. Most
of its state lives in object Descriptions, component tags and the positions of
the objects themselves.

That is not automatically wrong — **the table is the state**. A cube on the power
track *is* the score; re-reading it from the board is more robust than mirroring
it into a save. Arcs' scoring does exactly that
(`arcs/global/src__ArcsPlayer.lua:332`, reading tagged objects out of a zone).

The rule that follows: persist **only what the table cannot tell you** — a mode
flag, a round number, a player's chosen options. Everything derivable from object
positions should be derived.

---

## Checklist

- [ ] `onSave` serialises a declared shape with a `version`, not an accumulated
      table.
- [ ] `onLoad` applies defaults for every key and coerces types.
- [ ] Unknown keys are dropped, not carried forward.
- [ ] No flag lives in `Description`, `GMNotes` or `Nickname`.
- [ ] No GUID is persisted where a tag would do.
- [ ] `LuaScriptState` is never hand-edited.
- [ ] Anything derivable from the table is derived, not stored.

**Next:** [06 — Objects, tags and containers](06-objects-tags-containers.md).
