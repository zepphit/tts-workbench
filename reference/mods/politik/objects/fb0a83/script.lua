function shuffleAndDealCompany()
    -- Get the Startup Company Deck by GUID
    local deckGUID = "2629ce"
    local deck = getObjectFromGUID(deckGUID)
    
    if deck == nil then
        print("Startup Company Deck not found! Check the GUID.")
        return
    end
    
    -- Shuffle the deck
    deck.shuffle()
    print("[D9D9C1]Startup Company Deck shuffled!")
    
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
        
        print("Dealing 1 Startup Company card to " .. #seatedPlayers .. " players")
        
        -- Deal 1 card to each seated player
        for _, color in ipairs(seatedPlayers) do
            currentDeck.deal(1, color)
            Wait.time(function() end, 0.1)
        end
        
        -- Delete the button after dealing is complete
        Wait.time(function()
            self.clearButtons()
            print("[D9D9C1]Button removed - Startup Company dealing complete!")
        end, 1.0)
        
    end, 0.5)
end

-- Create a button to trigger this
function onLoad()
    self.createButton({
        click_function = "shuffleAndDealCompany",
        function_owner = self,
        label = "Deal Startup Company",
        position = {0, 0.05, 2.5},
        width = 1000,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255}
    })
end