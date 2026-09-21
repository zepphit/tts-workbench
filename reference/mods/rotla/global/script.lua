--Any line proceeded by -- is a lua comment, and can safely be deleted.

--This script is powered by 18Engine, an easy-to-use, all-purpose script for 18xx games.
--https://github.com/goldencow2/18Engine/wiki

USE_SAVES = true
--set this to false while editing your mod or treasuries will persist.
--set this to true, copy in the script, use "save and play" from the modding menu, and then actually save your mod to enable saves (TTS is dumb).
--WARNING: If you intend on modifying any gameOptions, turn use_saves to false first.
---------- As of this writing this should only be an issue for BANK_SIZE.

gameOptions = {
    CHARTER_SHARES_PAY_COMPANY = true,
    TRACK_ON_RIGHT_CLICK = false,
    BANK_SIZE = 8000
}

gameEntities = {
    OTHER_ACTORS = {
            ['BANK'] = {
                moneyLabelGUID = 'bf2867',
            },
            ['PRIVATES'] = {
                payPrivatesButtonGUID = ''
            },
            ['REVENUE_TRACKER'] = {
                {['GUID']='e81db6', ['ROWS']=14, ['COLS']=1, ['START']=1, ['REVERSE_ROWS']=true},
                {['GUID']='c5bb7c', ['ROWS']=14, ['COLS']=1, ['START']=15, ['REVERSE_ROWS']=true},
                {['GUID']='43ae52', ['ROWS']=14, ['COLS']=1, ['START']=29, ['REVERSE_ROWS']=true},
                {['GUID']='3c5749', ['ROWS']=14, ['COLS']=1, ['START']=43, ['REVERSE_ROWS']=true},
                {['GUID']='07b4a6', ['ROWS']=14, ['COLS']=1, ['START']=57, ['REVERSE_ROWS']=true},
            },


    }, COMPANIES = {
            --Minors
            ['Northern Port'] = {
                inputCounterGUID = 'c0aee6',
                moneyLabelGUID = '204513',
                charterGUID = '31f938',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = '7a009f',
            },
            ['Suburban'] = {
                inputCounterGUID = 'd9247a',
                moneyLabelGUID = '869be3',
                charterGUID = 'c8c4f4',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = '48834b',
            },
            ['Express'] = {
                inputCounterGUID = 'dbb296',
                moneyLabelGUID = '6f3637',
                charterGUID = 'f6da0c',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = '986f07',
            },
            ['Eastern Mining'] = {
                inputCounterGUID = '38f99d',
                moneyLabelGUID = '375e6d',
                charterGUID = 'a14c9d',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = 'bf301f',
            },
            ['Expansive'] = {
                inputCounterGUID = '587bcc',
                moneyLabelGUID = '15fc6a',
                charterGUID = '9215dc',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = 'aef755',
            },
            ['Overnight'] = {
                inputCounterGUID = '0e37d2',
                moneyLabelGUID = '654184',
                charterGUID = 'faeeff',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = 'd0fc4f',
            },
            ['Resourceful'] = {
                inputCounterGUID = '712771',
                moneyLabelGUID = 'aaa3d5',
                charterGUID = 'c09768',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = '375a2a',
            },
            ['Agricultural'] = {
                inputCounterGUID = '29584c',
                moneyLabelGUID = 'e3273c',
                charterGUID = 'fbc699',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = '45e65e',
            },
            ['Tunneling'] = {
                inputCounterGUID = 'd52ab1',
                moneyLabelGUID = '005127',
                charterGUID = '66c514',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = '19beb0',
            },
            ['Spacious'] = {
                inputCounterGUID = '5fcac2',
                moneyLabelGUID = '3f14d0',
                charterGUID = 'edf702',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = '107bd9',
            },
            ['Adaptive'] = {
                inputCounterGUID = '2aa20c',
                moneyLabelGUID = '6f97d5',
                charterGUID = '128794',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = 'f13c32',
            },
            ['Bridging'] = {
                inputCounterGUID = 'b5968c',
                moneyLabelGUID = 'd712db',
                charterGUID = '9d067d',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = 'd58d5a',
            },

            ['Circus'] = {
                inputCounterGUID = '3d1ebc',
                moneyLabelGUID = '41d81a',
                charterGUID = 'e2ca7c',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = 'df8140',
            },
            ['Manufacturing'] = {
                inputCounterGUID = 'd29571',
                moneyLabelGUID = 'e20dfe',
                charterGUID = 'a73c21',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = '33d61a',
            },
            ['Coupling'] = {
                inputCounterGUID = '180400',
                moneyLabelGUID = '179f9a',
                charterGUID = '6b4c4c',
                ISSUE_SIZE = 5,
                LABEL_COLOR = 'White',
                ['revenueTrackerGUID'] = 'da188d',
            },
            ['Twin Cities'] = {
                inputCounterGUID = '33218a',
                moneyLabelGUID = 'dc9bc5',
                charterGUID = 'fb6855',
                ISSUE_SIZE = 5,
                ['revenueTrackerGUID'] = '3ce219',
            },

            --MAJORS
            ['CONSORTIUM'] = {
                inputCounterGUID = 'd7e9e9',
                moneyLabelGUID = '1f4665',
                charterGUID = '642908',
                ['revenueTrackerGUID'] = '73e7ea',
            },
            ['INTERNATIONAL'] = {
                inputCounterGUID = 'afb153',
                moneyLabelGUID = 'ecc6d7',
                charterGUID = '315596',
                ['revenueTrackerGUID'] = '4cdf45',
            },

            ['EXPERIMENT'] = {
                inputCounterGUID = '11efa7',
                moneyLabelGUID = 'a9c257',
                charterGUID = '3a8db6',
                ['revenueTrackerGUID'] = '7395e3',
            },

            ['FEDERATION'] = {
                inputCounterGUID = '3d63b6',
                moneyLabelGUID = '092918',
                charterGUID = 'a578a9',
                ['revenueTrackerGUID'] = 'ec5f4b',
            },

            ['UNION'] = {
                inputCounterGUID = '24d1fb',
                moneyLabelGUID = '2d6d8f',
                charterGUID = 'f65752',
                ['revenueTrackerGUID'] = 'dd60a3',
            },

            ['SYSTEM'] = {
                inputCounterGUID = '1dfcac',
                moneyLabelGUID = 'ef912c',
                charterGUID = 'f2d29d',
                ['revenueTrackerGUID'] = '5724c7',
            },

            ['AUTHORITY'] = {
                inputCounterGUID = 'f6b4be',
                moneyLabelGUID = '9c8f0b',
                charterGUID = 'e4dcd0',
                ['revenueTrackerGUID'] = '906b3b',
            },

            ['LEAGUE'] = {
                inputCounterGUID = '256aa4',
                moneyLabelGUID = 'dbbeab',
                charterGUID = '57494a',
                ['revenueTrackerGUID'] = '11640e',
            },

            --National
            ['Metropolitan'] = {
                inputCounterGUID = '312091',
                charterGUID = '6a5bb2',
                ['revenueTrackerGUID'] = '4cfd81',
                COMPANIES_CAN_BANK_TRANSFER = false,
            },


            --- etc.

    }, PLAYERS = {
        ['Red'] = {
            inputCounterGUID = '0e212c',
            moneyLabelGUID = '6b135b',
        },
        ['Blue'] = {
            inputCounterGUID = '589181',
            moneyLabelGUID = 'dfe277',
        },
        ['Yellow'] = {
            inputCounterGUID = 'ddc5e6',
            moneyLabelGUID = 'b15b83',
        },
        ['Green'] = {
            inputCounterGUID = '8ac938',
            moneyLabelGUID = '026a61',
        },
        ['Orange'] = {
            inputCounterGUID = '6d1d50',
            moneyLabelGUID = '6d9d6a',
        },
        ['Purple'] = {
            inputCounterGUID = 'e89072',
            moneyLabelGUID = '5ca31d',
        },
        ['Brown'] = {
            inputCounterGUID = '0fb802',
            moneyLabelGUID = '2c8f6d',
        },

    }
}

---VERSION 2.96, copy and paste everything below this line to update!

-----You probably shouldn't edit these unless you know what you're doing.
    -----They can be overwritten by including the option in gameOptions.
gameOptionDefaults = {
    COMPANIES_CAN_FULL_PAY = true,
    COMPANIES_CAN_HALF_PAY = false,

    HALF_PAY_ROUND = 10, --Round the payout of a half-pay to the nearest multiple of this, in favor of the players.
    -- this can be entered as a table, e.g, HALF_PAY_ROUND = {2,5,10} if you are using multiple values for ISSUE_SIZE (see below)

    BANK_SIZE = nil,
    TRANSACTION_LOG_GUID = nil,
    MONEY_SYMBOL = nil,
    MONEY_SYMBOL_POSITION = nil, --'end' to put at end.
    BANK_POOL_SHARES_PAY_COMPANY = false,
    BANK_POOL_ZONE_GUID = nil,
    IPO_SHARES_PAY_COMPANY = false,
    IPO_ZONE_GUID = nil,
    CHARTER_SHARES_PAY_COMPANY = false,

    COMPANIES_CAN_CROSS_INVEST = false,
    COMPANIES_CAN_OWN_OTHER_SHARES = true,
    --Bad wording, kept for backwards compatibility.
    --If COMPANIES_CAN_CROSS_INVEST is set to true for Company A, then Companies B, C, D, etc. can own shares in Company A.
    --If COMPANIES_CAN_OWN_OTHER_SHARES is set to true for Company A, then Company A can own shares in Companies B, C, D, etc. but only if COMPANIES_CAN_CROSS_INVEST is set to true for those companies.
    --If all companies can own shares in all companies, then just set COMPANIES_CAN_CROSS_INVEST to true in global and you're done.
    --If a single company can own shares in any company then set COMPANIES_CAN_CROSS_INVEST to true in global, COMPANIES_CAN_OWN_OTHER_SHARES to false in global, and COMPANIES_CAN_OWN_OTHER_SHARES to true for that one company.

    SHARE_DESCRIPTIONS_ARE_PERCENTAGE = false, --The number appended to a share's description is the % of the revenue it will receive e.g 'B&O20' = 20%, 'UdW5' = 5%
    USE_PRIVATES = false, --If set to true, script expects you to supply a GUID for an object to stick a "pay privates" button on.
    COMPANIES_CAN_OWN_PRIVATES = true, --if set to false, the script won't ask you to supply charter GUIDs

    COMPANY_CHARTERS_ARE_SHARES = false, --The charter itself represents 1 share.
    --This will also set the company to assume only 1 share exists, and the player who presses the payout button will be paid for it.
    --This also sets the HALF_PAY_ROUND for the company to 1.

    PROPORTIONAL_PAYOUTS = false,
    -- The payout per share will be the total dividend divided by the number of shares paid.
    -- e.g, if only 7 shares are owned by players/companies then the dividend is split 7 ways.
    -- The per-share (not total) dividend is rounded up.

    ISSUE_SIZE = 10,
    --how many shares the company has. Irrelevant if SHARE_DESCRIPTIONS_ARE_PERCENTAGE is set.
    --If entered as a table, e.g, ISSUE_SIZE = {2,5,10},
    --then a button is created allowing the company to change issue size mid-game, defaulting to the first value listed.

    COMPANY_CREDITS = false,
    -- Companies will not take from or give money to the bank. Only relevant if BANK_SIZE is set.

    COMPANIES_CAN_BANK_TRANSFER = true,
    -- If false, the script won't spawn buttons for "take money" and "spend money"

    --NAME = 'name',
    --! Don't uncomment this, it's documentation. !
    --setting a company's NAME option will print that name in the logs instead of the table name.

    COMPANIES_PAY_FLAT_RATE = false, --Each share earns the amount entered into the counter, instead of dividing the amount between them.
    --If SHARE_DESCRIPTIONS_ARE_PERCENTAGE, then the amount entered is paid for each 10% the owner holds.

    HAND_SHARES_PAY_PLAYER = true, -- if set to false, shares and privates in the players hands will not pay money.

    TRACK_REVENUE = true, --If true, companies will automatically track revenue.
    ADJUST_INPUT_BY_REVENUE = true, -- If true, companies will adjust their input counters automatically when a revenue marker is placed.
    --Both options are ignored if the revenue tracker isn't being used (see documentation).

    TRACK_ON_RIGHT_CLICK = true,
    -- If true, right clicking payout/half-pay will move the corresponding revenue tracker.
    -- If false, left clicking will move it and right clicking will not.

    TRACK_REVENUE_PER_SHARE = false,
    --By default, the automatic revenue tracker assumes revenue is being tracker per-share.
    --E.g, '18' for a 5-share company is a total revenue of $90 but '18' for a 10-share company is a total revenue of $180 and the input counter will be set appropriately.
    --If this is set to true, then the set companies are tracked as if they were 10-shares regardless of size, e.g, placing the tracker down on '18' sets the input counter to $180.

    PRIVATES_USE_GM_NOTES = false, --If set to true, the script will look for the 'Private#' string in the GM Notes field (change your color to black and right click the object)

    COMPANIES_PAY_FROM_TREASURY = false, --When a company pays out the money comes from its treasury rather than the bank. A message will display if there isn't enough money.

    LABEL_COLOR = {0,0,0}, --the color of a player/company's label text. Red, Green, Blue; values range from 0 to 1 (not 0 to 255).
}

