-- ttslib/03-ui.lua — buttons addressed by name, and thin wrappers over XML UI.
-- Answers critique C3.  Depends on: 00-log.
--
-- Button indexes are positional and start at 0, so inserting one createButton
-- renumbers every later button — silently.  Arcs' own source warns "must add
-- buttons in the order of the actual indices !!!!!!!!!!" and RotLA maintains a
-- btnIndex counter by hand (docs/critique.md#c3).
--
-- Here every button has a name.  The name is turned into the button's
-- click_function, so the name -> index map is read back out of getButtons()
-- whenever it is needed: nothing is cached, nothing goes stale, and an insert
-- anywhere changes nothing.  Scripted buttons are not stored in the save file —
-- no save in this folder contains button data — so onLoad always rebuilds them;
-- calling ui.button again simply edits the one that is already there.
--
--   ui.button(obj, "total", { label = "0", position = {0, 0.2, 0},
--                             width = 600, height = 300, font_size = 200,
--                             onClick = function(o, colour, alt) ... end })
--   ui.set(obj, "total", { label = "3" })   -- survives insertions above it

ttslib = ttslib or {}

local LOG = assert(ttslib.log, "load ttslib/00-log.lua before 03-ui.lua")

local U = {}
ttslib.ui = U

U.LABEL_FONT_SIZE = 300 -- a zero-size button needs a big one: RotLA uses 1000

-- The environment this copy of ttslib is running in: `self` in an object
-- script, `Global` in the Global script.  Resolved lazily, because `self` is
-- not necessarily bound while the chunk itself is still being executed.
-- Reading an undefined global is nil in Lua, so this is safe in both.
local function env()
  return self or Global
end
U.env = env

-- Handlers are installed under a generated name, so function_owner and the
-- function definition can never drift apart — which is exactly Rurik's inert
-- advisor panel, four buttons pointing at handlers that live in another script
-- (docs/critique.md, live bug 3).
--
-- One object's script has a namespace to itself; Global's is shared by every
-- button on every object, so qualify those with the object's GUID.
local function clickName(obj, name)
  local owner = env()
  if owner == obj then
    return "ttslib_" .. name
  end
  local guid = (obj and obj.getGUID and obj.getGUID()) or "global"
  return "ttslib_" .. guid .. "_" .. name
end

-- getButtons() returns nil, not an empty table, when there are no buttons.
local function indexOf(obj, fname)
  local buttons = obj.getButtons()
  if not buttons then return nil end
  for _, button in ipairs(buttons) do
    if button.click_function == fname then return button.index end
  end
  return nil
end

-- index(obj, name) — the current index, for the escape hatch back to the raw
-- API.  Do not store it; read it again when you next need it.
function U.index(obj, name)
  if not obj then return nil end
  return indexOf(obj, clickName(obj, name))
end

-- button(obj, name, params) — create the named button, or edit it if it exists.
--
-- params are createButton's, minus click_function and function_owner, which are
-- generated, plus:
--   onClick  function(clicked_object, player_colour, alt_click)
--
-- alt_click is true on right-click: one button, two actions.
function U.button(obj, name, params)
  if not LOG.expect(obj, "ui.button: no object", name) then return nil end
  LOG.assert(type(name) == "string" and name ~= "", "ui.button needs a name")
  params = params or {}

  local owner = params.function_owner or env()
  local fname = clickName(obj, name)
  local handler = params.onClick

  if handler ~= nil and type(handler) ~= "function" then
    LOG.error("ui.button '" .. name .. "': onClick must be a function")
    handler = nil
  end
  -- A real no-op beats a deliberate typo as the click_function of a label.
  owner.setVar(fname, handler or function() end)

  local spec = {}
  for key, value in pairs(params) do
    if key ~= "onClick" and key ~= "function_owner" then
      spec[key] = value
    end
  end
  spec.click_function = fname
  spec.function_owner = owner

  local index = indexOf(obj, fname)
  if index then
    spec.index = index
    obj.editButton(spec)
  else
    obj.createButton(spec)
  end
  return name
end

-- label(obj, name, params) — text attached to an object.  There is no label
-- primitive in TTS: a button of width 0 and height 0 cannot be clicked and
-- renders as floating text.
function U.label(obj, name, params)
  -- Copy first: the caller's table is theirs, and a params table reused across
  -- objects would otherwise carry this label's width and font size onward.
  local spec = {}
  for key, value in pairs(params or {}) do spec[key] = value end
  spec.width = 0
  spec.height = 0
  spec.font_size = spec.font_size or U.LABEL_FONT_SIZE
  spec.label = spec.label or ""
  return U.button(obj, name, spec)
end

-- set(obj, name, params) — edit by name.  Reports loudly when the name is
-- unknown, instead of editing whichever button happens to hold that index.
function U.set(obj, name, params)
  if not LOG.expect(obj, "ui.set: no object", name) then return false end
  local index = indexOf(obj, clickName(obj, name))
  if index == nil then
    LOG.error("ui.set: no button named '" .. tostring(name) .. "' on this object",
      obj.getGUID and obj.getGUID())
    return false
  end
  -- Copy, so the caller's table does not go home carrying this object's index
  -- and silently edit the wrong button on the next one.
  local spec = {}
  for key, value in pairs(params or {}) do spec[key] = value end
  spec.index = index
  return obj.editButton(spec)
end

-- remove(obj, name) — removing an index shifts every higher index down by one,
-- which is why nothing here remembers indexes between calls.
function U.remove(obj, name)
  if not obj then return false end
  local index = indexOf(obj, clickName(obj, name))
  if index == nil then return false end
  return obj.removeButton(index)
end

function U.clear(obj)
  if not obj then return false end
  return obj.clearButtons()
end

-- unscale(obj) — button width, height and scale are in the object's local space,
-- so a board scaled 6x renders its buttons 6x too big.  Pass this as `scale` and
-- that is cancelled.  Y stays 1: a button is flat.
--
-- Whether `position` needs the same treatment is cookbook open question 4: the
-- API says only "relative to the Object's center", never in which units, and no
-- mod in the corpus puts buttons on a scaled object.  If positions turn out to
-- be post-scale they must be divided by the same factors; demo/Global.lua takes
-- the other reading deliberately.  Until it is tested in TTS, keep anchors at
-- scale 1 and the question does not arise.
function U.unscale(obj)
  local s = obj.getScale()
  return {
    x = (s.x ~= 0) and (1 / s.x) or 1,
    y = 1,
    z = (s.z ~= 0) and (1 / s.z) or 1,
  }
end

-- ------------------------------------------------------------------- XML UI
--
-- Screen-space panels, as opposed to world-space buttons.  These are one-line
-- wrappers whose only job is to route to the right UI object: the global UI for
-- the table, obj.UI for markup attached to an object.  Handler signature there
-- is (player, value, id), not the button one.
--
-- setXml replaces the whole root, so build the panel once and change it with
-- attr/attrs/value afterwards.

local function panel(target)
  return (target and target.UI) or UI
end
U.panel = panel

function U.xml(target, xml, assets)
  return panel(target).setXml(xml, assets)
end

function U.attr(target, id, attribute, value)
  return panel(target).setAttribute(id, attribute, value)
end

function U.attrs(target, id, values)
  return panel(target).setAttributes(id, values)
end

function U.value(target, id, value)
  return panel(target).setValue(id, value)
end

function U.show(target, id)
  return panel(target).show(id)
end

function U.hide(target, id)
  return panel(target).hide(id)
end
