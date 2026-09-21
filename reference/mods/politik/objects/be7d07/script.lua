-- Campaign Price tracker configuration
local campaignTokenGUID = "c4224f"
local currentPriceIndex = 5

-- Price positions from left to right
local pricePositions = {
    {pos = {-6.74, 5.67, 10.16}, label = "Campaign » Price 1"},
    {pos = {-6.28, 5.67, 10.15}, label = "Campaign » Price 2"},
    {pos = {-5.86, 5.67, 10.15}, label = "Campaign » Price 3"},
    {pos = {-5.42, 5.67, 10.15}, label = "Campaign » Price 4"},
    {pos = {-5.00, 5.67, 10.15}, label = "Campaign » Price 5"},
    {pos = {-4.56, 5.67, 10.15}, label = "Campaign » Price 6"},
    {pos = {-4.12, 5.67, 10.15}, label = "Campaign » Price 7"},
    {pos = {-3.69, 5.67, 10.15}, label = "Campaign » Price 8"},
    {pos = {-3.25, 5.67, 10.16}, label = "Campaign » Price 9"},
    {pos = {-2.83, 5.67, 10.16}, label = "Campaign » Price 10"}
}

-- Move campaign price token left
function moveCampaignPriceLeft()
    if currentPriceIndex > 1 then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex - 1
        moveCampaignToken(oldIndex, currentPriceIndex, "decreased")
    end
end

-- Move campaign price token right
function moveCampaignPriceRight()
    if currentPriceIndex < #pricePositions then
        local oldIndex = currentPriceIndex
        currentPriceIndex = currentPriceIndex + 1
        moveCampaignToken(oldIndex, currentPriceIndex, "increased")
    end
end

-- Helper function to move the token and print message
function moveCampaignToken(oldIndex, newIndex, changeType)
    local campaignToken = getObjectFromGUID(campaignTokenGUID)
    
    if not campaignToken then
        printToAll("Error: Campaign price token not found!", Color.Red)
        return
    end
    
    -- Move the token
    campaignToken.setPositionSmooth(pricePositions[newIndex].pos, false, false)
    
    -- Calculate change
    local change = math.abs(newIndex - oldIndex)
    local changeSymbol = changeType == "increased" and "+" or "-"
    
    -- Light blue color for campaign (7B88C5)
    local campaignColor = Color(0x7B/255, 0x88/255, 0xC5/255)
    
    -- Format message
    local message = string.format("Campaign Price %s%d (%d → %d)", 
        changeSymbol, change, oldIndex, newIndex)
    
    -- Print message with campaign color
    printToAll(message, campaignColor)
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
        click_function = "moveCampaignPriceLeft",
        function_owner = self,
        label = "◄",
        position = {-0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[7B88C5]Decrease Campaign Price"
    })
    
    -- Right arrow button
    self.createButton({
        click_function = "moveCampaignPriceRight",
        function_owner = self,
        label = "►",
        position = {0.45, 1, 0},
        rotation = {0, 0, 0},
        width = 400,
        height = 300,
        font_size = 150,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "[7B88C5]Increase Campaign Price"
    })
end