-- Clash Price tracker configuration
local clashTokenGUID = "3ddb37"
local currentPriceIndex = 2

-- Price positions from left to right
local pricePositions = {
    {pos = {-6.72, 5.67, 9.66}, label = "Clash » Price 1"},
    {pos = {-6.29, 5.67, 9.65}, label = "Clash » Price 2"},
    {pos = {-5.86, 5.67, 9.66}, label = "Clash » Price 3"},
    {pos = {-5.43, 5.67, 9.65}, label = "Clash » Price 4"},
    {pos = {-4.99, 5.67, 9.65}, label = "Clash » Price 5"},
    {pos = {-4.56, 5.67, 9.65}, label = "Clash » Price 6"},
    {pos = {-4.13, 5.67, 9.66}, label = "Clash » Price 7"},
    {pos = {-3.69, 5.67, 9.66}, label = "Clash » Price 8"},
    {pos = {-3.26, 5.67, 9.65}, label = "Clash » Price 9"},
    {pos = {-2.82, 5.67, 9.65}, label = "Clash » Price 10"}
}

-- Move clash price token left
function moveClashPriceLeft()
    if currentPriceIndex > 1 then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex - 1
        moveClashToken(oldIndex, currentPriceIndex, "decreased")
    end
end

-- Move clash price token right
function moveClashPriceRight()
    if currentPriceIndex < #pricePositions then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex + 1
        moveClashToken(oldIndex, currentPriceIndex, "increased")
    end
end

-- Helper function to move the token and print message
function moveClashToken(oldIndex, newIndex, changeType)
    local clashToken = getObjectFromGUID(clashTokenGUID)
    
    if not clashToken then
        printToAll("Error: Clash price token not found!", Color.Red)
        return
    end
    
    -- Move the token
    clashToken.setPositionSmooth(pricePositions[newIndex].pos, false, false)
    
    -- Calculate change
    local change = math.abs(newIndex - oldIndex)
    local changeSymbol = changeType == "increased" and "+" or "-"
    
    -- Red color for clash (D64949)
    local clashColor = Color(0xD6/255, 0x49/255, 0x49/255)
    
    -- Format message
    local message = string.format("Clash Price %s%d (%d → %d)", 
        changeSymbol, change, oldIndex, newIndex)
    
    -- Print message with clash color
    printToAll(message, clashColor)
end

-- Save current price index
function onSave()
    return JSON.encode({priceIndex = currentPriceIndex})
end

-- Create buttons on load
function onLoad(saved_data)
    -- Restore saved price index if it exists
    if saved_data and saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.priceIndex then
            currentPriceIndex = loaded_data.priceIndex
        end
    end
    
    -- Left arrow button
    self.createButton({
        click_function = "moveClashPriceLeft",
        function_owner = self,
        label = "◄",
        position = {-0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[D64949]Decrease Clash Price"
    })
    
    -- Right arrow button
    self.createButton({
        click_function = "moveClashPriceRight",
        function_owner = self,
        label = "►",
        position = {0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[D64949]Increase Clash Price"
    })
end