function shuffleDrawAndFlip()
    local deckGUID = "652542"
    local deck = getObjectFromGUID(deckGUID)
    
    if deck == nil then
        print("Deck not found! Check the GUID.")
        return
    end
    
    -- Step 1: Check for card at position {-11.32, 5.68, -6.15} and move to bottom of deck
    local oldPosition = {-11.32, 5.68, -6.15}
    local objectsAtOldPos = Physics.cast({
        origin = oldPosition,
        direction = {0, 1, 0},
        type = 3,
        size = {1, 1, 1},
        max_distance = 0.5
    })
    
    for _, hit in ipairs(objectsAtOldPos) do
        if hit.hit_object.type == "Card" then
            print("Found card at old position, moving to discard position")
            hit.hit_object.setPositionSmooth({-11.60, 6, -9.45})
            break
        end
    end
    
    -- Step 2: Check for card at position {-13.65, 5.95, -6.18} and move to {-11.32, 5.68, -6.15}
    local currentPosition = {-13.65, 5.95, -6.18}
    local objectsAtCurrentPos = Physics.cast({
        origin = currentPosition,
        direction = {0, 1, 0},
        type = 3,
        size = {1, 1, 1},
        max_distance = 0.5
    })
    
    for _, hit in ipairs(objectsAtCurrentPos) do
        if hit.hit_object.type == "Card" then
            print("Found card at current position, moving to old position")
            hit.hit_object.setPositionSmooth(oldPosition)
            break
        end
    end
    
    -- Wait a moment for cards to move before shuffling
    Wait.time(function()
        local currentDeck = getObjectFromGUID(deckGUID)
        
        if currentDeck == nil then
            print("Deck disappeared!")
            return
        end
        
        -- Step 3: Remove top card, shuffle the rest, then put it back on top
        local topCard = currentDeck.takeObject({
            position = {currentDeck.getPosition()[1], currentDeck.getPosition()[2] + 3, currentDeck.getPosition()[3]},
            smooth = false
        })
        
        -- Small wait to ensure card is removed before shuffling
        Wait.time(function()
            local deckToShuffle = getObjectFromGUID(deckGUID)
            
            if deckToShuffle ~= nil then
                deckToShuffle.shuffle()
                print("Deck shuffled (top card excluded)!")
                
                -- Put the top card back on top using putObject
                Wait.time(function()
                    local finalDeck = getObjectFromGUID(deckGUID)
                    
                    if finalDeck ~= nil and topCard ~= nil then
                        finalDeck.putObject(topCard)
                    end
                    
                    -- Step 4-6: Wait for cards to settle, then draw second card and flip
                    Wait.time(function()
                        local completeDeck = getObjectFromGUID(deckGUID)
                        
                        if completeDeck == nil then
                            print("Deck disappeared after shuffle!")
                            return
                        end
                        
                        -- Take the top card (which we'll put back)
                        local tempTopCard = completeDeck.takeObject({
                            position = {completeDeck.getPosition()[1], completeDeck.getPosition()[2] + 3, completeDeck.getPosition()[3]},
                            smooth = false
                        })
                        
                        Wait.time(function()
                            local deckAfterFirstTake = getObjectFromGUID(deckGUID)
                            
                            if deckAfterFirstTake == nil then
                                print("Deck disappeared!")
                                return
                            end
                            
                            -- Step 5: Randomly decide if card should be flipped (50/50 chance)
                            local shouldFlip = math.random(1, 2) == 1
                            
                            -- Step 4 & 6: Take the second card (now the top card) and place it at the position
                            local card = deckAfterFirstTake.takeObject({
                                position = currentPosition,
                                smooth = true,
                                flip = shouldFlip
                            })
                            
                            -- Put the original top card back on top using putObject
                            Wait.time(function()
                                local finalDeckAgain = getObjectFromGUID(deckGUID)
                                if finalDeckAgain ~= nil and tempTopCard ~= nil then
                                    finalDeckAgain.putObject(tempTopCard)
                                end
                            end, 0.2)
                            
                            if shouldFlip then
                                print("Drew second card and flipped it")
                            else
                                print("Drew second card (not flipped)")
                            end
                        end, 0.2)
                        
                    end, 0.5)
                end, 0.3)
            end
        end, 0.1)
        
    end, 0.3)
end

-- Create a button to trigger this
function onLoad()
    self.createButton({
        click_function = "shuffleDrawAndFlip",
        function_owner = self,
        label = "Resolve Landscape",
        position = {0, 0.05, 3},
        width = 900,
        height = 450,
        font_size = 100,
        color = {217/255, 217/255, 193/255}
    })
end