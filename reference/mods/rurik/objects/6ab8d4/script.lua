-- Inventory Bag Script (per-player, per-resource)
-- Tags on THIS bag must include:
--   one of: Coin/Fur/Wood/Fish/Honey/Ore
--   one of: Blue/White/Yellow/Red  (optional, not required here)
--
-- Global must contain: requestResourceToBag({destBag=self, amount=1})

val = val or 0

local function findByTag(tag)
    for _,o in ipairs(getAllObjects()) do
        if o and o.hasTag(tag) then return o end
    end
    return nil
end

function onLoad(saveinf)
    if saveinf and #saveinf > 0 then
        local t = JSON.decode(saveinf)
        val = tonumber(t.val) or 0
    else
        val = 0
    end

    local funcName = "InvClick"

    local func = function(_, playerColor, alt_click)
        -- alt_click == true means RIGHT click on a TTS button
        if alt_click then
            removeOneToTrash()
        else
            addOneFromSupply()
        end
    end
    self.setVar(funcName, func)

    -- Invisible click button
    self.createButton({
        click_function = funcName,
        function_owner = self,
        position = {0,0,0},
        rotation = {0,0,0},
        height = 220,
        width = 220,
        font_size = 0
    })

    -- Counter label
    self.createButton({
        click_function = "DoNothing",
        function_owner = self,
        label = tostring(val),
        font_color = "White",
        position = {0,0,-1.6},
        rotation = {0,0,0},
        height = 0,
        width = 0,
        font_size = 570
    })
end

function onSave()
    return JSON.encode({ val = val })
end

function DoNothing() end

-- When a token enters this bag, increase counter
function onObjectEnterContainer(container, obj)
    if container ~= self then return end
    val = math.min(val + 1, 768)
    self.editButton({ index = 1, label = tostring(val) })
end

-- When a token leaves this bag, decrease counter
function onObjectLeaveContainer(container, obj)
    if container ~= self then return end
    val = math.max(val - 1, 0)
    self.editButton({ index = 1, label = tostring(val) })
end

function addOneFromSupply()
    -- Call your Global function to pull 1 from the correct supply bag into THIS bag.
    if Global and Global.call then
        Global.call("requestResourceToBag", { destBag = self, amount = 1 })
    end
end

function removeOneToTrash()
    local trash = findByTag("Trash")
    if not trash or trash.type ~= "Bag" then
        broadcastToAll("TRASH: No bag tagged 'Trash' found.", {1,0.3,0.3})
        return
    end

    -- Take one object out of this bag and put into trash
    self.takeObject({
        position = self.getPosition() + Vector(0,2,0),
        smooth = false,
        callback_function = function(obj)
            if obj and not obj.isDestroyed() then
                trash.putObject(obj)
            end
        end,
        callback_owner = self
    })
end
