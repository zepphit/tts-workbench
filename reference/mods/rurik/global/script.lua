----------------------------------------------------------------
-- ONE CLEAN GLOBAL SCRIPT (Merged)
-- - Tag cache + wait helpers
-- - Setup + next round
-- - Deeds market refresh (no zones)
-- - Resources replenish
-- - Character tile system (no zones)
-- - Deed tuck system (board auto-slot)
-- - AdvisorPay panel + proxy bribe selection
-- - OPTIONAL legacy: onObjectEnterScriptingZone character-handling
--
-- Required tags used here (make sure these exist on objects):
--   tracker_player_count
--   bag_coins, bag_fish, bag_honey, bag_fur, bag_wood, bag_ore
--   deck_deeds1, deck_deeds2, deck_schemes, deck_characters, deck_objectives
--   deck_start_deeds_a, deck_start_deeds_b
--   bag_rebels
--   tile_warfare, board_advisors, token_first_player, token_round, tile_next_round
--   tile_char_blue, tile_char_yellow, tile_char_red, tile_char_purple
--   Advisor_Pay (panel object)
-- Advisors: tag "Advisor" (+ optional "secondround"/"thirdround") and have snap point tagged "Coin Spot"
-- Player coin bags: type Bag + tags "Coin" + player color (Blue/Yellow/Red/Purple)
--
-- Optional (legacy replacement for your zone GUID logic):
--   zone_character_minis                 (zone holding the character minis)
--   zone_char_hand_Blue / Yellow / Red / Purple (zones where character cards enter)
----------------------------------------------------------------

---------------------------------------------------------------
-- TAG CACHE + LOOKUP
---------------------------------------------------------------
TAG_MULTI = TAG_MULTI or nil

local function rebuildTagCache()
    TAG_MULTI = {}
    for _, o in ipairs(getAllObjects()) do
        local tags = o.getTags()
        if tags then
            for _, t in ipairs(tags) do
                TAG_MULTI[t] = TAG_MULTI[t] or {}
                table.insert(TAG_MULTI[t], o)
            end
        end
    end
end

function getByTag(tag)
    local list = TAG_MULTI and TAG_MULTI[tag] or nil
    if not list or #list == 0 then return nil end
    return list[1]
end

function waitByTag(tag, timeoutSeconds)
    local start = Time.time
    while true do
        rebuildTagCache()
        local o = getByTag(tag)
        if o then return o end
        if timeoutSeconds and (Time.time - start) > timeoutSeconds then return nil end
        coroutine.yield(0)
    end
end

---------------------------------------------------------------
-- BASIC UTILS
---------------------------------------------------------------
local function gmNumberFromObject(obj, defaultVal)
    if not obj then return defaultVal end
    local n = tonumber(string.match(obj.getGMNotes() or "", "%d+"))
    return n or defaultVal
end

function waitAmount(seconds)
    local start = Time.time
    while (Time.time - start) < (seconds or 0) do
        coroutine.yield(0)
    end
end

function safeCall(fnName, ...)
    local fn = _G[fnName]
    if type(fn) ~= "function" then
        broadcastToAll("MISSING FUNCTION: "..tostring(fnName), {r=1,g=0.6,b=0.2})
        return false
    end
    local ok, err = pcall(fn, ...)
    if not ok then
        broadcastToAll("ERROR in "..tostring(fnName)..": "..tostring(err), {r=1,g=0.2,b=0.2})
        return false
    end
    return true
end

local PLAYABLE_COLORS = {"Blue","Yellow","Red","Purple"}

local function seatedPlayableColors()
    local seated = {}
    for _, c in ipairs(PLAYABLE_COLORS) do
        if Player[c] and Player[c].seated then table.insert(seated, c) end
    end
    return seated
end

local function selectedPlayerCount()
    rebuildTagCache()
    local tracker = getByTag("tracker_player_count")
    if not tracker then
        broadcastToAll("COUNT ERROR: Missing tag 'tracker_player_count' (defaulting to 2).", {1,0.6,0.2})
        return 2
    end

    local notes = tostring(tracker.getGMNotes() or "")
    local n = tonumber(string.match(notes, "%d+")) or 2
    if n < 2 then n = 2 end
    if n > 4 then n = 4 end
    return n
end

-- Mode B: deal to selected player-count colors even if seats mismatch
local function colorsForSelectedCount()
    local n = selectedPlayerCount()
    if n <= 2 then return {"Blue","Yellow"} end
    if n == 3 then return {"Blue","Yellow","Red"} end
    return {"Blue","Yellow","Red","Purple"}
end

-- Returns -1 if UI-selected player count != seated player count (your existing behaviour)
function setPlayerAmount()
    local playerAmount = 0
    if Player["Blue"].seated   then playerAmount = playerAmount + 1 end
    if Player["Yellow"].seated then playerAmount = playerAmount + 1 end
    if Player["Red"].seated    then playerAmount = playerAmount + 1 end
    if Player["Purple"].seated then playerAmount = playerAmount + 1 end

    local forcedAmount = selectedPlayerCount()
    if forcedAmount ~= playerAmount then return -1 end
    return playerAmount
end

---------------------------------------------------------------
-- POSITIONS / DATA TABLES (your originals kept)
---------------------------------------------------------------
-- (These are defined at bottom in your paste; keep them there as-is)
-- Deeds1Position, Deeds2Position, ResourcesOn2Regions, ResourcesOn3Regions, ResourcesOn4Regions, Rebel2Regions, Rebel3Regions, Rebel4Regions
-- StartingPlayerToken, StartingPlayerTokenRotation

---------------------------------------------------------------
-- ON LOAD / BOOT
---------------------------------------------------------------
function onLoad()
    rebuildTagCache()
    startLuaCoroutine(Global, "bootCoroutine")

    -- Build AdvisorPay panel after load settles
    Wait.time(function()
        if AdvisorPay and AdvisorPay.buildPaymentPanel then
            AdvisorPay._panelBuilt = false
            AdvisorPay.buildPaymentPanel(true)
        end
    end, 1.0)
end

function bootCoroutine()
    rebuildTagCache()

    local coinsBag = waitByTag("bag_coins", 10)
    if not coinsBag then
        broadcastToAll("ERROR: Missing tag bag_coins on coins bag.", {r=1,g=0.2,b=0.2})
        return 1
    end

    local currentRound = gmNumberFromObject(coinsBag, 0)

    if currentRound < 1 then
        UI.show("setupMenu")
    else
        createNextRoundButton()
    end

    return 1
end

function onPlayerConnect(player)
    -- Ensure late joiners get the panel buttons
    Wait.time(function()
        if AdvisorPay and AdvisorPay.buildPaymentPanel then
            AdvisorPay._panelBuilt = false
            AdvisorPay.buildPaymentPanel(true)
        end
    end, 1.0)
end

---------------------------------------------------------------
-- SETUP COROUTINE
---------------------------------------------------------------
function selectedSetup()
    startLuaCoroutine(Global, "selectedSetupCoRoutine")
end

function selectedSetupCoRoutine()
    UI.hide("setupMenu")
    waitAmount(0.5)
    startLuaCoroutine(Global, "setupCoRutine")
    return 1
end

function setupCoRutine()
    local textColor = {r=190/255, g=190/255, b=190/255}

    local working      = waitByTag("bag_fish", 10) -- used as a lock flag (your pattern)
    local roundTracker = waitByTag("bag_coins", 10)

    if not working or not roundTracker then
        broadcastToAll("ERROR: Missing tagged bags (bag_fish/bag_coins).", {r=1,g=0.2,b=0.2})
        return 1
    end

    if string.match(working.getGMNotes() or "", "yes") then
        broadcastToAll("Setup already running.", {r=1,g=0.6,b=0.2})
        return 1
    end

    working.setGMNotes("yes")

    safeCall("displayDeeds1")
    safeCall("displayDeeds2")
    safeCall("spreadResources")
    safeCall("splitSchemes")
    safeCall("prepareAdvisorsBoard")
    safeCall("shuffleWarfare")
    safeCall("dealStartingDeeds")

    waitAmount(1.5)

    safeCall("setupRebels")
    safeCall("dealCharacters")

    waitAmount(1.5)

    safeCall("dealSecretObjectives")

    waitAmount(1.5)

    safeCall("chooseStartingPlayer")

    working.setGMNotes("")
    roundTracker.setGMNotes("1")

    safeCall("createNextRoundButton")

    waitAmount(1)
    broadcastToAll("Setup Complete", textColor)

    return 1
