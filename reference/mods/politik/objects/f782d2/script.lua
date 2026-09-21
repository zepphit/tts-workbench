function onLoad()
    self.createButton({
        click_function = "deletePlayerAreas",
        function_owner = self,
        label = "Delete vacant \n Player Areas",
        position = {0, 0.05, 3.5},
        width = 800,
        height = 300,
        font_size = 80,
        color = {30/255, 30/255, 30/255},  -- Dark Grey background
        font_color = {217/255, 217/255, 193/255}  -- Cream text
    })
    
    self.createButton({
        click_function = "refreshCameraButtons",
        function_owner = self,
        label = "Refresh Camera\nButtons",
        position = {0, 0.05, 2.7},
        width = 800,
        height = 300,
        font_size = 80,
        color = {30/255, 30/255, 30/255},  -- Dark Grey background
        font_color = {217/255, 217/255, 193/255}  -- Cream text
    })
end

function deletePlayerAreas()
    local deletedAreas = {}
    local playerColors = {"White", "Brown", "Red", "Orange", "Yellow", "Green", "Teal", "Blue", "Purple", "Pink", "Grey", "Black"}
    
    -- Objects to never delete
    local protectedGUIDs = {"45ce70"}
    
    -- Find all scripting zones
    local allZones = {}
    for _, obj in ipairs(getAllObjects()) do
        if obj.type == "Scripting" or obj.type == "ScriptingTrigger" then
            table.insert(allZones, obj)
        end
    end
    
    -- Get seated players
    local seatedPlayers = {}
    local seatedPlayersList = getSeatedPlayers()
    
    if seatedPlayersList then
        for _, seated in ipairs(seatedPlayersList) do
            seatedPlayers[seated] = true
        end
    end
    
    -- Helper function to check if object is protected
    local function isProtected(obj)
        for _, guid in ipairs(protectedGUIDs) do
            if obj.getGUID() == guid then
                return true
            end
        end
        return false
    end
    
    -- Process each zone
    for _, zone in ipairs(allZones) do
        local zoneName = zone.getName()
        
        -- Check if this zone's name matches a player color
        for _, color in ipairs(playerColors) do
            if zoneName == color then
                -- Check if this player is NOT seated
                if not seatedPlayers[color] then
                    local objectsInZone = zone.getObjects()
                    local deletedCount = 0
                    
                    for _, obj in ipairs(objectsInZone) do
                        if obj ~= self and not isProtected(obj) then
                            obj.destruct()
                            deletedCount = deletedCount + 1
                        end
                    end
                    
                    if deletedCount > 0 then
                        table.insert(deletedAreas, color .. " (" .. deletedCount .. " objects)")
                    end
                end
                break
            end
        end
    end
    
    -- Announce results
    if #deletedAreas > 0 then
        printToAll("Deleted player areas: " .. table.concat(deletedAreas, ", "), {1, 0.5, 0})
    else
        printToAll("No vacant player areas found with objects to delete.", {0.5, 0.5, 0.5})
    end
    
    -- Delete only the first button (Delete vacant Player Areas)
    Wait.time(function()
        self.removeButton(0)  -- Remove the first button (index 0)
    end, 1)
end

function refreshCameraButtons()
    -- Call the global function to create camera buttons
    Global.call("createCameraButtons")
    printToAll("Camera buttons refreshed based on seated players!", {0, 1, 0})
end