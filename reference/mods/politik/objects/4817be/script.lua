function setupLandscape()
    -- Get the deck by GUID
    local deckGUID = "652542"
    local deck = getObjectFromGUID(deckGUID)
    
    if deck == nil then
        print("Landscape Deck not found! Check the GUID.")
        return
    end
    
    -- Step 1: Remove top card, shuffle the deck, then put it back
    local topCard = deck.takeObject({
        position = {deck.getPosition()[1], deck.getPosition()[2] + 3, deck.getPosition()[3]},
        smooth = false
    })
    
    Wait.time(function()
        local currentDeck = getObjectFromGUID(deckGUID)
        
        if currentDeck == nil then
            print("Deck disappeared!")
            return
        end
        
        currentDeck.shuffle()
        print("[D9D9C1]Landscape Deck shuffled!")
        
        -- Put the top card back on top
        Wait.time(function()
            local deckAfterShuffle = getObjectFromGUID(deckGUID)
            
            if deckAfterShuffle ~= nil and topCard ~= nil then
                deckAfterShuffle.putObject(topCard)
            end
            
            -- Step 2: Wait for shuffle to complete, then draw first card (second from top)
            Wait.time(function()
                local currentDeck = getObjectFromGUID(deckGUID)
                
                if currentDeck == nil then
                    print("Deck disappeared after shuffle!")
                    return
                end
                
                -- Remove top card temporarily
                local tempTopCard1 = currentDeck.takeObject({
                    position = {currentDeck.getPosition()[1], currentDeck.getPosition()[2] + 3, currentDeck.getPosition()[3]},
                    smooth = false
                })
                
                Wait.time(function()
                    local deckForFirstDraw = getObjectFromGUID(deckGUID)
                    
                    if deckForFirstDraw == nil then
                        print("Deck disappeared!")
                        return
                    end
                    
                    -- Randomly decide if first card should be flipped (50/50 chance)
                    local shouldFlip1 = math.random(1, 2) == 1
                    
                    -- Take the second card (now top) and place it at the position
                    local card1 = deckForFirstDraw.takeObject({
                        position = {-11.32, 5.68, -6.15},
                        smooth = true,
                        flip = shouldFlip1
                    })
                    
                    -- Put the top card back
                    Wait.time(function()
                        local deckAfterFirstDraw = getObjectFromGUID(deckGUID)
                        if deckAfterFirstDraw ~= nil and tempTopCard1 ~= nil then
                            deckAfterFirstDraw.putObject(tempTopCard1)
                        end
                    end, 0.2)
                    
                    if shouldFlip1 then
                        print("Drew first card and flipped it")
                    else
                        print("Drew first card (not flipped)")
                    end
                    
                    -- Step 3: Shuffle the deck again (excluding top card)
                    Wait.time(function()
                        local currentDeck2 = getObjectFromGUID(deckGUID)
                        
                        if currentDeck2 == nil then
                            print("Deck disappeared!")
                            return
                        end
                        
                        -- Remove top card before second shuffle
                        local topCard2 = currentDeck2.takeObject({
                            position = {currentDeck2.getPosition()[1], currentDeck2.getPosition()[2] + 3, currentDeck2.getPosition()[3]},
                            smooth = false
                        })
                        
                        Wait.time(function()
                            local deckToShuffle2 = getObjectFromGUID(deckGUID)
                            
                            if deckToShuffle2 ~= nil then
                                deckToShuffle2.shuffle()
                                print("[D9D9C1]Landscape Deck shuffled again!")
                                
                                -- Put top card back
                                Wait.time(function()
                                    local deckAfterShuffle2 = getObjectFromGUID(deckGUID)
                                    if deckAfterShuffle2 ~= nil and topCard2 ~= nil then
                                        deckAfterShuffle2.putObject(topCard2)
                                    end
                                    
                                    -- Step 4: Draw second card after second shuffle (second from top)
                                    Wait.time(function()
                                        local currentDeck3 = getObjectFromGUID(deckGUID)
                                        
                                        if currentDeck3 == nil then
                                            print("Deck disappeared after second shuffle!")
                                            return
                                        end
                                        
                                        -- Remove top card temporarily
                                        local tempTopCard2 = currentDeck3.takeObject({
                                            position = {currentDeck3.getPosition()[1], currentDeck3.getPosition()[2] + 3, currentDeck3.getPosition()[3]},
                                            smooth = false
                                        })
                                        
                                        Wait.time(function()
                                            local deckForSecondDraw = getObjectFromGUID(deckGUID)
                                            
                                            if deckForSecondDraw == nil then
                                                print("Deck disappeared!")
                                                return
                                            end
                                            
                                            -- Randomly decide if second card should be flipped (50/50 chance)
                                            local shouldFlip2 = math.random(1, 2) == 1
                                            
                                            -- Take the second card (now top) and place it at the second position
                                            local card2 = deckForSecondDraw.takeObject({
                                                position = {-13.65, 5.68, -6.18},
                                                smooth = true,
                                                flip = shouldFlip2
                                            })
                                            
                                            -- Put the top card back
                                            Wait.time(function()
                                                local deckAfterSecondDraw = getObjectFromGUID(deckGUID)
                                                if deckAfterSecondDraw ~= nil and tempTopCard2 ~= nil then
                                                    deckAfterSecondDraw.putObject(tempTopCard2)
                                                end
                                            end, 0.2)
                                            
                                            if shouldFlip2 then
                                                print("Drew second card and flipped it")
                                            else
                                                print("Drew second card (not flipped)")
                                            end
                                            
                                            -- Step 5: Deal tokens based on number of players
                                            Wait.time(function()
                                                dealTokens()
                                                
                                                -- Step 6: Delete the button
                                                Wait.time(function()
                                                    self.clearButtons()
                                                    print("Button removed - Landscape setup complete!")
                                                end, 1.0)
                                            end, 0.5)
                                            
                                        end, 0.2)
                                        
                                    end, 0.5)
                                end, 0.3)
                            end
                        end, 0.1)
                        
                    end, 0.5)
                    
                end, 0.2)
                
            end, 0.5)
        end, 0.3)
    end, 0.1)