-----YOU DO NOT NEED TO EDIT ANYTHING BELOW THIS LINE-----
SAVE_STATE = {
    versionNumber = 2.95
}

function onSave()
    --saved_data = JSON.encode(gameEntities)
    if not USE_SAVES then
        saved_data = ''
    else
        --bank amount
        SAVE_STATE['Bank Treasury'] = gameEntities.OTHER_ACTORS['BANK'].treasury

        --company treasuries, company issue sizes and issue indicies
        for k,company in pairs(gameEntities.COMPANIES) do
            SAVE_STATE['Company ' .. k] = company.treasury
            if (type(company.ISSUE_SIZE) == 'table') then
                SAVE_STATE['CompanyIS' .. k] = company.issueSize
                SAVE_STATE['CompanyII' .. k] = company.issueIndex
            end

        end

        --player treasuries
        for k,player in pairs(gameEntities.PLAYERS) do
            SAVE_STATE['Player ' .. k] = player.treasury
        end

        saved_data = JSON.encode(SAVE_STATE)
    end
    return saved_data
end

function onload(saved_data)
    if saved_data~='' then
        SAVE_STATE = JSON.decode(saved_data)
    end

    --necessary default crap due to privates copying code from companies.
    if gameOptions.HAND_SHARES_PAY_PLAYER == nil then
        gameOptions.HAND_SHARES_PAY_PLAYER = true
    end

    INVESTABLE_COMPANY_EXISTS = checkInvest()

    initCompanies()
    initPlayers()
    initBank()
    initPrivates()
    initLog()
    initIPO()
    initBankPool()
    initRevenue()

    --UI
    if getObjectFromGUID('3835be') then
        createSetupButtons()
    else
    end
end

function string.split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function table.shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

