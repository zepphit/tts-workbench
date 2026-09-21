-- ============================================================
-- ADVISOR PAY PANEL (Object Script)
-- Builds +/- / TOTAL / PAY / CANCEL on itself.
-- Forwards clicks to Global (AdvisorPay service).
-- ============================================================

local TOTAL_INDEX = nil

local function buildUI()
    self.clearButtons()

    local BTN_Y  = 0.25
    local ROW1_Z = 0.80
    local ROW2_Z = 0.05
    local ROW3_Z = -0.70

    -- Row 1: +/- buttons
    local spacing = 1.25
    local startX  = -((6 - 1) * spacing) / 2

    local btns = {
        {label="-5", delta=-5},
        {label="-2", delta=-2},
        {label="-1", delta=-1},
        {label="+1", delta= 1},
        {label="+2", delta= 2},
        {label="+5", delta= 5},
    }

    for i,b in ipairs(btns) do
        local d = b.delta
        local fnName = "AdvisorPayPanel_delta_" .. tostring(d)

        -- define per-button handler
        _G[fnName] = function(_, playerColor, alt_click)
            Global.call("AdvisorPay_panelAdjust", { delta = d })
        end

        self.createButton({
            click_function = fnName,
            function_owner = Global, -- IMPORTANT: functions live on Global environment
            label          = b.label,
            position       = { startX + spacing*(i-1), BTN_Y, ROW1_Z },
            rotation       = {0,180,0},
            width          = 520,
            height         = 360,
            font_size      = 185,
            color          = {0.2,0.2,0.2,0.95},
            font_color     = {1,1,1,1},
            tooltip        = "Adjust bribe total"
        })
    end

    -- Row 2: TOTAL label
    self.createButton({
        click_function = "noop",
        function_owner = Global,
        label          = "TOTAL: 0",
        position       = {0, BTN_Y, ROW2_Z},
        rotation       = {0,180,0},
        width          = 1800,
        height         = 320,
        font_size      = 210,
        color          = {0,0,0,0.8},
        font_color     = {1,1,1,1},
        tooltip        = ""
    })
    TOTAL_INDEX = #self.getButtons()

    -- Row 3: CANCEL / PAY
    self.createButton({
        click_function = "AdvisorPayPanel_cancel",
        function_owner = Global,
        label          = "CANCEL",
        position       = {-1.35, BTN_Y, ROW3_Z},
        rotation       = {0,180,0},
        width          = 950,
        height         = 380,
        font_size      = 200,
        color          = {0.55,0.2,0.2,0.95},
        font_color     = {1,1,1,1},
        tooltip        = "Clear selection and total"
    })

    self.createButton({
        click_function = "AdvisorPayPanel_pay",
        function_owner = Global,
        label          = "PAY",
        position       = {1.35, BTN_Y, ROW3_Z},
        rotation       = {0,180,0},
        width          = 950,
        height         = 380,
        font_size      = 200,
        color          = {0.2,0.55,0.2,0.95},
        font_color     = {1,1,1,1},
        tooltip        = "Take coins from your bag and place onto the selected Advisor"
    })
end

-- Global-owned handlers (since function_owner = Global)
function AdvisorPayPanel_cancel(_, playerColor, alt_click)
    Global.call("AdvisorPay_panelCancel", { playerColor = playerColor })
end

function AdvisorPayPanel_pay(_, playerColor, alt_click)
    Global.call("AdvisorPay_panelPay", { playerColor = playerColor })
end

-- Called by Global to update the TOTAL label
function AdvisorPayPanel_setTotal(params)
    if not TOTAL_INDEX then return end
    local total = 0
    if type(params) == "table" and params.total ~= nil then
        total = tonumber(params.total) or 0
    end
    self.editButton({ index = TOTAL_INDEX, label = "TOTAL: " .. tostring(total) })
end

function onLoad()
    buildUI()

    -- Register with Global so it knows how to update TOTAL without scanning
    Global.call("AdvisorPay_registerPanel", { guid = self.getGUID() })
end
