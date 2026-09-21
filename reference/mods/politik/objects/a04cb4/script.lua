-- Research Price tracker configuration
local researchTokenGUID = "9e42a2"
local currentPriceIndex = 5

-- Price positions from left to right
local pricePositions = {
    {pos = {-6.72, 5.67, 10.65}, label = "Research Price 1"},
    {pos = {-6.29, 5.67, 10.64}, label = "Research Price 2"},
    {pos = {-5.86, 5.67, 10.65}, label = "Research Price 3"},
    {pos = {-5.42, 5.67, 10.66}, label = "Research Price 4"},
    {pos = {-4.99, 5.67, 10.65}, label = "Research Price 5"},
    {pos = {-4.57, 5.67, 10.66}, label = "Research Price 6"},
    {pos = {-4.14, 5.67, 10.66}, label = "Research Price 7"},
    {pos = {-3.69, 5.67, 10.66}, label = "Research Price 8"},
    {pos = {-3.26, 5.67, 10.65}, label = "Research Price 9"},
    {pos = {-2.83, 5.67, 10.65}, label = "Research Price 10"}
}

-- Move research price token left
function moveResearchPriceLeft()
    if currentPriceIndex > 1 then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex - 1
        moveResearchToken(oldIndex, currentPriceIndex, "decreased")
    end
end

-- Move research price token right
function moveResearchPriceRight()
    if currentPriceIndex < #pricePositions then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex + 1
        moveResearchToken(oldIndex, currentPriceIndex, "increased")
    end
end

-- Helper function to move the token and print message
function moveResearchToken(oldIndex, newIndex, changeType)
    local researchToken = getObjectFromGUID(researchTokenGUID)
    
    if not researchToken then
        printToAll("Error: Research price token not found!", Color.Red)
        return
    end
    
    -- Move the token
    researchToken.setPositionSmooth(pricePositions[newIndex].pos, false, false)
    
    -- Calculate change
    local change = math.abs(newIndex - oldIndex)
    local changeSymbol = changeType == "increased" and "+" or "-"
    
    -- Light blue color for research (7ABCD1)
    local researchColor = Color(0x7A/255, 0xBC/255, 0xD1/255)
    
    -- Format message
    local message = string.format("Research Price %s%d (%d → %d)", 
        changeSymbol, change, oldIndex, newIndex)
    
    -- Print message with research color
    printToAll(message, researchColor)
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
        click_function = "moveResearchPriceLeft",
        function_owner = self,
        label = "◄",
        position = {-0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[7ABCD1]Decrease Research Price"
    })
    
    -- Right arrow button
    self.createButton({
        click_function = "moveResearchPriceRight",
        function_owner = self,
        label = "►",
        position = {0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[7ABCD1]Increase Research Price"
    })
end