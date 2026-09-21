-- Variable to track confirmation state
local confirmationActive = false
-- Map player colors to their corresponding zone GUIDs
local playerZones = {
    Red = "c7fb8b",
    Blue = "532cbc",
    Green = "aa0e05",
    Yellow = "0d25b6",
    Brown = "e9fbd8",
    Purple = "886a19"
}
function readyButton(obj, playerColor, altClick)
    -- If not in confirmation state, activate confirmation
    if not confirmationActive then
        confirmationActive = true
        
        -- Check if player has a zone assigned
        if playerZones[playerColor] == nil then
            print("No zone assigned for " .. playerColor .. " player.")
            resetButton()
            return
        end
        
        print("Click Ready again to confirm deletion of activated cards.")
        
        -- Update button to show it's in confirmation mode
        self.editButton({
            index = 0,
            label = "Confirm?",
            color = {0/255, 0/255, 0/255, 1},  -- Black background
            font_color = {237/255, 230/255, 186/255, 1}  -- Beige text
        })
        
        -- Reset confirmation after 3 seconds if not clicked
        Wait.time(function()
            if confirmationActive then
                resetButton()
            end
        end, 3)
        
        return
    end
    
    -- If already in confirmation state, proceed with deletion
    local zoneGUID = playerZones[playerColor]
    
    if zoneGUID == nil then
        print("No zone assigned for " .. playerColor .. " player.")
        resetButton()
        return
    end
    
    local zone = getObjectFromGUID(zoneGUID)
    
    if zone == nil then
        print("Scripting zone not found for " .. playerColor .. " player! Check the GUID.")
        resetButton()
        return
    end
    
    -- Get all objects in the zone
    local objectsInZone = zone.getObjects()
    local deletedCount = 0
    
    -- Loop through all objects in the zone
    for _, obj in ipairs(objectsInZone) do
        -- Check if it's a card and has the "activated card" tag
        if obj.type == "Card" and obj.hasTag("activated card") then
            print("Deleting card: " .. obj.getName())
            obj.destruct()
            deletedCount = deletedCount + 1
        end
    end
    
    print(playerColor .. " player ready! Deleted " .. deletedCount .. " activated card(s).")
    
    -- Rotate all remaining cards to 180 degrees on Y axis
    local rotatedCount = 0
    local remainingObjects = zone.getObjects()
    
    for _, obj in ipairs(remainingObjects) do
        if obj.type == "Card" then
            local currentRotation = obj.getRotation()
            -- Check if the card is not at 180 degrees (y-axis rotation)
            if math.abs(currentRotation.y - 180) > 0.1 then
                obj.setRotationSmooth({currentRotation.x, 180, currentRotation.z})
                rotatedCount = rotatedCount + 1
            end
        end
    end
    
    print("Rotated " .. rotatedCount .. " card(s) to 180 degrees.")
    resetButton()
end
function resetButton()
    confirmationActive = false
    self.editButton({
        index = 0,
        label = "Ready\nCards",
        color = {0/255, 0/255, 0/255, 1},  -- Black background
        font_color = {237/255, 230/255, 186/255, 1}  -- Beige text
    })
end
-- Create the Ready button
function onLoad()
    confirmationActive = false
    self.createButton({
        click_function = "readyButton",
        function_owner = self,
        label = "Ready\nCards",
        position = {0, 0.5, 0},  
        width = 450,
        height = 450,
        font_size = 125,
        color = {0/255, 0/255, 0/255, 1},  -- Black background
        font_color = {237/255, 230/255, 186/255, 1}  -- Beige text
    })
end