end

---------------------------------------------------------------
-- DEEDS MARKET (DISPLAY + REFRESH, NO ZONES)
---------------------------------------------------------------
function displayDeeds1()
    local n = selectedPlayerCount()
    local slots = n + 1

    local deck = waitByTag("deck_deeds1", 10)
    if not deck or (deck.type ~= "Deck" and deck.type ~= "Card") then
        broadcastToAll("ERROR: Missing deck_deeds1 (tag the deck).", {r=1,g=0.2,b=0.2})
        return
    end

    if deck.type == "Deck" then deck.shuffle() end
    for i = 1, slots do
        deck.takeObject({ position = Deeds1Position[i], rotation = {0,270,0}, smooth = false })
    end
end

function displayDeeds2()
    local n = selectedPlayerCount()
    local slots = n + 1

    local deck = waitByTag("deck_deeds2", 10)
    if not deck or (deck.type ~= "Deck" and deck.type ~= "Card") then
        broadcastToAll("ERROR: Missing deck_deeds2 (tag the deck).", {r=1,g=0.2,b=0.2})
        return
    end

    if deck.type == "Deck" then deck.shuffle() end
    for i = 1, slots do
        deck.takeObject({ position = Deeds2Position[i], rotation = {0,270,0}, smooth = false })
    end
end

local function deedInSlot(pos, radius)
    radius = radius or 1.35
    local r2 = radius * radius
    for _, o in ipairs(getAllObjects()) do
        if o and (o.hasTag("Deed") or o.hasTag("deed")) then
            local p = o.getPosition()
            local dx = p.x - pos[1]
            local dz = p.z - pos[3]
            if (dx*dx + dz*dz) <= r2 then return true end
        end
    end
    return false
end

local function refillDeedsFromDeckTag(deckTag, positions, slotsNeeded)
    local deck = getByTag(deckTag)
    if not deck then
        broadcastToAll("DEEDS: Can't find "..tostring(deckTag).." by tag.", {1,0.3,0.3})
        return
    end
    if deck.type ~= "Deck" and deck.type ~= "Card" then
        broadcastToAll("DEEDS: "..tostring(deckTag).." is "..tostring(deck.type).." (expected Deck/Card).", {1,0.3,0.3})
        return
    end

    for i = 1, slotsNeeded do
        local pos = positions[i]
        if pos and not deedInSlot(pos, 1.35) then
            if deck.type == "Deck" then
                deck.takeObject({ position = pos, rotation = {0,270,0}, smooth = false })
            else
                deck.setPositionSmooth(pos, false, true)
                deck.setRotationSmooth({0,270,0}, false, true)
                break
            end
        end
    end
end

function refreshDeeds()
    rebuildTagCache()
    local n = selectedPlayerCount()
    local slotsNeeded = n + 1
    refillDeedsFromDeckTag("deck_deeds1", Deeds1Position, slotsNeeded)
    refillDeedsFromDeckTag("deck_deeds2", Deeds2Position, slotsNeeded)
end

---------------------------------------------------------------
-- RESOURCES (SPREAD + REPLENISH)
---------------------------------------------------------------
local function takeFromBagToPos(bagTag, pos, rot)
    local bag = getByTag(bagTag)
    if not bag then
        broadcastToAll("ERROR: Missing tag "..tostring(bagTag).." on a bag.", {1,0.2,0.2})
        return
    end
    bag.takeObject({ position = pos, rotation = rot or {0,0,0}, smooth = false })
end

function spreadResources()
    local n = selectedPlayerCount()

    takeFromBagToPos("bag_fish",  ResourcesOn2Regions[1], {0, 75, 0})
    takeFromBagToPos("bag_fish",  ResourcesOn2Regions[2], {0, 75, 0})
    takeFromBagToPos("bag_honey", ResourcesOn2Regions[3], {0, 45, 0})
    takeFromBagToPos("bag_fur",   ResourcesOn2Regions[4], {0, 60, 0})
    takeFromBagToPos("bag_wood",  ResourcesOn2Regions[5], {0,135, 0})
    takeFromBagToPos("bag_wood",  ResourcesOn2Regions[6], {0,135, 0})
    takeFromBagToPos("bag_ore",   ResourcesOn2Regions[7], {0, 90, 0})
    takeFromBagToPos("bag_ore",   ResourcesOn2Regions[8], {0, 90, 0})

    if n > 2 then
        takeFromBagToPos("bag_fish",  ResourcesOn3Regions[1], {0, 75, 0})
        takeFromBagToPos("bag_honey", ResourcesOn3Regions[2], {0, 45, 0})
        takeFromBagToPos("bag_wood",  ResourcesOn3Regions[3], {0,135, 0})
    end

    if n > 3 then
        takeFromBagToPos("bag_fish", ResourcesOn4Regions[1], {0, 75, 0})
        takeFromBagToPos("bag_fur",  ResourcesOn4Regions[2], {0, 60, 0})
        takeFromBagToPos("bag_wood", ResourcesOn4Regions[3], {0,135, 0})
        takeFromBagToPos("bag_ore",  ResourcesOn4Regions[4], {0, 90, 0})
    end
end

local function isTagNearPos(tag, pos, radius)
    radius = radius or 1.0
    local r2 = radius*radius
    for _, o in ipairs(getAllObjects()) do
        if o and o.hasTag(tag) then
            local p = o.getPosition()
            local dx = p.x - pos[1]
            local dz = p.z - pos[3]
            if (dx*dx + dz*dz) <= r2 then return true end
        end
    end
    return false
end

local function refillResourceAt(bagTag, pos, rot)
    if isTagNearPos("Resource", pos, 1.0) then return end
    local bag = getByTag(bagTag)
    if not bag then
        broadcastToAll("END ROUND: Missing bag tag "..tostring(bagTag), {r=1,g=0.6,b=0.2})
        return
    end
    bag.takeObject({ position = pos, rotation = rot or {0,0,0}, smooth = false })
end

function replenishGoods()
    local n = setPlayerAmount()
    if n < 0 then n = selectedPlayerCount() end

    refillResourceAt("bag_fish",  ResourcesOn2Regions[1], {0, 75, 0})
    refillResourceAt("bag_fish",  ResourcesOn2Regions[2], {0, 75, 0})
    refillResourceAt("bag_honey", ResourcesOn2Regions[3], {0, 45, 0})
    refillResourceAt("bag_fur",   ResourcesOn2Regions[4], {0, 60, 0})
    refillResourceAt("bag_wood",  ResourcesOn2Regions[5], {0,135, 0})
    refillResourceAt("bag_wood",  ResourcesOn2Regions[6], {0,135, 0})
    refillResourceAt("bag_ore",   ResourcesOn2Regions[7], {0, 90, 0})
    refillResourceAt("bag_ore",   ResourcesOn2Regions[8], {0, 90, 0})

    if n > 2 then
        refillResourceAt("bag_fish",  ResourcesOn3Regions[1], {0, 75, 0})
        refillResourceAt("bag_honey", ResourcesOn3Regions[2], {0, 45, 0})
        refillResourceAt("bag_wood",  ResourcesOn3Regions[3], {0,135, 0})
    end

    if n > 3 then
        refillResourceAt("bag_fish", ResourcesOn4Regions[1], {0, 75, 0})
        refillResourceAt("bag_fur",  ResourcesOn4Regions[2], {0, 60, 0})
        refillResourceAt("bag_wood", ResourcesOn4Regions[3], {0,135, 0})
        refillResourceAt("bag_ore",  ResourcesOn4Regions[4], {0, 90, 0})
    end
end

