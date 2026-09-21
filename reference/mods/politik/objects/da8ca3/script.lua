-- Carbon Price tracker configuration
local carbonTokenGUID = "ecb229"
local currentPriceIndex = 5

-- Price positions from left to right
local pricePositions = {
    {pos = {-6.73, 5.67, 11.16}, label = "Carbon Price 1"},
    {pos = {-6.29, 5.67, 11.15}, label = "Carbon Price 2"},
    {pos = {-5.86, 5.67, 11.15}, label = "Carbon Price 3"},
    {pos = {-5.43, 5.67, 11.15}, label = "Carbon Price 4"},
    {pos = {-4.99, 5.67, 11.15}, label = "Carbon Price 5"},
    {pos = {-4.55, 5.67, 11.15}, label = "Carbon Price 6"},
    {pos = {-4.13, 5.67, 11.15}, label = "Carbon Price 7"},
    {pos = {-3.68, 5.67, 11.16}, label = "Carbon Price 8"},
    {pos = {-3.26, 5.67, 11.16}, label = "Carbon Price 9"},
    {pos = {-2.82, 5.67, 11.15}, label = "Carbon Price 10"}
}

-- Move carbon price token left
function moveCarbonPriceLeft()
    if currentPriceIndex > 1 then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex - 1
        moveCarbonToken(oldIndex, currentPriceIndex, "decreased")
    end
end

-- Move carbon price token right
function moveCarbonPriceRight()
    if currentPriceIndex < #pricePositions then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex + 1
        moveCarbonToken(oldIndex, currentPriceIndex, "increased")
    end
end

-- Helper function to move the token and print message
function moveCarbonToken(oldIndex, newIndex, changeType)
    local carbonToken = getObjectFromGUID(carbonTokenGUID)
    
    if not carbonToken then
        printToAll("Error: Carbon price token not found!", Color.Red)
        return
    end
    
    -- Move the token
    carbonToken.setPositionSmooth(pricePositions[newIndex].pos, false, false)
    
    -- Calculate change
    local change = math.abs(newIndex - oldIndex)
    local changeSymbol = changeType == "increased" and "+" or "-"
    
    -- Light grey color for carbon
    local carbonColor = Color(0.8, 0.8, 0.8)
    
    -- Format message
    local message = string.format("Carbon Price %s%d (%d → %d)", 
        changeSymbol, change, oldIndex, newIndex)
    
    -- Print message with carbon color
    printToAll(message, carbonColor)
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
        click_function = "moveCarbonPriceLeft",
        function_owner = self,
        label = "◄",
        position = {-0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[A9A9A9]Decrease Carbon Price"
    })
    
    -- Right arrow button
    self.createButton({
        click_function = "moveCarbonPriceRight",
        function_owner = self,
        label = "►",
        position = {0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[A9A9A9]Increase Carbon Price"
    })
end