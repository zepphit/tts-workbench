-- Bundled by luabundle {"rootModuleName":"Zero Marker.0289cb.lua","version":"1.6.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(nil)
__bundle_register("Zero Marker.0289cb.lua", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/AmbitionMarkers")

end)
__bundle_register("src/AmbitionMarkers", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Used in all aspects of manipulating zero marker and 3 ambition markers
require("src/GUIDs")

local ambitionMarkers = {}

local action_cards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local Log = require("src/LOG")

-- is_face_down = false = lower (teal) side is face up
-- is_face_down = true  = higher (yellow) side is face up
local markers = {
    {
        object = getObjectFromGUID(ambition_marker_GUIDs[1]),
        column_pos = Vector({-0.83, 0.2, -1.07}),
        [false] = {
            first_power = 5,
            second_power = 3,
            power_desc = "5 / 3 power"
        },
        [true] = {
            first_power = 9,
            second_power = 4,
            power_desc = "9 / 4 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[2]),
        column_pos = Vector({-0.92, 0.2, -1.07}),
        [false] = {
            first_power = 3,
            second_power = 2,
            power_desc = "3 / 2 power"
        },
        [true] = {
            first_power = 6,
            second_power = 3,
            power_desc = "6 / 3 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[3]),
        column_pos = Vector({-1.00, 0.21, -1.07}),
        [false] = {
            first_power = 2,
            second_power = 0,
            power_desc = "2 / 0 power"
        },
        [true] = {
            first_power = 4,
            second_power = 2,
            power_desc = "4 / 2 power"
        }
    },   {
        object = getObjectFromGUID(ambition_marker_GUIDs[4]),
        column_pos = Vector({-0.83, 0.2, -1.07}),
        [true] = {
            first_power = 6,
            second_power = 4,
            third_power = 2,
            power_desc = "6 / 4 / 2 power"
        },
        [false] = {
            first_power = 10,
            second_power = 5,
            third_power = 3,
            power_desc = "10 / 5 / 3 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[5]),
        column_pos = Vector({-0.92, 0.2, -1.07}),
        [true] = {
            first_power = 4,
            second_power = 2,
            third_power = 1,
            power_desc = "4 / 2 / 1 power"
        },
        [false] = {
            first_power = 7,
            second_power = 4,
            third_power = 2,
            power_desc = "7 / 4 / 2 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[6]),
        column_pos = Vector({-1.00, 0.21, -1.07}),
        [false] = {
            first_power = 3,
            second_power = 1,
            third_power = 0,
            power_desc = "3 / 1 / 0 power"
        },
        [true] = {
            first_power = 5,
            second_power = 2,
            third_power = 1,
            power_desc = "5 / 2 / 1 power"
        }
    }
}

local ambitions = {
    {
        name = "Undeclared",
        row_pos = Vector({0, 0, -0.01})
    }, {
        name = "Tycoon",
        row_pos = Vector({0, 0, 0.35})
    }, {
        name = "Tyrant",
        row_pos = Vector({0, 0, 0.74})
    }, {
        name = "Warlord",
        row_pos = Vector({0, 0, 1.12})
    }, {
        name = "Keeper",
        row_pos = Vector({0, 0, 1.5})
    }, {
        name = "Empath",
        row_pos = Vector({0, 0, 1.91})
    }
}

local last_declared_marker = nil
local zero_button_hidden = false
local zero_button_menu_attached = false

function ambitionMarkers:is_zero_button_hidden()
    return zero_button_hidden or Global.getVar("zero_marker_button_hidden") or false
end

function ambitionMarkers:set_zero_button_hidden(hidden)
    zero_button_hidden = hidden
    if Global and Global.setVar then
        Global.setVar("zero_marker_button_hidden", hidden)
    end
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    if not zero_marker then
        return
    end

    if hidden then
        if zero_marker.clearButtons then
            zero_marker.clearButtons()
        elseif zero_marker.getButtons then
            local buttons = zero_marker.getButtons() or {}
            for index, button in ipairs(buttons) do
                if button and button.click_function == 'declare_ambition' then
                    pcall(function() zero_marker.removeButton(index) end)
                end
            end
        end
    else
        ambitionMarkers.add_button()
    end
end

function ambitionMarkers:toggle_zero_button(player_color, position, clicked_object)
    local hidden = ambitionMarkers:is_zero_button_hidden()
    ambitionMarkers:set_zero_button_hidden(not hidden)
    local status = hidden and "enabled" or "disabled"
    if type(player_color) == "string" and player_color ~= "" then
        broadcastToColor("Zero marker ambition button " .. status, player_color, {0.8, 0.8, 0.2})
    else
        broadcastToAll("Zero marker ambition button " .. status, {0.8, 0.8, 0.2})
    end
end

function ambitionMarkers:ensure_zero_marker_context_menu()
    if zero_button_menu_attached then
        return
    end

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    if not zero_marker or not zero_marker.addContextMenuItem then
        return
    end
    pcall(function()
        zero_marker.addContextMenuItem("Toggle Zero Button", function(player_color, position, clicked_object)
            ambitionMarkers:toggle_zero_button(player_color, position, clicked_object)
        end)
        zero_button_menu_attached = true
    end)
end

function ambitionMarkers:get_ambition_info(object)
    -- Guard against missing object or reach board (load-order issues)
    if not object or not object.getPosition then
        -- Try resolving the ambition marker by any known ambition_marker_GUIDs
        local found = nil
        if ambition_marker_GUIDs then
            for i = 1, #ambition_marker_GUIDs do
                local g = ambition_marker_GUIDs[i]
                local o = getObjectFromGUID(g)
                if o and o.getPosition then
                    found = o
                    break
                end
            end
        end
        if not found then
            Log.WARNING("get_ambition_info called with invalid object and no ambition marker fallbacks available")
            return
        end
        object = found
    end

    -- safe guid for retry tracking and indexing
    local obj_guid = (object.getGUID and object.getGUID()) or object.guid or "unknown"

    local reach_map = getObjectFromGUID(reach_board_GUID)
    if not reach_map then
        -- Wait and retry a few times in case the reach board hasn't loaded yet
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("reach_board not found; aborting ambition info for " .. tostring(obj_guid))
            return
        end
    end

    -- ensure object has a valid position
    local obj_pos = object.getPosition()
    if not obj_pos then
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("object has no position; aborting ambition info for " .. tostring(obj_guid))
            return
        end
    end

    local local_pos = reach_map.positionToLocal(obj_pos)
    if not local_pos then
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("positionToLocal returned nil; aborting for " .. tostring(obj_guid))
            return
        end
    end

    -- Instead of computing only for the moved object, refresh all markers
    ambitionMarkers.refresh_all_ambitions()
end


-- Scan all ambition markers and update the global ambitions table
function ambitionMarkers:refresh_all_ambitions()
    local reach_map = getObjectFromGUID(reach_board_GUID)
    if not reach_map then
        -- retry shortly if reach board missing
        Wait.time(function()
            ambitionMarkers.refresh_all_ambitions()
        end, 0.5)
        return
    end

    local global_ambitions = {}
    for i = 1, (ambition_marker_GUIDs and #ambition_marker_GUIDs or 0) do
        local guid = ambition_marker_GUIDs[i]
        local obj = getObjectFromGUID(guid)
        if obj and obj.getPosition then
            local pos = obj.getPosition()
            local local_pos = reach_map.positionToLocal(pos)
            if local_pos then
                local ambition_pos_z = local_pos.z
                local ambition_number = math.floor((ambition_pos_z + 1.83) / 0.39)
                if (ambition_number == 1) then
                    global_ambitions[guid] = ""
                elseif (ambition_number == 2) then
                    global_ambitions[guid] = "Tycoon"
                elseif (ambition_number == 3) then
                    global_ambitions[guid] = "Tyrant"
                elseif (ambition_number == 4) then
                    global_ambitions[guid] = "Warlord"
                elseif (ambition_number == 5) then
                    global_ambitions[guid] = "Keeper"
                elseif (ambition_number == 6) then
                    global_ambitions[guid] = "Empath"
                else
                    global_ambitions[guid] = ""
                end
            else
                global_ambitions[guid] = ""
            end
        else
            global_ambitions[guid] = ""
        end
    end


    Wait.time(function()
        Global.setVar("active_ambitions", global_ambitions)
        Global.call("update_player_scores")
    end, 1)
end


-- Calculate estimated ambition points for each player based on the currently
-- declared ambition markers and their flipped states. Returns a table
-- mapping player color -> estimated points (number).
function ambitionMarkers:calculate_player_ambition_points()
    local estimates = {}
    local active_players = Global.getVar("active_players") or {}
    for _, p in ipairs(active_players) do estimates[p.color] = 0 end

    local active_ambitions = Global.getVar("active_ambitions") or {}
    -- mapping from ambition name to ArcsPlayer stat field
    local stat_map = {
        Tycoon = "tycoon",
        Tyrant = "captives",
        Warlord = "trophies",
        Keeper = "keeper",
        Empath = "empath"
    }

    -- Helper: find index of guid in ambition_marker_GUIDs
    local function find_marker_index(guid)
        if not ambition_marker_GUIDs then return nil end
        for i = 1, #ambition_marker_GUIDs do
            if ambition_marker_GUIDs[i] == guid then return i end
        end
        return nil
    end

    -- Collect markers by ambition name (a single ambition may have multiple markers; sum their rewards)
    for guid, ambition_name in pairs(active_ambitions) do
        if ambition_name and ambition_name ~= "" and stat_map[ambition_name] then
            local idx = find_marker_index(guid)
            if not idx then goto continue end
            local marker_def = markers[idx]
            if not marker_def then goto continue end

            local obj = getObjectFromGUID(guid)
            local flipped = false
            if obj and obj.is_face_down ~= nil then flipped = obj.is_face_down end
            local power_def = marker_def[flipped] or marker_def[false] or {}

            -- build prize list (1st, 2nd, optional 3rd)
            local prizes = {}
            if power_def.first_power then table.insert(prizes, power_def.first_power) end
            if power_def.second_power then table.insert(prizes, power_def.second_power) end
            if power_def.third_power then table.insert(prizes, power_def.third_power) end

            -- Build ranking of players for this ambition
            local stat_field = stat_map[ambition_name]
            local players = {}
            for _, p in ipairs(active_players) do
                -- ensure player's stats have been updated (update_score should be called beforehand)
                local val = 0
                pcall(function() val = tonumber(p[stat_field]) or 0 end)
                -- Qualification: player must have at least 1 of the stat to qualify
                if val >= 1 then
                    table.insert(players, { color = p.color, value = val })
                end
            end
            if #players == 0 then goto continue end
            table.sort(players, function(a, b) return a.value > b.value end)

            -- Assign prizes with tie rules:
            -- - Players must have >=1 to qualify (already filtered)
            -- - If multiple players tie for a rank, they each receive the prize
            --   for one position lower (i.e., tied players go down one spot).
            local pos = 1
            while pos <= #players do
                -- find tie group
                local tie_val = players[pos].value
                local tie_group = { players[pos] }
                local j = pos + 1
                while j <= #players and players[j].value == tie_val do
                    table.insert(tie_group, players[j])
                    j = j + 1
                end

                -- Determine prize index: if tie group size > 1, they go down one spot
                local prize_index
                if #tie_group > 1 then
                    prize_index = pos + 1
                else
                    prize_index = pos
                end
                local prize = prizes[prize_index] or 0

                for _, entry in ipairs(tie_group) do
                    estimates[entry.color] = (estimates[entry.color] or 0) + prize
                end

                pos = j
            end
        end
        ::continue::
    end

    return estimates
end

-- Helper: apply a card-based ambition demotion (e.g., Elder for Tyrant, Archivist for Tycoon, Warrior for Empath)
local function apply_ambition_card_demotion(ambition_name, card_name, per_player, result, prizes, untied_winners, active_players)
    if ambition_name and card_name then
        for _, p in ipairs(active_players) do
            local has_card = false
            local area_zone_guid = nil
            pcall(function()
                if player_pieces_GUIDs and player_pieces_GUIDs[p.color] then
                    area_zone_guid = player_pieces_GUIDs[p.color].area_zone
                end
            end)
            if area_zone_guid then
                local area_zone = getObjectFromGUID(area_zone_guid)
                if area_zone and area_zone.getObjects then
                    local objs = area_zone.getObjects()
                    for _, obj in ipairs(objs) do
                        local obj_name = ""
                        pcall(function() obj_name = obj.getName() or "" end)
                        if string.find(obj_name or "", card_name) then
                            has_card = true
                            break
                        end
                    end
                end
            end

            if has_card then
                local prev = per_player[p.color] or 0
                
                -- Only process if player actually qualified (had some points)
                if prev > 0 then
                    -- Find which rank the player currently earned
                    local current_rank = nil
                    for i, prize in ipairs(prizes) do
                        if prev == prize then
                            current_rank = i
                            break
                        end
                    end
                    
                    if current_rank and current_rank > 0 then
                        -- Demote by one rank
                        local new_rank = current_rank + 1
                        local new_prize = prizes[new_rank] or 0
                        
                        -- Adjust only this player's points
                        local adjustment = new_prize - prev
                        result.totals[p.color] = (result.totals[p.color] or 0) + adjustment
                        per_player[p.color] = new_prize
                        
                        -- If they were untied first place winner, remove city bonus
                        if current_rank == 1 and untied_winners[ambition_name] == p.color then
                            untied_winners[ambition_name] = nil
                        end
                        
                        -- Record demotion note
                        if not result.ambition_notes[ambition_name] then result.ambition_notes[ambition_name] = {} end
                        local rank_label = nil
                        if new_rank == 2 then
                            rank_label = "2nd"
                        elseif new_rank == 3 then
                            rank_label = "3rd"
                        else
                            rank_label = tostring(new_prize) .. " points"
                        end
                        local extra = ""
                        if current_rank == 1 then
                            extra = "; no city bonus"
                        end
                        result.ambition_notes[ambition_name][p.color] = "(" .. card_name .. ": demoted to " .. rank_label .. extra .. ")"
                    end
                end
            end
        end
    end
end

-- Helper: apply Noble card restriction (only points if untied 1st place, else 0)
local function apply_ambition_card_noble(ambition_name, per_player, result, untied_winners, active_players)
    for _, p in ipairs(active_players) do
        local has_noble = false
        local area_zone_guid = nil
        pcall(function()
            if player_pieces_GUIDs and player_pieces_GUIDs[p.color] then
                area_zone_guid = player_pieces_GUIDs[p.color].area_zone
            end
        end)
        if area_zone_guid then
            local area_zone = getObjectFromGUID(area_zone_guid)
            if area_zone and area_zone.getObjects then
                local objs = area_zone.getObjects()
                for _, obj in ipairs(objs) do
                    local obj_name = ""
                    pcall(function() obj_name = obj.getName() or "" end)
                    if string.find(obj_name or "", "Noble") then
                        has_noble = true
                        break
                    end
                end
            end
        end

        if has_noble then
            local prev = per_player[p.color] or 0
            
            -- Only keep points if they were untied first place winner
            if untied_winners[ambition_name] ~= p.color then
                if prev > 0 then
                    -- Record note about losing points
                    if not result.ambition_notes[ambition_name] then result.ambition_notes[ambition_name] = {} end
                    result.ambition_notes[ambition_name][p.color] = "(Noble: no points unless untied 1st place)"
                    -- Set to 0
                    result.totals[p.color] = (result.totals[p.color] or 0) - prev
                    per_player[p.color] = 0
                end
            end
        end
    end
end

-- Helper: block points for a specific ambition if player has a card
local function apply_ambition_card_block(current_ambition, blocked_ambition, card_name, per_player, result, untied_winners, active_players)
    if current_ambition ~= blocked_ambition then
        return
    end

    for _, p in ipairs(active_players) do
        local has_card = false
        local area_zone_guid = nil
        pcall(function()
            if player_pieces_GUIDs and player_pieces_GUIDs[p.color] then
                area_zone_guid = player_pieces_GUIDs[p.color].area_zone
            end
        end)
        if area_zone_guid then
            local area_zone = getObjectFromGUID(area_zone_guid)
            if area_zone and area_zone.getObjects then
                local objs = area_zone.getObjects()
                for _, obj in ipairs(objs) do
                    local obj_name = ""
                    pcall(function() obj_name = obj.getName() or "" end)
                    if string.find(obj_name or "", card_name) then
                        has_card = true
                        break
                    end
                end
            end
        end

        if has_card then
            local prev = per_player[p.color] or 0
            if prev > 0 then
                -- Record note about blocking
                if not result.ambition_notes[blocked_ambition] then result.ambition_notes[blocked_ambition] = {} end
                result.ambition_notes[blocked_ambition][p.color] = "(" .. card_name .. ": blocked)"
                -- Set to 0
                result.totals[p.color] = (result.totals[p.color] or 0) - prev
                per_player[p.color] = 0
                if untied_winners[blocked_ambition] == p.color then
                    untied_winners[blocked_ambition] = nil
                end
            end
        end
    end
end

-- Build a detailed breakdown per ambition token and per-player assignment.
-- Returns a table: { totals = {color->points}, tokens = { { guid=..., ambition=..., prizes={...}, per_player={color->points} } } }
function ambitionMarkers:build_detailed_estimates()
    local result = { totals = {}, tokens = {}, ambition_bonuses = {}, ambition_notes = {} }
    local active_players = Global.getVar("active_players") or {}
    for _, p in ipairs(active_players) do result.totals[p.color] = 0 end

    local active_ambitions = Global.getVar("active_ambitions") or {}
    local stat_map = {
        Tycoon = "tycoon",
        Tyrant = "captives",
        Warlord = "trophies",
        Keeper = "keeper",
        Empath = "empath"
    }

    local function find_marker_index(guid)
        if not ambition_marker_GUIDs then return nil end
        for i = 1, #ambition_marker_GUIDs do if ambition_marker_GUIDs[i] == guid then return i end end
        return nil
    end

    -- Track which players won first place (untied) for which ambitions
    local untied_winners = {}  -- ambition_name -> player_color

    for guid, ambition_name in pairs(active_ambitions) do
        if ambition_name and ambition_name ~= "" and stat_map[ambition_name] then
            local idx = find_marker_index(guid)
            if not idx then goto continue end
            local marker_def = markers[idx]
            if not marker_def then goto continue end

            local obj = getObjectFromGUID(guid)
            local flipped = false
            if obj and obj.is_face_down ~= nil then flipped = obj.is_face_down end
            local power_def = marker_def[flipped] or marker_def[false] or {}

            local prizes = {}
            if power_def.first_power then table.insert(prizes, power_def.first_power) end
            if power_def.second_power then table.insert(prizes, power_def.second_power) end
            if power_def.third_power then table.insert(prizes, power_def.third_power) end

            -- build players who qualify
            local stat_field = stat_map[ambition_name]
            local players = {}
            for _, p in ipairs(active_players) do
                local val = 0
                pcall(function() val = tonumber(p[stat_field]) or 0 end)
                if val >= 1 then table.insert(players, { color = p.color, value = val }) end
            end
            if #players == 0 then
                -- record a token with zero impact
                local per_player = {}
                for _, p in ipairs(active_players) do per_player[p.color] = 0 end
                table.insert(result.tokens, { guid = guid, ambition = ambition_name, prizes = prizes, per_player = per_player, flipped = flipped })
                goto continue
            end
            table.sort(players, function(a,b) return a.value > b.value end)

            -- per-player points for this token
            local per_player = {}
            for _, p in ipairs(active_players) do per_player[p.color] = 0 end

            local pos = 1
            while pos <= #players do
                local tie_val = players[pos].value
                local tie_group = { players[pos] }
                local j = pos + 1
                while j <= #players and players[j].value == tie_val do
                    table.insert(tie_group, players[j])
                    j = j + 1
                end

                local prize_index = (#tie_group > 1) and (pos + 1) or pos
                local prize = prizes[prize_index] or 0
                for _, entry in ipairs(tie_group) do
                    per_player[entry.color] = (per_player[entry.color] or 0) + prize
                    result.totals[entry.color] = (result.totals[entry.color] or 0) + prize
                end

                -- Track untied first place winners
                if pos == 1 and #tie_group == 1 then
                    untied_winners[ambition_name] = tie_group[1].color
                end

                pos = j
            end

                -- Apply card-based ambition demotions
                if ambition_name == "Tyrant" then
                    apply_ambition_card_demotion("Tyrant", "Elder", per_player, result, prizes, untied_winners, active_players)
                elseif ambition_name == "Tycoon" then
                    apply_ambition_card_demotion("Tycoon", "Archivist", per_player, result, prizes, untied_winners, active_players)
                elseif ambition_name == "Empath" then
                    apply_ambition_card_demotion("Empath", "Warrior", per_player, result, prizes, untied_winners, active_players)
                end
                apply_ambition_card_demotion(ambition_name, "VOW OF SURVIVAL", per_player, result, prizes, untied_winners, active_players)

                -- Apply card-based ambition blocks (set to 0)
                apply_ambition_card_block(ambition_name, "Warlord", "OATH OF PEACE", per_player, result, untied_winners, active_players)
                apply_ambition_card_block(ambition_name, "Tycoon", "IRE OF THE TYCOONS", per_player, result, untied_winners, active_players)

                -- Apply Noble card restriction (all ambitions)
                apply_ambition_card_noble(ambition_name, per_player, result, untied_winners, active_players)

                table.insert(result.tokens, { guid = guid, ambition = ambition_name, prizes = prizes, per_player = per_player, flipped = flipped })
        end
        ::continue::
    end

    -- Apply loyal city bonuses for untied first place winners
    for ambition_name, winner_color in pairs(untied_winners) do
        local winner_player = nil
        for _, p in ipairs(active_players) do
            if p.color == winner_color then
                winner_player = p
                break
            end
        end

        if winner_player then
            -- Get the player's area zone
            local area_zone_guid = nil
            pcall(function()
                if player_pieces_GUIDs and player_pieces_GUIDs[winner_color] then
                    area_zone_guid = player_pieces_GUIDs[winner_color].area_zone
                end
            end)

            if area_zone_guid then
                local area_zone = getObjectFromGUID(area_zone_guid)
                if area_zone and area_zone.getObjects then
                    local zone_objects = area_zone.getObjects()
                    local loyal_city_count = 0
                    
                    -- Count only cities belonging to the winning player in their own area zone.
                    local city_guid_set = {}
                    if player_pieces_GUIDs and player_pieces_GUIDs[winner_color] and player_pieces_GUIDs[winner_color].cities then
                        for _, city_guid in ipairs(player_pieces_GUIDs[winner_color].cities) do
                            if city_guid then
                                city_guid_set[tostring(city_guid)] = true
                            end
                        end
                    end

                    for _, obj in ipairs(zone_objects) do
                        local obj_name = ""
                        pcall(function() obj_name = obj.getName() or "" end)
                        local obj_guid = ""
                        pcall(function() if obj and obj.getGUID then obj_guid = tostring(obj.getGUID()) end end)
                        local is_player_city = city_guid_set[obj_guid] == true
                        if not is_player_city then
                            is_player_city = string.find(obj_name, winner_color .. " City") ~= nil
                        end
                        if is_player_city then
                            loyal_city_count = loyal_city_count + 1
                        end
                    end

                    -- Apply bonus
                    local bonus = 0
                    if loyal_city_count == 0 then
                        bonus = 5
                    elseif loyal_city_count == 1 then
                        bonus = 2
                    end

                    if bonus > 0 then
                        result.totals[winner_color] = (result.totals[winner_color] or 0) + bonus
                        if not result.ambition_bonuses[ambition_name] then
                            result.ambition_bonuses[ambition_name] = {}
                        end
                        result.ambition_bonuses[ambition_name][winner_color] = bonus
                    end
                end
            end
        end
    end

    return result
end

function ambitionMarkers:set_zero_marker_button(click_function, tooltip)
    if ambitionMarkers:is_zero_button_hidden() then
        return false
    end

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    if not zero_marker then
        return false
    end

    local existing_button = nil
    if zero_marker.getButtons then
        local buttons = zero_marker.getButtons() or {}
        for _, button in ipairs(buttons) do
            if button and (button.click_function == click_function or button.click_function == 'declare_ambition' or button.click_function == 'undo_ambition') then
                existing_button = button
                break
            end
        end
    end

    if existing_button then
        local ok, err = pcall(function()
            local edit_params = {
                click_function = click_function,
                function_owner = zero_marker,
                position = {0, 0.05, 0},
                width = 3800,
                height = 950,
                tooltip = tooltip
            }
            if existing_button.index ~= nil then
                edit_params.index = existing_button.index
            end
            zero_marker.editButton(edit_params)
        end)
        if ok then
            return true
        end
    end

    local ok, err = pcall(function()
        zero_marker.createButton({
            click_function = click_function,
            function_owner = zero_marker,
            position = {0, 0.05, 0},
            width = 3800,
            height = 950,
            tooltip = tooltip
        })
    end)

    return ok
end

function ambitionMarkers:add_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    -- If the zero marker object isn't present yet (load order), retry shortly
    if not zero_marker then
        Wait.time(function()
            ambitionMarkers.add_button()
        end, 0.5)
        return
    end

    -- Attach context menu if needed even when the button is hidden
    ambitionMarkers:ensure_zero_marker_context_menu()

    if ambitionMarkers:is_zero_button_hidden() then
        return
    end

    local ok = ambitionMarkers:set_zero_marker_button('declare_ambition', 'Declare Ambition')
    if not ok then
        Wait.time(function()
            local zm = getObjectFromGUID(zero_marker_GUID)
            if zm then
                ambitionMarkers.add_button_attempts = (ambitionMarkers.add_button_attempts or 0) + 1
                if ambitionMarkers.add_button_attempts < 8 then
                    ambitionMarkers.add_button()
                end
            end
        end, 0.5)
    end
end

function ambitionMarkers:display_declare_button()
    if ambitionMarkers:is_zero_button_hidden() then
        return
    end

    ambitionMarkers:set_zero_marker_button('declare_ambition', 'Declare Ambition')
end

function ambitionMarkers:display_undo_button()
    if ambitionMarkers:is_zero_button_hidden() then
        return
    end

    ambitionMarkers:set_zero_marker_button('undo_ambition', 'Undo')
end


function ambitionMarkers:undo()
    broadcastToAll("Undo Ambition Declaration")
    if (last_declared_marker == nil) then
        Log.ERROR(
            "Could not find last declared ambition marker, resetting zero marker.")
         ambitionMarkers.display_declare_button()
        return
    end
    local reach_board = getObjectFromGUID(reach_board_GUID)
    if not reach_board then
        return
    end
    local undo_pos =
        reach_board.positionToWorld(last_declared_marker.column_pos)
    undo_pos.y = undo_pos.y + 0.3
    -- If this spot is occupied, place the returned marker to the left by 1.33
    local function positions_too_close(p1, p2)
        local dx = math.abs(p1.x - p2.x)
        local dz = math.abs(p1.z - p2.z)
        return dx < 0.45 and dz < 0.45
    end

    local occupied = false
    -- gather existing ambition marker world positions
    for _, m in ipairs(markers) do
        if m and m.object and m.object.getPosition then
            local ok, p = pcall(function() return m.object.getPosition() end)
            if ok and p and positions_too_close(undo_pos, p) then
                occupied = true
                break
            end
        end
    end

    if occupied then
        undo_pos.x = undo_pos.x - 1.33
    end

    if last_declared_marker and last_declared_marker.object and last_declared_marker.object.setPositionSmooth then
        last_declared_marker.object.setPositionSmooth(undo_pos)
    end

    -- move zero marker back
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    if zero_marker and zero_marker.setPositionSmooth then
        zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
        zero_marker.setRotationSmooth({0.00, 180.00, 0.00})
    end
    ambitionMarkers.display_declare_button()

    -- Immediately mark this marker as undeclared in Global state (safe via Global.call)
    pcall(function()
        local ok, guid = pcall(function() return last_declared_marker.object.getGUID() end)
        if ok and guid then
            pcall(function() Global.call('ambition_set_marker_undeclared', guid) end)
        end
    end)

    -- Refresh ambitions after undo movements settle (run in Global context)
    Wait.time(function()
        pcall(function() Global.call('ambition_refresh_proxy') end)
    end, 1.0)
end

function ambitionMarkers:reset_zero_marker()
    last_declared_marker = nil
    ambitionMarkers.display_declare_button()

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    local reach_board = getObjectFromGUID(reach_board_GUID)
    if zero_marker and reach_board and zero_marker.setPositionSmooth then
        zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
        zero_marker.setRotationSmooth({0.00, 180.00, 0.00})
    end
    -- Ensure global ambitions reflect reset position after move completes
    Wait.time(function()
        pcall(function() Global.call('ambition_refresh_proxy') end)
    end, 0.8)
end

function ambitionMarkers:highest_undeclared()
    local marker_zone = getObjectFromGUID(ambition_marker_zone_GUID)
    local available_markers = marker_zone.getObjects()
    local high_points = 0
    local high_marker = nil
    local marker_mapping = {
        [ambition_marker_GUIDs[1]] = markers[1],
        [ambition_marker_GUIDs[2]] = markers[2],
        [ambition_marker_GUIDs[3]] = markers[3],
        [ambition_marker_GUIDs[4]] = markers[4],
        [ambition_marker_GUIDs[5]] = markers[5],
        [ambition_marker_GUIDs[6]] = markers[6]
    }

    for _, marker in pairs(available_markers) do
        local this_marker = marker_mapping[marker.getGUID()]
        local this_points = this_marker[this_marker.object.is_face_down]
                                .first_power
        if this_points > high_points then
            high_points = this_points
            high_marker = this_marker
        end
    end

    return high_marker

end

-- Begin Object Code --
function onLoad()
    -- ambitionMarkers.add_button()
end
function declare_ambition(obj, player_color)

    local lead_info = action_cards.get_lead_info()

    -- Is there a lead card?
    if (not lead_info) then
        broadcastToColor("No lead card has been played", player_color)
        return
    end

    -- Is there an ambition marker?
    local high_marker = ambitionMarkers.highest_undeclared()
    if (not high_marker) then
        broadcastToColor("No ambition markers available", player_color)
        return
    end

    -- Get declared ambition 
    local is_faithful = (lead_info.type == "Faithful Zeal" or lead_info.type ==
                            "Faithful Wisdom")

    -- Is the lead card a 1?
    if (lead_info.real_number == 1 and not is_faithful) then
        broadcastToColor("Actions numbered 1 cannot be declared", player_color)
        return
    end

    local power = high_marker[high_marker.object.is_face_down].power_desc
    local reach_board = getObjectFromGUID(reach_board_GUID)

    local this_ambition
    local is_mandate = lead_info.type and string.find(lead_info.type, "Mandate")
    if (lead_info.real_number == 7 or is_faithful or is_mandate) then
        broadcastToAll("" .. player_color ..
                           " is declaring ambition of choice for " .. power,
            player_color)
        broadcastToColor("Move " .. power ..
                             " ambition marker to desired ambition",
            player_color)
    else
        this_ambition = ambitions[lead_info.real_number]
        
        -- Smart column selection: try middle first, then right, then left
        -- Only place in a column if it's empty at that ambition row
        -- World x-coordinates for columns: middle 17.64, right 18.97, left 16.16
        local function count_markers_at_ambition_row(target_x, target_z)
            local count = 0
            for _, m in ipairs(markers) do
                if m.object and m.object.getPosition then
                    local obj_pos = m.object.getPosition()
                    -- Check if marker is at this x column and approximately this z row
                    if math.abs(obj_pos.x - target_x) < 0.1 and math.abs(obj_pos.z - target_z) < 0.2 then
                        count = count + 1
                    end
                end
            end
            return count
        end
        
        -- Calculate the target z position for this ambition
        local target_pos = reach_board.positionToWorld(high_marker.column_pos + this_ambition.row_pos)
        local target_z = target_pos.z
        
        -- Check columns in priority order: middle, right, left
        local selected_column_x = 17.64  -- default to middle
        
        local middle_count = count_markers_at_ambition_row(17.64, target_z)
        if middle_count == 0 then
            selected_column_x = 17.64  -- middle is empty, use it
        else
            local right_count = count_markers_at_ambition_row(18.97, target_z)
            if right_count == 0 then
                selected_column_x = 18.97  -- middle is full, right is empty, use right
            else
                selected_column_x = 16.16  -- both middle and right full, use left
            end
        end
        
        -- Build position using the selected column and the ambition row
        local pos = reach_board.positionToWorld(high_marker.column_pos + this_ambition.row_pos)
        pos.x = selected_column_x
        pos.y = pos.y + 0.3
        high_marker.object.setPositionSmooth(pos)
        broadcastToAll("" .. player_color .. " has declared " ..
                           this_ambition.name .. " ambition for " .. power,
            player_color)
    end

    last_declared_marker = high_marker

    if this_ambition and ((this_ambition.name == "Keeper" or this_ambition.name == "Empath") and
        ArcsPlayer.has_secret_order(player_color)) then
        broadcastToAll(player_color .. " has SECRET ORDER")
        return
    end

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({1.02, 0.2, 0.67}))
    zero_marker.setRotationSmooth({0.00, 90.00, 0.00})

    ambitionMarkers.display_undo_button()

    -- After moving markers/zero marker via script, refresh ambitions
    -- after a short delay so smooth movements have settled.
    Wait.time(function()
        pcall(function() Global.call('ambition_refresh_proxy') end)
    end, 0.8)
end
function undo_ambition(obj, player_color)
    ambitionMarkers.undo(obj)
end
-- End Object Code --

return ambitionMarkers

end)
__bundle_register("src/LOG", function(require, _LOADED, __bundle_register, __bundle_modules)
local LOG = {
    logLevel = 4 --remember to set to 4 before uploading
}

function LOG.TRACE(message)
    if LOG.logLevel <= 1 then
        print("[TRACE] " .. message)
    end
end

function LOG.DEBUG(message)
    if LOG.logLevel <= 2 then
        print("[DEBUG] " .. message)
    end
end

function LOG.INFO(message)
    if LOG.logLevel <= 3 then
        print("[INFO] " .. message)
    end
end

function LOG.WARNING(message)
    -- If a WARNING occurs we want users to see it so they can report it
    print("[WARNING] " .. message)
end

function LOG.ERROR(message)
    -- If an ERROR occurs we want users to see it so they can report it
    print("[ERROR] " .. message)
end

return LOG

end)
__bundle_register("src/ArcsPlayer", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/GUIDs")
local Log = require("src/LOG")
local Resource = require("src/Resource")

local power_count = 0

local player_pieces = {
    ["White"] = {
        components = {
            board = "999dbd",
            score_board = "41c240",
            ships = "6883e6",
            mini_ships = "93dca4",
            starports = "b96445",
            agents = "c863eb",
            mini_agents = "57ca23",
            cities = {"822a9c", "00ee1b", "a50d56", "06f4a8", "81c3a7"},
            power = "38ef71",
            objective = "59d36b",
            trophy_wall1 = "657831",
            trophy_wall2 = "95db55",
            trophy_wall3 = "550c9f",
            trophy_captive_wall = "4cb9ae",
            captive_wall1 = "0ada6b",
            captive_wall2 = "cb98ce",
            captive_wall3 = "17a428"
        },
        initiative_zone = "2e1cd3",
        trophies_zone = "275a50",
        captives_zone = "0c07a0",
        area_zone = "a952c1",
        hand_zone = "c832bf"
    },
    ["Yellow"] = {
        components = {
            board = "5aa44c",
            score_board = "9ef1b2",
            ships = "a75924",
            mini_ships = "1ae879",
            starports = "b9ebd3",
            agents = "7b3749",
            mini_agents = "8018da",
            cities = {"dbf4de", "799077", "acfa72", "ac28fb", "b41592"},
            power = "e1edd4",
            objective = "c5bc19",
            trophy_wall1 = "b3a49f",
            trophy_wall2 = "3898be",
            trophy_wall3 = "c59e2f",
            trophy_captive_wall = "a404b9",
            captive_wall1 = "68b2a5",
            captive_wall2 = "d1564b",
            captive_wall3 = "d54de0"
        },
        initiative_zone = "3fc6fd",
        trophies_zone = "7f5014",
        captives_zone = "31a56f",
        area_zone = "238a92",
        hand_zone = "856b9d"
    },
    ["Teal"] = {
        components = {
            board = "ae512a",
            score_board = "5f8f5b",
            ships = "2da385",
            mini_ships = "94823f",
            starports = "7e625d",
            agents = "791097",
            mini_agents = "bb9a25",
            cities = {"f3da7f", "5e753e", "79b799", "fad0f1", "45c804"},
            power = "40f97a",
            objective = "3c2ffc",
            trophy_wall1 = "2ffd2c",
            trophy_wall2 = "187183",
            trophy_wall3 = "924ecc",
            trophy_captive_wall = "2ff29e",
            captive_wall1 = "be7e33",
            captive_wall2 = "685f39",
            captive_wall3 = "041961"
        },
        initiative_zone = "cdc545",
        trophies_zone = "3085c9",
        captives_zone = "fe0b0d",
        area_zone = "ee4b6e",
        hand_zone = "c9dd8d"
    },
    ["Pink"] = {
        components = {
            board = "57b06a",
            score_board = "44f508",
            ships = "8c5c67",
            mini_ships = "d623c4",
            starports = "ab5d17",
            agents = "673d59",
            mini_agents = "1ab7b7",
            cities = {"15943d", "d20e60", "98da52", "bc54f0", "bc2d71"},
            power = "d25054",
            objective = "f00e1f",
            trophy_wall1 = "6e10d3",
            trophy_wall2 = "62cdb3",
            trophy_wall3 = "5e4c14",
            trophy_captive_wall = "109201",
            captive_wall1 = "8fc894",
            captive_wall2 = "e2edaa",
            captive_wall3 = "72e9a9" --not sure if the order is right for the pinktrophy and captive walls, I did bottom right top, but I dont think it matters for now
        },
        initiative_zone = "fefc45",
        trophies_zone = "f57ed0",
        captives_zone = "755484",
        area_zone = "33c95d",
        hand_zone = "965437"
    },
    ["Red"] = {
        components = {
            board = "c0c8a1",
            score_board = "a51833",
            ships = "7e0fe2",
            mini_ships = "8c2ffb",
            starports = "51a8f5",
            agents = "bbb3aa",
            mini_agents = "bb9a25",
            cities = {"33577c", "cf5b95", "0ac3c2", "6e36ca", "282f37"},
            power = "4c96ac",
            objective = "8d76b7",
            trophy_wall1 = "dbe667",
            trophy_wall2 = "fd6687",
            trophy_wall3 = "b054a0",
            trophy_captive_wall = "843c9c",
            captive_wall1 = "a95354",
            captive_wall2 = "214a7b",
            captive_wall3 = "a018a0"
        },
        initiative_zone = "32f290",
        trophies_zone = "48b6fb",
        captives_zone = "7b011e",
        area_zone = "c2bf05",
        hand_zone = "54730a"
    }
}

ArcsPlayer = {
    color = "",
    has_initiative = false,
    hand_size = 0,
    power = 0,
    tycoon = 0,
    tyrant = 0,
    warlord = 0,
    keeper = 0,
    empath = 0,
    objective = 0,
    player_instance = nil,
    last_action_card = nil,
    last_seize_card = nil,
    resource_slot_pos = {
        {
            x = 0.863,
            y = 0.209,
            z = -0.741
        }, {
            x = 0.614,
            y = 0.209,
            z = -0.742
        }, {
            x = 0.365,
            y = 0.209,
            z = -0.742
        }, {
            x = 0.116,
            y = 0.209,
            z = -0.742
        }, {
            x = -0.132,
            y = 0.209,
            z = -0.742
        }, {
            x = -0.381,
            y = 0.209,
            z = -0.743
        }
    }
}

function ArcsPlayer.components_visibility(color, is_visible, is_campaign)
    local visibility = is_visible and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    for key, id in pairs(player_pieces[color]["components"]) do
        if (key == "cities") then
            ArcsPlayer._show_cities(color, is_visible)
        -- elseif (key == "objective" and is_visible and not is_campaign) then
            elseif (key == "objective" and is_visible and not is_campaign and Global.getVar("is_initial_setup")) then
                local obj = getObjectFromGUID(id)
                if (obj) then
                    obj.destroy()
                end
        else
            local obj = getObjectFromGUID(id)
            if (obj) then
                obj.setInvisibleTo(visibility)
            end
        end
    end
end

function ArcsPlayer._show_cities(color, is_visible)
    local visibility = is_visible and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}

    for _, id in pairs(player_pieces[color].components.cities) do
        local obj = getObjectFromGUID(id)
        obj.setInvisibleTo(visibility)
        -- local y_pos = is_visible and 1 or -2
        -- local pos = obj.getPosition()
        -- pos.y = y_pos
        -- obj.setPosition(pos)
        -- if (obj.hasTag("Lock")) then
        --     obj.locked = true
        -- else
        --     obj.locked = not is_visible
        -- end
    end
end

function ArcsPlayer:new(o)
    o = o or ArcsPlayer -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o:create_score()
    return o
end

function ArcsPlayer:setup(is_campaign)
    -- move power
    local y_pos
    local x_pos
    if (self.color == "Red") then
        y_pos = 3
        x_pos = -13.92
    elseif (self.color == "White") then
        y_pos = 3
        x_pos = -13.26
    elseif (self.color == "Teal") then
        y_pos = 2
        x_pos = -13.92
    elseif (self.color == "Yellow") then
        y_pos = 2
        x_pos = -13.26
    elseif (self.color == "Pink") then
        y_pos = 2
        x_pos = -13.26
    end
    local power = getObjectFromGUID(player_pieces[self.color].components.power)
    power.setPosition({x_pos, y_pos, -9.36})

    ArcsPlayer.components_visibility(self.color, true, is_campaign)
end

function ArcsPlayer:set_last_played_action_card(card_info)
    self.last_action_card = card_info
    if (Global.getVar("is_face_up_discard_active")) then
        local gold_color = {1, 0.7, 0.4}
        broadcastToAll(self.color .. " played " .. (card_info and card_info.type or "") .. " " .. (card_info and tostring(card_info.number) or ""), gold_color)
    end
end

function ArcsPlayer:set_last_played_seize_card(action_card_description)
    if string.find(action_card_description, "Mandate") then
        self.last_seize_card = {
            type = action_card_description,
            number = 0
        }
    else
        local card_type = string.sub(action_card_description, 1, -3)
        local card_number = tonumber(string.sub(action_card_description, -2, -1))
        self.last_seize_card = {
            type = card_type,
            number = card_number
        }
    end
end

function ArcsPlayer.has_secret_order(player_color)
    local area = getObjectFromGUID(player_pieces[player_color]["area_zone"])
    for _, obj in pairs(area.getObjects()) do
        if (obj.getName() == "SECRET ORDER") then
            return true
        end
    end

    return false
end

function ArcsPlayer:take_resource(name, slot_num)
    self.board = getObjectFromGUID(
        player_pieces[self.color]["components"]["board"])
    local board_pos = self.board.getPosition()
    local slot_pos = self.resource_slot_pos[slot_num]

    Resource:take(name, self.board.positionToWorld(slot_pos))
end

function ArcsPlayer:power_score(power_cube)
    -- Calculate base power from cube position
    local power_pos_x = power_cube and power_cube.getPosition().x or 0
    local base_power = math.floor((power_pos_x + 13.26) / 0.655)
    if base_power < 0 then base_power = 0 end

    -- Get bonus from zones
    local bonus = self:power_bonus()

    -- Calculate total and apply negative modifier if needed
    local total = base_power + bonus
    return self:is_power_negative() and -total or total
end

function ArcsPlayer:power_bonus()
    local bonus = 0
    local color_tag = self.color .. "Piece"

    -- Define zones and their bonus values
    local zones = {
        {guid = plus_fifty_power_zone_GUID, value = 50},
        {guid = plus_one_hundred_power_zone_GUID, value = 100}
    }

    for _, zone_info in ipairs(zones) do
        local zone = getObjectFromGUID(zone_info.guid)
        if not zone then
            Log.warning("Power bonus zone not found: " .. zone_info.guid)
        else
            -- Check objects in this zone
            for _, obj in ipairs(zone.getObjects()) do
                if obj.hasTag("power") and obj.hasTag(color_tag) then
                    bonus = bonus + zone_info.value
                end
            end
        end
    end

    return bonus
end

function ArcsPlayer:is_power_negative()
    local negative_zone = getObjectFromGUID(negative_power_zone_GUID)

    if not negative_zone then
        Log.warning("Negative power zone not found")
        return false
    end

    local color_tag = self.color .. "Piece"
    local objects = negative_zone.getObjects()

    for i = 1, #objects do
        local obj = objects[i]
        if obj.hasTag("power") and obj.hasTag(color_tag) then
            return true
        end
    end

    return false
end

function ArcsPlayer:objective_score(objective_marker)
    -- If the objective marker is missing or hidden to players, treat as 0
    if not objective_marker then return 0 end
    local ok, invisible_to = pcall(function()
        if objective_marker.getInvisibleTo then return objective_marker.getInvisibleTo() end
        return nil
    end)
    if ok and invisible_to and type(invisible_to) == "table" and next(invisible_to) ~= nil then
        return 0
    end

    -- Calculate objective score from marker position (same pattern as power)
    local objective_pos_x = 0
    pcall(function() objective_pos_x = objective_marker.getPosition().x end)
    local base_objective = math.floor((objective_pos_x + 13.26) / 0.655)
    if base_objective < 0 then base_objective = 0 end
    return base_objective
end

function ArcsPlayer:update_score()
    self.score_board = getObjectFromGUID(
        player_pieces[self.color]["components"]["score_board"])
    if (self.score_board == nil) then
        return
    end

    local ambitions = Global.getVar("active_ambitions")
    local white_color = Color.fromString("White")
    local gold_color = {0.8, 0.58, 0.27}

    local tycoon_active = false
    local tyrant_active = false
    local warlord_active = false
    local keeper_active = false
    local empath_active = false
    if (ambitions) then
        for k, v in pairs(ambitions) do
            if (v == "Tycoon") then
                tycoon_active = true
            elseif (v == "Tyrant") then
                tyrant_active = true
            elseif (v == "Warlord") then
                warlord_active = true
            elseif (v == "Keeper") then
                keeper_active = true
            elseif (v == "Empath") then
                empath_active = true
            end
        end
    end

    local power_cube = getObjectFromGUID(
        player_pieces[self.color]["components"].power)
    self.power = self:power_score(power_cube)
    local hand_zone = getObjectFromGUID(player_pieces[self.color]["hand_zone"])
    self.hand_size = hand_zone and #hand_zone.getObjects() or 0
    self.tycoon = self:count("Fuel") + self:count("Material")
    local captive_zone = getObjectFromGUID(
        player_pieces[self.color]["captives_zone"])
    self.captives = captive_zone and #captive_zone.getObjects() or 0
    local trophies_zone = getObjectFromGUID(
        player_pieces[self.color]["trophies_zone"])
    self.trophies = trophies_zone and #trophies_zone.getObjects() or 0
    self.keeper = self:count("Relic")
    self.empath = self:count("Psionic")
    local objective_marker = getObjectFromGUID(
    player_pieces[self.color]["components"].objective)
    self.objective = self:objective_score(objective_marker)
    local show_objective = not Global.getVar("is_basegame_setup")

    self.score_board.editButton({
        index = 0,
        label = self.power
    })
    self.score_board.editButton({
        index = 1,
        label = self.power
    })
    self.score_board.editButton({
        index = 2,
        label = self.hand_size
    })
    self.score_board.editButton({
        index = 3,
        label = self.hand_size
    })
    self.score_board.editButton({
        index = 4,
        label = self.tycoon
    })
    self.score_board.editButton({
        index = 5,
        label = self.tycoon,
        font_color = (tycoon_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 6,
        label = self.captives
    })
    self.score_board.editButton({
        index = 7,
        label = self.captives,
        font_color = (tyrant_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 8,
        label = self.trophies
    })
    self.score_board.editButton({
        index = 9,
        label = self.trophies,
        font_color = (warlord_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 10,
        label = self.keeper
    })
    self.score_board.editButton({
        index = 11,
        label = self.keeper,
        font_color = (keeper_active and gold_color or white_color)
    })
    self.score_board.editButton({
        index = 12,
        label = self.empath
    })
    self.score_board.editButton({
        index = 13,
        label = self.empath,
        font_color = (empath_active and gold_color or white_color)
    })
    if show_objective then
        self.score_board.editButton({
            index = 14,
            label = self.objective
        })
        self.score_board.editButton({
            index = 15,
            label = self.objective,
            font_color = (empath_active and gold_color or white_color)
        })
    else
        self.score_board.editButton({
            index = 14,
            label = ""
        })
        self.score_board.editButton({
            index = 15,
            label = ""
        })
    end
end

function ArcsPlayer:count(resource)
    local area = getObjectFromGUID(player_pieces[self.color]["area_zone"])
    local count = 0

    if (area == nil) then
        return count
    end

    for _, obj in pairs(area.getObjects()) do
        if (obj.getDescription() == resource) then
            if (obj.name == "Custom_Tile_Stack") then
                count = count + obj.getQuantity()
            else
                count = count + 1
            end
        end
    end

    return count
end

function ArcsPlayer:create_score()
    self.score_board = getObjectFromGUID(
        player_pieces[self.color]["components"]["score_board"])

    local shadow = Vector({0.01, 0, 0.04})
    -- local text_color = Color.fromString(self.color)
    local text_color = Color.fromString("White")
    local score_row = -0.2

    -- Power
    local power_pos = Vector({-6.65, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = power_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = power_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = {0.8, 0.58, 0.27}
    })

    -- Hand Size
    local hand_pos = Vector({-4.65, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = hand_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = hand_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 2. Tycoon
    local tycoon_pos = Vector({-1.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tycoon_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tycoon_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 3. Tyrant
    local tyrant_pos = Vector({0.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tyrant_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = tyrant_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 4. Warlord
    local warlord_pos = Vector({2.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = warlord_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = warlord_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 5. Keeper
    local keeper_pos = Vector({4.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = keeper_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = keeper_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })

    -- 6. Empath
    local empath_pos = Vector({6.5, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = empath_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = empath_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })
    -- 7. Objective
    local objective_pos = Vector({-3.075, 0.11, score_row})
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = objective_pos + shadow,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 525,
        font_color = {0, 0, 0}
    })
    self.score_board.createButton({
        function_owner = self,
        click_function = "doNothing",
        position = objective_pos,
        rotation = {0, 0, 0},
        width = 0,
        height = 0,
        font_size = 500,
        font_color = text_color
    })
    


    self:update_score()
end

return ArcsPlayer

end)
__bundle_register("src/Resource", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/GUIDs")
local LOG = require("src/LOG")

local Resource = {
    supply_tiles = {
        psionic = resources_markers_GUID["psionics"],
        relic = resources_markers_GUID["relics"],
        weapon = resources_markers_GUID["weapons"],
        fuel = resources_markers_GUID["fuel"],
        material = resources_markers_GUID["materials"]
    },
    clusters = {{
        ["a"] = "weapon",
        ["b"] = "fuel",
        ["c"] = "material"
    }, {
        ["a"] = "psionic",
        ["b"] = "weapon",
        ["c"] = "relic"
    }, {
        ["a"] = "material",
        ["b"] = "fuel",
        ["c"] = "weapon"
    }, {
        ["a"] = "relic",
        ["b"] = "fuel",
        ["c"] = "material"
    }, {
        ["a"] = "weapon",
        ["b"] = "relic",
        ["c"] = "psionic"
    }, {
        ["a"] = "material",
        ["b"] = "fuel",
        ["c"] = "psionic"
    }}
}

function Resource:take(name, pos)
    if not name or tostring(name) == "" then
        return nil
    end
    LOG.DEBUG("name:" .. tostring(name))

    -- perform a raycast to find the topmost resource on the supply tile
    local key = tostring(name):lower()
    local supply_guid = self.supply_tiles[key]
    if not supply_guid then
        return nil
    end
    local supply_tile = getObjectFromGUID(supply_guid)
    local hits = Physics.cast(
        {
            origin = supply_tile.getPosition() + Vector(0, -1, 0),
            direction = Vector(0,1,0),
            type = 1
        }
    )

    -- reverse iterate to get the top-most resource first
    local result = nil
    for i = #hits, 1, -1 do
        if hits[i].hit_object.getName():lower() == name:lower() and not hits[i].hit_object.isSmoothMoving() then
            result = hits[i].hit_object
            break
        end
    end

    -- early out if there's no resources in the supply
    if result == nil then
        return result
    end

    if result.getQuantity() ~= -1 then
        result = result.takeObject({
            position = pos,
            rotation = {0, 180, 0},
            smooth = true
        })
    else
        if pos ~= nil then
            result.setPositionSmooth(pos, false, true)
        end
        result.setRotationSmooth({0, 180, 0}, false, true)
    end
    return result
end

function Resource:name_from_cluster(cluster, system)
    if (system) then
        return self.clusters[cluster][system]
    else
        return self.clusters[cluster]
    end
end

return Resource

end)
__bundle_register("src/GUIDs", function(require, _LOADED, __bundle_register, __bundle_modules)
reach_board_GUID = "bb7d21"
setup_table_GUID = "0b4885"

setup_control_2 = "42caeb"
setup_control_3 = "5dc1e0"

-- leaders and lore
more_to_explore_fate_GUID = "768d3d"
more_to_explore_lore_GUID = "3441e5"

artifact_deck_GUID = "9c97c9"
reach_feature_deck_GUID = "a5e8a7"
windfall_deck_Guid = "8cfcb9"
lost_vaults_markers_GUID = "7c24cf"
lost_vaults_rules_GUID = "952d62"

mandate_cards_GUID = "c549b5"

include_fates_GUID = "be0e27"
action_deck_GUID = "227406"
action_deck_zone_GUID = "80ed31" -- "9bd42d"
action_deck_4P_GUID = "13bedd"
action_card_zone_GUID = "e6eca7"
seize_zone_GUID = "e6eca8"
face_up_discard_action_deck_GUID = "a8e929"
lead_card_zone_GUID = "9e5eae"
FUDiscard_marker_GUID = "000207"

snaps_5p_GUID = "fc47e1"

zero_marker_GUID = "0289cb"
zero_marker_zone_GUID = "3984e4"
negative_power_zone_GUID = "3984e5"
plus_fifty_power_zone_GUID = "3984e6"
plus_one_hundred_power_zone_GUID = "3984e7"

ambition_marker_GUIDs = {"c9e0ee", "a9b02a", "b0b4d0","5b499a", "d7d474", "0f526d"}
ambition_marker_zone_GUID = "06c552"
court_deck_zone_GUID = "7a33ff"
court_discard_zone_GUID = "7a33fa"

fate_GUID = "2d243a"
lore_GUID = "0d8ede"
base_court_deck_GUID = "9ac2b3"

-- Setup deck
setup_deck_GUID = "f02e75"

-- 4P setup deck
frontiers_4P_GUID = "ec2d75"
mix_up_1_4P_GUID = "646d5a"
mix_up_2_4P_GUID = "53671b"
mix_up_3_4P_GUID = "595066"

-- 5P setup deck (added)
frontiers_5P_GUID = "2cd1ed"
mix_up_1_5P_GUID = "b89490"
mix_up_2_5P_GUID = "e0ea87"
empires_5P_GUID = "f576ec"
extension_5P_GUID = "7d62f5"

-- 3P setup deck
frontiers_3P_GUID = "abc2f1"
core_conflict_3P_GUID = "6ee717"
homelands_3P_GUID = "eac88a"
mix_up_3P_GUID = "eb2f62"

-- 2P setup deck
frontiers_2P_GUID = "d4c37c"
homelands_2P_GUID = "559dbb"
mix_up_1_2P_GUID = "850244"
mix_up_2_2P_GUID = "ddc074"

initiative_GUID = "b3b3d0"
seized_initiative_GUID = "e0f490"

chapter_pawn_GUID = "9c3ac8"

-- Setup Menu example pieces
setup_meeples_GUIDs = {
    fresh_ship = "6e6f6b",
    damaged_ship = "b2b35c",
    fresh_imperial_ship = "5983db",
    damaged_imperial_ship = "e0bcd1",
    flag_ship = "339446",
    agent = "8e8851"
}

setup_unchanged_meeples_GUIDs = {}

setup_miniatures_GUIDs = {
    fresh_ship = "fb8e2b",
    damaged_ship = "20d86f",
    fresh_imperial_ship = "45e3ef",
    damaged_imperial_ship = "e4ac0b",
    flag_ship = "4cf25e",
    agent = "9d16be"
}

-- Players Pieces
player_pieces_GUIDs = {
    ["White"] = {
        player_board = "999dbd",
        resource = {"822a9c", "00ee1b"},
        ships = "6883e6",
        mini_ships = "93dca4",
        starports = "b96445",
        agents = "c863eb",
        mini_agents = "57ca23",
        cities = {"822a9c", "00ee1b", "a50d56", "06f4a8", "81c3a7"},
        initiative_zone = "2e1cd3",
        trophies_zone = "275a50",
        captives_zone = "0c07a0",
        area_zone = "a952c1"
    },
    ["Yellow"] = {
        player_board = "5aa44c",
        resource = {"dbf4de", "799077"},
        ships = "a75924",
        mini_ships = "1ae879",
        starports = "b9ebd3",
        agents = "7b3749",
        mini_agents = "8018da",
        cities = {"dbf4de", "799077", "acfa72", "ac28fb", "b41592"},
        initiative_zone = "3fc6fd",
        trophies_zone = "7f5014",
        captives_zone = "31a56f",
        area_zone = "238a92"
    },
    ["Red"] = {
        player_board = "c0c8a1",
        resource = {"33577c", "cf5b95"},
        ships = "7e0fe2",
        mini_ships = "8c2ffb",
        starports = "51a8f5",
        agents = "bbb3aa",
        mini_agents = "b9cde7",
        cities = {"33577c", "cf5b95", "0ac3c2", "6e36ca", "282f37"},
        initiative_zone = "32f290",
        trophies_zone = "48b6fb",
        captives_zone = "7b011e",
        area_zone = "c2bf05"
    },
    ["Teal"] = {
        player_board = "ae512a",
        resource = {"f3da7f", "f3da7f"},
        ships = "2da385",
        mini_ships = "94823f",
        starports = "7e625d",
        agents = "791097",
        mini_agents = "bb9a25",
        cities = {"f3da7f", "5e753e", "79b799", "fad0f1", "45c804"},
        initiative_zone = "cdc545",
        trophies_zone = "3085c9",
        captives_zone = "fe0b0d",
        area_zone = "ee4b6e"
    },
    ["Pink"] = {
        player_board = "57b06a",
        resource = {"15943d", "d20e60"},
        ships = "8c5c67",
        mini_ships = "d623c4",
        starports = "ab5d17",
        agents = "673d59",
        mini_agents = "1ab7b7",
        cities = {"15943d", "d20e60", "98da52", "bc54f0", "bc2d71"},
        initiative_zone = "fefc45",
        trophies_zone = "f57ed0",
        captives_zone = "755484",
        area_zone = "33c95d"
    }

}

-- Cluster GUIDs
cluster_zone_GUIDs = {
    [1] = { -- cluster
        gate = "261101",
        a = {
            buildings = {"300802", "a67a63"},
            ships = "296493"
        },
        b = {
            buildings = {"66652d"},
            ships = "7a01be"
        },
        c = {
            buildings = {"b05731", "083a9a"},
            ships = "3b90d3"
        }
    },
    [2] = { -- cluster
        gate = "815b16",
        a = {
            buildings = {"83abbd"},
            ships = "a34cdc"
        },
        b = {
            buildings = {"dfc711"},
            ships = "1dab32"
        },
        c = {
            buildings = {"13e02c", "13e02c"},
            ships = "797680"
        }
    },
    [3] = { -- cluster
        gate = "bd423f",
        a = {
            buildings = {"616435"},
            ships = "0ce2b8"
        },
        b = {
            buildings = {"8d6efe"},
            ships = "396c5e"
        },
        c = {
            buildings = {"50f42c", "9e0f65"},
            ships = "ad2a7c"
        }
    },
    [4] = { -- cluster
        gate = "db8a4f",
        a = {
            buildings = {"e54cea", "283076"},
            ships = "bc8f25"
        },
        b = {
            buildings = {"4dafc5", "8e7828"},
            ships = "5c72ba"
        },
        c = {
            buildings = {"489866"},
            ships = "e2a2f3"
        }
    },
    [5] = { -- cluster
        gate = "42710a",
        a = {
            buildings = {"c36b81"},
            ships = "07b826"
        },
        b = {
            buildings = {"fccac8"},
            ships = "99b331"
        },
        c = {
            buildings = {"6795f2", "b493d4"},
            ships = "d0f854"
        }
    },
    [6] = { -- cluster
        gate = "0b73a3",
        a = {
            buildings = {"13107a"},
            ships = "aa2992"
        },
        b = {
            buildings = {"9e28b7", "7bb712"},
            ships = "d79fe8"
        },
        c = {
            buildings = {"e88c25"},
            ships = "4af68d"
        }
    }
}

resources_GUID = {
    psionics = "1b4b0b",
    relics = "5895b5",
    weapons = "1c2d2a",
    fuel = "ed2820",
    materials = "57c2c6"
}

resources_markers_GUID = {
    psionics = "a89706",
    relics = "473675",
    weapons = "2fdfa3",
    fuel = "5cb321",
    materials = "eb1cba"
}

----------------------------------------------------
-- campaign
----------------------------------------------------

control_GUID = "6e21fe"

event_deck_GUID = "ad423d"
chapter_track_GUID = "4d34d7"
chapter_zone_GUID = "2d2c49"

campaign_court_GUID = "fb55bf"
imperial_council_GUID = "89ddf3"
laws_GUID = "f0362b"
guild_envoys_depart_GUID = "ba6fc8"
govern_GUID = "df60d0"
regents_GUID = "9c8d55"

event_die_GUID = "684608"
number_die_GUID = "d5e298"
die_zone_GUID = "1b45bb"

imperial_ships_GUID = "beb54d"
mini_imperial_ships_GUID = "31121e"
flagships_GUID = "ea53d9"
mini_flagships_GUID = "36f5c0"
free_cities_GUID = "80742e"
free_starports_GUID = "c79cb8"
blight_GUID = "ff61a8"

A_Fates_GUID = "0ac7d1"

end)
__bundle_register("src/ActionCards", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/GUIDs")
local LOG = require("src/LOG")
local supplies = require("src/Supplies")

local ActionCards = {}

-- Face Down Discard
local fdd_pos = Vector({0.94, 10.00, -1.26})
local fdd_rot = Vector({0.00, 90.00, 180.00})

-- Face Up Discard

local fud_marker_pos = {
    [true] = Vector({-19.93, 0.96, -2.31}),
    [false] = Vector({-19.93, -1.00, -2.31})
}

local fud_pos = Vector({-3.70, 0.20, 0.00})
local fud_rot = Vector({0.00, 90.00, 1.00})
local fud_offset = Vector({0.35, 0.00, 0.00})
local fud_tag = "Face Up Discard Action"

local face_up_discard_guids = {
    ["Administration 1"] = "b994c0",
    ["Administration 2"] = "a2931d",
    ["Administration 3"] = "d129a1",
    ["Administration 4"] = "a66e2a",
    ["Administration 5"] = "94fc68",
    ["Administration 6"] = "6aeb5e",
    ["Administration 7"] = "9b829b",
    ["Aggression 1"] = "f3c7de",
    ["Aggression 2"] = "03b948",
    ["Aggression 3"] = "698e3b",
    ["Aggression 4"] = "2a414a",
    ["Aggression 5"] = "8d6270",
    ["Aggression 6"] = "c421f0",
    ["Aggression 7"] = "9ab788",
    ["Construction 1"] = "dcff50",
    ["Construction 2"] = "8946d4",
    ["Construction 3"] = "36b467",
    ["Construction 4"] = "06317b",
    ["Construction 5"] = "432418",
    ["Construction 6"] = "478926",
    ["Construction 7"] = "0c38cb",
    ["Mobilization 1"] = "5694f9",
    ["Mobilization 2"] = "a6d390",
    ["Mobilization 3"] = "e43e5d",
    ["Mobilization 4"] = "8f521a",
    ["Mobilization 5"] = "bcf2e7",
    ["Mobilization 6"] = "7981dc",
    ["Mobilization 7"] = "864dd1",
    ["Event1"] = "fe7a80",
    ["Event2"] = "eff76c",
    ["Event3"] = "39a322",
    ["Faithful 1"] = "fe9e2d",
    ["Faithful 2"] = "8a8534",
    ["Faithful 3"] = "28334e",
    ["Faithful 4"] = "db3626",
    ["Faithful 5"] = "d28723",
    ["Faithful 6"] = "add17e",
    ["Faithful 7"] = "fd45b2",
    ["Faithful 8"] = "cf723b",
    ["Faithful 9"] = "f3e5fe"
}

function ActionCards.get_action_deck()
    local action_deck_zone = getObjectFromGUID(action_deck_zone_GUID)
    if not action_deck_zone then
        LOG.WARNING("ActionCards.get_action_deck: action_deck_zone not found: " .. tostring(action_deck_zone_GUID))
        return getObjectFromGUID(action_deck_GUID)
    end
    local action_deck_zone_objects = action_deck_zone.getObjects()

    if (action_deck_zone_objects) then
        -- Prefer a Deck object, but fall back to a single Card (when deck reduced to 1)
        local found_card_guid = nil
        for _, v in ipairs(action_deck_zone_objects) do
            if v.tag == "Deck" or v.name == "Deck" then
                action_deck_GUID = v.guid
                return getObjectFromGUID(action_deck_GUID)
            end
            -- remember any single card fallback; prefer cards that look like action cards
            if v.tag == "Card" then
                if not found_card_guid then found_card_guid = v.guid end
                if (v.getName and v.getName() == "Action Card") or (v.hasTag and v.hasTag("Action")) then
                    found_card_guid = v.guid
                    break
                end
            end
        end
        if found_card_guid then
            action_deck_GUID = found_card_guid
            return getObjectFromGUID(action_deck_GUID)
        end
    end

    return getObjectFromGUID(action_deck_GUID)
end

function ActionCards.setup_deck(player_count)
    local four_player_deck = getObjectFromGUID(action_deck_4P_GUID)
    local mandate_deck = getObjectFromGUID(mandate_cards_GUID)

    local deck = ActionCards.get_action_deck()
    if (player_count >= 4) then
                LOG.INFO("put in 4p deck")
        deck.putObject(four_player_deck)
        Wait.time(function()
            deck.randomize()
            if player_count >= 5 then
                deck.putObject(mandate_deck)
            end
        end, 1.5)
    else
        LOG.INFO("destroyed 4p deck")
        destroyObject(four_player_deck)
    end

end

function ActionCards.setup_events(player_count)
    local event_deck = getObjectFromGUID(event_deck_GUID)
    local deck = ActionCards.get_action_deck()
    if (player_count < 4) then
        event_deck.takeObject().destroy()
    end
    deck.putObject(event_deck)
    Wait.time(function()
        deck.randomize()
    end, 1.5)
end

function ActionCards.toggle_face_up_discard()
    local is_fud_active = Global.getVar("is_face_up_discard_active")
    is_fud_active = not is_fud_active
    local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
    fud_marker.setPosition(fud_marker_pos[is_fud_active])
    Global.setVar("is_face_up_discard_active", is_fud_active)
    return is_fud_active
end

function ActionCards.is_face_up_discard_active()
    return Global.getVar("is_face_up_discard_active")
end

function ActionCards.deal_hand(num)
    broadcastToAll("Shuffle and deal 6 action cards to all players")
    local deck = ActionCards.get_action_deck()
    deck.randomize()
    Wait.time(function()
        deck.deal(num)
    end, 1)
end

function ActionCards.check_deck()
    local deck = ActionCards.get_action_deck()
    local deck_size = #getSeatedPlayers() >= 4 and 28 or 20
    return deck_size <= #deck.getObjects()
end

function ActionCards.check_hands()
    local active_players = Global.getVar("active_players")
    for _, player in ipairs(active_players) do
        if #Player[player.color].getHandObjects() > 0 then
            broadcastToAll("" .. player.color .. " still has cards in hand!",
                player.color)
            return true
        end
    end
    return false
end

function ActionCards.clear_played()
    LOG.INFO("ActionCards.clear_played")

    local action_zone = getObjectFromGUID(action_card_zone_GUID)
    if not action_zone then
        LOG.WARNING("ActionCards.clear_played: action_card_zone not found: " .. tostring(action_card_zone_GUID))
        return true
    end
    local played_objects = action_zone.getObjects()

    -- Handle union cards
    local union_marked_cards = ActionCards.union_handling(played_objects)
    local union_center_card_offset = 0

    local union_like_names = {
        ["THE PROPHET"] = true,
        ["THE YOUNG LIGHT"] = true,
        ["THE PRODIGAL ONE"] = true
    }

    -- clean up
    for ct, obj in ipairs(played_objects) do
        if (obj.getName() ~= "Action Card") and obj.hasTag("Resource") then
            supplies.returnObject(obj)
        end
        if obj.getName() == "Action Card" then
            local is_union_card = false
            if union_marked_cards and #union_marked_cards > 0 then
                for _, card_info in ipairs(union_marked_cards) do
                    if card_info.guid == obj.guid then
                        ActionCards.to_center_board(obj, union_center_card_offset)
                        union_center_card_offset = union_center_card_offset + 1
                        is_union_card = true
                        break
                    end
                end
            end

            if not is_union_card then
                if Global.getVar("is_face_up_discard_active") and not obj.is_face_down then
                    ActionCards.to_face_up_discard(obj)
                end
                ActionCards.to_face_down_discard(obj)
            end
        elseif (obj.getName() ~= "Action Card") and obj.hasTag("Court") and not string.find(obj.getDescription(), "Union") then
            local obj_name = obj.getName and obj.getName() or ""
            local upper_name = string.upper(obj_name)
            if union_like_names[upper_name] then
                -- These cards are handled in union_handling and should stay in center area.
                goto continue_cleanup
            end
            local court_discard = getObjectFromGUID(court_discard_zone_GUID)
            if court_discard then
                obj.setPositionSmooth(court_discard.getPosition() + Vector({0, 3, 0}))
                obj.setRotationSmooth(Vector({0, 270, 0}))
            end
        end
        ::continue_cleanup::
    end

    return true
end

function ActionCards.to_face_down_discard(card)
    LOG.INFO("ActionCards.to_face_down_discard")
    local reach_map = getObjectFromGUID(reach_board_GUID)
    local pos = reach_map.positionToWorld(fdd_pos)
    local active_players = getSeatedPlayers()
    if active_players and #active_players >= 5 then
        pos.z = pos.z + 1.57
    end
    local rot = fdd_rot
    card.setPositionSmooth(pos)
    card.setRotationSmooth(rot)
end

function ActionCards.to_face_up_discard(card)
    LOG.INFO("ActionCards.to_face_up_discard")
    local count = #ActionCards.get_face_up_discard_cards()
    local pos = fud_pos + count * fud_offset;
    local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
    pos = fud_marker.positionToWorld(pos)
    local rot = card.getRotation() -- get the y rotation of the card and use fud rot for the x and z
    rot.x = fud_rot.x
    -- for faithful cards we need to adjust the slight z rotation based on which side is play
    if rot.y > 180 then
        rot.z = -fud_rot.z
    else
        rot.z = fud_rot.z
    end

    local card_name = card.getDescription()

    local discarded_card = nil
    local fud_discard_action_deck = getObjectFromGUID(
        face_up_discard_action_deck_GUID)

    for _, v in ipairs(fud_discard_action_deck.getObjects()) do
        if (v.description == card_name) then
            discarded_card = fud_discard_action_deck.takeObject({
                guid = v.guid
            })
            break
        end
    end

    if (discarded_card) then
        discarded_card.setLock(true)
        discarded_card.addTag(fud_tag)
        discarded_card.setRotation(rot)
        Wait.time(function()
            discarded_card.setPosition(pos)
        end, 0.20) -- 200ms delay
    end
end

function ActionCards.to_center_board(card, offset)
    card_shift_offset = offset * -0.05
    local center_pos = getObjectFromGUID(reach_board_GUID).positionToWorld(Vector({(0.07 + card_shift_offset), 10.00, 0}))
    card.setPositionSmooth(center_pos)
    card.setRotationSmooth(Vector({0, 180, 0}))
end

function ActionCards.clear_face_up_discard()
    LOG.DEBUG("ActionCards.clear_face_up_discard()")
    local fud_discard_action_deck = getObjectFromGUID(
        face_up_discard_action_deck_GUID)

    for ct, obj in ipairs(ActionCards.get_face_up_discard_cards()) do
        obj.setLock(false)
        obj.removeTag(fud_tag)
        fud_discard_action_deck.putObject(obj)
    end
end

function ActionCards.get_face_up_discard_cards()
    return getObjectsWithTag(fud_tag)
end

-- Returns the type and number of an action card
function ActionCards.get_info(card)

    if (card.getName() ~= "Action Card") then
        return
    end

    local desc = card.getDescription()
    local card_type = string.sub(desc, 1, -3)
    local card_number = tonumber(string.sub(desc, -2, -1))

    if string.find(desc, "Mandate") then
        card_type = desc
        card_number = 0
    elseif (card_type == "Faithful") then
        card_type = card.getRotation().y < 180 and "Faithful Zeal" or "Faithful Wisdom"
    end

    return {
        guid = card.guid,
        type = card_type,
        number = card_number
    }

end

-- Returns type and number of lead card
function ActionCards.get_lead_info()
    local lead = nil
    local is_ambition_declared = false
    local lead_zone = getObjectFromGUID(lead_card_zone_GUID)

    if (lead_zone) then
        local lead_obj = nil
        for _, obj in ipairs(lead_zone.getObjects()) do
            if (obj.getName() == "Action Card") then
                lead = ActionCards.get_info(obj)
                lead.real_number = lead.number
                lead_obj = obj
            end

            if (obj.getName() == "Zero Marker") then
                is_ambition_declared = true
            end
        end

        -- Fallback: if zero marker wasn't reported in the zone, check proximity
        -- of the global zero marker object to the lead card (covers "on top" cases)
        if (not is_ambition_declared) and lead_obj then
            local ok, zm = pcall(function() return getObjectFromGUID(zero_marker_GUID) end)
            local zero_marker = ok and zm or nil
            if zero_marker and zero_marker.getPosition and lead_obj.getPosition then
                local zmp = zero_marker.getPosition()
                local leadp = lead_obj.getPosition()
                -- horizontal distance (x,z plane)
                local dx = zmp.x - leadp.x
                local dz = zmp.z - leadp.z
                local horiz_dist = math.sqrt(dx * dx + dz * dz)
                -- consider it "on top" if horizontally very close and slightly above
                if horiz_dist <= 1.2 and (zmp.y - leadp.y) > 0.05 then
                    is_ambition_declared = true
                end
            end
        end
    else
        LOG.ERROR("Could not find lead zone")
    end

    if (is_ambition_declared) then
        LOG.TRACE("ambition is declared, setting lead number to 0")
        lead.number = 0
    end
    if (lead) then
        LOG.DEBUG("leading card: " .. lead.type .. " " .. lead.number)
    end
    return lead
end

function ActionCards.get_surpassing_card()
    local lead = ActionCards.get_lead_info()
    if (not lead) then
        LOG.ERROR("Could not determine lead card")
        return nil
    end

    local surpassing_card = nil
    local max_surpassing_number = 0
    local played_zone = getObjectFromGUID(action_card_zone_GUID)
    if not played_zone then
        LOG.WARNING("ActionCards.get_surpassing_card: action_card_zone not found: " .. tostring(action_card_zone_GUID))
        return nil
    end

    LOG.DEBUG("get_surpassing_card: lead card is " .. tostring(lead.type) .. " " .. tostring(lead.number) .. " (guid=" .. tostring(lead.guid) .. ")")
    local found_mandate_surpass = false
    local numeric_surpass_found = false
    for _, v in ipairs(played_zone.getObjects()) do
        if (v.guid == lead.guid) then
            LOG.DEBUG("Skipping lead card itself (guid=" .. tostring(v.guid) .. ")")
            goto continue
        end

        if v.getName() ~= "Action Card" then
            LOG.DEBUG("Skipping non-action card: " .. tostring(v.getName()))
            goto continue
        end

        do -- avoid error with goto jumping into surpassing_card scope
            local card = ActionCards.get_info(v)
            if (card) then
                LOG.DEBUG("Checking card: " .. tostring(card.type) .. " " .. tostring(card.number) .. " (guid=" .. tostring(card.guid) .. ")")
            else
                LOG.DEBUG("get_info returned nil for card with guid " .. tostring(v.guid))
            end
            if card then
                if lead.type and string.find(lead.type, "Mandate") then
                    -- Mandate lead: numeric cards outrank mandates; highest numeric wins.
                    -- Mandates only count if no numeric cards are played.
                    LOG.DEBUG("Mandate lead: comparing card.number=" .. tostring(card.number) .. " to max_surpassing_number=" .. tostring(max_surpassing_number))
                    if card.number > 0 then
                        if card.number > max_surpassing_number then
                            LOG.DEBUG("Mandate surpass (numeric): setting surpassing_card to " .. tostring(card.type) .. " " .. tostring(card.number) .. " (guid=" .. tostring(card.guid) .. ")")
                            max_surpassing_number = card.number
                            surpassing_card = card
                            numeric_surpass_found = true
                        end
                    elseif card.type and string.find(card.type, "Mandate") and not numeric_surpass_found and not found_mandate_surpass then
                        -- No numeric surpass yet: first non-lead Mandate card found wins among mandates
                        LOG.DEBUG("Mandate tie-break: first non-lead Mandate card found, setting surpassing_card to " .. tostring(card.type) .. " (guid=" .. tostring(card.guid) .. ")")
                        surpassing_card = card
                        found_mandate_surpass = true
                    end
                elseif (lead.type == card.type and lead.number < card.number and card.number > max_surpassing_number) then
                    LOG.DEBUG("Suit match surpass: setting surpassing_card to " .. tostring(card.type) .. " " .. tostring(card.number) .. " (guid=" .. tostring(card.guid) .. ")")
                    max_surpassing_number = card.number
                    surpassing_card = card
                end
            end
        end
        ::continue::
    end
    if surpassing_card then
        LOG.INFO("Final surpassing card: " .. tostring(surpassing_card.type) .. " " .. tostring(surpassing_card.number) .. " (guid=" .. tostring(surpassing_card.guid) .. ")")
    else
        LOG.INFO("No surpassing card found.")
    end

    if (surpassing_card) then
        LOG.INFO("surpassing card: " .. surpassing_card.type .. " " ..
                     surpassing_card.number)
    end
    return surpassing_card
end

function ActionCards.count_seize_cards()
    local seize_zone = getObjectFromGUID(seize_zone_GUID)
    if (not seize_zone) then
        return 0
    end
    local seize_zone_objects = seize_zone.getObjects()
    local count = 0
    for _, obj in ipairs(seize_zone_objects) do
        if obj.hasTag("Action") and obj.is_face_down then
            count = count + 1
        end
    end
    return count
end

function ActionCards.count_action_cards()
    local count = 0
    local played_zone = getObjectFromGUID(action_card_zone_GUID)
    if not played_zone then
        LOG.WARNING("ActionCards.count_action_cards: action_card_zone not found: " .. tostring(action_card_zone_GUID))
        return 0
    end
    for _, obj in ipairs(played_zone.getObjects()) do
        if obj.hasTag("Action") then
            count = count + 1
        end
    end
    return count
end

function ActionCards.find_seize_player()
    local seize_zone = getObjectFromGUID(seize_zone_GUID)
    if not seize_zone then
        LOG.WARNING("ActionCards.find_seize_player: seize_zone not found: " .. tostring(seize_zone_GUID))
        return nil
    end
    local seize_zone_objects = seize_zone.getObjects()
    for _, obj in ipairs(seize_zone_objects or {}) do
        if obj.hasTag("Action") and obj.is_face_down then
            local seize_card = ActionCards.get_info(obj)
            local all_players = Global.getVar("active_players")
            for _, p in ipairs(all_players) do
                if p.last_seize_card and p.last_seize_card.type ==
                    seize_card.type and p.last_seize_card.number ==
                    seize_card.number then
                    return p.color
                end
            end
        end
    end
    print("No seize player found despite detecting a seize card")
    return nil
end

function ActionCards.draw_bottom(player_color, position, object)
    local hand_zone = Player[player_color].getHandTransform()
    local deck = ActionCards.get_action_deck()
    local drawn_card = deck.takeObject({
        top = false,
        position = hand_zone.position,
        rotation = hand_zone.rotation + Vector({0, 180, 180})
    })
    -- wait .75 seconds and flip it face up
    Wait.time(function()
        drawn_card.setRotation(Vector({0, 180, 0}))
    end, 0.75)
end

function ActionCards.faceup_discard_visibility(show)
    local visibility = show and {} or
                               {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    local discard = getObjectFromGUID(FUDiscard_marker_GUID)
    discard.setInvisibleTo(visibility)
end

function ActionCards.get_fud_marker()
    local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
    return fud_marker
end

-- Returns a list of action card GUIDs marked for union cards
function ActionCards.union_handling(played_objects)
    LOG.INFO("ActionCards.union_handling")

    local union_marked_cards = {}
    local union_like_names = {
        ["THE PROPHET"] = true,
        ["THE YOUNG LIGHT"] = true,
        ["THE PRODIGAL ONE"] = true
    }
    local function move_to_union_like_fixed_spot(trigger_card)
        if not trigger_card then return end
        -- Fixed world-space destination for special union-like cards.
        trigger_card.setPositionSmooth({3.25, 2.06, -0.64})
        trigger_card.setRotationSmooth(Vector({0, 180, 0}))
    end

    for _, obj in pairs(played_objects) do
        local obj_name = obj.getName and obj.getName() or ""
        local upper_name = string.upper(obj_name)
        local is_named_union_like = union_like_names[upper_name] == true
        local is_union_like = string.find(upper_name, "UNION") ~= nil or is_named_union_like

        -- Check if the card name contains "UNION" or matches one of the union-like names.
        if is_union_like then
            -- Find the closest face up action card
            local closest_face_up_action_card = nil
            local min_distance = 20

            for _, card in pairs(played_objects) do
                if card.getName() == "Action Card" and not card.is_face_down then
                    local distance = Vector.distance(obj.getPosition(), card.getPosition())
                    if distance < min_distance then
                        min_distance = distance
                        closest_face_up_action_card = card
                    end
                end
            end

            if closest_face_up_action_card then
                table.insert(union_marked_cards, {
                    guid = closest_face_up_action_card.guid,
                    description = closest_face_up_action_card.getDescription(),
                    reserved_by = obj_name
                })
                broadcastToAll("Whoever played " .. obj_name .. ", please pull " .. closest_face_up_action_card.getDescription() .. " back into your hand.")

                if is_named_union_like then
                    -- For specific union-like cards, move to one fixed middle-map spot.
                    move_to_union_like_fixed_spot(obj)
                else
                    -- Move regular union trigger cards to court discard.
                    local court_discard = getObjectFromGUID(court_discard_zone_GUID)
                    if court_discard then
                        obj.setPositionSmooth(court_discard.getPosition() + Vector({0, 3, 0}))
                        obj.setRotationSmooth(Vector({0, 270, 0}))
                    end
                end
            else
                broadcastToAll("Union card in play but no face up action cards to mark for union recall", Color.Red)
                if is_named_union_like then
                    -- Still place these cards in center area even if no action card was marked.
                    move_to_union_like_fixed_spot(obj)
                end
            end
        end
    end

    return union_marked_cards
end

return ActionCards

end)
__bundle_register("src/Supplies", function(require, _LOADED, __bundle_register, __bundle_modules)
local LOG = require("src/LOG")
require("src/GUIDs")

local SupplyManager = {}
-- Map player color names to broadcast RGB colors (values 0..1)
local PLAYER_BROADCAST_COLOR = {
    White = {1, 1, 1},
    Red = {1, 0, 0},
    Yellow = {1, 1, 0},
    Teal = {0, 0.8, 0.8},
    Pink = {1, 0.4, 0.7},
    Blue = {0.2, 0.6, 1},
    Green = {0.0, 0.8, 0.0},
    Orange = {1, 0.6, 0.0},
    Purple = {0.6, 0.2, 0.8},
    Brown = {0.5, 0.3, 0.1},
    Grey = {0.7, 0.7, 0.7},
    Black = {0.0, 0.0, 0.0}
}
-- TODO
-- stack management algorithm
-- remove from game GUID

local city_row = {{0.10, 2.00, -2.00}, {0.33, 2.00, -2.00},
                  {0.56, 2.00, -2.00}, {0.79, 2.00, -2.00},
                  {1.02, 2.00, -2.00}}

local all_supplies = {
    -- Player Agents
    ["White Agent"] = {
        bag = player_pieces_GUIDs["White"]["agents"],
        mini_bag = player_pieces_GUIDs["White"]["mini_agents"]
    },
    ["Teal Agent"] = {
        bag = player_pieces_GUIDs["Teal"]["agents"],
        mini_bag = player_pieces_GUIDs["Teal"]["mini_agents"]
    },
    ["Yellow Agent"] = {
        bag = player_pieces_GUIDs["Yellow"]["agents"],
        mini_bag = player_pieces_GUIDs["Yellow"]["mini_agents"]
    },
    ["Red Agent"] = {
        bag = player_pieces_GUIDs["Red"]["agents"],
        mini_bag = player_pieces_GUIDs["Red"]["mini_agents"]
    },

    -- Player Fresh Ships
    ["White Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["White"]["ships"],
        mini_bag = player_pieces_GUIDs["White"]["mini_ships"]
    },
    ["Teal Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Teal"]["ships"],
        mini_bag = player_pieces_GUIDs["Teal"]["mini_ships"]
    },
    ["Yellow Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Yellow"]["ships"],
        mini_bag = player_pieces_GUIDs["Yellow"]["mini_ships"]
    },
    ["Red Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Red"]["ships"],
        mini_bag = player_pieces_GUIDs["Red"]["mini_ships"]
    },

    -- Player Damaged Ships
    ["White Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["White"]["ships"],
        mini_bag = player_pieces_GUIDs["White"]["mini_ships"],
        state = 1
    },
    ["Teal Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Teal"]["ships"],
        mini_bag = player_pieces_GUIDs["Teal"]["mini_ships"],
        state = 1
    },
    ["Yellow Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Yellow"]["ships"],
        mini_bag = player_pieces_GUIDs["Yellow"]["mini_ships"],
        state = 1
    },
    ["Red Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Red"]["ships"],
        mini_bag = player_pieces_GUIDs["Red"]["mini_ships"],
        state = 1
    },

    -- Player Damaged Ships
    ["White Starport"] = {
        bag = player_pieces_GUIDs["White"]["starports"],
        face_up = true
    },
    ["Teal Starport"] = {
        bag = player_pieces_GUIDs["Teal"]["starports"],
        face_up = true
    },
    ["Yellow Starport"] = {
        bag = player_pieces_GUIDs["Yellow"]["starports"],
        face_up = true
    },
    ["Red Starport"] = {
        bag = player_pieces_GUIDs["Red"]["starports"],
        face_up = true
    },

    -- Player Cities
    ["White City"] = {
        origin = player_pieces_GUIDs["White"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["White"]["cities"],
        pos = city_row
    },
    ["Teal City"] = {
        origin = player_pieces_GUIDs["Teal"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Teal"]["cities"],
        pos = city_row
    },
    ["Yellow City"] = {
        origin = player_pieces_GUIDs["Yellow"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Yellow"]["cities"],
        pos = city_row
    },
    ["Red City"] = {
        origin = player_pieces_GUIDs["Red"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Red"]["cities"],
        pos = city_row
    },
    -- all pinks
    -- Player Agents
    ["Pink Agent"] = {
        bag = player_pieces_GUIDs["Pink"]["agents"],
        mini_bag = player_pieces_GUIDs["Pink"]["mini_agents"]
    },

    -- Player Fresh Ships
    ["Pink Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Pink"]["ships"],
        mini_bag = player_pieces_GUIDs["Pink"]["mini_ships"]
    },

    -- Player Damaged Ships
    ["Pink Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Pink"]["ships"],
        mini_bag = player_pieces_GUIDs["Pink"]["mini_ships"],
        state = 1
    },

    -- Player Starport
    ["Pink Starport"] = {
        bag = player_pieces_GUIDs["Pink"]["starports"],
        face_up = true
    },

    -- Player Cities
    ["Pink City"] = {
        origin = player_pieces_GUIDs["Pink"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Pink"]["cities"],
        pos = city_row
    },

    -- Resources
    ["Psionic"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["psionics"]
    },
    ["Relic"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["relics"]
    },
    ["Weapon"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["weapons"]
    },
    ["Fuel"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["fuel"]
    },
    ["Material"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["materials"]
    },

    -- Campaign Components
    ["Blight"] = {
        bag = blight_GUID
    },
    ["Imperial Ship (Damaged)"] = {
        bag = imperial_ships_GUID,
        mini_bag = mini_imperial_ships_GUID
    },
    ["Imperial Ship (Fresh)"] = {
        bag = imperial_ships_GUID,
        mini_bag = mini_imperial_ships_GUID
    },
    ["Free City"] = {
        bag = free_cities_GUID
    },
    ["Free Starport"] = {
        bag = free_starports_GUID
    },

    -- Miscallaneous
    [""] = {
        ignore = true
    },
    ["Zero Marker"] = {
        pos = {0.938, 1.747, 1.091},
        rot = {0.00, 180.00, 0.00},
        origin = reach_board_GUID
    }
}

-- Main return
function SupplyManager.returnObject(object, is_bottom_deck, returning_player_color)

    local deck_pos = is_bottom_deck and -1 or 1
    local supply = all_supplies[object.getName()]

    if not supply then
        LOG.ERROR("Unable to return '" .. object.getName() ..
                      "' to a supply.")
        return
    end

    -- Check for additional changes that should be made when returning to supply
    if supply.state then
        object = object.setState(supply.state)
    elseif supply.face_up and object.is_face_down then
        object.flip()
    elseif supply.face_down and not object.is_face_down then
        object.flip()
    end

    -- Complete return based on type --

    -- Ignore return
    if supply.ignore then
        return

    elseif supply.mini_bag then
        local regular_bag_exists = getObjectFromGUID(supply.bag)
        if regular_bag_exists then
            regular_bag_exists.putObject(object)
        else
            getObjectFromGUID(supply.mini_bag).putObject(object)
        end

    elseif supply.bag then
        getObjectFromGUID(supply.bag).putObject(object)

        -- Return to deck
        -- If deck doesn't exist then put card where deck was and make it the deck
    elseif supply.deck then
        local deck = getObjectFromGUID(supply.deck)
        if deck then
            object.setPosition(supply.pos)
            object.setRotation(supply.rot)
            local new_deck = deck.putObject(object)
            if new_deck then
                supply.deck = new_deck.getGUID()
                supply.pos = new_deck.getPosition() + deck_pos *
                                 Vector(0, 2, 0)
                supply.rot = new_deck.getRotation()
            end
        else
            supply.deck = object.getGUID()
            object.setPosition(supply.pos)
            object.setRotation(supply.rot)
        end

        -- Return a set of objects to a set of positions
    elseif supply.set then
        for ct, obj_GUID in ipairs(supply.set) do
            if object.getGUID() == obj_GUID then
                local pos = supply.pos[ct]
                pos = supply.origin and
                          getObjectFromGUID(supply.origin).positionToWorld(
                        pos)
                -- If this is a City being returned to its supply, lower it in Z
                local ok_name, nm = pcall(function() return object.getName() end)
                -- if ok_name and nm and string.find(nm, "City") then
                --     pcall(function()
                --         if pos.z then pos.z = pos.z - 1.64 end
                --     end)
                -- end
                object.setPositionSmooth(pos, false, true)
                -- Broadcast to all players that the city was returned and instruct placement
                if ok_name and nm and string.find(nm, "City") then
                    -- determine owner color from the city's name (e.g., 'White City' -> 'White')
                    local owner_color = nil
                    local nm_lower = string.lower(nm)
                    for colname, _ in pairs(player_pieces_GUIDs) do
                        if string.find(nm_lower, string.lower(colname)) then
                            owner_color = colname
                            break
                        end
                    end

                    local msg
                    if owner_color then
                        msg = "Returned " .. tostring(nm) .. " to its supply. The " .. tostring(owner_color) .. " player should place it in the rightmost city slot; resources may be rearranged."
                    else
                        msg = "Returned " .. tostring(nm) .. " to its supply. The player who returned it should place it in the rightmost city slot; resources may be rearranged."
                    end

                    -- choose broadcast color based on the owner (who gets the city back)
                    local col = {r=0.8, g=0.8, b=0.8}
                    if owner_color and PLAYER_BROADCAST_COLOR[owner_color] then
                        local c = PLAYER_BROADCAST_COLOR[owner_color]
                        col = {r=c[1], g=c[2], b=c[3]}
                    end
                    broadcastToAll(msg, col)
                end
            end
        end

        -- Return an object to a position
    elseif supply.pos then
        local pos = supply.pos
        pos = supply.origin and
                  getObjectFromGUID(supply.origin).positionToWorld(pos) or
                  pos
        object.setPositionSmooth(pos, false, true)
        if (supply.rot) then
            object.setRotationSmooth(supply.rot)
        end
    end

end

-- Expanded returns
function SupplyManager.returnEverything()
    for _, i in pairs(getObjects()) do
        SupplyManager.returnObject(i)
    end
end

function SupplyManager.returnZone(zone)
    for _, i in pairs(zone.getObjects()) do
        SupplyManager.returnObject(i)
    end
end

-- Remove from game shortcut
function SupplyManager.removeFromGame(object)
    local bin = getObjectFromGUID(Global.getVar(
        "removed_from_game_GUID"))
    bin.putObject(object)
end

-- Context menu return implementation
function SupplyManager.addMenuToAllObjects()
    for _, object in pairs(getObjects()) do
        SupplyManager.addMenuToObject(object)
    end
end

function SupplyManager.addMenuToObject(object)
    -- log("Adding return context menu option to "..object.getName())
    if object.getName() ~= "" and all_supplies[object.getName()] then
        object.addContextMenuItem("Return to supply",
            SupplyManager.returnFromMenu)
        object.addContextMenuItem("Take as trophy",
            SupplyManager.trophyFromMenu)
        object.addContextMenuItem("Take as captive",
            SupplyManager.captiveFromMenu)
        if object.type == "Card" then
            object.addContextMenuItem("Card to deck bottom",
                SupplyManager.buryFromMenu)
            -- Add 'Discard' option for tagged court cards (Guild, Vox, Lore)
            pcall(function()
                if object.hasTag and (object.hasTag("Guild") or object.hasTag("Vox") or object.hasTag("Lore")) then
                    object.addContextMenuItem("Discard",
                        SupplyManager.discardToCourtFromMenu)
                end
            end)
        end
    end
    -- Add special context menu for Material Cartel cards so user can place
    -- the materials disk above the card.
    local ok, name = pcall(function() return object.getName and object.getName() end)
    if ok and name then
        local nl = string.lower(name)
        -- detect any '* Cartel' cards and add a context menu to place the matching marker
        if string.find(nl, "cartel") then
            -- choose a resource key based on the cartel name
            local resource_key
            if string.find(nl, "material") then
                resource_key = "materials"
            elseif string.find(nl, "fuel") then
                resource_key = "fuel"
            elseif string.find(nl, "weapon") or string.find(nl, "weapons") then
                resource_key = "weapons"
            elseif string.find(nl, "psionic") or string.find(nl, "psionics") then
                resource_key = "psionics"
            elseif string.find(nl, "relic") then
                resource_key = "relics"
            end
            if resource_key then
                pcall(function()
                    object.addContextMenuItem("Place supply on card",
                        function(player_color, position, obj) SupplyManager.placeResourceMarkerOnCard(player_color, position, obj) end)
                    -- allow returning the resource marker to its initial origin
                    object.addContextMenuItem("Return supply",
                        function(player_color, position, obj) SupplyManager.returnResourceMarkerToOrigin(player_color, position, obj) end)
                end)
            end
        end
    end

    -- Also ensure any Card with Guild/Vox/Lore tags gets a 'Discard' menu
    pcall(function()
        if object.type == "Card" and object.hasTag then
            local is_tagged = object.hasTag("Guild") or object.hasTag("Vox") or object.hasTag("Lore")
            if is_tagged then
                -- Avoid adding duplicate when the card is already in all_supplies
                local in_supplies = false
                local ok_name, nm = pcall(function() return object.getName and object.getName() end)
                if ok_name and nm and nm ~= "" and all_supplies[nm] then in_supplies = true end
                if not in_supplies then
                    object.addContextMenuItem("Discard", SupplyManager.discardToCourtFromMenu)
                end
            end
        end
    end)

    -- If the card is Sworn Guardians, add bury-to-court option
    pcall(function()
        if object.type == "Card" and object.getName then
            local ok, nm = pcall(function() return object.getName() end)
            if ok and nm then
                if string.lower(nm) == string.lower("SWORN GUARDIANS") then
                    object.addContextMenuItem("Bury into Court Deck", SupplyManager.burySwornGuardiansFromMenu)
                end
            end
        end
    end)
end

-- Generic handler: move the resource marker (from resources_markers_GUID)
-- above the provided card and also move any object that was sitting on top
-- the marker to remain stacked.
function SupplyManager.placeResourceMarkerOnCard(player_color, position, object)
    if not object or not object.getName then return end
    local name = object.getName()
    if not name then return end
    local nl = string.lower(name)
    if not string.find(nl, "cartel") then return end

    local resource_key
    if string.find(nl, "material") then
        resource_key = "materials"
    elseif string.find(nl, "fuel") then
        resource_key = "fuel"
    elseif string.find(nl, "weapon") or string.find(nl, "weapons") then
        resource_key = "weapons"
    elseif string.find(nl, "psionic") or string.find(nl, "psionics") then
        resource_key = "psionics"
    elseif string.find(nl, "relic") then
        resource_key = "relics"
    end
    if not resource_key then
        LOG.ERROR("Unknown cartel resource for card: " .. tostring(name))
        return
    end

    local marker_guid = resources_markers_GUID and resources_markers_GUID[resource_key]
    if not marker_guid then
        LOG.ERROR("Resource marker GUID not configured for " .. tostring(resource_key))
        return
    end

    local marker = getObjectFromGUID(marker_guid)
    if not marker then
        LOG.ERROR("Resource marker object not found (GUID=" .. tostring(marker_guid) .. ")")
        return
    end

    -- record current marker position (if present) so we can move stacked objects
    local ok_old, old_pos = pcall(function() return marker.getPosition() end)

    -- target position above the card
    local above = {0, 1.8, 0}
    local target_pos = object.positionToWorld(above)
    pcall(function() marker.setPositionSmooth(target_pos) end)
    if marker.setRotation then pcall(function() marker.setRotationSmooth({0, 90, 0}) end) end

    -- If we have an old marker position, move any objects that were on top of it
    if ok_old and old_pos then
        for _, candidate in ipairs(getObjects()) do
            if candidate.getGUID and candidate.getGUID() ~= marker.getGUID() and candidate.getGUID() ~= object.getGUID() then
                local ok2, cpos = pcall(function() return candidate.getPosition() end)
                if ok2 and cpos then
                    local dx = math.abs(cpos.x - old_pos.x)
                    local dz = math.abs(cpos.z - old_pos.z)
                    local dy = cpos.y - old_pos.y
                    if dx <= 0.6 and dz <= 0.6 and dy > 0.05 then
                        local rel_y = dy
                        local new_pos = {target_pos[1], target_pos[2] + rel_y, target_pos[3]}
                        pcall(function() candidate.setPositionSmooth(new_pos) end)
                    end
                end
            end
        end
    end
end

-- Move the materials marker (resources_markers_GUID["materials"]) above the
-- selected card. Callback signature: (player_color, position, object)
function SupplyManager.placeMaterialsOnCard(player_color, position, object)
    if not object or not object.getName then return end
    local mat_guid = resources_markers_GUID and resources_markers_GUID["materials"]
    if not mat_guid then
        LOG.ERROR("materials GUID not configured")
        return
    end
    local mat_obj = getObjectFromGUID(mat_guid)
    if not mat_obj then
        LOG.ERROR("Materials marker object not found (GUID=" .. tostring(mat_guid) .. ")")
        return
    end

    -- Move the materials disk above the card (0, 1.8, 0) in card-local coordinates
    local above = {0, 1.8, 0}
    local target_pos = object.positionToWorld(above)
    mat_obj.setPositionSmooth(target_pos)
    -- ensure marker is oriented upright
    if mat_obj.setRotation then
        mat_obj.setRotationSmooth({0, 90, 0})
    end
    -- Also move any object that was sitting on top of the materials marker
    -- so it stays on top of the marker after the move.
    local ok, mat_pos = pcall(function() return mat_obj.getPosition() end)
    if not ok or not mat_pos then return end

    for _, candidate in ipairs(getObjects()) do
        if candidate.getGUID and candidate.getGUID() ~= mat_obj.getGUID() and candidate.getGUID() ~= object.getGUID() then
            local ok2, cpos = pcall(function() return candidate.getPosition() end)
            if ok2 and cpos then
                local dx = math.abs(cpos.x - mat_pos.x)
                local dz = math.abs(cpos.z - mat_pos.z)
                local dy = cpos.y - mat_pos.y
                -- consider it 'on top' if horizontally very close and vertically above the marker
                if dx <= 0.6 and dz <= 0.6 and dy > 0.05 then
                    -- preserve the vertical offset relative to the marker
                    local rel_y = dy
                    local new_pos = {target_pos[1], target_pos[2] + rel_y, target_pos[3]}
                    pcall(function()
                        candidate.setPositionSmooth(new_pos)
                    end)
                end
            end
        end
    end
end


-- Return a resource marker to its configured origin coordinates and move any stacked objects with it.
function SupplyManager.returnResourceMarkerToOrigin(player_color, position, object)
    if not object or not object.getName then return end
    local name = object.getName()
    if not name then return end
    local nl = string.lower(name)
    if not string.find(nl, "cartel") then return end

    local resource_key
    if string.find(nl, "material") then
        resource_key = "materials"
    elseif string.find(nl, "fuel") then
        resource_key = "fuel"
    elseif string.find(nl, "weapon") or string.find(nl, "weapons") then
        resource_key = "weapons"
    elseif string.find(nl, "psionic") or string.find(nl, "psionics") then
        resource_key = "psionics"
    elseif string.find(nl, "relic") then
        resource_key = "relics"
    end
    if not resource_key then
        LOG.ERROR("Unknown cartel resource for card: " .. tostring(name))
        return
    end

    local marker_guid = resources_markers_GUID and resources_markers_GUID[resource_key]
    if not marker_guid then
        LOG.ERROR("Resource marker GUID not configured for " .. tostring(resource_key))
        return
    end

    local marker = getObjectFromGUID(marker_guid)
    if not marker then
        LOG.ERROR("Resource marker object not found (GUID=" .. tostring(marker_guid) .. ")")
        return
    end

    -- map resource keys to their initial world coordinates (from user)
    local origins = {
        materials = {-16.17, 1.00, -8.98},
        fuel = {-16.18, 1.00, -6.83},
        weapons = {-16.14, 1.00, -4.81},
        relics = {-16.09, 1.00, -2.84},
        psionics = {-16.08, 1.00, -0.82}
    }

    local target_pos = origins[resource_key]
    if not target_pos then
        LOG.ERROR("No origin coordinates configured for " .. tostring(resource_key))
        return
    end

    -- record old marker position so stacked objects can be moved with it
    local ok_old, old_pos = pcall(function() return marker.getPosition() end)

    pcall(function() marker.setPositionSmooth(target_pos) end)
    if marker.setRotation then pcall(function() marker.setRotationSmooth({0, 90, 0}) end) end

    -- Move any objects that were sitting on top of the marker to remain stacked.
    if ok_old and old_pos then
        for _, candidate in ipairs(getObjects()) do
            if candidate.getGUID and candidate.getGUID() ~= marker.getGUID() and candidate.getGUID() ~= object.getGUID() then
                local ok2, cpos = pcall(function() return candidate.getPosition() end)
                if ok2 and cpos then
                    local dx = math.abs(cpos.x - old_pos.x)
                    local dz = math.abs(cpos.z - old_pos.z)
                    local dy = cpos.y - old_pos.y
                    if dx <= 0.6 and dz <= 0.6 and dy > 0.05 then
                        local rel_y = dy
                        local new_pos = {target_pos[1], target_pos[2] + rel_y, target_pos[3]}
                        pcall(function() candidate.setPositionSmooth(new_pos) end)
                    end
                end
            end
        end
    end
end


-- Move a tagged court card to the court discard zone. Callback signature:
-- (player_color, position, object)
function SupplyManager.discardToCourtFromMenu(player_color, position, object)
    if not object then return end
    local court_discard = getObjectFromGUID(court_discard_zone_GUID)
    if not court_discard then
        LOG.ERROR("Court discard zone not found: " .. tostring(court_discard_zone_GUID))
        return
    end
    pcall(function()
        object.setPositionSmooth(court_discard.getPosition() + Vector({0, 3, 0}))
        if object.setRotationSmooth then
            object.setRotationSmooth(Vector({0, 270, 0}))
        end
    end)
end

-- Bury the Sworn Guardians into the court deck (attempt to put into the base court deck,
-- fallback to moving to the court deck zone).
function SupplyManager.burySwornGuardiansFromMenu(player_color, position, object)
    if not object then return end

    -- Prefer the deck currently in the court deck zone
    local court_zone = getObjectFromGUID(court_deck_zone_GUID)
    if court_zone and court_zone.getObjects then
        local objs = court_zone.getObjects()
        for _, obj in ipairs(objs) do
            if obj and obj.tag == "Deck" and obj.putObject then
                pcall(function()
                    obj.putObject(object)
                end)
                return
            end
        end
    end

    -- If no deck in zone, fall back to configured base court deck GUID
    local base_guid = (Global and Global.getVar and Global.getVar("base_court_deck_GUID")) or base_court_deck_GUID
    local ok_base, base_deck = pcall(function() return base_guid and getObjectFromGUID(base_guid) end)
    if ok_base and base_deck and base_deck.putObject then
        pcall(function()
            base_deck.putObject(object)
        end)
        return
    end

    -- final fallback: move the card to the court deck zone position
    if court_zone then
        pcall(function()
            object.setPositionSmooth(court_zone.getPosition() + Vector({0, 3, 0}))
            if object.setRotationSmooth then object.setRotationSmooth(Vector({0, 270, 0})) end
        end)
    else
        LOG.ERROR("Unable to find court deck or zone to bury Sworn Guardians")
    end
end

function SupplyManager.returnFromMenu(player_color, position, object)
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for ct, k in ipairs(i.getSelectedObjects()) do
                Wait.time(function()
                    SupplyManager.returnObject(k, nil, player_color)
                end, (ct - 1) * 0.5)
            end
        end
    end
end

function SupplyManager.captiveFromMenu(player_color, position, object)
    local zone = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["captives_zone"])
    SupplyManager.addToZone(player_color, zone, object)
end

function SupplyManager.trophyFromMenu(player_color, position, object)
    local zone = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["trophies_zone"])
    SupplyManager.addToZone(player_color, zone, object)
end

function SupplyManager.addToZone(player_color, zone, object)
    local area = Vector({0.18, 0, 0.18})
    local sectors = {
        [0] = Vector({1, 0, 1}),
        [1] = Vector({-1, 0, 1}),
        [2] = Vector({-1, 0, -1}),
        [3] = Vector({1, 0, -1})
    }
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for ct, k in ipairs(i.getSelectedObjects()) do
                local pos = Vector({area.x * math.random(), 0,
                                    area.z * math.random()})
                pos = pos * sectors[ct % 4]
                pos = zone.positionToWorld(pos)
                Wait.time(function()
                    k.setPositionSmooth(pos)
                end, (ct - 1) * .5)
            end
        end
    end
end

function SupplyManager.buryFromMenu(player_color, position, object)
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for _, k in pairs(i.getSelectedObjects()) do
                if k.type == "Card" then
                    SupplyManager.returnObject(k, true)
                end
            end
        end
    end
end

return SupplyManager

end)
return __bundle_require("Zero Marker.0289cb.lua")