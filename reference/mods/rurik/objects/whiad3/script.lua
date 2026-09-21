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

local function getOwnerColorTag()
    -- Advisor tokens are tagged with one of these colours
    local colors = {"Blue","Yellow","Red","Purple"}
    for _,c in ipairs(colors) do
        if self.hasTag and self.hasTag(c) then return c end
    end
    return nil
end

function onLoad()
    if self.hasTag and not self.hasTag("Advisor") then return end
    if hasBribeButton() then return end

    -- Your token scale is {0.33, 1.00, 0.33} so a slightly lower Y usually looks nicer
    self.createButton({
        click_function = "Advisor_onBribePressed",
        function_owner = self,
        label          = "BRIBE",
        position       = {0, 0.18, 0},
        rotation       = {0, 0, 0},
        width          = 900,
        height         = 350,
        font_size      = 200,
        color          = {0.15, 0.15, 0.15, 0.95},
        font_color     = {1, 1, 1, 1},
        tooltip        = "Select this Advisor for bribe payment"
    })
end

function Advisor_onBribePressed(_, playerColor, alt_click)
    -- Optional restriction: only the token’s tagged colour can click BRIBE
    local owner = getOwnerColorTag()
    if owner and owner ~= playerColor then
        broadcastToColor("That Advisor belongs to "..owner..".", playerColor, {1,0.6,0.2})
        return
    end

    Global.call("AdvisorPay_proxyBribe", {
        guid = self.getGUID(),
        playerColor = playerColor,
        alt_click = alt_click
    })
end