end

function dealTokens()
    -- Get number of seated players
    local seatedPlayers = getSeatedPlayers()
    local playerCount = #seatedPlayers
    
    if playerCount == 0 then
        print("No players seated - skipping token dealing")
        return
    end
    
    -- Token bag definitions
    local tokenBags = {
        {guid = "8aa37b", position = {-9.60, 5.71, 11.67}, name = "Media"},
        {guid = "3e13da", position = {-9.60, 5.71, 10.93}, name = "Energy"},
        {guid = "982746", position = {-9.60, 5.71, 10.20}, name = "Financial"},
        {guid = "17d685", position = {-9.59, 5.71, 9.46}, name = "Humanities"},
        {guid = "2f6778", position = {-9.59, 5.71, 8.73}, name = "Technology"},
        {guid = "58349c", position = {-9.60, 5.71, 7.98}, name = "Manufacturing"}
    }
    
    -- Deal tokens from each bag
    for _, bagInfo in ipairs(tokenBags) do
        local bag = getObjectFromGUID(bagInfo.guid)
        
        if bag ~= nil then
            for i = 1, playerCount do
                -- Add vertical offset for each token to create a nice stack
                local stackPosition = {
                    bagInfo.position[1],
                    bagInfo.position[2] + (i - 1) * 0.3,  -- 0.3 units between each token
                    bagInfo.position[3]
                }
                
                bag.takeObject({
                    position = stackPosition,
                    smooth = true
                })
                Wait.time(function() end, 0.1)  -- Small delay between tokens
            end
        else
            print("Warning: " .. bagInfo.name .. " bag not found (GUID: " .. bagInfo.guid .. ")")
        end
        
        Wait.time(function() end, 0.2)  -- Delay between bags
    end
    
    -- Convert number to word
    local numberWords = {
        [1] = "One",
        [2] = "Two",
        [3] = "Three",
        [4] = "Four",
        [5] = "Five",
        [6] = "Six",
        [7] = "Seven",
        [8] = "Eight"
    }
    
    local countWord = numberWords[playerCount] or tostring(playerCount)
    printToAll(countWord .. "[D9D9C1] market tokens per type dealt\n» » » » » »  manually adjust per active Landscape.", {1, 1, 1})
end

-- Create a button to trigger this
function onLoad()
    self.createButton({
        click_function = "setupLandscape",
        function_owner = self,
        label = "Setup Landscape",
        position = {0, 0.05, 2.5},
        width = 800,
        height = 300,
        font_size = 90,
        color = {217/255, 217/255, 193/255}
    })
end