---------------------------------------------------------------
-- SCHEMES
---------------------------------------------------------------
function splitSchemes()
    local schemesDeck = waitByTag("deck_schemes", 10)
    if not schemesDeck or (schemesDeck.type ~= "Deck" and schemesDeck.type ~= "Card") then
        broadcastToAll("ERROR: Missing deck_schemes (tag the Schemes deck).", {r=1,g=0.2,b=0.2})
        return
    end

    local CARD_POS  = {-17.90, 0.88,  7.94}
    local CARD_ROT  = { 0.00, 90.00,  0.00}
    local DECK1_POS = {-17.90, 0.94,  5.60}
    local DECK2_POS = {-17.90, 0.95, 10.28}
    local DECK_ROT  = { 0.00, 90.00, 180.00}

    if schemesDeck.type == "Deck" then
        schemesDeck.shuffle()

        schemesDeck.takeObject({ position = CARD_POS, rotation = CARD_ROT, smooth = false })

        local qty  = schemesDeck.getQuantity()
        local half = math.floor(qty / 2)

        if half > 0 then
            schemesDeck.takeObject({ position = DECK1_POS, rotation = DECK_ROT, smooth = true })
            for i = 2, half do
                schemesDeck.takeObject({ position = DECK1_POS, rotation = DECK_ROT, smooth = true })
            end
        end

        schemesDeck.setPositionSmooth(DECK2_POS, true, true)
        schemesDeck.setRotationSmooth(DECK_ROT, true, true)
    else
        schemesDeck.setPositionSmooth(CARD_POS, true, true)
        schemesDeck.setRotationSmooth(CARD_ROT, true, true)
    end
end

---------------------------------------------------------------
-- WARFARE TILE
---------------------------------------------------------------
function shuffleWarfare()
    local tile = waitByTag("tile_warfare", 10)
    if not tile then
        broadcastToAll("SETUP: Missing tile_warfare tag on the warfare tile.", {r=1,g=0.2,b=0.2})
        return
    end

    local chosen = math.random(1, 2)
    if tile.getStateId and tile.getStateId() == chosen then return end
    tile.setState(chosen)
end

---------------------------------------------------------------
-- STARTING DEEDS / CHARACTERS / OBJECTIVES (Mode B: selected count)
---------------------------------------------------------------
function dealStartingDeeds()
    local deckA = waitByTag("deck_start_deeds_a", 10)
    local deckB = waitByTag("deck_start_deeds_b", 10)

    if not deckA or deckA.type ~= "Deck" then
        broadcastToAll("ERROR: Missing deck_start_deeds_a (tag the deck).", {r=1,g=0.2,b=0.2})
        return
    end
    if not deckB or deckB.type ~= "Deck" then
        broadcastToAll("ERROR: Missing deck_start_deeds_b (tag the deck).", {r=1,g=0.2,b=0.2})
        return
    end

    deckA.shuffle()
    deckB.shuffle()

    for _, c in ipairs(colorsForSelectedCount()) do
        deckA.deal(1, c)
        deckB.deal(1, c)
    end
end

function dealCharacters()
    local characters = waitByTag("deck_characters", 10)
    if not characters or (characters.type ~= "Deck" and characters.type ~= "Card") then
        broadcastToAll("ERROR: Missing deck_characters (tag the Characters deck).", {r=1,g=0.2,b=0.2})
        return
    end
    if characters.type == "Deck" then characters.shuffle() end
    for _, c in ipairs(colorsForSelectedCount()) do
        characters.deal(1, c)
    end
end

function dealSecretObjectives()
    local objectives = waitByTag("deck_objectives", 10)
    if not objectives or (objectives.type ~= "Deck" and objectives.type ~= "Card") then
        broadcastToAll("ERROR: Missing deck_objectives (tag the Objectives deck).", {r=1,g=0.2,b=0.2})
        return
    end
    if objectives.type == "Deck" then objectives.shuffle() end
    for _, c in ipairs(colorsForSelectedCount()) do
        objectives.deal(2, c)
    end
end

---------------------------------------------------------------
-- ADVISORS BOARD STATE
---------------------------------------------------------------
function prepareAdvisorsBoard()
    local b = waitByTag("board_advisors", 10)
    if not b then
        broadcastToAll("ERROR: Missing board_advisors tag on Advisors board.", {1,0.2,0.2})
        return
    end

    local n = selectedPlayerCount()

    -- Keep the mapping that worked in your newer version:
    local map = {
  [2] = 1, -- 2 players -> state 1
  [3] = 2, -- 3 players -> state 2
  [4] = 2, -- 4 players -> state 2
}

    local target = map[n] or 1

    if b.getStateId and b.getStateId() ~= target then
        b.setState(target)
    end
end
---------------------------------------------------------------
-- REBELS
---------------------------------------------------------------
function setupRebels()
    local rebelBag = waitByTag("bag_rebels", 10)
    if not rebelBag then
        broadcastToAll("ERROR: Missing bag_rebels tag on Rebel bag.", {r=1,g=0.2,b=0.2})
        return
    end

    local n = setPlayerAmount()
    if n < 0 then n = selectedPlayerCount() end

    rebelBag.shuffle()

    local FIXED_ROTATION = {x=0.00, y=90.00, z=180.00}

    local function snap(obj, pos)
        if not obj or obj.isDestroyed() then return end
        obj.locked = true
        obj.setPosition(pos)
        obj.setRotation(FIXED_ROTATION)
        obj.setVelocity({0,0,0})
        obj.setAngularVelocity({0,0,0})
        Wait.frames(function()
            if not obj or obj.isDestroyed() then return end
            obj.setPosition(pos)
            obj.setRotation(FIXED_ROTATION)
            obj.setVelocity({0,0,0})
            obj.setAngularVelocity({0,0,0})
            obj.locked = false
        end, 2)
    end

    local function spawnAt(pos)
        rebelBag.takeObject({
            position = pos,
            rotation = FIXED_ROTATION,
            smooth   = false,
            callback_owner = Global,
            callback_function = function(obj) snap(obj, pos) end
        })
    end

    for i=1, 8 do spawnAt(Rebel2Regions[i]) end
    if n > 2 then
        for i=1, 3 do spawnAt(Rebel3Regions[i]) end
        if n > 3 then
            for i=1, 4 do spawnAt(Rebel4Regions[i]) end
        end
    end
end

---------------------------------------------------------------
-- STARTING PLAYER + TURN ORDER
---------------------------------------------------------------
-- IMPORTANT: set these indexes to match YOUR StartingPlayerToken array order.
-- If your token positions array is NOT [Blue, Yellow, Red, Purple], change them here.
START_TOKEN_INDEX = {
    Blue   = 3,
    Yellow = 4,
    Red    = 2,
    Purple = 1,
}

