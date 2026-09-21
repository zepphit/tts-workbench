function deleteSetupButtons()
    -- Replace these with the actual GUIDs of your 5 button objects
    local buttonObjects = {
        "4817be",
        "c0a7c3",
        "fb0a83",
        "289b39",
        "f782d2"
    }
    
    -- Delete the button from each object
    for _, guid in ipairs(buttonObjects) do
        local obj = getObjectFromGUID(guid)
        
        if obj ~= nil then
            obj.clearButtons()
        else
            print("Warning: Object with GUID " .. guid .. " not found!")
        end
    end
    
    printToAll("All Setup Buttons deleted", {217/255, 217/255, 193/255})
    
    -- Delete this button itself
    self.clearButtons()
end

function onLoad()
    self.createButton({
        click_function = "deleteSetupButtons",
        function_owner = self,
        label = "Delete Setup Buttons",
        position = {0, 0.05, 2.8},
        width = 800,
        height = 300,
        font_size = 80,
        color = {30/255, 30/255, 30/255},  -- Dark Grey background
        font_color = {217/255, 217/255, 193/255}  -- Cream text
    })
end