function createSetupButtons()

    FLAGS = {
        --base options
        ['LONG_GAME'] = true,
        ['SHORT_GAME'] = false,
        ['RANDOMIZED_SHORT_GAME'] = false,
        ['MICRO_GAME_2'] = false,
        ['MICRO_GAME_3'] = false,

        ['RANDOMIZE_MINORS'] = false,

        ['USE_OPTIONALS'] = false,

        ['DISTANT_CONNECTIONS'] = false,

        --Landmarks Expansion
        ['USE_LANDMARKS'] = false,
        ['USE_LANDMARKS_AUTO'] = false,
        ['USE_LANDMARKS_MANUAL'] = false,

        ['USE_METRO'] = false,

        ['USE_EVENTS'] = false,

        ['USE_NEW_MINORS'] = false,

        ['USE_ONLY_NEW_MINORS'] = false,

        ['USE_CROWDED'] = false,

        ['USE_SUB_TILES'] = false,

        --[''] = false,
    }

    BUTTON_Y = 0
    BUTTON_SCALE = 1

    createToggle('6b1f4a', ' Long Game', 5800, 1200, "The full game using every map tile and Minor Company.\n\n[i]Note: Not recommended with 2 players.[/i]")
    createToggle('968a28', ' Short Game', 5800, 1200, "The short game using fewer map tiles and 8 Minor Companies.\n\n[i]Note: Not recommended with 5 players.[/i]")
    createToggle('c9e5d2', ' Random\nShort Game', 5800, 2000, "The short game, but with a random selection of 8 Minor Companies.")
    createToggle('026ddf', ' Micro Game\n[i](2 Players)[/i]', 5800, 2000, "The smallest game, with only 4 Minor Companies.")
    createToggle('68cf90', ' Micro Game\n[i](3 Players)[/i]', 5800, 2000, "The smallest game, with only 6 Minor Companies.")

    --createToggle('217d0e', ' Distant\nConnections', 5800, 2000, "The map tiles will be divided into 3 [i](2)[/i] stacks to make 3 [i](2)[/i] separate maps in the long [i](short)[/i] game. Trains can cross from map to map using the Distant Destination tiles.\n\n[i]Note: Not compatible with the Micro Game.[/i]")

    createGroup({'6b1f4a','968a28','c9e5d2','026ddf','68cf90',})

    createLabel('077047','Landmarks')

    createToggle('c719e3', ' Landmarks', 5800, 1200, "Include 3 random Landmark tiles.")
    createToggle('7a1456', ' Landmarks\n[i](manual)[/i]', 5800, 2000, "Use Landmarks, but you can decide what tiles to add before building the map.")
    createGroup({'c719e3','7a1456'})

    createToggle('a114c2', ' Metropolitan', 5800, 1200, "Use the neutral Metropolitan Corporation.")

    createToggle('f16f9f', ' Events', 5800, 1200, "Add event cards which change the rules each cycle.\n\nNote: This will include all of the New City Herald events but any extras can be ignored unless playing with the bank breaking variant.")

    createToggle('94bbb2', ' New Minors', 5800, 1200, "Add the 4 new minor Companies. The Companies in play will be randomly selected.")
    createToggle('8ef4eb', ' New Minors\n[i](always)[/i]', 5800, 2000, "Add the 4 new minor Companies and ensure that they are included in the game.")
    createGroup({'94bbb2','8ef4eb'})

    createToggle('a703b6', ' Crowded Map', 5800, 1200, "Play with 4 additional Companies on the same size of map [i](16 Companies in the long game, 12 in the short)[/i].")

    createToggle('3b34ec', ' Sub Tiles', 5800, 1200, "Add 2 new terrain tiles, then randomly remove 2 terrain tiles for even more map variety.")

    createToggle('c27a49', ' Optional\nTrains [i](2-3p)[/i]', 5800, 2000, "An extra 3-train and 5-train are included when playing with 4 or more players.\n\nSelect this option to include these trains with less than 4 players.")

    PLAYER_COUNT = math.min(math.max(#getSeatedPlayers(), 1),7)
    local board = getObjectFromGUID('3835be')
    local bScale = 0.4*board.getScale()

    board.createButton({
        label="Start Game",
        width = 3300,
        height = 699,
        position = {0/bScale.x,0.5,0/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "startGame",
        --tooltip = "Make sure all players are seated before pressing Start Game!",
        color = {218/255,173/255,51/255},
    })
    board.createButton({
        label="<",
        width = 500,
        height = 699,
        position = {-4/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "pCountDec",
        color = {218/255,173/255,51/255},
    })
    board.createButton({
        label=">",
        width = 500,
        height = 699,
        position = {4/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "pCountInc",
        color = {218/255,173/255,51/255},
    })
    board.createButton({
        label="Players: " .. tostring(PLAYER_COUNT),
        width = 3300,
        height = 699,
        position = {0/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "empty",
        color = {218/255,173/255,51/255},
    })
    board.createButton({
        label="Manual Setup",
        width = 5000,
        height = 699,
        position = {0/bScale.x,0.5,1.5/bScale.z},
        scale = {0.5/bScale.x,0.5,0.5/bScale.z},
        font_size = 549,
        click_function = "manual",
    })
end

function pCountInc()
    PLAYER_COUNT = PLAYER_COUNT + 1
    if PLAYER_COUNT > 7 then PLAYER_COUNT = 1 end
    updateBoard()
end
function pCountDec()
    PLAYER_COUNT = PLAYER_COUNT - 1
    if PLAYER_COUNT < 1 then PLAYER_COUNT = 7 end
    updateBoard()
end

function updateBoard()
    local board = getObjectFromGUID('3835be')
    board.editButton({index=3, label="Players: " .. PLAYER_COUNT})
end

function onPlayerChangeColor(color)
    if getObjectFromGUID('3835be') then
        PLAYER_COUNT = math.min(math.max(#getSeatedPlayers(), 1),7)
        updateBoard()
    end
end

function manual()
    for _,obj in ipairs(getAllObjects()) do
        if obj.hasTag("UI") then obj.destruct() end
    end
    Notes.setNotes("")
    unlockStuff()
end

function createGroup(t)
    for _,g in ipairs(t) do
        FLAGS[g] = t
    end
end

function toggleFlag(obj)
    local fStr = obj.getGMNotes()
    if fStr == '' then broadcastToAll("You forgot to set the GM notes") end
    if FLAGS[fStr] == nil then broadcastToAll("You forgot to add to the flags table.") end
    FLAGS[fStr] = not FLAGS[fStr]
    updateToggle(obj)
end

function createToggle(guid, text, w, h, tool)
    local obj = getObjectFromGUID(guid)
    if obj then
    if not h then h = 800 end
        obj.createButton(
            {
                click_function = "toggleFlag",
                label = '[ ]' .. text,
                position = {0, BUTTON_Y, 0},
                font_size = 1000,
                width = w,
                height = h,
            }
        )
        if tool then obj.editButton({index=0, tooltip = tool}) end
        updateToggle(obj)
    end
end

function updateToggle(obj)
    local fStr = obj.getGMNotes()
    local flag = FLAGS[fStr]
    local app = ""
    if flag then app = '[x]' else app = '[ ]' end
    local bString = string.sub(obj.getButtons()[1].label, 4)

    if flag then
        obj.editButton({index=0,label=app..bString})
        --set all other flags in group to false
        local g = obj.getGUID()
        if FLAGS[g] then
            for _,guid in ipairs(FLAGS[g]) do
                if g~=guid then
                    local o = getObjectFromGUID(guid)
                    local flag = o.getGMNotes()
                    FLAGS[flag] = false
                    updateToggle(o)
                end
            end
        end
    else
        obj.editButton({index=0,label=app..bString})
    end
end

function createScroll(guid, w, h, arrowOffset, arrowW)
    local obj = getObjectFromGUID(guid)
    if obj then
        local f = obj.getGMNotes()
        if f=="" then
            broadcastToAll("You forgot to set the GM notes")
            return
        end
        f_att = FLAGS[f .. '_ATT']
        if not h then h = 800 end
        if not arrowW then arrowW = 0.375*h end
        obj.createButton(
            {
                click_function = "empty",
                --label = f_att[FLAGS[f]][1],
                --tooltip = f_att[FLAGS[f]][2],
                position = {0, BUTTON_Y, 0},
                font_size = 1000,
                width = w,
                height = h,
            }
        )
        if not arrowOffset then arrowOffset = 0 end
        obj.createButton(
            {
                click_function = "scrollFlagLeft",
                label = "<",
                position = {-(w/1000)*1.2-arrowOffset, BUTTON_Y, 0},
                font_size = 1000,
                width = arrowW,
                height = h,
            }
        )
        obj.createButton(
            {
                click_function = "scrollFlagRight",
                label = ">",
                position = {(w/1000)*1.2+arrowOffset, BUTTON_Y, 0},
                font_size = 1000,
                width = arrowW,
                height = h,
            }
        )
        updateScroll(obj,f_att,FLAGS[f])
    end
end

function scrollFlagLeft(obj)
    local fStr = obj.getGMNotes()
    local ndx = FLAGS[fStr]
    local att = FLAGS[fStr .. '_ATT']
    local ndxMin = 1
    local ndxMax = #att
    if (ndx-1)<ndxMin then
        ndx = ndxMax
    else
        ndx = ndx-1
    end
    FLAGS[fStr] = ndx
    updateScroll(obj,att,ndx)
end

function scrollFlagRight(obj)
    local fStr = obj.getGMNotes()
    local ndx = FLAGS[fStr]
    local att = FLAGS[fStr .. '_ATT']
    local ndxMin = 1
    local ndxMax = #att
    if (ndx+1)>ndxMax then
        ndx = ndxMin
    else
        ndx = ndx+1
    end
    FLAGS[fStr] = ndx
    updateScroll(obj,att,ndx)
end

function updateScroll(obj,att,ndx)
    obj.editButton({
        index=0,
        label=att[ndx][1],
        tooltip = att[ndx][2],
    })
    obj.editButton({
        index=1,
        tooltip = att[ndx][2],
    })
    obj.editButton({
        index=2,
        tooltip = att[ndx][2],
    })
end

function createLabel(guid, text)
    local obj = getObjectFromGUID(guid)
    if obj then
        obj.createButton(
            {
                click_function = "empty",
                label = text,
                position = {0, BUTTON_Y, 0},
                font_size = 1000,
                width = 0,
                height = 0,
                font_color = "White",
            }
        )
    end
end

function empty() end

function multiDestruct(t)
    for _,o in ipairs(t) do
        if type(o)=='string' then
            local obj = getObjectFromGUID(o)
            if obj then
                zoneDestruct(obj)
            end
        else
            zoneDestruct(o)
        end
    end
end

function zoneDestruct(obj)
    if obj.type == 'Scripting' then
        local objs = obj.getObjects()
        for _,o in ipairs(objs) do
            o.destruct()
        end
        obj.destruct()
    else
        obj.destruct()
    end
end

function startGame()
    --flag handling
    if FLAGS.MICRO_GAME_2 or FLAGS.MICRO_GAME_3 then
        FLAGS.DISTANT_CONNECTIONS = false
    end

    if FLAGS.USE_ONLY_NEW_MINORS then
        FLAGS.USE_NEW_MINORS = true
    end

    if FLAGS.USE_CROWDED and FLAGS.LONG_GAME then
        FLAGS.USE_NEW_MINORS = true
    end

    if FLAGS.USE_CROWDED and FLAGS.SHORT_GAME then
        FLAGS.SHORT_GAME = false
        FLAGS.RANDOMIZED_SHORT_GAME = true
    end

    if FLAGS.USE_LANDMARKS_AUTO or FLAGS.USE_LANDMARKS_MANUAL then
        FLAGS.USE_LANDMARKS = true
    end

    if FLAGS.RANDOMIZED_SHORT_GAME or FLAGS.MICRO_GAME_2 or FLAGS.MICRO_GAME_3 or FLAGS.USE_NEW_MINORS then
        FLAGS.RANDOMIZE_MINORS = true
    end

    if PLAYER_COUNT>=4 then
        FLAGS.USE_OPTIONALS = true
    end

    if PLAYER_COUNT>=6 then
        FLAGS.USE_NEW_MINORS = true
        FLAGS.BIG_PLAYERS = true
        FLAGS.USE_SUB_TILES = true
        FLAGS.RANDOMIZE_MINORS = true
    end

    for _,obj in ipairs(getAllObjects()) do
        if obj.hasTag("UI") then obj.destruct() end
    end
    Notes.setNotes("")

    local t = {"Red","Blue","Yellow","Green","Orange","Purple","Brown"}
    seatedPlayers = {}
    unseatedPlayers = {}

    for _,color in ipairs(t) do
        if Player[color].seated then
            table.insert(seatedPlayers,color)
        else
            table.insert(unseatedPlayers,color)
        end
    end
    if #seatedPlayers~=PLAYER_COUNT then
        seatedPlayers = {}
        unseatedPlayers = {}
        for i=1,PLAYER_COUNT do
            table.insert(seatedPlayers,t[i])
        end
        for i=PLAYER_COUNT+1,7 do
            table.insert(unseatedPlayers,t[i])
        end
    end

    if PLAYER_COUNT==1 then
        seatedPlayers = {'Red', 'Yellow'}
        unseatedPlayers = {"Blue","Green","Orange","Purple","Brown"}
    end

    for _,obj in ipairs(getAllObjects()) do
        for _,color in ipairs(unseatedPlayers) do
            if obj.hasTag(color) then obj.destruct() end
        end
    end

    --shuffle distant destination cards
    getObjectFromGUID('230803').shuffle()

    --raise hidden zone
    if FLAGS.RANDOMIZE_MINORS then
        getObjectFromGUID('fa3559').setPosition({-40.78, 3.53, 0.77})
    end

    --metropolitan
    if not FLAGS.USE_METRO then
        multiDestruct({'91c2cd','0be792','4cfd81'})
    else
        if not FLAGS.LONG_GAME then
            multiDestruct({'8e22a2','4aaafc','4ee43a',})
        end
        if PLAYER_COUNT<=5 then
            multiDestruct({'580247','79cfdd',})
        end
    end

    if PLAYER_COUNT==1 then
    else
        multiDestruct({'2d410a','1973eb'})
    end

    if not FLAGS.BIG_PLAYERS then
        getObjectFromGUID('44287e').destruct()
    end

    --events
    if FLAGS.USE_EVENTS then
        setupEvents()
    else
        multiDestruct({'e3bd65','28d90f','d64060'})
    end

    local sp = seatedPlayers[math.random(1,#seatedPlayers)]

    setupStacks()

    if FLAGS.USE_LANDMARKS_MANUAL then
        broadcastToAll("Add landmark project tiles of your choice to the Map Tiles bag, then shuffle it.\n")
    end
    if PLAYER_COUNT==1 then
        broadcastToAll("See chat for remaining setup.")
        printToAll('---------------------')
        printToAll('• Press the "Shuffle Minors" button.\n\n• Choose one Minor, then select another Minor at random [i](Use a die. Select 1 Minor from each column, or rearrange the Minors into 2 columns of 3 afterwards.)[/i].\n\n• Follow the remaining setup instructions in the solo rulebook.')
    else
        broadcastToAll('Create the map starting with Player ' .. sp .. ', then press the "Shuffle Minors" and "Pick First Player" buttons.')
    end

    setupTrains()
    startingMoney()

    --create remaining setup buttons
    createOtherButtons()
end

function setupEvents()
    local d1 = getObjectFromGUID('e3bd65')
    d1.shuffle()
    local d2 = getObjectFromGUID('28d90f')
    d2.shuffle()

    local toRemove = 4
    if not FLAGS.LONG_GAME then
        toRemove = 5
    end
    for i=1,toRemove do
        d1.takeObject().destruct()
    end
    getObjectFromGUID('d64060').setPosition(d2.getPosition())
    d2.setPosition(d1.getPosition())
    d1.setPosition(d1.getPosition()+Vector(0,2,0))
end

function startingMoney()
    if FLAGS.LONG_GAME or FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME then
        local t = {
            450,
            450,
            300,
            275,
            220,
            265,
            225,
        }
        setStartingMoney(t[PLAYER_COUNT])
    elseif FLAGS.MICRO_GAME_3 then
        local t = {
            340,
            340,
            225,
            170,
            135,
            135,
            135,
        }
        setStartingMoney(t[PLAYER_COUNT])
    elseif FLAGS.MICRO_GAME_2 then
        local t = {
            225,
            225,
            170,
            130,
            130,
            130,
            130,
        }
        setStartingMoney(t[PLAYER_COUNT])
    end
end

function setStartingMoney(n)
    for _,color in ipairs(seatedPlayers) do
        gameEntities.PLAYERS[color].treasury = n
        updateLabel(gameEntities.PLAYERS[color])
    end
    gameEntities.OTHER_ACTORS['BANK'].treasury = gameEntities.OTHER_ACTORS['BANK'].treasury - #seatedPlayers*n
    updateLabel(gameEntities.OTHER_ACTORS['BANK'])
end

function setupTrains()
    local d = getObjectFromGUID('e5047f')

    local max = {
        9, --2
        6, --3
        5, --4
        4, --5
        2, --6
        7, --7/D
    }

    local toKeep = nil
    if FLAGS.LONG_GAME then
        toKeep = {7,5,4,3,2,7,}
    elseif FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME then
        toKeep = {6,4,3,2,1,6,}
    elseif FLAGS.MICRO_GAME_3 then
        toKeep = {5,4,4,0,0,0,}
    elseif FLAGS.MICRO_GAME_2 then
        toKeep = {3,3,3,0,0,0,}
    end

    if FLAGS.USE_OPTIONALS then
        toKeep[2]=toKeep[2]+1
        if not (FLAGS.MICRO_GAME_3 or FLAGS.MICRO_GAME_2) then
            toKeep[4]=toKeep[4]+1
        end
    end

    if FLAGS.BIG_PLAYERS then
        toKeep[1]=toKeep[1]+2
        toKeep[3]=toKeep[3]+1
    end

    for i=2,7 do
        local keep = toKeep[i-1]
        local toRemove = max[i-1]-keep
        for n=1,toRemove do
            takeByGMNotes(d,tostring(i),{}).destruct()
        end
    end
end

function setupStacks()
    local zoneTable = { --home tile #, zone
        ['1'] = getObjectFromGUID('29a37c'),
        ['2'] = getObjectFromGUID('98984b'),
        ['3'] = getObjectFromGUID('71d038'),
        ['4'] = getObjectFromGUID('a2aee6'),
        ['5'] = getObjectFromGUID('d2bb17'),
        ['6'] = getObjectFromGUID('ce9f59'),
        ['7'] = getObjectFromGUID('a19d78'),
        ['8'] = getObjectFromGUID('6bad00'),
        ['9'] = getObjectFromGUID('08a5e8'),
        ['10'] = getObjectFromGUID('d84035'),
        ['11'] = getObjectFromGUID('109f5c'),
        ['21'] = getObjectFromGUID('5dc8aa'),
        ['L1'] = getObjectFromGUID('5190b0'),
        ['L2'] = getObjectFromGUID('3b1424'),
        ['L3'] = getObjectFromGUID('724101'),
        ['TwinCities'] = getObjectFromGUID('541a4a'),
    }

    local bag = getObjectFromGUID('1e7a40')
    bag.shuffle()

    --basic terrain
    if (FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME) and not FLAGS.BIG_PLAYERS then
        takeByGMNotes(bag,'12',{}).destruct()
        takeByGMNotes(bag,'13',{}).destruct()
        takeByGMNotes(bag,'14',{}).destruct()
    end

    if FLAGS.USE_SUB_TILES then
        bag.putObject(getObjectFromGUID('53666d'))
        bag.putObject(getObjectFromGUID('1c7e0b'))
        if not FLAGS.BIG_PLAYERS then
            bag.shuffle()
            bag.takeObject().destruct()
            bag.takeObject().destruct()
        end
    end
    bag.shuffle()

    if FLAGS.USE_CROWDED and not FLAGS.BIG_PLAYERS then
        if FLAGS.MICRO_GAME_3 then
            bag.takeObject().destruct()
            bag.takeObject().destruct()
            bag.takeObject().destruct()
        elseif FLAGS.MICRO_GAME_2 then
            bag.takeObject().destruct()
            bag.takeObject().destruct()
        else
            bag.takeObject().destruct()
            bag.takeObject().destruct()
            bag.takeObject().destruct()
            bag.takeObject().destruct()
        end
    end

    if FLAGS.MICRO_GAME_3 and not FLAGS.BIG_PLAYERS then
        --9 random tiles
        for i=1,9 do
            bag.takeObject().destruct()
        end
    elseif FLAGS.MICRO_GAME_2 and not FLAGS.BIG_PLAYERS then
        --6 random tiles
        for i=1,12 do
            bag.takeObject().destruct()
        end
    end

    --distant destinations
    local destBag = getObjectFromGUID('fabb1e')
    if (FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME or FLAGS.MICRO_GAME_3) and not FLAGS.BIG_PLAYERS then
        takeByGMNotes(destBag,'26',{}).destruct()
    end
    if FLAGS.MICRO_GAME_3 and not FLAGS.BIG_PLAYERS then
        destBag.takeObject().destruct() --use 1, non-26 distant destination
    elseif FLAGS.MICRO_GAME_2 and not FLAGS.BIG_PLAYERS then --use a random distant destination
        destBag.takeObject().destruct()
        destBag.takeObject().destruct()
    end
    for i=1,destBag.getQuantity() do
        bag.putObject(destBag.takeObject())
    end
    destBag.destruct()

    --capital cities
    local cBag = getObjectFromGUID('ffadb2')
    if (FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME) and not FLAGS.BIG_PLAYERS then
        cBag.takeObject().destruct()
    elseif (FLAGS.MICRO_GAME_2 or FLAGS.MICRO_GAME_3) and not FLAGS.BIG_PLAYERS then
        cBag.takeObject().destruct()
        cBag.takeObject().destruct()
    end
    for i=1,cBag.getQuantity() do
        bag.putObject(cBag.takeObject())
    end
    cBag.destruct()

    --landmarks
    if FLAGS.USE_LANDMARKS then
        if FLAGS.USE_LANDMARKS_AUTO then
            local lBag = getObjectFromGUID('573b19')
            local toUse = 3
            if FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME then
                toUse = 2
            elseif FLAGS.MICRO_GAME_2 or FLAGS.MICRO_GAME_3 then
                toUse = 1
            end
            if FLAGS.BIG_PLAYERS then
                toUse = 3
            end
            for i=1,toUse do
                bag.putObject(lBag.takeObject())
            end
        end
    else
        multiDestruct({'573b19','45fb78'})
    end

    --company homes
    local homeBag = getObjectFromGUID('93f4f1')
    if not FLAGS.USE_NEW_MINORS then
        takeByGMNotes(homeBag,'L1',{}).destruct()
        multiDestruct({zoneTable['L1']})
        takeByGMNotes(homeBag,'L2',{}).destruct()
        multiDestruct({zoneTable['L2']})
        takeByGMNotes(homeBag,'L3',{}).destruct()
        multiDestruct({zoneTable['L3']})
        takeByGMNotes(homeBag,'TwinCities',{}).destruct()
        multiDestruct({zoneTable['TwinCities'],'1b07c4','2f9ad4'})
    end

    if FLAGS.RANDOMIZE_MINORS then
        local toUse = 12
        if FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME then
            toUse = 8
        elseif FLAGS.MICRO_GAME_3 then
            toUse = 6
        elseif FLAGS.MICRO_GAME_2 then
            toUse = 4
        end
        if FLAGS.USE_CROWDED or FLAGS.BIG_PLAYERS then
            if FLAGS.MICRO_GAME_3 then
                toUse = toUse+3
            elseif FLAGS.MICRO_GAME_2 then
                toUse = toUse+2
            else
                toUse = toUse+4
            end
        end

        if FLAGS.USE_ONLY_NEW_MINORS and not FLAGS.BIG_PLAYERS then
            toUse = toUse-4
            bag.putObject(takeByGMNotes(homeBag,'L1',{}))
            bag.putObject(takeByGMNotes(homeBag,'L2',{}))
            bag.putObject(takeByGMNotes(homeBag,'L3',{}))
            bag.putObject(takeByGMNotes(homeBag,'TwinCities',{}))
        end

        local toRemove = homeBag.getQuantity()-toUse
        for i=1,toRemove do
            local o = homeBag.takeObject()
            local str = o.getGMNotes()
            o.destruct()
            multiDestruct({zoneTable[str]})
        end
        for i=1,homeBag.getQuantity() do
            bag.putObject(homeBag.takeObject())
        end
        homeBag.destruct()
    else
        if FLAGS.SHORT_GAME then
            takeByGMNotes(homeBag,'9',{}).destruct()
            multiDestruct({zoneTable['9']})
            takeByGMNotes(homeBag,'11',{}).destruct()
            multiDestruct({zoneTable['11']})
            takeByGMNotes(homeBag,'10',{}).destruct()
            multiDestruct({zoneTable['10']})
            takeByGMNotes(homeBag,'21',{}).destruct()
            multiDestruct({zoneTable['21']})
        end
        for i=1,homeBag.getQuantity() do
            bag.putObject(homeBag.takeObject())
        end
        homeBag.destruct()
    end
    bag.shuffle()
end

function takeByGMNotes(bag,str,parameters)
    for _,obj in ipairs(bag.getObjects()) do
        if obj.gm_notes == str then
            parameters.guid = obj.guid
            return bag.takeObject(parameters)
        end
    end
    return nil
end

function createOtherButtons()
     local s = 1
     getObjectFromGUID('e2cf9b').createButton({
         label = 'Shuffle Minors',
         tooltip = "Arrange the Minor Companies into random stacks.\n\nPress this after building the map, or before if you think that's more fun.",
         click_function = 'shuffleMinors',
         scale = {s,s,s},
         font_size = 1000,
         position = {0,0,0},
         width = 5000,
         height = 1200,
     })

     getObjectFromGUID('d06145').createButton({
         label = 'Pick\nFirst Player',
         tooltip = "Arrange the Minor Companies into random stacks.\n\nPress this after building the map.",
         click_function = 'dealStartingPlayer',
         scale = {s,s,s},
         font_size = 1000,
         position = {0,0,0},
         width = 5000,
         height = 2000,
     })
end

function unlockStuff()
    for _,obj in ipairs(getObjectsWithTag("UnlockMe")) do
        obj.setLock(false)
    end
end

function shuffleMinors()
    unlockStuff()

    --remove hidden zone
    if getObjectFromGUID('fa3559') then getObjectFromGUID('fa3559').destruct() end

    --get existing minors
    local zones = { --zone, stock token, revenue token
        {getObjectFromGUID('d84035'),getObjectFromGUID('a9df71'),getObjectFromGUID('d0fc4f'),},
        {getObjectFromGUID('29a37c'),getObjectFromGUID('3453c4'),getObjectFromGUID('aef755'),},
        {getObjectFromGUID('ce9f59'),getObjectFromGUID('160ab1'),getObjectFromGUID('48834b'),},
        {getObjectFromGUID('98984b'),getObjectFromGUID('50bae8'),getObjectFromGUID('bf301f'),},
        {getObjectFromGUID('d2bb17'),getObjectFromGUID('2dea57'),getObjectFromGUID('986f07'),},
        {getObjectFromGUID('a19d78'),getObjectFromGUID('8a010c'),getObjectFromGUID('7a009f'),},
        {getObjectFromGUID('109f5c'),getObjectFromGUID('34d8c7'),getObjectFromGUID('107bd9'),},
        {getObjectFromGUID('5dc8aa'),getObjectFromGUID('24d3c7'),getObjectFromGUID('f13c32'),},
        {getObjectFromGUID('08a5e8'),getObjectFromGUID('a22f28'),getObjectFromGUID('d58d5a'),},
        {getObjectFromGUID('6bad00'),getObjectFromGUID('e811d8'),getObjectFromGUID('19beb0'),},
        {getObjectFromGUID('a2aee6'),getObjectFromGUID('522eea'),getObjectFromGUID('375a2a'),},
        {getObjectFromGUID('71d038'),getObjectFromGUID('daac00'),getObjectFromGUID('45e65e'),},

        {getObjectFromGUID('5190b0'),getObjectFromGUID('429d31'),getObjectFromGUID('df8140'),},
        {getObjectFromGUID('3b1424'),getObjectFromGUID('656223'),getObjectFromGUID('33d61a'),},
        {getObjectFromGUID('724101'),getObjectFromGUID('8aa162'),getObjectFromGUID('da188d'),},
        {getObjectFromGUID('541a4a'),getObjectFromGUID('cd1cae'),getObjectFromGUID('3ce219'),},
    }

    local t = {}
    for _,data in ipairs(zones) do
        if data[1] then
            table.insert(t,data[1])
        else
            data[2].destruct()
            data[3].destruct()
        end
    end
    table.shuffle(t)

    local basePos = Vector({-33.38, 1.03, -10.72})
    local xOffset = Vector(-6,0,0)
    local zOffset = Vector(0,0,6)

    local numCols = nil

    if FLAGS.LONG_GAME then
        numCols = 3
    elseif (FLAGS.SHORT_GAME or FLAGS.RANDOMIZED_SHORT_GAME) then
        numCols = 2
    elseif FLAGS.MICRO_GAME_3 then
        numCols = 2
    elseif FLAGS.MICRO_GAME_2 then
        numCols = 2
    end

    if FLAGS.USE_CROWDED or FLAGS.BIG_PLAYERS then
        numCols = numCols+1
    end

    for n,zone in ipairs(t) do
        local c = (n-1)%numCols
        local r = math.floor((n-1)/numCols)
        local pos = basePos+c*xOffset+r*zOffset
        moveMinor(zone,pos)
    end

    if numCols == 2 then
        shiftMajors(11.93)
    elseif numCols == 3 then
        shiftMajors(5.88)
    end

    getObjectFromGUID('e2cf9b').destruct()
end

function shiftMajors(amount)
    local objs = getObjectFromGUID('5ceda9').getObjects()
    for _,obj in ipairs(objs) do
        obj.setPosition(obj.getPosition()+Vector(amount,0,0))
    end
end

function moveMinor(zone,labelPosition)
    local objs = zone.getObjects()
    local parent = findLabel(objs)
    local parentPos = parent.getPosition()
    local destPos = labelPosition
    for _,obj in ipairs(objs) do
        local offset = obj.getPosition()-parentPos
        local newPos = destPos+offset
        obj.setPosition(newPos)
    end
end

function findLabel(objs)
    for _,obj in ipairs(objs) do
        if obj.hasTag("Label") then return obj end
    end
end

function dealStartingPlayer()
    --starting player
    local sp = seatedPlayers[math.random(1,#seatedPlayers)]
    broadcastToAll(sp .. ' is the starting player.', sp)
    getObjectFromGUID('817a23').deal(1, sp)

    getObjectFromGUID('d06145').destruct()
end

function companyExists(company)
    if (getObjectFromGUID(company.inputCounterGUID) and getObjectFromGUID(company.charterGUID) and getObjectFromGUID(company.moneyLabelGUID)) then
        return true
    elseif company.charterGUID == '6a5bb2' then
        return getObjectFromGUID(company.charterGUID)
    end
end

function playerExists(player)
    return (getObjectFromGUID(player.inputCounterGUID) and getObjectFromGUID(player.moneyLabelGUID))
end

function initCompanies()
    for k,company in pairs(gameEntities.COMPANIES) do
        if companyExists(company) then --existance check

            --Copy over or override global options
            for j,v in pairs(gameOptionDefaults) do
                if company[j]==nil then
                    if gameOptions[j]==nil then
                        company[j] = v
                    else
                        company[j] = gameOptions[j]
                    end
                end
            end

            --check for a charter if one is required.
            company.HAS_CHARTER = ( (company.CHARTER_SHARES_PAY_COMPANY) or (company.COMPANIES_CAN_OWN_OTHER_SHARES and INVESTABLE_COMPANY_EXISTS) or (company.USE_PRIVATES and company.COMPANIES_CAN_OWN_PRIVATES) )

            company.key = k
            if company.name then company.NAME = company.name end --backwards compatibility
            if not company.NAME then company.NAME = k end
            if not company.shareDescription then company.shareDescription = k end

            if (type(company.ISSUE_SIZE) == 'table') then
                --company is capable of being more than one issue size

                --error checking
                if company.SHARE_DESCRIPTIONS_ARE_PERCENTAGE then
                    broadcastToAll('ERROR, ' .. k .. ' Company: SHARE_DESCRIPTIONS_ARE_PERCENTAGE is not compatible with multiple issue sizes.', ERROR_COLOR)
                end
                if company.COMPANY_CHARTERS_ARE_SHARES then
                    broadcastToAll('ERROR, ' .. k .. ' Company: COMPANY_CHARTERS_ARE_SHARES is not compatible with multiple issue sizes.', ERROR_COLOR)
                end

                if SAVE_STATE['CompanyIS' .. k] then
                    company.issueSize = SAVE_STATE['CompanyIS' .. k]
                    company.issueIndex = SAVE_STATE['CompanyII' .. k]
                else
                    company.issueSize = company.ISSUE_SIZE[1]
                    company.issueIndex = 1
                end
            else
                --company has only one issue size
                company.issueSize = company.ISSUE_SIZE
            end

            if (type(company.HALF_PAY_ROUND) == 'table') then

                --error checking
                if not (type(company.ISSUE_SIZE) == 'table') then
                    broadcastToAll('ERROR, ' .. k .. ' Company: Multiple values given for HALF_PAY_ROUND but only one value given for ISSUE_SIZE', ERROR_COLOR)
                    return
                end

                if #company.ISSUE_SIZE ~= #company.HALF_PAY_ROUND then
                    broadcastToAll('ERROR, ' .. k .. ' Company: # of values given for HALF_PAY_ROUND does not match # of values given for ISSUE_SIZE', ERROR_COLOR)
                end

                if SAVE_STATE['CompanyIS' .. k] then
                    company.halfPayRound = company.HALF_PAY_ROUND[company.issueIndex]
                else
                    company.halfPayRound = company.HALF_PAY_ROUND[1]
                end

            else
                company.halfPayRound = company.HALF_PAY_ROUND
            end

            if SAVE_STATE['Company ' .. k] then
                company.treasury = SAVE_STATE['Company ' .. k]
            else
                company.treasury = 0
            end

            if company.COMPANY_CHARTERS_ARE_SHARES then
                company.issueSize = 2
                company.SHARE_DESCRIPTIONS_ARE_PERCENTAGE = false
                company.halfPayRound = 1
                getObjectFromGUID(company.inputCounterGUID).setName('This Company will pay the player who clicks the button.')
            end

            updateLabel(company)

            --input
            local inputCounter = getObjectFromGUID(company.inputCounterGUID)
            local s = 1
            inputCounter.createInput({
                input_function = "empty",
                position = {0,0.1,0.1},
                width = 1520,
                height = 500,
                scale = {s,s,s},
                font_size = 478,
                label = "###",
                alignment = 3,
                validation = 2,
                tooltip = 'Type the amount of money to take/spend/payout into this box.'
            })

            --fucking LUA wizardry
            --Using a locally defined function as the click_function allows us to access the other local variables in this for loop

            local btnIndex = 0
            local fullPayIndex = nil
            local halfPayIndex = nil
            --increment as buttons are created, because createButton doesn't return the button's index for some fucking reason.
            --button indexes also start at zero because convention sucks.

            if company.COMPANIES_CAN_HALF_PAY then
                local payFuncName = k .. 'PayHalf'
                local payFunc = function(object, color, alt) buttonHelper(company, 'PayHalf', color, alt) end
                Global.setVar(payFuncName, payFunc)
                payHalfParams.click_function = payFuncName
                getObjectFromGUID(company.inputCounterGUID).createButton(payHalfParams)
                halfPayIndex = btnIndex
                btnIndex = btnIndex+1
            end

            if company.COMPANIES_CAN_FULL_PAY then
                local payFuncName = k .. 'Payout'
                local payFunc = function(object, color, alt) buttonHelper(company, 'Payout', color, alt) end
                Global.setVar(payFuncName, payFunc)
                payFullParams.click_function = payFuncName
                getObjectFromGUID(company.inputCounterGUID).createButton(payFullParams)
                fullPayIndex = btnIndex
                btnIndex = btnIndex+1
            end

            if company.COMPANIES_CAN_HALF_PAY and company.COMPANIES_CAN_FULL_PAY then
                getObjectFromGUID(company.inputCounterGUID).editButton({index=halfPayIndex, position = addv(payHalfParams.position,{0,0,-0.2})})
                getObjectFromGUID(company.inputCounterGUID).editButton({index=fullPayIndex, label='Pay Full', position = addv(payFullParams.position,{0,0,0.2})})
            end

            --[[
            if gameEntities.OTHER_ACTORS.REVENUE_TRACKER and company.TRACK_REVENUE then
                --set payout tooltips
                if company.COMPANIES_CAN_FULL_PAY then
                    if company.TRACK_ON_RIGHT_CLICK then
                        getObjectFromGUID(company.inputCounterGUID).editButton({index=fullPayIndex, tooltip='Right-click this button to track revenue.'})
                    else
                        getObjectFromGUID(company.inputCounterGUID).editButton({index=fullPayIndex, tooltip='Right-click this button to [i]not[/i] track revenue.'})
                    end
                end

                if company.COMPANIES_CAN_HALF_PAY then
                    if company.TRACK_ON_RIGHT_CLICK then
                        getObjectFromGUID(company.inputCounterGUID).editButton({index=halfPayIndex, tooltip='Right-click this button to track revenue.'})
                    else
                        getObjectFromGUID(company.inputCounterGUID).editButton({index=halfPayIndex, tooltip='Right-click this button to [i]not[/i] track revenue.'})
                    end
                end
            end
            ]]

            if (type(company.ISSUE_SIZE) == 'table') then
                local changeSizeFuncName = k .. 'changeSize'
                local changeSizeFunc = function(object, color) changeSize(company) end
                Global.setVar(changeSizeFuncName, changeSizeFunc)
                changeSizeParams.click_function = changeSizeFuncName
                changeSizeParams.label = company.issueSize .. '-Share'
                getObjectFromGUID(company.inputCounterGUID).createButton(changeSizeParams)
                company.changeSizeButtonIndex = btnIndex
                btnIndex = btnIndex+1
            end

            if company.COMPANIES_CAN_BANK_TRANSFER then
                local bankFuncName = k .. 'bankTransfer'
                local bankFunc = function(object, color) buttonHelper(company, 'Bank Transfer') end
                Global.setVar(bankFuncName, bankFunc)
                bankTransferParams.click_function = bankFuncName
                getObjectFromGUID(company.inputCounterGUID).createButton(bankTransferParams)
                btnIndex = btnIndex+1

                local withholdFuncName = k .. 'withholdTransfer'
                local withholdFunc = function(object, color) buttonHelper(company, 'Withhold') end
                Global.setVar(withholdFuncName, withholdFunc)
                withholdParams.click_function = withholdFuncName
                getObjectFromGUID(company.inputCounterGUID).createButton(withholdParams)
                btnIndex = btnIndex+1
            end
        end
    end
end

function empty()
end

function initPlayers()
    for k,player in pairs(gameEntities.PLAYERS) do
        if playerExists(player) then --existance check
            --okay
            player.key = k
            if Player[k].seated then player.NAME = Player[k].steam_name else player.NAME = k end
            if SAVE_STATE['Player ' .. k] then
                player.treasury = SAVE_STATE['Player ' .. k]
            else
                player.treasury = 0
            end
            updateLabel(player)

            --input
            local inputCounter = getObjectFromGUID(player.inputCounterGUID)
            local s = 1
            inputCounter.createInput({
                input_function = "empty",
                position = {0,0.1,0.1},
                width = 1520,
                height = 500,
                scale = {s,s,s},
                font_size = 478,
                label = "###",
                alignment = 3,
                validation = 2,
                tooltip = 'Type the amount of money to take/spend into this box.'
            })

            --Using a locally defined function as the click_function allows us to access the other local variables in this for loop
            local bankFuncName = k .. 'bankTransfer'
            local bankFunc = function(object, color) buttonHelper(player, 'Bank Transfer') end
            Global.setVar(bankFuncName, bankFunc)
            bankTransferParams.click_function = bankFuncName
            getObjectFromGUID(player.inputCounterGUID).createButton(bankTransferParams)

            local withholdFuncName = k .. 'withholdTransfer'
            local withholdFunc = function(object, color) buttonHelper(player, 'Withhold') end
            Global.setVar(withholdFuncName, withholdFunc)
            withholdParams.click_function = withholdFuncName
            getObjectFromGUID(player.inputCounterGUID).createButton(withholdParams)
        end
    end
end

function initIPO()
    --if global or any company has IPO_SHARES_PAY_COMPANY, enforce a GUID and fetch bank pool zone
    local usingIPO = gameOptions.IPO_SHARES_PAY_COMPANY
    for k,v in pairs(gameEntities.COMPANIES) do
        usingIPO = usingIPO or v.IPO_SHARES_PAY_COMPANY
    end

    --if using IPO, check to see if the GUID is set.
    if usingIPO then
        if not (gameOptions.IPO_ZONE_GUID) then
            broadcastToAll('IPO_SHARES_PAY_COMPANY is set for at least one company but could not find IPO_ZONE_GUID in gameOptions', ERROR_COLOR) return
        end
        if not getObjectFromGUID(gameOptions.IPO_ZONE_GUID) then
            broadcastToAll('ERROR: IPO_ZONE_GUID does not match anything in this mod.', ERROR_COLOR) return
        end

        --error free
        IPO_ZONE = getObjectFromGUID(gameOptions.IPO_ZONE_GUID)
    end
end

function initBankPool()
    --if global or any company has BANK_SHARES_PAY_COMPANY, enforce a GUID and fetch bank pool zone
    local usingBankPool = gameOptions.BANK_POOL_SHARES_PAY_COMPANY
    for k,v in pairs(gameEntities.COMPANIES) do
        usingBankPool = usingBankPool or v.BANK_POOL_SHARES_PAY_COMPANY
    end

    --if using bank pool, check to see if the GUID is set.
    if usingBankPool then
        if not (gameOptions.BANK_POOL_ZONE_GUID) then
            broadcastToAll('BANK_POOL_SHARES_PAY_COMPANY is set for at least one company but could not find BANK_POOL_ZONE_GUID in gameOptions', ERROR_COLOR) return
        end
        if type(gameOptions.BANK_POOL_ZONE_GUID)=='table' then
            for _,g in ipairs(gameOptions.BANK_POOL_ZONE_GUID) do
                if not getObjectFromGUID(g) then
                    broadcastToAll('ERROR: One of the GUIDs in BANK_POOL_ZONE_GUID is missing or incorrect.', ERROR_COLOR) return
                end
            end
        else
            if not getObjectFromGUID(gameOptions.BANK_POOL_ZONE_GUID) then
                broadcastToAll('ERROR: BANK_POOL_ZONE_GUID does not match anything in this mod.', ERROR_COLOR) return
            end
        end

        --error free
        if type(gameOptions.BANK_POOL_ZONE_GUID)=='table' then
            BANK_POOL_ZONE = gameOptions.BANK_POOL_ZONE_GUID
        else
            BANK_POOL_ZONE = getObjectFromGUID(gameOptions.BANK_POOL_ZONE_GUID)
        end
    end
end

function initBank()
    --Check if there should be a bank.
    USE_BANK = gameOptions.BANK_SIZE
    if USE_BANK and not gameEntities.OTHER_ACTORS['BANK'] then broadcastToAll('ERROR: Bank size is non-zero but no "BANK" entry was found in gameEntities.OTHER_ACTORS', ERROR_COLOR) return end

    if USE_BANK then
        --error checking
        if not gameEntities.OTHER_ACTORS['BANK'].moneyLabelGUID then
            broadcastToAll('ERROR: No "moneyLabelGUID" entry was found in gameEntities.OTHER_ACTORS[\'BANK\'].', ERROR_COLOR) return
        end
        if not getObjectFromGUID(gameEntities.OTHER_ACTORS['BANK'].moneyLabelGUID) then
            broadcastToAll('ERROR: An object could not be found for the bank\'s moneyLabelGUID.', ERROR_COLOR) return
        end

        --Okay
        if SAVE_STATE['Bank Treasury'] then
            gameEntities.OTHER_ACTORS['BANK'].treasury = SAVE_STATE['Bank Treasury']
        else
            gameEntities.OTHER_ACTORS['BANK'].treasury = gameOptions.BANK_SIZE
        end

        updateLabel(gameEntities.OTHER_ACTORS['BANK'])
    end
end

function initPrivates()
    if gameOptions.USE_PRIVATES and not gameEntities.OTHER_ACTORS['PRIVATES'] then broadcastToAll('ERROR: USE_PRIVATES is set but no "PRIVATES" entry was found in gameEntities.OTHER_ACTORS', ERROR_COLOR) return end

    if gameOptions.USE_PRIVATES then
        --error checking
        if not gameEntities.OTHER_ACTORS['PRIVATES'].payPrivatesButtonGUID then
            broadcastToAll('ERROR: No "payPrivatesButtonGUID" entry was found in gameEntities.OTHER_ACTORS[\'PRIVATES\'].', ERROR_COLOR) return
        end
        if not getObjectFromGUID(gameEntities.OTHER_ACTORS['PRIVATES'].payPrivatesButtonGUID) then
            broadcastToAll('ERROR: An object could not be found for the privatess\' payPrivatesButtonGUID.', ERROR_COLOR) return
        end

        --Okay
        getObjectFromGUID(gameEntities.OTHER_ACTORS['PRIVATES'].payPrivatesButtonGUID).createButton(payPrivatesParams)
    end
end

function initLog()
    if gameOptions.TRANSACTION_LOG_GUID then
        --error checking
        if not getObjectFromGUID(gameOptions.TRANSACTION_LOG_GUID) then
            broadcastToAll('ERROR: TRANSACTION_LOG_GUID was set but an object with that GUID could not be found.', ERROR_COLOR) return
        end

        --Okay
        TRANSACTION_LOG = getObjectFromGUID(gameOptions.TRANSACTION_LOG_GUID)
        TRANSACTION_LOG.setName('Transaction Log')
        TRANSACTION_LOG.setDescription('')

        TRANSACTIONS = nil
    end
end

function initRevenue()
    if gameEntities.OTHER_ACTORS.REVENUE_TRACKER then
        for _,b in ipairs(gameEntities.OTHER_ACTORS.REVENUE_TRACKER) do
            local box = getObjectFromGUID(b.GUID)
            if box then
                b.valid = true

                local s = box.getScale()
                local s2 = Vector(-s.x/2,-s.y/2,s.z/2)
                b.upperleft = box.getPosition()+s2
                s2 = Vector(s.x/2,-s.y/2,-s.z/2)
                b.lowerright = box.getPosition()+s2
                b.width= b.lowerright.x-b.upperleft.x
                b.height = b.upperleft.z-b.lowerright.z
                b.cellWidth = b.width / b.COLS
                b.cellHeight = b.height / b.ROWS

                if not b.VERTICAL_INC then b.VERTICAL_INC = b.COLS end

                b.maxValue = b.START + b.COLS-1 + b.VERTICAL_INC * (b.ROWS-1)
            end
        end
    end
end

function getValue(company)
    local counter = getObjectFromGUID(company.inputCounterGUID)
    if not counter then return 0 end
    local val = tonumber(counter.getInputs()[1].value)
    if not val then val = 0 end
    return val
end

function setValue(company, val)
    local counter = getObjectFromGUID(company.inputCounterGUID)
    if not counter then return end
    counter.editInput({index=0,value=val})
end

function buttonHelper(caller, type, color, alt)
    local amount = getValue(caller)
    if amount == 0 then return end
    if type == 'Bank Transfer' then
        amount = amount*-1
        transferMoneyWithBank(caller, amount, true, true)
    elseif type == 'Payout' then
        Payout(caller, amount, color)
    elseif type == 'Withhold' then
        Withhold(caller, amount)
    elseif type == 'PayHalf' then
        printToAll('')
        if (amount > 0) then
            Payout(caller, roundTo(amount/2, caller.halfPayRound, true), color)
            if not caller.COMPANIES_PAY_FROM_TREASURY then Withhold(caller, roundTo(amount/2, caller.halfPayRound, false), color) end
        else
            Payout(caller, roundTo(amount/2, caller.halfPayRound, false), color)
            if not caller.COMPANIES_PAY_FROM_TREASURY then Withhold(caller, roundTo(amount/2, caller.halfPayRound, true), color) end
        end
    end

    --move revenue tracker
    if gameEntities.OTHER_ACTORS.REVENUE_TRACKER and caller.TRACK_REVENUE and alt~=nil then
        if not caller.TRACK_ON_RIGHT_CLICK then alt = not alt end
        if alt then
            --find appropriate box
            local num = 0
            if caller.TRACK_REVENUE_PER_SHARE then num = math.floor(amount/caller.issueSize) else num = amount/10 end
            for _,b in ipairs(gameEntities.OTHER_ACTORS.REVENUE_TRACKER) do
                if num>=b.START and num<=b.maxValue and (num-b.START)%b.VERTICAL_INC>=0 and (num-b.START)%b.VERTICAL_INC<=b.COLS-1 then
                    local xcell = (num-b.START) % (b.VERTICAL_INC)
                    local zcell = math.floor((num-b.START) / b.VERTICAL_INC)
                    local obj = getObjectFromGUID(caller['revenueTrackerGUID'])

                    local xpos = nil
                    if b.REVERSE_COLS then
                        xpos = b.lowerright.x - b.cellWidth*(xcell+0.5)
                    else
                        xpos = b.upperleft.x + b.cellWidth*(xcell+0.5)
                    end

                    local zpos = nil
                    if b.REVERSE_ROWS then
                        zpos = b.lowerright.z + b.cellHeight*(zcell+0.5)
                    else
                        zpos = b.upperleft.z - b.cellHeight*(zcell+0.5)
                    end

                    if (obj) then
                        obj.setPositionSmooth({xpos, obj.getPosition().y+3, zpos}, false, true)
                    else
                        --broadcastToColor("Automatic tracking requires the first value to be placed manually.", color, 'Red')
                    end
                    break
                end
            end
        end
    end
end

function transferMoneyWithBank(caller, amount, print, log)
    --print = boolean, print to all chat?
    --log = boolean, print to the log object?
    caller.treasury = caller.treasury + amount
    updateLabel(caller)
    if USE_BANK and not caller.COMPANY_CREDITS then
        gameEntities.OTHER_ACTORS['BANK'].treasury = gameEntities.OTHER_ACTORS['BANK'].treasury - amount
        updateLabel(gameEntities.OTHER_ACTORS['BANK'])
    end
    if (amount > 0) then
        logTransaction(amount, 'Bank', caller.NAME, print, log)
    elseif (amount < 0) then
        logTransaction(amount*-1, caller.NAME, 'Bank', print, log)
    end
end

function Withhold(caller, amount)
    transferMoneyWithBank(caller, amount, true, true)
end

function Payout(caller, amount, color)
    local payoutTable = {}
    --Part of this function spawns ScriptingZones, which take more than one frame to load.
    --The waitFlags are used to make sure all ScriptingZones have loaded and done their thing before continuing.

    local waitFlags = {}

    if caller.COMPANY_CHARTERS_ARE_SHARES then
        payoutTable[color] = {gameEntities.PLAYERS[color], 2}
    else

        --tabulate player shares
        for k,v in pairs(gameEntities.PLAYERS) do
            payoutTable[k] = {v, 0}
            --if player has a designated zone, search that for shares matching this company
            if getObjectFromGUID(v.shareZoneGUID) then
                if getObjectFromGUID(v.shareZoneGUID).tag == 'Scripting' then
                    payoutTable[k][2] = searchContainer(getObjectFromGUID(v.shareZoneGUID).getObjects(), caller, payoutTable[k][2])
                else

                    waitFlags[k] = false

                    --Dynamically spawn a scripting zone to on the charter
                    local bb = getObjectFromGUID(v.shareZoneGUID).getBoundsNormalized()
                    local params = {}
                    local callbackName = "callbackPlayer" .. k
                    params.position = getObjectFromGUID(v.shareZoneGUID).getPosition()
                    params.rotation = getObjectFromGUID(v.shareZoneGUID).getRotation()
                    params.scale = { bb.size.x, bb.size.y+8, bb.size.z }
                    params.callback = callbackName
                    params.type = 'ScriptingTrigger'
                    params.sound = false
                    local zone = spawnObject(params)

                    local callbackFunc = function()
                        payoutTable[k][2] = searchContainer(zone.getObjects(), caller, payoutTable[k][2])
                        waitFlags[k] = true
                        zone.destruct()
                    end
                    Global.setVar(callbackName, callbackFunc)

                end
            end
            --search the player's hand
            if caller.HAND_SHARES_PAY_PLAYER then
                payoutTable[k][2] = searchContainer(Player[k].getHandObjects(), caller, payoutTable[k][2])
            end
        end

        --tabulate company shares
            payoutTable[caller.key] = {caller, 0}
            --bank pool
            if caller.BANK_POOL_SHARES_PAY_COMPANY then
                if type(BANK_POOL_ZONE)=='table' then --multiple bank pools
                    for _,poolG in ipairs(BANK_POOL_ZONE) do
                        local pool = getObjectFromGUID(poolG)
                        payoutTable[caller.key][2] = searchContainer(pool.getObjects(), caller, payoutTable[caller.key][2])
                    end
                else --single bank pool
                    payoutTable[caller.key][2] = searchContainer(BANK_POOL_ZONE.getObjects(), caller, payoutTable[caller.key][2])
                end
            end
            --IPO
            if caller.IPO_SHARES_PAY_COMPANY then
                payoutTable[caller.key][2] = searchContainer(IPO_ZONE.getObjects(), caller, payoutTable[caller.key][2])
            end
            --Charter
            if caller.CHARTER_SHARES_PAY_COMPANY then
                waitFlags[caller.key] = false

                --Dynamically spawn a scripting zone to on the charter
                local bb = getObjectFromGUID(caller.charterGUID).getBoundsNormalized()
                local params = {}
                local callbackName = "callback" .. caller.key
                params.position = getObjectFromGUID(caller.charterGUID).getPosition()
                params.rotation = getObjectFromGUID(caller.charterGUID).getRotation()
                params.scale = { bb.size.x, bb.size.y+8, bb.size.z }
                params.callback = callbackName
                params.type = 'ScriptingTrigger'
                params.sound = false
                local zone = spawnObject(params)

                local key = caller.key
                local callbackFunc = function()
                Wait.frames(function()
                payoutTable[key][2] = searchContainer(zone.getObjects(), caller, payoutTable[key][2])
                waitFlags[key] = true
                zone.destruct()
                end, 3)
                end 
                Global.setVar(callbackName, callbackFunc)
            end


        --tabulate shares on other companies

        if caller.COMPANIES_CAN_CROSS_INVEST then
            for k,v in pairs(gameEntities.COMPANIES) do
                if k~=caller.key and v.COMPANIES_CAN_OWN_OTHER_SHARES and v.HAS_CHARTER then
                    payoutTable[k] = {v,0}
                    waitFlags[k] = false

                    --Dynamically spawn a scripting zone to on the charter
                    local bb = getObjectFromGUID(v.charterGUID).getBoundsNormalized()
                    local params = {}
                    local callbackName = "callback" .. k
                    params.position = getObjectFromGUID(v.charterGUID).getPosition()
                    params.rotation = getObjectFromGUID(v.charterGUID).getRotation()
                    params.scale = { bb.size.x, bb.size.y+8, bb.size.z }
                    params.callback = callbackName
                    params.type = 'ScriptingTrigger'
                    params.sound = false
                    local zone = spawnObject(params)

                    local callbackFunc = function()
                        payoutTable[k][2] = searchContainer(zone.getObjects(), caller, payoutTable[k][2])
                        waitFlags[k] = true
                        zone.destruct()
                    end
                    Global.setVar(callbackName, callbackFunc)
                end
            end
        end

    end

            Wait.condition(
            function()
                transferPayouts(caller, payoutTable, amount)
            end,
            function()
                local temp = true
                for k,v in pairs(waitFlags) do
                    temp = temp and v
                end
                return temp
            end)
end

function transferPayouts(caller, payoutTable, amount)
    printToAll("--- " .. caller.NAME .. " pays out " .. formatLabel(amount) .. " ---")
    logTransaction(amount, 'Bank', caller.NAME .. ' Shares', false, true)

    if caller.PROPORTIONAL_PAYOUTS then transferPropPayouts(caller, payoutTable, amount) return end
    if caller.COMPANIES_PAY_FLAT_RATE then transferFlatPayouts(caller, payoutTable, amount) return end

    if caller.COMPANIES_PAY_FROM_TREASURY then
        caller.treasury = caller.treasury - amount
        updateLabel(caller)
    end

    local someoneGotPaid = false
    for k,v in pairs(payoutTable) do
        if (v[2]~=0) then
            someoneGotPaid = true
            local calc = 0
            local string = ''
            if amount > 0 then
                if caller.SHARE_DESCRIPTIONS_ARE_PERCENTAGE then
                    calc = math.ceil(amount*v[2]/100)
                    string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. '%.'
                else
                    calc = math.ceil(amount*v[2]/caller.issueSize)
                    string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. ' shares (' .. v[2]*100/caller.issueSize .. '%).'
                end
            else
                if caller.SHARE_DESCRIPTIONS_ARE_PERCENTAGE then
                    calc = math.floor(amount*v[2]/100)
                    string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. '%.'
                else
                    calc = math.floor(amount*v[2]/caller.issueSize)
                    string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. ' shares (' .. v[2]*100/caller.issueSize .. '%).'
                end
            end
            if not caller.COMPANIES_PAY_FROM_TREASURY then
                transferMoneyWithBank(v[1], calc, false, false)
            else
                v[1].treasury = v[1].treasury + calc
                updateLabel(v[1])
            end
            printToAll(string)
        end
    end
    if not someoneGotPaid then broadcastToAll('No company or player was paid dividends. Make sure shares are where they should be.') end
end

function transferPropPayouts(caller, payoutTable, amount)
    if caller.COMPANIES_PAY_FROM_TREASURY then
        caller.treasury = caller.treasury - amount
        updateLabel(caller)
    end

    local someoneGotPaid = false
    local shareCount = 0
    local perShare = 0
    for k,v in pairs(payoutTable) do
        shareCount = shareCount + v[2]
    end
    if amount > 0 then
        perShare = math.ceil(amount/shareCount)
    else
        perShare = math.floor(amount/shareCount)
    end

    for k,v in pairs(payoutTable) do
        local calc = 0
        if (v[2]~=0) then
            calc = v[2]*perShare
            string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. ' shares (' .. v[2] .. '/' .. shareCount .. ')'
            if not caller.COMPANIES_PAY_FROM_TREASURY then
                transferMoneyWithBank(v[1], calc, false, false)
            else
                v[1].treasury = v[1].treasury + calc
                updateLabel(v[1])
            end
            printToAll(string)
        end
    end
end

function transferFlatPayouts(caller, payoutTable, amount)
    local someoneGotPaid = false
        for k,v in pairs(payoutTable) do
            if (v[2]~=0) then
                someoneGotPaid = true
                local calc = 0
                local string = ''
                if caller.SHARE_DESCRIPTIONS_ARE_PERCENTAGE then
                    calc = math.ceil(amount*v[2]/10)
                    string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. '%.'
                else
                    calc = math.ceil(amount*v[2])
                    string = v[1].NAME .. ' paid ' .. formatLabel(calc) .. ' for ' .. v[2] .. ' shares.'
                end
                if not caller.COMPANIES_PAY_FROM_TREASURY then
                    transferMoneyWithBank(v[1], calc, false, false)
                else
                    caller.treasury = caller.treasury - calc
                    v[1].treasury = v[1].treasury + calc
                    updateLabel(v[1])
                    updateLabel(caller)
                end
                printToAll(string)
            end
        end
        if not someoneGotPaid then broadcastToAll('No company or player was paid dividends. Make sure shares are where they should be.') end
end

function payPrivates()
    local fakeCaller = {} --hacky shit so I can use the share search function on privates
    fakeCaller.shareDescription = 'Private'
    local use_gm = gameOptions.PRIVATES_USE_GM_NOTES

    local payoutTable = {}
    --Part of this function spawns ScriptingZones, which take more than one frame to load.
    --The waitFlags are used to make sure all ScriptingZones have loaded and done their thing before continuing.
    local waitFlags = {}

    --tabulate player privates
    for k,v in pairs(gameEntities.PLAYERS) do
        payoutTable[k] = {v, 0}
        --if player has a designated zone, search that for shares matching this company
        if getObjectFromGUID(v.shareZoneGUID) then
            if getObjectFromGUID(v.shareZoneGUID).tag == 'Scripting' then
                payoutTable[k][2] = searchContainer(getObjectFromGUID(v.shareZoneGUID).getObjects(), fakeCaller, payoutTable[k][2], use_gm)
            else

                waitFlags[k] = false

                --Dynamically spawn a scripting zone to on the charter
                local bb = getObjectFromGUID(v.shareZoneGUID).getBoundsNormalized()
                local params = {}
                local callbackName = "callbackPlayer" .. k
                params.position = getObjectFromGUID(v.shareZoneGUID).getPosition()
                params.rotation = getObjectFromGUID(v.shareZoneGUID).getRotation()
                params.scale = { bb.size.x, bb.size.y+8, bb.size.z }
                params.callback = callbackName
                params.type = 'ScriptingTrigger'
                params.sound = false
                local zone = spawnObject(params)

                local callbackFunc = function()
                    payoutTable[k][2] = searchContainer(zone.getObjects(), fakeCaller, payoutTable[k][2], use_gm)
                    waitFlags[k] = true
                    zone.destruct()
                end
                Global.setVar(callbackName, callbackFunc)

            end
        end
        --search the player's hand
        if gameOptions.HAND_SHARES_PAY_PLAYER then
            payoutTable[k][2] = searchContainer(Player[k].getHandObjects(), fakeCaller, payoutTable[k][2], use_gm)
        end
    end

    --tabulate company privates
    for k,v in pairs(gameEntities.COMPANIES) do
        if v.COMPANIES_CAN_OWN_PRIVATES and v.USE_PRIVATES then
            payoutTable[k] = {v,0}
            waitFlags[k] = false

            --Dynamically spawn a scripting zone to on the charter
            local bb = getObjectFromGUID(v.charterGUID).getBoundsNormalized()
            local params = {}
            local callbackName = "callback" .. k .. "private"
            params.position = getObjectFromGUID(v.charterGUID).getPosition()
            params.rotation = getObjectFromGUID(v.charterGUID).getRotation()
            params.scale = { bb.size.x, bb.size.y+8, bb.size.z }
            params.callback = callbackName
            params.type = 'ScriptingTrigger'
            params.sound = false
            local zone = spawnObject(params)

            local callbackFunc = function()
                payoutTable[k][2] = searchContainer(zone.getObjects(), fakeCaller, payoutTable[k][2], use_gm)
                waitFlags[k] = true
                zone.destruct()
            end
            Global.setVar(callbackName, callbackFunc)
        end
    end

    Wait.condition(
    function()
        transferPrivatePayouts(payoutTable)
    end,
    function()
        local temp = true
        for k,v in pairs(waitFlags) do
            temp = temp and v
        end
        return temp
    end)
end

function transferPrivatePayouts(payoutTable)
    printToAll("--- Privates pay out ---")
    local someoneGotPaid = false
    for k,v in pairs(payoutTable) do
        if (v[2]~=0) then
            transferMoneyWithBank(v[1], v[2], false, false)
            printToAll(v[1].NAME .. ' paid ' .. formatLabel(v[2]) .. ' for Privates')
            someoneGotPaid = true
        end
    end
    if not someoneGotPaid then broadcastToAll('No company or player was paid revenue. Make sure private companies are where they should be.') end
end

function searchContainer(container, caller, count, gm)
    if gm then return searchContainerGM(container, caller, count) end

    --this only works if container is a literal list of object values
    for i,o in ipairs(container) do
        if o.getQuantity() == -1 then
            --object is a singleton
            count = addShare(o.getDescription(),caller,count)
        else
            --object is a deck, or maybe not because getQuanity works for stacks but getObjects does not.
            if o.tag=='Deck' then
                for j,k in ipairs(o.getObjects()) do
                    count = addShare(k.description,caller,count)
                end
            end
        end
    end
    return count
end

function searchContainerGM(container, caller, count)
    --same as above but with GM notes
    --this only works if container is a literal list of object values
    for i,o in ipairs(container) do
        if o.getQuantity() == -1 then
            --object is a singleton
            count = addShare(o.getGMNotes(),caller,count)
        else
            --object is a deck, or maybe not because getQuanity works for stacks but getObjects does not.
            if o.tag=='Deck' then
                for j,k in ipairs(o.getObjects()) do
                    count = addShare(k.gm_notes,caller,count)
                end
            end
        end
    end
    return count
end

function addShare(description, caller, count)
    --if description includes the caller's expected description then add to num
    if (string.find(description, caller.shareDescription, 1, true)) then
        local num = tonumber(string.sub(description, 1+#caller.shareDescription))
        if num ~= nil then
            return (count + num)
        end
    end
    return count
end

---MISC. HELPER FUNCTIONS---

function changeSize(company)
    company.issueIndex = incLoop(company.issueIndex,#company.ISSUE_SIZE)
    company.issueSize = company.ISSUE_SIZE[company.issueIndex]
    if (type(company.HALF_PAY_ROUND) == 'table') then
        company.halfPayRound = company.HALF_PAY_ROUND[company.issueIndex]
    end
    getObjectFromGUID(company.inputCounterGUID).editButton({index=company.changeSizeButtonIndex, label=company.ISSUE_SIZE[company.issueIndex]..'-Share',})
end

function incLoop(input,max)
    --returns input+1 unless input+1 > max, in which case return 1.
    --good for looping through tables with numbered indicies.
    if input+1 > max then
        return 1
    else
        return input+1
    end
end

function logTransaction(amount, source, target, print, log)
    local str = os.date("%H:%M - ") .. 'Transferred ' .. formatLabel(amount) .. ' from ' .. source .. ' to ' .. target
    if print then
        printToAll(str)
    end

    if TRANSACTION_LOG and log then
        --nested tables?
        TRANSACTIONS = { next = TRANSACTIONS, value = str }
        local t = TRANSACTIONS
        local item = 0
        local transactionLog = ''
        while t and item < 9 do
            transactionLog = transactionLog .. t.value .. '\n'
            item = item + 1
            t = t.next
        end
        TRANSACTION_LOG.setDescription(transactionLog)
    end
end

function updateLabel(table_entry)
    if not table_entry.moneyLabelGUID then return end
    local label = getObjectFromGUID(table_entry.moneyLabelGUID)
    local button_parameters = {}
    button_parameters.click_function = 'nilFunction'
    button_parameters.label = formatLabel(table_entry.treasury)
    button_parameters.position = {0, 0.5, 0.05}
    button_parameters.rotation = {0, 0, 0}
    button_parameters.width = 0
    button_parameters.height = 0
    button_parameters.font_size = 1000
    local s = label.getScale()
    local larger = math.max(s.x,s.z)
    button_parameters.scale = 0.25*Vector({larger/s.x,1,larger/s.z})

    if table_entry.LABEL_COLOR then
        button_parameters.font_color = table_entry.LABEL_COLOR
    end

    getObjectFromGUID(table_entry.moneyLabelGUID).clearButtons()
    getObjectFromGUID(table_entry.moneyLabelGUID).createButton(button_parameters)
end

function formatLabel(number)
    local newLabel = format_int(number)
    if gameOptions.MONEY_SYMBOL then
        if gameOptions.MONEY_SYMBOL_POSITION == 'end' then
            newLabel = newLabel .. gameOptions.MONEY_SYMBOL
        else
            newLabel = gameOptions.MONEY_SYMBOL .. newLabel
        end
    end
    return newLabel
end

function format_int(number)
  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")
  -- reverse the int-string back remove an optional comma and put the
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

function addv(v1, v2)
    --add vectors
    return {v1[1]+v2[1], v1[2]+v2[2], v1[3]+v2[3]}
end

function roundTo(input, roundAmount, upDown)
    --returns input rounded to roundAmount
    --if upDown = true, round up, else round down
    if upDown then
        return math.ceil(input / roundAmount) * roundAmount
    else
        return math.floor(input / roundAmount) * roundAmount
    end
end

function checkInvest()
    --returns true if any company has COMPANIES_CAN_CROSS_INVEST set.
    local ret = false
    for k,v in pairs(gameEntities.COMPANIES) do
        if v.COMPANIES_CAN_CROSS_INVEST then ret = true end
    end
    return ret
end

-- event functions ---
function onPlayerChangeColor(color)
    if gameEntities.PLAYERS[color] then gameEntities.PLAYERS[color].NAME = Player[color].steam_name end
end

function onObjectDrop(_, obj)
    if gameEntities.OTHER_ACTORS.REVENUE_TRACKER then
        if #obj.getDescription() > 30 then return end
        if (string.find(obj.getDescription(), "Revenue")) or (string.find(obj.getDescription(), "revenue")) or (string.find(obj.getDescription(), "REVENUE")) then
            local str = obj.getDescription()

            --I don't know anything about string functions, this should remove the word "revenue" and any excess spaces
            --But leave the spaces within the company name alone.
            --Unless user put a company name that has spaces, like, at the end of it e.g., 'B&O    ' but then the user is a moron so screw them.
            str = string.gsub(str, "^%s*(.-)%s*$", "%1")
            str = string.sub(str,1,-8)
            str = string.gsub(str, "^%s*(.-)%s*$", "%1")

            --check if remaining string corresponds to a company.
            if gameEntities.COMPANIES[str] ~= nil then
                --set the token to not sticky, so it doesn't lift other tokens with it when grabbed.
                obj.sticky = false

                --check if object was dropped within the revenue tracker.
                local pos = obj.getPosition()
                for _,b in ipairs(gameEntities.OTHER_ACTORS.REVENUE_TRACKER) do
                    if b.valid then
                        if pos.x >= b.upperleft.x and pos.x<= b.lowerright.x and pos.z <= b.upperleft.z and pos.z >= b.lowerright.z then
                            --find x-cell
                            local xcell = math.floor( (math.abs(pos.x-b.upperleft.x)/b.width)*b.COLS )
                            local zcell = math.floor( (math.abs(pos.z-b.upperleft.z)/b.height)*b.ROWS )

                            --snap to grid
                            obj.setPositionSmooth({b.upperleft.x + b.cellWidth*(xcell+0.5), pos.y, b.upperleft.z - b.cellHeight*(zcell+0.5)}, false, true)

                            --recalculate for reverse
                            if b.REVERSE_COLS then xcell = math.floor( (math.abs(pos.x-b.lowerright.x)/b.width)*b.COLS ) end
                            if b.REVERSE_ROWS then zcell = math.floor( (math.abs(pos.z-b.lowerright.z)/b.height)*b.ROWS ) end

                            --set counter based on grid position
                            local company = gameEntities.COMPANIES[str]
                            company['revenueTrackerGUID'] = obj.getGUID()
                            local input = getObjectFromGUID(company.inputCounterGUID)

                            local val = b.START + xcell + b.VERTICAL_INC*zcell

                            if company.ADJUST_INPUT_BY_REVENUE then
                                if company.TRACK_REVENUE_PER_SHARE then
                                    setValue(company, val*company.issueSize)
                                else
                                    setValue(company, val*10)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

---Hardcoded values---

ERROR_COLOR = {r=1, g=0, b=0}

bankTransferParams = {}
bankTransferParams.label = 'Spend'
bankTransferParams.position = {-0.8,0.1,-0.8}
bankTransferParams.rotation = {0,0,0}
bankTransferParams.width = 2500
bankTransferParams.height = 1000
bankTransferParams.font_size = 1000
bankTransferParams.tooltip = 'Send money to the bank.'
bankTransferParams.scale = {0.3,0.3,0.3}


withholdParams = {}
withholdParams.label = 'Take'
withholdParams.position = {0.8,0.1,-0.8}
withholdParams.rotation = {0,0,0}
withholdParams.width = 2500
withholdParams.height = 1000
withholdParams.font_size = 1000
withholdParams.tooltip = 'Take money from the bank.'
withholdParams.scale = {0.3,0.3,0.3}

payFullParams = {}
payFullParams.label = 'Payout'
payFullParams.tooltip = 'Pay money to the shareholders.'
payFullParams.position = {0,0.1,-1.5}
payFullParams.rotation = {0,0,0}
payFullParams.width = 2500
payFullParams.height = 1000
payFullParams.font_size = 1000
payFullParams.scale = {0.3,0.3,0.3}

payHalfParams = {}
payHalfParams.label = 'Pay Half'
payHalfParams.position = {-1,0.1, 0}
payHalfParams.rotation = {0,180,0}
payHalfParams.width = 400
payHalfParams.height = 100
payHalfParams.font_size = 50

payPrivatesParams = {}
payPrivatesParams.label = 'Pay Privates'
payPrivatesParams.click_function = 'payPrivates'
payPrivatesParams.position = {0,0.25,0}
payPrivatesParams.width = 1600
payPrivatesParams.height = 450
payPrivatesParams.font_size = 225

changeSizeParams = {}
changeSizeParams.label = 'filler, set by code'
changeSizeParams.position = {1,0.1, 0}
changeSizeParams.rotation = {0,180,0}
changeSizeParams.width = 400
changeSizeParams.height = 100
changeSizeParams.font_size = 75
changeSizeParams.tooltip = 'Click here to cycle through issue sizes'