function chooseStartingPlayer()
    local firstPlayerToken = waitByTag("token_first_player", 10)
    if not firstPlayerToken then
        broadcastToAll("ERROR: Missing token_first_player tag.", {1,0.2,0.2})
        return
    end

    -- Build ring from selected player count only
    local n = selectedPlayerCount()
    local ring
    if n <= 2 then
        ring = {"Blue","Yellow"}
    elseif n == 3 then
        ring = {"Blue","Yellow","Red"}
    else
        ring = {"Blue","Yellow","Red","Purple"}
    end

    -- Better randomness
    math.randomseed(os.time() + math.floor(Time.time * 1000))

    local chosenColor = ring[math.random(1, #ring)]
    local idx = START_TOKEN_INDEX[chosenColor]

    if not idx or not StartingPlayerToken[idx] then
        broadcastToAll("ERROR: No starting position for "..chosenColor, {1,0.2,0.2})
        return
    end

    -- Move token
    firstPlayerToken.setPositionSmooth(StartingPlayerToken[idx], false, true)
    firstPlayerToken.setRotationSmooth(StartingPlayerTokenRotation[idx], false, true)

    -- Build turn order starting from chosen color
    local startIndex = 1
    for i,c in ipairs(ring) do
        if c == chosenColor then
            startIndex = i
            break
        end
    end

    local order = {}
    for i = 0, #ring - 1 do
        table.insert(order, ring[((startIndex - 1 + i) % #ring) + 1])
    end

    -- Always enable turns
    Turns.enable = false
    Turns.type   = 2
    Turns.order  = order
    Turns.enable = true

    broadcastToAll("Starting Player: "..chosenColor, {0.8,0.9,0.8})
end

---------------------------------------------------------------
-- ROUND ADVISOR DEPLOYMENT
---------------------------------------------------------------
local PLAYER_COLORS = {"Blue","Purple","Red","Yellow"}

local function _advisorColorTag(obj)
    for _,c in ipairs(PLAYER_COLORS) do
        if obj.hasTag(c) then return c end
    end
    return nil
end

local ROUND_ADVISOR_TARGETS = {
    [2] = { -- secondround
        Blue   = { pos = {-6.61, 0.94, -18.80}, rot = {0.00, 180.00, 0.00} },
        Purple = { pos = {15.86, 0.94, -18.80}, rot = {0.00, 180.00, 0.00} },
        Red    = { pos = {17.59, 0.94,  26.16}, rot = {0.00,   0.00, 0.00} },
        Yellow = { pos = {-7.74, 0.94,  26.16}, rot = {0.00,   0.00, 0.00} },
        tag = "secondround",
    },
    [3] = { -- thirdround (only for 2 or 3 players)
        Blue   = { pos = {-5.29, 0.94, -18.80}, rot = {0.00, 180.00, 0.00} },
        Purple = { pos = {17.17, 0.94, -18.80}, rot = {0.00, 180.00, 0.00} },
        Red    = { pos = {16.25, 0.94,  26.16}, rot = {0.00,   0.00, 0.00} },
        Yellow = { pos = {-9.07, 0.94,  26.16}, rot = {0.00,   0.00, 0.00} },
        tag = "thirdround",
    }
}

local function deployRoundAdvisors(roundNumber)
    local cfg = ROUND_ADVISOR_TARGETS[roundNumber]
    if not cfg then return end

    if roundNumber == 3 then
        local n = selectedPlayerCount()
        if n > 3 then return end
    end

    local perColorCount = {Blue=0,Purple=0,Red=0,Yellow=0}

    for _,o in ipairs(getAllObjects()) do
        if o and not o.isDestroyed() and o.hasTag("Advisor") and o.hasTag(cfg.tag) then
            local c = _advisorColorTag(o)
            local target = c and cfg[c] or nil
            if target then
                perColorCount[c] = (perColorCount[c] or 0) + 1
                local k = perColorCount[c] - 1
                local pos = { target.pos[1], target.pos[2] + (0.15 * k), target.pos[3] }

                o.locked = false
                o.setPositionSmooth(pos, false, true)
                o.setRotationSmooth(target.rot, false, true)
            end
        end
    end
end

---------------------------------------------------------------
-- NEXT ROUND
---------------------------------------------------------------
ROUND_POS = {
    [1] = nil,
    [2] = {-14.07, 1.06, 8.16},
    [3] = {-14.07, 1.06, 9.29},
}

function nextRound()
    safeCall("cleanCoins")
    safeCall("replenishGoods")
    safeCall("refreshDeeds")

    local tracker = getByTag("bag_coins")
    if not tracker then
        broadcastToAll("ERROR: bag_coins not found (round tracker).", {r=1,g=0.2,b=0.2})
        return
    end

    local current = tonumber(string.match(tracker.getGMNotes() or "", "%d+")) or 1
    local newRound = current + 1
    if newRound > 3 then
        broadcastToAll("Already at final round (Round 3).", {r=1,g=0.6,b=0.2})
        return
    end

    tracker.setGMNotes(tostring(newRound))
    deployRoundAdvisors(newRound)

    local tok = getByTag("token_round")
    if tok then
        local pos = ROUND_POS[newRound]
        if pos then tok.setPositionSmooth(pos) end
    end

    broadcastToAll("Advanced to Round "..tostring(newRound), {r=0.8,g=0.8,b=0.8})
end

---------------------------------------------------------------
-- CLEAN COINS ON ADVISORS (Coin Spot snap point)
---------------------------------------------------------------
local COIN_SPOT_TAG = "Coin Spot"

local function snapPointHasTag(sp, wanted)
    if not sp or not sp.tags then return false end
    for _,t in ipairs(sp.tags) do
        if t == wanted then return true end
    end
    return false
end

local function advisorCoinSpotWorldPos(advisorObj)
    if not advisorObj then return nil end
    if advisorObj.getSnapPoints and advisorObj.positionToWorld then
        local sps = advisorObj.getSnapPoints()
        if sps then
            for _,sp in ipairs(sps) do
                if snapPointHasTag(sp, COIN_SPOT_TAG) then
                    local w = advisorObj.positionToWorld(sp.position)
                    return {w.x, w.y, w.z}
                end
            end
        end
    end
    if advisorObj.getBoundsNormalized then
        local b = advisorObj.getBoundsNormalized()
        local c = b.center
        return {c.x, c.y, c.z}
    end
    local p = advisorObj.getPosition()
    return {p.x, p.y, p.z}
end

local function dist2XZ(a, b)
    local dx = a[1] - b[1]
    local dz = a[3] - b[3]
    return dx*dx + dz*dz
end

local function isCoinLike(o)
    if not o or o.isDestroyed() then return false end
    if o.hasTag and (o.hasTag("Coin") or o.hasTag("coin")) then return true end
    local nm = string.lower(tostring(o.getName() or ""))
    return string.find(nm, "coin", 1, true) ~= nil
end

function cleanCoins()
    local RADIUS = 1.2
    local r2 = RADIUS * RADIUS
    local Y_MIN = -0.2
    local Y_MAX =  2.0

    local advisors, coins = {}, {}

    for _,o in ipairs(getAllObjects()) do
        if o and not o.isDestroyed() and o.hasTag and o.hasTag("Advisor") then table.insert(advisors, o) end
        if isCoinLike(o) then table.insert(coins, o) end
    end

    for _,ad in ipairs(advisors) do
        local spot = advisorCoinSpotWorldPos(ad)
        local yMin = spot[2] + Y_MIN
        local yMax = spot[2] + Y_MAX

        for _,coin in ipairs(coins) do
            if coin and not coin.isDestroyed() then
                local p = coin.getPosition()
                local pos = {p.x, p.y, p.z}
                if pos[2] >= yMin and pos[2] <= yMax and dist2XZ(pos, spot) <= r2 then
                    coin.destruct()
                end
            end
        end
    end
end

---------------------------------------------------------------
-- NEXT ROUND BUTTON
---------------------------------------------------------------
function createNextRoundButton()
    local host = getByTag("tile_next_round")
    if not host then
        broadcastToAll("ERROR: Missing tag tile_next_round (button host).", {r=1,g=0.2,b=0.2})
        return
    end

    host.clearButtons()
    host.createButton({
        click_function = "nextRound",
        function_owner = Global,
        label          = "Next\nRound",
        position       = {0, 0.25, 0},
        rotation       = {0, 180, 0},
        scale          = {1, 1, 1},
        width          = 1200,
        height         = 700,
        font_size      = 220,
        color          = {0.2,0.2,0.2,0.95},
        font_color     = {1,1,1,1},
        tooltip        = "Run end-of-round cleanup + advance round",
    })
end

---------------------------------------------------------------
-- CHARACTER TILE SYSTEM (NO ZONES)
---------------------------------------------------------------
CHAR_TILE_RADIUS = 2.5

CHAR_TILES = {
    Blue   = { tileTag="tile_char_blue",   dest={-16.5,1,-11},  tint={r=51/255,g=179/255,b=230/255} },
    Yellow = { tileTag="tile_char_yellow", dest={  2.2,1, 18},  tint={r=242/255,g=217/255,b= 37/255} },
    Red    = { tileTag="tile_char_red",    dest={ 27.6,1, 18},  tint={r=231/255,g=0,     b= 68/255} },
    Purple = { tileTag="tile_char_purple", dest={  5.8,1,-11},  tint={r=0.412,g=0.235,b=0.369} },
}

CARD_OWNER  = CARD_OWNER  or {} -- card guid -> color
CARD_TO_MINI= CARD_TO_MINI or {} -- card guid -> mini guid

CHAR_HOME = {
    Gleb      = {32.35, 0.9,  -8.66},
    Boris     = {30.4,  0.9,  -8.66},
    Agatha    = {32.35, 0.9,  -10.4},
    Maria     = {30.4,  0.9,  -10.4},
    Theofana  = {32.35, 0.9,  -4.8},
    Sviatopolk= {32.35, 0.9,  -6.55},
    Mstislav  = {30.4,  0.9,  -4.8},
    Yaroslav  = {30.4,  0.9,  -6.55},
}

local function dist2_vec(a,b)
    local dx=a.x-b.x; local dy=a.y-b.y; local dz=a.z-b.z
    return dx*dx + dy*dy + dz*dz
end

local function isCharacterCard(o)
    return o and (o.type=="Card") and (o.hasTag("Character") or o.hasTag("character"))
end

local function isCharacterMini(o)
    if not o then return false end
    local isTroop = o.hasTag("Troop") or o.hasTag("troop")
    local isChar  = o.hasTag("Character") or o.hasTag("character")
    return isTroop and isChar
end

local function getCharacterNameTag(obj)
    local names = {"Gleb","Boris","Agatha","Maria","Theofana","Sviatopolk","Mstislav","Yaroslav"}
    for _,n in ipairs(names) do
        if obj.hasTag(n) then return n end
    end
    return nil
end

local function findMiniForCard(card)
    local nameTag = getCharacterNameTag(card)
    if not nameTag then return nil, "Card missing name tag (Gleb/Boris/etc)." end

    for _,o in ipairs(getAllObjects()) do
        if isCharacterMini(o) and o.hasTag(nameTag) then
            return o, nil
        end
    end
    return nil, "No mini found with tag "..nameTag
end

local function cardOnWhichTile(card)
    rebuildTagCache()
    local p = card.getPosition()
    local r2 = CHAR_TILE_RADIUS*CHAR_TILE_RADIUS
    for color,data in pairs(CHAR_TILES) do
        local tile = getByTag(data.tileTag)
        if tile then
            local tp = tile.getPosition()
            if dist2_vec(p,tp) <= r2 then
                return color
            end
        end
    end
    return nil
end

local function moveMiniToColor(mini, color)
    local data = CHAR_TILES[color]
    if not data then return end
    mini.setPositionSmooth(data.dest, false, true)
    if data.tint then mini.setColorTint(data.tint) end
end

local function returnMiniHome(mini)
    local nameTag = getCharacterNameTag(mini)
    if not nameTag then return end
    local home = CHAR_HOME[nameTag]
    if not home then return end
    mini.setPositionSmooth(home, false, true)
end

local function tryAssignCard(card)
    local color = cardOnWhichTile(card)
    if not color then return end

    local mini, err = findMiniForCard(card)
    if not mini then
        broadcastToAll("ERROR: "..tostring(err), {r=1,g=0.2,b=0.2})
        return
    end

    CARD_OWNER[card.getGUID()] = color
    CARD_TO_MINI[card.getGUID()] = mini.getGUID()
    moveMiniToColor(mini, color)
end

local function maybeUnassignCard(card)
    local guid = card.getGUID()
    local prev = CARD_OWNER[guid]
    if not prev then return end

    local nowColor = cardOnWhichTile(card)
    if nowColor then return end

    local miniGuid = CARD_TO_MINI[guid]
    if miniGuid then
        local mini = getObjectFromGUID(miniGuid)
        if mini then returnMiniHome(mini) end
    end

    CARD_OWNER[guid] = nil
    CARD_TO_MINI[guid] = nil
end

---------------------------------------------------------------
-- DEED TUCK SYSTEM v3 (hard slots, max 3 per column, locks)
---------------------------------------------------------------
DEED_SLOTS = DEED_SLOTS or {
    Purple = { {nil,nil,nil}, {nil,nil,nil}, {nil,nil,nil} },
    Blue   = { {nil,nil,nil}, {nil,nil,nil}, {nil,nil,nil} },
    Yellow = { {nil,nil,nil}, {nil,nil,nil}, {nil,nil,nil} },
    Red    = { {nil,nil,nil}, {nil,nil,nil}, {nil,nil,nil} },
}

DEED_LAYOUT = DEED_LAYOUT or {
    Purple = {
        cols = {
            { { 9.38, 0.88, -12.18}, { 9.38, 0.87, -11.48}, { 9.38, 0.86, -10.84} },
            { {12.02, 0.88, -12.18}, {12.02, 0.87, -11.48}, {12.02, 0.86, -10.84} },
            { {14.45, 0.88, -12.18}, {14.45, 0.87, -11.48}, {14.45, 0.86, -10.84} },
        },
        rot = {0,180,0}, lockPlaced = true, maxPerCol = 3, snapRadius2 = 9.0,
    },
    Blue = {
        cols = {
            { {-13.09, 0.88, -12.19}, {-13.09, 0.86, -11.49}, {-13.09, 0.86, -10.85} },
            { {-10.40, 0.88, -12.19}, {-10.40, 0.87, -11.49}, {-10.40, 0.86, -10.85} },
            { { -7.78, 0.88, -12.19}, { -7.78, 0.87, -11.49}, { -7.78, 0.86, -10.85} },
        },
        rot = {0,180,0}, lockPlaced = true, maxPerCol = 3, snapRadius2 = 9.0,
    },
    Yellow = {
        cols = {
            { {-1.06, 0.88, 19.55}, {-1.06, 0.86, 18.68}, {-1.06, 0.85, 17.80} },
            { {-3.68, 0.88, 19.55}, {-3.68, 0.86, 18.68}, {-3.68, 0.85, 17.80} },
            { {-6.37, 0.87, 19.55}, {-6.37, 0.86, 18.68}, {-6.37, 0.85, 17.80} },
        },
        rot = {0,0,0}, lockPlaced = true, maxPerCol = 3, snapRadius2 = 9.0,
    },
    Red = {
        cols = {
            { {24.15, 0.88, 19.55}, {24.15, 0.86, 18.68}, {24.15, 0.85, 17.80} },
            { {21.51, 0.88, 19.55}, {21.51, 0.86, 18.68}, {21.51, 0.85, 17.80} },
            { {18.82, 0.87, 19.55}, {18.82, 0.86, 18.68}, {18.82, 0.85, 17.80} },
        },
        rot = {0,0,0}, lockPlaced = true, maxPerCol = 3, snapRadius2 = 9.0,
    },
}

local function dist2_xyz(p, q)
    local dx = p[1] - q[1]
    local dz = p[3] - q[3]
    return dx*dx + dz*dz
end

local function objPosArray(obj)
    local p = obj.getPosition()
    return {p.x, p.y, p.z}
end

local function findObjInSlots(obj)
    for color,cols in pairs(DEED_SLOTS) do
        for c=1,3 do
            for i=1,3 do
                if cols[c][i] == obj then return color, c, i end
            end
        end
    end
    return nil
end

local function removeObjEverywhere(obj)
    for color,cols in pairs(DEED_SLOTS) do
        for c=1,3 do
            for i=1,3 do
                if cols[c][i] == obj then cols[c][i] = nil end
            end
        end
    end
end

local function compactColumn(color, col)
    local layout = DEED_LAYOUT[color]
    if not layout then return end
    local slots = DEED_SLOTS[color][col]

    local kept = {}
    for i=1,3 do
        local o = slots[i]
        if o and not o.isDestroyed() then table.insert(kept, o) end
    end

    DEED_SLOTS[color][col] = {nil,nil,nil}

    for i,o in ipairs(kept) do
        if i > layout.maxPerCol then break end
        local pos = layout.cols[col][i]
        o.setPositionSmooth(pos, false, true)
        o.setRotationSmooth(layout.rot, false, true)
        if layout.lockPlaced then o.locked = true end
        DEED_SLOTS[color][col][i] = o
    end
end

local function pickNearestColumn(color, obj)
    local layout = DEED_LAYOUT[color]
    if not layout then return nil end
    local p = objPosArray(obj)

    local bestCol, bestD = nil, nil
    for col=1,3 do
        local anchor = layout.cols[col][1]
        local d = dist2_xyz(p, anchor)
        if (not bestD) or d < bestD then bestD = d; bestCol = col end
    end
    if bestD and bestD <= layout.snapRadius2 then return bestCol end
    return nil
end

local function firstFreeSlot(color, col)
    for i=1,3 do
        if not DEED_SLOTS[color][col][i] then return i end
    end
    return nil
end

local function deedTuck_onDrop(player_color, obj)
    if not obj or not obj.hasTag("Deed") then return end
    local layout = DEED_LAYOUT[player_color]
    if not layout then return end

    local col = pickNearestColumn(player_color, obj)
    if not col then return end

    local slot = firstFreeSlot(player_color, col)
    if not slot then
        broadcastToAll(player_color.." deed column "..col.." is full (max 3).", {r=1,g=0.7,b=0.2})
        return
    end

    removeObjEverywhere(obj)
    obj.locked = false

    local pos = layout.cols[col][slot]
    obj.setPositionSmooth(pos, false, true)
    obj.setRotationSmooth(layout.rot, false, true)
    if layout.lockPlaced then obj.locked = true end

    DEED_SLOTS[player_color][col][slot] = obj
    compactColumn(player_color, col)
end

local function deedTuck_onPickUp(obj)
    if not obj or not obj.hasTag("Deed") then return end
    local color, col, slot = findObjInSlots(obj)
    if not color then return end
    obj.locked = false
    DEED_SLOTS[color][col][slot] = nil
    compactColumn(color, col)
end

---------------------------------------------------------------
-- ONE SET OF OBJECT HOOKS (merged)
---------------------------------------------------------------
function onObjectDrop(player_color, obj)
    if not obj then return end

    -- Character tile system
    if isCharacterCard(obj) then
        tryAssignCard(obj)
        maybeUnassignCard(obj)
    end

    -- Deed tuck system
    if obj.hasTag("Deed") then
        deedTuck_onDrop(player_color, obj)
    end
end

function onObjectPickUp(player_color, obj)
    if not obj then return end

    -- Character tile system
    if isCharacterCard(obj) then
        local guid = obj.getGUID()
        local miniGuid = CARD_TO_MINI[guid]
        if miniGuid then
            local mini = getObjectFromGUID(miniGuid)
            if mini then returnMiniHome(mini) end
        end
        CARD_OWNER[guid] = nil
        CARD_TO_MINI[guid] = nil
    end

    -- Deed tuck system
    if obj.hasTag("Deed") then
        deedTuck_onPickUp(obj)
    end
end

---------------------------------------------------------------
-- OPTIONAL LEGACY REPLACEMENT: Character cards entering zones
-- Uses tags instead of GUIDs:
--   zone_character_minis
--   zone_char_hand_Blue/Yellow/Red/Purple
---------------------------------------------------------------
function onObjectEnterScriptingZone(zone, obj)
    if not zone or not obj then return end
    if not isCharacterCard(obj) then return end

    local color = nil
    if zone.hasTag("zone_char_hand_Blue")   then color = "Blue" end
    if zone.hasTag("zone_char_hand_Yellow") then color = "Yellow" end
    if zone.hasTag("zone_char_hand_Red")    then color = "Red" end
    if zone.hasTag("zone_char_hand_Purple") then color = "Purple" end
    if not color then return end

    rebuildTagCache()
    local minisZone = getByTag("zone_character_minis")
    if not minisZone then return end

    local mini = nil
    for _, b in ipairs(minisZone.getObjects()) do
        if b and b.hasMatchingTag and b.hasMatchingTag(obj) then
            mini = b
            break
        end
    end

    if mini then
        local data = CHAR_TILES[color]
        if data and data.tint then mini.setColorTint(data.tint) end
        if data and data.dest then mini.setPositionSmooth(data.dest) end
    end
end

---------------------------------------------------------------
-- RESOURCE REQUEST BUTTON HELPER (unchanged)
---------------------------------------------------------------
local RESOURCE_TAGS = {"Coin","Fur","Wood","Fish","Honey","Ore"}
local COLOR_TAGS    = {"Blue","Purple","Yellow","Red"}

local function getFirstMatchingTag(obj, list)
    for _,t in ipairs(list) do
        if obj.hasTag(t) then return t end
    end
    return nil
end

local function supplyTagForResource(res)
    if res == "Coin"  then return "bag_coins" end
    if res == "Wood"  then return "bag_wood"  end
    if res == "Ore"   then return "bag_ore"   end
    if res == "Fish"  then return "bag_fish"  end
    if res == "Honey" then return "bag_honey" end
    if res == "Fur"   then return "bag_fur"   end
    return nil
end

function requestResourceToBag(params)
    local destBag = params and params.destBag
    local amount  = tonumber(params and params.amount) or 1
    if not destBag or destBag.type ~= "Bag" then return end

    local res = getFirstMatchingTag(destBag, RESOURCE_TAGS)
    if not res then
        broadcastToAll("RESOURCE: Inventory bag missing tags: Coin/Fur/Wood/Fish/Honey/Ore", {1,0.3,0.3})
        return
    end

    local supplyTag = supplyTagForResource(res)
    local supply = getByTag(supplyTag)
    if not supply then
        broadcastToAll("RESOURCE: Missing supply bag tag "..tostring(supplyTag), {1,0.3,0.3})
        return
    end

    for i=1, amount do
        supply.takeObject({
            position = destBag.getPosition() + Vector(0,2,0),
            smooth = false,
            callback_function = function(obj)
                if obj and not obj.isDestroyed() then
                    destBag.putObject(obj)
                end
            end,
            callback_owner = Global
        })
    end
end

---------------------------------------------------------------
-- UI HANDLERS (unchanged)
---------------------------------------------------------------
function UIHideSetupMenu()
    UI.hide("setupMenu")
    UI.show("setupMenuClosed")
end

function UIShowSetupMenu()
    UI.show("setupMenu")
    UI.hide("setupMenuClosed")
end

function playerAmountSelected(player, amount, id)
    rebuildTagCache()

    local a = string.lower(tostring(amount or ""))
    local n = 2
    if string.find(a, "4") then n = 4
    elseif string.find(a, "3") then n = 3 end

    local tracker = getByTag("tracker_player_count")
    if not tracker then
        broadcastToAll("UI ERROR: Missing object tagged 'tracker_player_count'.", {1,0.3,0.3})
        return
    end

    tracker.setGMNotes(tostring(n))
    broadcastToAll("UI selected "..n.." player", {0.8,0.8,0.8})
end

---------------------------------------------------------------
-- ADVISOR PAY SYSTEM (kept, but without overriding onLoad)
---------------------------------------------------------------
AdvisorPay = AdvisorPay or {}
AdvisorPay.activeAdvisorGUID = AdvisorPay.activeAdvisorGUID or nil
AdvisorPay.activePlayerColor = AdvisorPay.activePlayerColor or nil
AdvisorPay.currentAmount     = AdvisorPay.currentAmount or 0
AdvisorPay._panelBuilt       = AdvisorPay._panelBuilt or false

AdvisorPay.GLOW_COLOR    = {1, 0.8, 0.15}
AdvisorPay.GLOW_DURATION = 999999

AdvisorPay.PANEL_TAG = "Advisor_Pay"
AdvisorPay.COIN_SPOT_TAG = "Coin Spot"

function noop() end

local function _hasTag(o, t) return o and o.hasTag and o.hasTag(t) end
local function _isPlayerColor(color) return color=="Blue" or color=="Yellow" or color=="Red" or color=="Purple" end

local function _findByTag(tag)
    for _,o in ipairs(getAllObjects()) do
        if o and o.hasTag and o.hasTag(tag) then return o end
    end
    return nil
end

local function _applyGlow(obj)
    if obj and not obj.isDestroyed() and obj.highlightOn then
        obj.highlightOn(AdvisorPay.GLOW_COLOR, AdvisorPay.GLOW_DURATION)
    end
end

local function _removeGlow(obj)
    if obj and not obj.isDestroyed() and obj.highlightOff then
        obj.highlightOff()
    end
end

local function _findPlayerCoinBag(playerColor)
    if not _isPlayerColor(playerColor) then return nil end
    for _,o in ipairs(getAllObjects()) do
        if o and o.type=="Bag" and o.hasTag and o.hasTag("Coin") and o.hasTag(playerColor) then
            return o
        end
    end
    return nil
end

local function _getActiveAdvisor()
    if not AdvisorPay.activeAdvisorGUID then return nil end
    local a = getObjectFromGUID(AdvisorPay.activeAdvisorGUID)
    if not a or a.isDestroyed() then return nil end
    if not _hasTag(a, "Advisor") then return nil end
    return a
end

local function _clearSelectionAndTotal()
    local a = _getActiveAdvisor()
    if a then _removeGlow(a) end
    AdvisorPay.activeAdvisorGUID = nil
    AdvisorPay.activePlayerColor = nil
    AdvisorPay.currentAmount = 0
    AdvisorPay.updatePanelDisplay()
end

local function _snapPointHasTag(sp, wanted)
    if not sp or not sp.tags then return false end
    for _,t in ipairs(sp.tags) do
        if t == wanted then return true end
    end
    return false
end

local function _advisorCoinSpotWorldPos(advisorObj)
    if advisorObj and advisorObj.getSnapPoints and advisorObj.positionToWorld then
        local sps = advisorObj.getSnapPoints()
        if sps then
            for _,sp in ipairs(sps) do
                if _snapPointHasTag(sp, AdvisorPay.COIN_SPOT_TAG) then
                    local world = advisorObj.positionToWorld(sp.position)
                    return {world.x, world.y, world.z}
                end
            end
        end
    end

    if advisorObj and advisorObj.getBoundsNormalized then
        local b = advisorObj.getBoundsNormalized()
        local c = b.center
        local s = b.size
        return {c.x, c.y + (s.y/2) + 0.35, c.z}
    end
    return nil
end

function AdvisorPay_proxyBribe(params)
    if type(params) ~= "table" then return end
    local guid = params.guid
    local playerColor = params.playerColor
    local alt_click = params.alt_click
    if not guid or not playerColor then return end
    if not _isPlayerColor(playerColor) then return end
    local advisorObj = getObjectFromGUID(guid)
    if not advisorObj or (advisorObj.isDestroyed and advisorObj.isDestroyed()) then return end
    AdvisorPay_onBribePressed(advisorObj, playerColor, alt_click)
end

function AdvisorPay_onBribePressed(advisorObj, playerColor, alt_click)
    if not advisorObj or advisorObj.isDestroyed() then return end
    if not _hasTag(advisorObj, "Advisor") then return end
    if not _isPlayerColor(playerColor) then return end

    local prev = _getActiveAdvisor()
    if prev and prev ~= advisorObj then _removeGlow(prev) end

    AdvisorPay.activeAdvisorGUID = advisorObj.getGUID()
    AdvisorPay.activePlayerColor = playerColor
    AdvisorPay.currentAmount = 0
    AdvisorPay.updatePanelDisplay()
    _applyGlow(advisorObj)

    broadcastToColor("Bribe target selected.", playerColor, {0.85,0.85,0.85})
end

function AdvisorPay.updatePanelDisplay()
    local panel = _findByTag(AdvisorPay.PANEL_TAG)
    if not panel then return end
    if AdvisorPay.TOTAL_BUTTON_INDEX == nil then return end
    panel.editButton({
        index = AdvisorPay.TOTAL_BUTTON_INDEX,
        label = "TOTAL: " .. tostring(AdvisorPay.currentAmount)
    })
end

local function _adjustAmount(delta)
    if not _getActiveAdvisor() then return end
    AdvisorPay.currentAmount = math.max(0, AdvisorPay.currentAmount + delta)
    AdvisorPay.updatePanelDisplay()
end

function AdvisorPay_plus1(_, playerColor)  _adjustAmount( 1) end
function AdvisorPay_plus2(_, playerColor)  _adjustAmount( 2) end
function AdvisorPay_plus5(_, playerColor)  _adjustAmount( 5) end
function AdvisorPay_minus1(_, playerColor) _adjustAmount(-1) end
function AdvisorPay_minus2(_, playerColor) _adjustAmount(-2) end
function AdvisorPay_minus5(_, playerColor) _adjustAmount(-5) end

function AdvisorPay_cancel(btnObj, playerColor, alt_click)
    _clearSelectionAndTotal()
end

local function _spawnCoinsToAdvisor(playerColor, advisorObj, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    local bag = _findPlayerCoinBag(playerColor)
    if not bag then
        broadcastToColor("No coin bag found for "..playerColor..". Tag your bag with 'Coin' and '"..playerColor.."'.", playerColor, {1,0.6,0.2})
        return false
    end

    local base = _advisorCoinSpotWorldPos(advisorObj)
    if not base then return false end

    local offsets = {
        { 0.00, 0.00, 0.00},
        { 0.22, 0.00, 0.00},
        {-0.22, 0.00, 0.00},
        { 0.00, 0.00, 0.22},
        { 0.00, 0.00,-0.22},
    }

    for i=1, amount do
        local off = offsets[((i-1) % #offsets) + 1]
        local pos = { base[1] + off[1], base[2] + 0.12*(i-1), base[3] + off[3] }
        bag.takeObject({ position = pos, rotation = {0,0,0}, smooth = true })
    end

    return true
end

function AdvisorPay_pay(btnObj, playerColor, alt_click)
    local amt = tonumber(AdvisorPay.currentAmount) or 0
    if amt <= 0 then return end

    local payer = AdvisorPay.activePlayerColor or playerColor
    if not _isPlayerColor(payer) then payer = playerColor end
    if not _isPlayerColor(payer) then return end

    local advisor = _getActiveAdvisor()
    if not advisor or (advisor.isDestroyed and advisor.isDestroyed()) then
        broadcastToColor("No valid Advisor selected.", payer, {1,0.6,0.2})
        _clearSelectionAndTotal()
        return
    end

    local ok = _spawnCoinsToAdvisor(payer, advisor, amt)
    if ok then
        broadcastToColor("Paid "..tostring(amt).." coin(s).", payer, {0.8,0.9,0.8})
        _clearSelectionAndTotal()
    else
        broadcastToColor("Payment failed (missing coin bag or coin spot).", payer, {1,0.6,0.2})
    end
end

function AdvisorPay.buildPaymentPanel(force)
    local panel = _findByTag(AdvisorPay.PANEL_TAG)
    if not panel then
        broadcastToAll("AdvisorPay: Missing object tagged 'Advisor_Pay'", {1,0.4,0.4})
        return
    end

    if AdvisorPay._panelBuilt and not force then return end
    panel.clearButtons()

    local BTN_Y = 0.25
    local ROW1_Z = 0.80
    local ROW2_Z = 0.05
    local ROW3_Z = -0.70

    local spacing = 1.25
    local startX = -((6 - 1) * spacing) / 2

    local btns = {
        {label="-5", fn="AdvisorPay_minus5"},
        {label="-2", fn="AdvisorPay_minus2"},
        {label="-1", fn="AdvisorPay_minus1"},
        {label="+1", fn="AdvisorPay_plus1"},
        {label="+2", fn="AdvisorPay_plus2"},
        {label="+5", fn="AdvisorPay_plus5"},
    }

    for i,b in ipairs(btns) do
        panel.createButton({
            click_function = b.fn,
            function_owner = Global,
            label          = b.label,
            position       = { startX + spacing*(i-1), BTN_Y, ROW1_Z },
            rotation       = {0,180,0},
            width          = 520,
            height         = 360,
            font_size      = 185,
            color          = {0.2,0.2,0.2,0.95},
            font_color     = {1,1,1,1},
            tooltip        = "Adjust bribe total"
        })
    end

    panel.createButton({
        click_function = "noop",
        function_owner = Global,
        label          = "TOTAL: 0",
        position       = {0, BTN_Y, ROW2_Z},
        rotation       = {0,180,0},
        width          = 1800,
        height         = 320,
        font_size      = 210,
        color          = {0,0,0,0.8},
        font_color     = {1,1,1,1},
        tooltip        = ""
    })
    AdvisorPay.TOTAL_BUTTON_INDEX = #panel.getButtons()

    panel.createButton({
        click_function = "AdvisorPay_cancel",
        function_owner = Global,
        label          = "CANCEL",
        position       = {-1.35, BTN_Y, ROW3_Z},
        rotation       = {0,180,0},
        width          = 950,
        height         = 380,
        font_size      = 200,
        color          = {0.55,0.2,0.2,0.95},
        font_color     = {1,1,1,1},
        tooltip        = "Clear selection and total"
    })

    panel.createButton({
        click_function = "AdvisorPay_pay",
        function_owner = Global,
        label          = "PAY",
        position       = {1.35, BTN_Y, ROW3_Z},
        rotation       = {0,180,0},
        width          = 950,
        height         = 380,
        font_size      = 200,
        color          = {0.2,0.55,0.2,0.95},
        font_color     = {1,1,1,1},
        tooltip        = "Take coins from your bag and place onto the selected Advisor"
    })

    AdvisorPay._panelBuilt = true
    AdvisorPay.updatePanelDisplay()
end
-----------------------------------------------		
	-- Wait Frames

	function waitAmount(amount)
		local initial = os.time()
		local final = initial + (amount/5)
		
		while final > os.time() do
			coroutine.yield(0)
		end
	end 
------------------------------------------

	AdvisorsBlue = {
		{-14.82, 1.2, -16.98},
		{-13.97, 1.2, -16.98},
		{-13.12, 1.2, -16.96},
		{-12.26, 1.2, -16.96},
		{-11.38, 1.2, -16.94},
	}
	
	AdvisorsRed = {
		{22.72, 1.2, 24.39},
		{21.86, 1.2, 24.39},
		{20.99, 1.2, 24.40},
		{20.15, 1.2, 24.40},
		{19.25, 1.2, 24.38},
	}
	
	AdvisorsPurple = {
		{6.21, 1.2, -16.94},
		{7.06, 1.2, -16.94},
		{7.91, 1.2, -16.93},
		{8.77, 1.2, -16.92},
		{9.63, 1.2, -16.93},
	}
	
	AdvisorsYellow = {
		{1.37, 1.2, 24.44},
		{0.49, 1.2, 24.44},
		{-0.35, 1.2, 24.43},
		{-1.23, 1.2, 24.44},
		{-2.11, 1.2, 24.44},
	}
	
	Bowl = {
		{-11.51, 1.4, -18.60},
		{19.38, 1.4, 26.00},
		{9.54, 1.4, -18.60},
		{-1.95, 1.4, 26.00},
	}

	CoinsBlue = {
		{-13.52, 1.2, -20},
		{-12.83, 1.2, -20},
		{-12.15, 1.2, -20},
		{-11.47, 1.2, -20},
	}
	
	CoinsRed = {
		{21.60, 1.2, 27.5},
		{20.91, 1.2, 27.5},
		{20.23, 1.2, 27.5},
		{19.54, 1.2, 27.5},
	}
	
	CoinsPurple = {
		{7.43, 1.2, -20},
		{8.12, 1.2, -20},
		{8.80, 1.2, -20},
		{9.48, 1.2, -20},
	}
	
	CoinsYellow = {
		{0.20, 1.2, 27.5},
		{-0.48, 1.2, 27.5},
		{-1.17, 1.2, 27.5},
		{-1.85, 1.2, 27.5},
	}

	Deeds1Position = {
		{26.58, 0.89, 11.36},
		{26.58, 0.89, 8.94},
		{26.58, 0.89, 6.51},
		{26.58, 0.89, 4.06},
		{26.58, 0.89, 1.62},
	}
	
	Deeds2Position = {
		{29.92, 0.89, 11.30},
		{29.92, 0.89, 8.94},
		{29.92, 0.89, 6.51},
		{29.92, 0.89, 4.06},
		{29.92, 0.89, 1.62},
	}
	
	Rebel2Regions = {
		{14.53, 1.08, -2.07},
		{10.31, 1.17, 3.00},
		{6.57, 2.0, 3.69},
		{13.21, 1.14, 4.86},
		{11.62, 1.17, 1.82},
		{1.30, 2.0, 0.32},
		{0.56, 1.17, 6.38},
		{5.49, 1.17, 0.44},
	}
	
	OrdersBlueAttack = {
		{-9.76, 1.2, -17.11},
		{-8.56, 1.2, -17.14},
		{-7.38, 1.2, -17.14},
	}
	
	OrdersBlueMove = {
		{-9.73, 1.2, -18.32},
		{-8.56, 1.2, -18.32},
		{-7.38, 1.2, -18.32},
	}
	
	OrdersRedAttack = {
		{17.69, 1.2, 24.53},
		{16.51, 1.2, 24.53},
		{15.34, 1.2, 24.53},
	}
	
	OrdersRedMove = {
		{17.69, 1.2, 25.70},
		{16.50, 1.2, 25.70},
		{15.34, 1.2, 25.70},
	}
	
	OrdersPurpleAttack = {
		{11.24, 1.2, -17.19},
		{12.41, 1.2, -17.19},
		{13.59, 1.2, -17.19},
	}
	
	OrdersPurpleMove = {
		{11.24, 1.2, -18.36},
		{12.41, 1.2, -18.36},
		{13.59, 1.2, -18.36},
	}
	
	OrdersYellowAttack = {
		{-3.76, 1.2, 24.43},
		{-4.94, 1.2, 24.43},
		{-6.12, 1.2, 24.44},
	}
	
	OrdersYellowMove = {
		{-3.76, 1.2, 25.61},
		{-4.94, 1.2, 25.61},
		{-6.11, 1.2, 25.61},
	}
	
	Rebel3Regions = {
		{0.47, 2.0, -4.98},
		{19.40, 2.0, -3.39},
		{3.71, 1.28, 11.11},
	}
	
	Rebel4Regions = {
		{18.79, 2.0, 8.88},
		{22.79, 2.0, 1.69},
		{8.29, 2.0, -7.48},
		{6.67, 2.0, 11.77}
	}
	
	ResourcesOn2Regions = {
		{13.74, 1.08, -3.67},
		{10.89, 1.08, 5.15},
		{6.52, 1.08, 4.65},
		{13.94, 1.08, 7.32},
		{1.21, 1.08, 1.53},
		{12.31, 1.08, -0.03},
		{1.70, 1.08, 8.22},
		{6.37, 1.08, -1.34},
	}
	
	ResourcesOn3Regions = {
		{0.46, 1.2, -3.42},
		{19.24, 1.2, -2.39},
		{2.93, 1.2, 12.35},
	}
	
	ResourcesOn4Regions = {
		{17.15, 1.2, 12.07},
		{22.13, 1.2, 0.33},
		{8.30, 1.2, -6.10},
		{10.05, 1.2, 11.79},
	}
	
	RoundToken = {
		{-14.07, 1.06, 7.04},
		{-14.07, 1.06, 8.14},
		{-14.07, 1.06, 9.31},
	}
	
	StartingPlayerToken = {
		{21.14, 1.56, -10.98},
		{12.63, 1.56, 18.38},
		{-1.74, 1.56, -11.01},
		{-12.76, 1.56, 18.52},
	}
	
	StartingPlayerTokenRotation = {
		{0, 180, 0},
		{0, 0, 0},
		{0, 180, 0},
		{0, 0, 0},
	}
	
	
-- Bagcoi GMNotes = Current game round (number)
-- Bagfis GMNotes = Working ("yes" or void)
-- Baghon GMNotes = Player amount (number)
-- Bagfur GMNotes = Selected player amount (number)
-- Bagwoo GMNotes = 
-- Bagore GMNOtes = 