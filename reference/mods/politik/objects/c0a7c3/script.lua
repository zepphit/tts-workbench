-- Mapping of Nation cards to their corresponding Propaganda cards
-- Replace these GUIDs with your actual card GUIDs
local nationToPropaganda = {
    ["ed969b"] = {"a08374", "b8ae90"}, -- Arden
    ["227485"] = {"c4c95e", "8fc32b"}, -- The Baaslands
    ["451e70"] = {"3e1b68", "d5b354"}, -- Centina
    ["b4887a"] = {"4901f2", "c91987"}, -- Gran Santi
    ["abb2b2"] = {"70f73a", "32fac2"}, -- Indoverra
    ["14282c"] = {"ef1f3d", "26f6bb"}, -- Libris
    ["b811c7"] = {"3b2ccd", "03f0a2"}, -- Isant Isay
    ["1355c9"] = {"397974", "233dd6"}, -- Mount Roq
    ["d44d94"] = {"58a7ac", "79451a"}, -- Neometro
    ["244181"] = {"a8b5d8", "d5971b"}, -- Rodgrod
    ["34861a"] = {"2fce62", "68d517"}, -- Ticca Republic
    ["e93999"] = {"67bf66", "9c439d"} -- UTP
}

function shuffleAndDealNations()
    -- Get the Nations Deck by GUID
    local deckGUID = "c6434d"
    local deck = getObjectFromGUID(deckGUID)
    
    if deck == nil then
        print("Nations Deck not found! Check the GUID.")
        return
    end
    
    -- Shuffle the deck
    deck.shuffle()
    print("[D9D9C1]Nations Deck shuffled!")
    
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
        
        print("Dealing 2 Nation cards to " .. #seatedPlayers .. " players")
        
        -- Track which cards are dealt to which players
        local dealtCards = {}
        
        -- Deal 2 cards to each seated player and track them
        for i = 1, 2 do
            for _, color in ipairs(seatedPlayers) do
                -- Get the top card's GUID before dealing
                local deckContents = currentDeck.getObjects()
                if #deckContents > 0 then
                    local topCardGUID = deckContents[1].guid
                    
                    -- Deal the card
                    currentDeck.deal(1, color)
                    
                    -- Track which player got this card
                    if not dealtCards[color] then
                        dealtCards[color] = {}
                    end
                    table.insert(dealtCards[color], topCardGUID)
                    
                    Wait.time(function() end, 0.1)
                end
            end
        end
        
        -- Wait for Nation cards to be dealt, then deal Propaganda cards
        Wait.time(function()
            dealPropagandaCards(dealtCards)
            
            -- Delete the button after everything is complete
            Wait.time(function()
                self.clearButtons()
                print("Button removed - dealing complete!")
            end, 1.0)
        end, 1.5)
        
    end, 0.5)
end

function dealPropagandaCards(dealtCards)
    print("[D9D9C1]Dealing Propaganda cards...")
    
    -- For each player and their dealt Nation cards
    for playerColor, nationCardGUIDs in pairs(dealtCards) do
        print("Dealing Propaganda to " .. playerColor)
        
        for _, nationGUID in ipairs(nationCardGUIDs) do
            -- Get the corresponding Propaganda card GUIDs
            local propagandaGUIDs = nationToPropaganda[nationGUID]
            
            if propagandaGUIDs then
                -- Deal both Propaganda cards for this Nation
                for _, propGUID in ipairs(propagandaGUIDs) do
                    local propCard = getObjectFromGUID(propGUID)
                    if propCard then
                        propCard.deal(1, playerColor)
                        Wait.time(function() end, 0.1)
                    else
                        print("Propaganda card " .. propGUID .. " not found!")
                    end
                end
            else
                print("No Propaganda mapping found for Nation card " .. nationGUID)
            end
        end
    end
    
    print("[D9D9C1]Propaganda dealing complete!")
end

-- Create a button to trigger this
function onLoad()
    self.createButton({
        click_function = "shuffleAndDealNations",
        function_owner = self,
        label = "Deal Nations",
        position = {0, 0.05, 2.5},
        width = 1000,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255}
    })
end