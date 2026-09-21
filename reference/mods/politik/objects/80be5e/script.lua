-- Educate Price tracker configuration
local educateTokenGUID = "0de2b0"
local currentPriceIndex = 2

-- Price positions from left to right
local pricePositions = {
    {pos = {-6.73, 5.67, 9.15}, label = "Educate » Price 1"},
    {pos = {-6.29, 5.67, 9.15}, label = "Educate » Price 2"},
    {pos = {-5.86, 5.67, 9.14}, label = "Educate » Price 3"},
    {pos = {-5.43, 5.67, 9.16}, label = "Educate » Price 4"},
    {pos = {-4.99, 5.67, 9.15}, label = "Educate » Price 5"},
    {pos = {-4.56, 5.67, 9.15}, label = "Educate » Price 6"},
    {pos = {-4.13, 5.67, 9.14}, label = "Educate » Price 7"},
    {pos = {-3.70, 5.67, 9.14}, label = "Educate » Price 8"},
    {pos = {-3.25, 5.67, 9.15}, label = "Educate » Price 9"},
    {pos = {-2.82, 5.67, 9.15}, label = "Educate » Price 10"}
}

-- Move educate price token left
function moveEducatePriceLeft()
    if currentPriceIndex > 1 then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex - 1
        moveEducateToken(oldIndex, currentPriceIndex, "decreased")
    end
end

-- Move educate price token right
function moveEducatePriceRight()
    if currentPriceIndex < #pricePositions then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex + 1
        moveEducateToken(oldIndex, currentPriceIndex, "increased")
    end
end

-- Helper function to move the token and print message
function moveEducateToken(oldIndex, newIndex, changeType)
    local educateToken = getObjectFromGUID(educateTokenGUID)
    
    if not educateToken then
        printToAll("Error: Educate price token not found!", Color.Red)
        return
    end
    
    -- Move the token
    educateToken.setPositionSmooth(pricePositions[newIndex].pos, false, false)
    
    -- Calculate change
    local change = math.abs(newIndex - oldIndex)
    local changeSymbol = changeType == "increased" and "+" or "-"
    
    -- Pink color for educate (C86A8D)
    local educateColor = Color(0xC8/255, 0x6A/255, 0x8D/255)
    
    -- Format message
    local message = string.format("Educate Price %s%d (%d → %d)", 
        changeSymbol, change, oldIndex, newIndex)
    
    -- Print message with educate color
    printToAll(message, educateColor)
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
        click_function = "moveEducatePriceLeft",
        function_owner = self,
        label = "◄",
        position = {-0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[C86A8D]Decrease Educate Price"
    })
    
    -- Right arrow button
    self.createButton({
        click_function = "moveEducatePriceRight",
        function_owner = self,
        label = "►",
        position = {0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[C86A8D]Increase Educate Price"
    })
end