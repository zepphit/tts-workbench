-- Food Price tracker configuration
local foodTokenGUID = "e9ed5e"
local currentPriceIndex = 8

-- Price positions from left to right
local pricePositions = {
    {pos = {-6.73, 5.67, 11.66}, label = "Food » Price 1"},
    {pos = {-6.29, 5.67, 11.66}, label = "Food » Price 2"},
    {pos = {-5.85, 5.67, 11.65}, label = "Food » Price 3"},
    {pos = {-5.42, 5.67, 11.65}, label = "Food » Price 4"},
    {pos = {-4.99, 5.67, 11.65}, label = "Food » Price 5"},
    {pos = {-4.55, 5.67, 11.65}, label = "Food » Price 6"},
    {pos = {-4.12, 5.67, 11.66}, label = "Food » Price 7"},
    {pos = {-3.69, 5.67, 11.65}, label = "Food » Price 8"},
    {pos = {-3.25, 5.67, 11.65}, label = "Food » Price 9"},
    {pos = {-2.82, 5.67, 11.66}, label = "Food » Price 10"}
}

-- Move food price token left
function moveFoodPriceLeft()
    if currentPriceIndex > 1 then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex - 1
        moveFoodToken(oldIndex, currentPriceIndex, "decreased")
    end
end

-- Move food price token right
function moveFoodPriceRight()
    if currentPriceIndex < #pricePositions then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex + 1
        moveFoodToken(oldIndex, currentPriceIndex, "increased")
    end
end

-- Helper function to move the token and print message
function moveFoodToken(oldIndex, newIndex, changeType)
    local foodToken = getObjectFromGUID(foodTokenGUID)
    
    if not foodToken then
        printToAll("Error: Food price token not found!", Color.Red)
        return
    end
    
    -- Move the token
    foodToken.setPositionSmooth(pricePositions[newIndex].pos, false, false)
    
    -- Calculate change
    local change = math.abs(newIndex - oldIndex)
    local changeSymbol = changeType == "increased" and "+" or "-"
    
    -- Light green color for food
    local foodColor = Color(0.6, 1, 0.6)
    
    -- Format message
    local message = string.format("Food Price %s%d (%d → %d)", 
        changeSymbol, change, oldIndex, newIndex)
    
    -- Print message with food color
    printToAll(message, foodColor)
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
        click_function = "moveFoodPriceLeft",
        function_owner = self,
        label = "◄",
        position = {-0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[95CE93]Decrease Food Price"
    })
    
    -- Right arrow button
    self.createButton({
        click_function = "moveFoodPriceRight",
        function_owner = self,
        label = "►",
        position = {0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[95CE93]Increase Food Price"
    })
end