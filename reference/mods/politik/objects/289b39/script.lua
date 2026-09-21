function shuffleAndDealPolitik()
    -- Get the Politik Deck by GUID
    local deckGUID = "6dde1a"
    local deck = getObjectFromGUID(deckGUID)
    
    if deck == nil then
        print("Politik Deck not found! Check the GUID.")
        return
    end
    
    -- Shuffle the Politik deck
    deck.shuffle()
    print("[D9D9C1]Politik Deck shuffled!")
    
    -- Shuffle the Obligation deck (GUID: d75693)
    local obligationDeckGUID = "d75693"
    local obligationDeck = getObjectFromGUID(obligationDeckGUID)
    
    if obligationDeck ~= nil then
        obligationDeck.shuffle()
        print("[D9D9C1]Obligation Deck shuffled!")
    else
        print("Warning: Obligation Deck not found (GUID: " .. obligationDeckGUID .. ")!")
    end
    
    -- Wait for shuffle to complete
    Wait.time(function()
        local currentDeck = getObjectFromGUID(deckGUID)
        
        if currentDeck == nil then
            print("Deck disappeared after shuffle!")
            return
        end
        
        -- Get all seated players
        local seatedPlayers = getSeatedPlayers()
        
        if #seatedPlayers == 0 then
            print("No players seated!")
            return
        end
        
        print("Dealing 6 Politik cards to " .. #seatedPlayers .. " players")
        
        -- Deal 6 cards to each seated player
        for i = 1, 6 do
            for _, color in ipairs(seatedPlayers) do
                currentDeck.deal(1, color)
                Wait.time(function() end, 0.1)
            end
        end
        
        -- After dealing is complete, swap this button out for the
        -- "Who Goes First?" button in the exact same spot
        Wait.time(function()
            self.clearButtons()
            createWhoGoesFirstButton()
            print("[D9D9C1]Dealing complete - click 'Who Goes First?' to select the starting player!")
        end, 1.5)
        
    end, 0.5)
end

-- Creates the "Who Goes First?" button in the same position/style as the deal button
function createWhoGoesFirstButton()
    self.createButton({
        click_function = "determineWhoGoesFirst",
        function_owner = self,
        label = "Who Goes First?",
        position = {0, 0.05, 2.5},
        width = 1000,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255}
    })
end

-- Triggered by clicking "Who Goes First?"
function determineWhoGoesFirst()
    local seatedPlayers = getSeatedPlayers()
    
    if #seatedPlayers == 0 then
        print("No players seated!")
        return
    end
    
    selectRandomStartingPlayer(seatedPlayers)
    
    -- Delete the "Delete Setup Buttons" button
    local deleteButtonObj = getObjectFromGUID("2765dc")
    if deleteButtonObj ~= nil then
        deleteButtonObj.clearButtons()
    end
    
    -- Delete this button
    self.clearButtons()
    print("[D9D9C1]Button removed - starting player selection complete!")
end

function selectRandomStartingPlayer(seatedPlayers)
    -- Randomly select a starting player
    local randomIndex = math.random(1, #seatedPlayers)
    local startingPlayerColor = seatedPlayers[randomIndex]
    
    -- Disable turns first to prevent automatic announcement
    Turns.enable = false
    
    -- Set the starting player's turn
    Turns.turn_color = startingPlayerColor
    
    -- Now enable turns (this won't trigger an announcement since turn is already set)
    Turns.enable = true
    Turns.type = 1  -- Auto (normal turn order)
    
    -- Get player name for announcement
    local playerName = Player[startingPlayerColor].steam_name or startingPlayerColor
    
    -- Convert color to capitalized format for display
    local displayColor = startingPlayerColor:sub(1,1):upper() .. startingPlayerColor:sub(2)
    
    -- Announce in chat with the player's color
    local colorRGB = stringColorToRGB(startingPlayerColor)
    printToAll(displayColor .. " player starts the game!", colorRGB)
end

-- Helper function to convert color string to RGB
function stringColorToRGB(colorStr)
    local colors = {
        White = Color(1, 1, 1),
        Red = Color(0.856, 0.1, 0.094),
        Orange = Color(0.956, 0.392, 0.113),
        Yellow = Color(0.905, 0.898, 0.172),
        Green = Color(0.192, 0.701, 0.168),
        Blue = Color(0.118, 0.53, 1),
        Purple = Color(0.627, 0.125, 0.941),
        Pink = Color(0.96, 0.439, 0.807),
        Brown = Color(0.443, 0.231, 0.09),
        Grey = Color(0.5, 0.5, 0.5),
        Black = Color(0.25, 0.25, 0.25)
    }
    
    return colors[colorStr:sub(1,1):upper() .. colorStr:sub(2)] or Color(1, 1, 1)
end

-- Create a button to trigger this
function onLoad()
    self.createButton({
        click_function = "shuffleAndDealPolitik",
        function_owner = self,
        label = "Deal Politik Cards",
        position = {0, 0.05, 2.5},
        width = 1000,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255}
    })
end