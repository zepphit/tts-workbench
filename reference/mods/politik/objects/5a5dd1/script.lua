-- Button function to clean up cards and tokens
function cleanupLeadersAndCards()
    -- Scripted Zone GUID
    local scriptedZoneGUID = "7286eb"
    
    -- Position for discarding politik cards
    local discardPosition = {12.50, 6.52, 14.25}
    
    -- Additional objects to move
    local objectsToMove = {
        {guid = "a12779", position = {14.26, 6, 8.10}},
        {guid = "dfbaeb", position = {14.26, 6, 7.16}}
    }
    
    -- Bag GUIDs
    local bags = {
        corp = "fe9d6e",
        military = "347ef4",
        political = "6953bb"
    }
    
    -- Counters
    local counts = {
        politikCard = 0,
        corpLeader = 0,
        militaryLeader = 0,
        politicalLeader = 0
    }
    
    -- Get the scripted zone
    local scriptedZone = getObjectFromGUID(scriptedZoneGUID)
    if not scriptedZone then
        printToAll("Error: Scripted Zone not found!", Color.Red)
        return
    end
    
    -- Move specific objects to their positions
    for _, objData in ipairs(objectsToMove) do
        local obj = getObjectFromGUID(objData.guid)
        if obj then
            obj.setPositionSmooth(objData.position, false, false)
        else
            printToAll("Warning: Object " .. objData.guid .. " not found!", Color.Orange)
        end
    end
    
    -- Get the bag objects
    local bagObjects = {
        corp = getObjectFromGUID(bags.corp),
        military = getObjectFromGUID(bags.military),
        political = getObjectFromGUID(bags.political)
    }
    
    -- Validate bags exist
    local missingBags = {}
    for bagType, bagObj in pairs(bagObjects) do
        if not bagObj then
            table.insert(missingBags, bagType)
        end
    end
    
    if #missingBags > 0 then
        printToAll("Warning: Missing bags: " .. table.concat(missingBags, ", "), Color.Orange)
    end
    
    -- Get all objects in the scripted zone
    local objectsInZone = scriptedZone.getObjects()
    
    if #objectsInZone == 0 then
        printToAll("No objects found in cleanup zone.", Color.Yellow)
        return
    end
    
    -- Process each object in the zone
    for _, obj in ipairs(objectsInZone) do
        -- Skip if object is being held
        if not obj.held_by_color then
            local tags = obj.getTags()
            local processed = false
            
            -- Check tags and process accordingly
            for _, tag in ipairs(tags) do
                if tag == "politik card" and not processed then
                    obj.setRotation({0, 270, 180})
                    obj.setPositionSmooth(discardPosition, false, false)
                    
                    -- Count individual cards in deck or single card
                    if obj.type == "Deck" then
                        counts.politikCard = counts.politikCard + #obj.getObjects()
                    else
                        counts.politikCard = counts.politikCard + 1
                    end
                    processed = true
                    break
                    
                elseif tag == "corp leader" and bagObjects.corp and not processed then
                    bagObjects.corp.putObject(obj)
                    counts.corpLeader = counts.corpLeader + 1
                    processed = true
                    break
                    
                elseif tag == "military leader" and bagObjects.military and not processed then
                    bagObjects.military.putObject(obj)
                    counts.militaryLeader = counts.militaryLeader + 1
                    processed = true
                    break
                    
                elseif tag == "political leader" and bagObjects.political and not processed then
                    bagObjects.political.putObject(obj)
                    counts.politicalLeader = counts.politicalLeader + 1
                    processed = true
                    break
                end
            end
        end
    end
    
    -- Announce results
    local message = string.format(
        "Cleanup Complete:\n" ..
        "Politik Cards discarded: %d\n" ..
        "Corp Leaders returned: %d\n" ..
        "Military Leaders returned: %d\n" ..
        "Political Leaders returned: %d",
        counts.politikCard, counts.corpLeader, 
        counts.militaryLeader, counts.politicalLeader
    )
    
    printToAll(message, Color.White)
end

-- Function to fan decks
function fanDeck()
    -- Scripted Zone GUID
    local scriptedZoneGUID = "7286eb"
    
    -- Fan Deck script object GUID
    local fanDeckScriptGUID = "d34970"
    
    -- Get the scripted zone
    local scriptedZone = getObjectFromGUID(scriptedZoneGUID)
    if not scriptedZone then
        printToAll("Error: Scripted Zone not found!", Color.Red)
        return
    end
    
    -- Get the fan deck script object
    local fanDeckScript = getObjectFromGUID(fanDeckScriptGUID)
    if not fanDeckScript then
        printToAll("Error: Fan Deck script not found!", Color.Red)
        return
    end
    
    -- Get all objects in the scripted zone
    local objectsInZone = scriptedZone.getObjects()
    
    -- Find card stacks
    local cardStacks = {}
    for _, obj in ipairs(objectsInZone) do
        if obj.type == "Deck" or obj.type == "Card" then
            table.insert(cardStacks, obj)
        end
    end
    
    -- Check if we have any stacks
    if #cardStacks == 0 then
        printToAll("No card stacks found in the zone", Color.Orange)
        return
    end
    
    -- Fan all card stacks with delays
    local player = Player.getPlayers()[1] -- Get first seated player
    
    for i, stack in ipairs(cardStacks) do
        Wait.time(function()
            fanDeckScript.call("explodeStack", {
                player = player,
                triggerObj = stack
            })
        end, (i - 1) * 0.5)
    end
    
    printToAll("Fanning " .. #cardStacks .. " card stack(s)", Color.Yellow)
end

-- Create buttons on load
function onLoad()
    -- Cleanup button
    self.createButton({
        click_function = "cleanupLeadersAndCards",
        function_owner = self,
        label = "Cleanup",
        position = {0, 0.05, 2.65},
        rotation = {0, 0, 0},
        width = 800,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "Return leaders to bags and discard politik cards"
    })
    
    -- Fan Deck button
    self.createButton({
        click_function = "fanDeck",
        function_owner = self,
        label = "Fan Decks",
        position = {0, 0.05, 1.75},
        rotation = {0, 0, 0},
        width = 800,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255},
        font_color = {0, 0, 0},
        tooltip = "Click to fan focus card stacks and resolve clash"
    })
end