-- ObjectScript.lua — the template for a script attached to a component.
--
-- Architectural rule 1: one bundle, thin object scripts.  A library compiled
-- into many objects is Arcs' problem — 16 of its modules exist in two to four
-- slots each, byte-identical until somebody edits one of them and the other
-- three keep resolving the old values with no error (critique C5).  So ttslib
-- lives in Global, once, and this file stays short enough to read in full.
--
-- Before you paste this onto an object, ask whether it needs a script at all.
-- Behaviour that varies by component belongs in a tag and a config table in
-- Global, registered once through ttslib.events (C6).  RotLA has 51 copies of
-- the same 997-character bag script; a one-line fix there is a 51-site edit.
--
-- What is left for an object script is the case where the object itself is the
-- subject: a button on this component, its own persisted state.

-- Global's onLoad has not run yet when this fires — object scripts load first —
-- so anything that needs Global waits a frame.
function onLoad(script_state)
  Wait.frames(function()
    -- Buttons are not saved with the object, so build them on every load.  The
    -- click function is named and owned here, in the same file as its
    -- definition: function_owner and the definition must never drift apart,
    -- which is what leaves four of Rurik's advisor buttons inert (live bug 3).
    self.createButton({
      click_function = "onComponentClick",
      function_owner = self,
      label = "",
      position = { 0, 0.3, 0 },
      width = 400,
      height = 400,
      color = { 1, 1, 1, 0 }, -- invisible click target
    })
  end, 1)
end

-- Delegate in a line or two.  componentClicked is one of the named functions on
-- Global's bus; keep that list short and keep the payload a plain table.
function onComponentClick(clickedObject, playerColour, altClick)
  Global.call("componentClicked", {
    guid = self.getGUID(),
    colour = playerColour,
    alt = altClick,
  })
end

-- If this component genuinely owns state, declare it the same way Global does.
-- Global.call cannot return a table, so keep what crosses the bus to strings,
-- numbers and booleans.
--
-- function onSave()
--   return JSON.encode({ v = 1, used = used })
-- end
