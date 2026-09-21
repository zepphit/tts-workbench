-- Bundled by luabundle {"rootModuleName":"Global.-1.lua","version":"1.6.0"}
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
__bundle_register("Global.-1.lua", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/Global")
end)
__bundle_register("src/Global", function(require, _LOADED, __bundle_register, __bundle_modules)
local authors = "Quinnsicle, Scyth02, McChew, fallspectrum, Laurens"
local version = "1.0"
local game_id = "" -- unique ID for this game session, generated on first load

require("src/GUIDs")

available_colors = {"White", "Yellow", "Red", "Teal", "Pink"}

----------------------------------------------------
-- [DEBUG] REMEMBER TO SET TO FALSE BEFORE RELEASE
----------------------------------------------------
debug = false
debug_player_count = 2
----------------------------------------------------

with_leaders = false
with_more_to_explore = false
is_face_up_discard_active = false
with_miniatures = false
with_laurens_custom_leader = false
with_pnp2_lost_vaults = false
with_pnp3_leaders = false
dont_use_base_and_pack_leaders = false
use_scavengers_scouts_deck = false
is_auto_end_round_enabled = false -- toggle end round
is_basegame_setup = false
turn_count = 0
leader_draft_count = nil
lore_draft_count = nil

oop_components = {
  {
    Sector = {
      pos = {-0.16, 0.97, -1.02},
      rot = {0, 180, -0.01},
      scale = {2.48, 1, 2.48},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769502/1D85B9468BB538D788FCF7576A05606918CD0DD4/"
    },
    Gate = {
      pos = {-0.04, 0.97, -0.63},
      rot = {0, 189.24, -0.01},
      scale = {0.71, 1, 0.71},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
    }
  }, {
    Sector = {
      pos = {-0.50, 0.97, -0.64},
      rot = {0, 180, -0.01},
      scale = {2.48, 1, 2.48},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769605/A40A0C79B27F1F1C45E0570E46BA8A7B253F356E/"
    },
    Gate = {
      pos = {-0.23, 0.97, -0.21},
      rot = {0, 252.52, 0},
      scale = {0.44, 1, 0.44},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }, {
    Sector = {
      pos = {-0.45, 0.97, 0.73},
      rot = {0, 179.99, -0.01},
      scale = {2.36, 1, 2.36},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769710/C408A11914F7F4DEA83686851730DDF10A8BD5D4/"
    },
    Gate = {
      pos = {-0.2, 0.97, 0.28},
      rot = {0, 305.16, 0},
      scale = {0.44, 1, 0.44},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }, {
    Sector = {
      pos = {0.17, 0.97, 0.90},
      rot = {0, 179, -0.01},
      scale = {2.54, 1, 2.54},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769816/0AA42154550040133E7D6740F85CD487D5F6967B/"
    },
    Gate = {
      pos = {0.05, 0.97, 0.52},
      rot = {-0.01, 12.02, 0},
      scale = {0.71, 1, 0.71},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
    }
  }, {
    Sector = {
      pos = {0.5, 0.97, 0.55},
      rot = {0, 179.99, -0.01},
      scale = {2.48, 1, 2.48},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445770194/8600421030523070B8E2F05CECC3281DF24989AC/"
    },
    Gate = {
      pos = {0.24, 0.97, 0.1},
      rot = {-0.01, 72.87, -0.01},
      scale = {0.44, 1, 0.44},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }, {
    Sector = {
      pos = {0.46, 0.97, -0.82},
      rot = {0, 180.00, -0.01},
      scale = {2.29, 1, 2.29},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445770362/76677A077FC1D6CD3672DCC036646ABFD2881F62/"
    },
    Gate = {
      pos = {0.2, 0.97, -0.39},
      rot = {-0.01, 125.02, -0.01},
      scale = {0.44, 1, 0.44},
      img = "https://steamusercontent-a.akamaihd.net/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }
}

initiative_player_position = {-2, 0, 0}

active_players = {}
starting_players = {}

-- Cache player steam names early so they survive if players leave before submission
local player_steam_name_cache = {}
function cache_player_steam_names()
    player_steam_name_cache = {}
    local seated = getSeatedPlayers()
    if seated and #seated > 0 then
        for _, color in ipairs(seated) do
            local ok, player = pcall(function() return Player[color] end)
            if ok and player and player.steam_name and player.steam_name ~= "" then
                player_steam_name_cache[color] = player.steam_name
            else
                player_steam_name_cache[color] = color
            end
        end
    end
    Global.setVar("player_steam_name_cache", player_steam_name_cache)
end

  -- Update cache from currently seated players without clearing existing entries.
  -- This preserves names for disconnected players while allowing seat-takeover overrides.
  function refresh_player_steam_name_cache_from_seated()
    local cache = Global.getVar("player_steam_name_cache") or player_steam_name_cache or {}
    local seated = getSeatedPlayers()
    if seated and #seated > 0 then
      for _, color in ipairs(seated) do
        local ok, player = pcall(function() return Player[color] end)
        if ok and player and player.steam_name and player.steam_name ~= "" then
          cache[color] = player.steam_name
        else
          cache[color] = color
        end
      end
    end
    player_steam_name_cache = cache
    Global.setVar("player_steam_name_cache", player_steam_name_cache)
  end

  local function update_cached_steam_name_for_color(color)
    if not color or color == "" or color == "Grey" then return end
    local cache = Global.getVar("player_steam_name_cache") or player_steam_name_cache or {}
    local ok, player = pcall(function() return Player[color] end)
    if ok and player and player.steam_name and player.steam_name ~= "" then
      cache[color] = player.steam_name
    else
      cache[color] = color
    end
    player_steam_name_cache = cache
    Global.setVar("player_steam_name_cache", player_steam_name_cache)
  end

  function onPlayerConnect(player)
    local color = nil
    pcall(function()
      if player and player.color then color = tostring(player.color) end
    end)
    if color and color ~= "" and color ~= "Grey" then
      update_cached_steam_name_for_color(color)
    end
  end

  function onPlayerChangeColor(player_color)
    local color = tostring(player_color or "")
    if color ~= "" and color ~= "Grey" then
      update_cached_steam_name_for_color(color)
    end
    Wait.time(function()
      refresh_player_steam_name_cache_from_seated()
    end, 0.2)
  end

-- Retrieve cached steam name for a player, fallback to color if not cached
function get_cached_steam_name(color)
    local cache = Global.getVar("player_steam_name_cache") or {}
    return cache[color] or color
end

active_ambitions = {
    c9e0ee = "",
    a9b02a = "",
    b0b4d0 = ""
}

zoneWaits = {}
-- track which deck objects we've already patched with the draw-bottom menu
draw_bottom_patched = {}
local OverlayChatCommands = require("src/events/OverlayChatCommands")
local DropActionEvents = require("src/events/DropActionEvents")
local score_ambitions_run_id = 0

-- Scan the action deck zone periodically and attach the "Draw bottom card" menu
function scan_action_deck_zone()
  local zone = getObjectFromGUID(action_deck_zone_GUID)
  if not zone then return end

  local found = {}
  local objs = zone.getObjects()
  if objs then
    for _, obj in ipairs(objs) do
      local is_deck = false
      -- prefer the stable tag, fall back to name property/method
      if obj.tag and obj.tag == "Deck" then
        is_deck = true
      elseif obj.getName and obj.getName() == "Deck" then
        is_deck = true
      elseif obj.name == "Deck" then
        is_deck = true
      end
      if is_deck then
        local guid = nil
        if obj.getGUID then guid = obj.getGUID() end
        if not guid and obj.guid then guid = obj.guid end
        if guid then
          found[guid] = true
          if not draw_bottom_patched[guid] then
            pcall(function()
              obj.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
            end)
            draw_bottom_patched[guid] = true
          end
        end
      end
    end
  end

  -- Remove tracking for decks that have left or been destroyed
  for guid, _ in pairs(draw_bottom_patched) do
    if not found[guid] then
      draw_bottom_patched[guid] = nil
    end
  end
end
 
-- Chat commands for overlay control:
--  !overlay start   -> enable automatic sending each turn
--  !overlay stop    -> disable automatic sending
--  !overlay once    -> send one immediate update
--  !overlay status  -> show current state
--  !overlay help    -> show this command list
function onChat(message, player)
  if OverlayChatCommands.handle(message) then
    return
  end
end

function schedule_scan()
  scan_action_deck_zone()
  Wait.time(schedule_scan, 2)
end
----------------------------------------------------
AmbitionMarkers = require("src/AmbitionMarkers")
local ActionCards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Control = require("src/Control")
local Counters = require("src/Counters")
local Initiative = require("src/InitiativeMarker")
local RoundManager = require("src/RoundManager")
local SetupControl = require("src/SetupControl")
local Supplies = require("src/Supplies")
local Camera = require("src/Camera")
local Timer = require("src/Timer")
local LOG = require("src/LOG")
local SheetsSender = require("src/SheetsSender")
local ErrataFaqService = require("src/integrations/ErrataFaqService")
local SheetsSenderOverlay = nil

-- Whether to automatically send overlay updates each turn when enabled
overlay_sending_enabled = false
overlay_cards_hidden = false
-- Overlay alignment: 'left' (default) or 'right'
overlay_align = "left"

-- Try to require overlay sender if present (optional)
SheetsSenderOverlay = require("src/SheetsSenderOverlay")

-- Generate a unique ID for this game session
local function generate_game_id()
    local seed = os.time() * 1000 + math.random(1, 999)
    return string.format("%X", seed)
end

-- Proxy to refresh ambitions from other script contexts.
-- Some object scripts cannot safely call Global-setter operations
-- directly, so call this function via `Global.call('ambition_refresh_proxy')`.
function ambition_refresh_proxy()
  pcall(function() AmbitionMarkers.refresh_all_ambitions() end)
end

-- Mark a specific ambition marker GUID as undeclared in the global ambitions map.
-- Called via `Global.call('ambition_set_marker_undeclared', guid)` from other scripts.
function ambition_set_marker_undeclared(guid)
  if not guid then return end
  pcall(function()
    local active = Global.getVar('active_ambitions') or {}
    active[guid] = ""
    Global.setVar('active_ambitions', active)
    pcall(function() Global.call('update_player_scores') end)
  end)
end

function assignPlayerToAvailableColor(player, color)
    local color = table.remove(available_colors, 1)
    broadcastToAll("\nAssigning " .. player.steam_name .. " to color " .. color)
    player.changeColor(color)
end

function get_arcs_player(color)
    for _, p in ipairs(active_players) do
        if (p.color == color) then
            return p
        end
    end
end

DropActionEvents.configure({
    get_arcs_player = get_arcs_player,
    get_action_cards = function() return ActionCards end,
    ambition_get_info = function(obj) return AmbitionMarkers.get_ambition_info(obj) end,
    log_warning = function(message) LOG.WARNING(message) end,
    log_debug = function(message) LOG.DEBUG(message) end,
    action_card_zone_GUID = action_card_zone_GUID,
    seize_zone_GUID = seize_zone_GUID,
    zone_waits = zoneWaits
})

function update_player_scores()
    for _, p in ipairs(active_players) do
        p:update_score()
    end
    -- After updating player score widgets, compute detailed ambition point estimates
    -- (stored in Global but NOT automatically broadcast; use context menu on markers to show)
    local ok, breakdown = pcall(function()
        local AmbitionMarkers = AmbitionMarkers
        if AmbitionMarkers and AmbitionMarkers.build_detailed_estimates then
            return AmbitionMarkers:build_detailed_estimates()
        end
        return nil
    end)
    if ok and breakdown then
        Global.setVar("ambition_point_estimates_detailed", breakdown)
    end
end

-- Helper function to convert player color name to RGB
local function color_name_to_rgb(color_name)
    local color_map = {
    White = {1, 1, 1},
    Brown = {0.443, 0.231, 0.09},
    Red = {0.856, 0.1, 0.094},
    Orange = {0.956, 0.392, 0.113},
    Yellow = {0.905, 0.898, 0.172},
    Green = {0.192, 0.701, 0.168},
    Teal = {0.129, 0.694, 0.607},
    Blue = {0.118, 0.53, 1},
    Purple = {0.627, 0.125, 0.941},
    Pink = {0.96, 0.439, 0.807},
    Grey = {0.5, 0.5, 0.5},
    Black = {0.25, 0.25, 0.25}
    }
  return color_map[color_name] or {0.6, 1, 0.6}
end

-- Print a detailed ambition estimates breakdown to chat.
function print_ambition_estimates()
    -- ensure player scores are up-to-date
    Global.call("update_player_scores")
    local breakdown = Global.getVar("ambition_point_estimates_detailed")

    if not breakdown then
        broadcastToAll("Could not compute ambition estimates", {1, 0.4, 0.4})
        return
    end

    -- Title
    broadcastToAll("=== Ambition Power Gain ===", {0.35, 0.7, 1})
    
    -- Totals: show gain and projected total (current + gain)
    local total_parts = {}
    for color, pts in pairs(breakdown.totals or {}) do
      local gain = tonumber(pts) or 0
      -- get current power from ArcsPlayer instance if available
      local current = 0
      local ap = get_arcs_player(color)
      if ap and ap.power ~= nil then
        current = ap.power
      end
      local projected = current + gain
      table.insert(total_parts, { color = color, gain = gain, current = current, projected = projected })
    end
    if #total_parts > 0 then
      broadcastToAll("TOTALS:", {0.6, 1, 0.6})
      for _, entry in ipairs(total_parts) do
        local player_color_rgb = color_name_to_rgb(entry.color)
        broadcastToAll("  " .. entry.color .. ": " .. tostring(entry.gain) .. " (" .. tostring(entry.current) .. " → " .. tostring(entry.projected) .. ")", player_color_rgb)
      end
    else
      broadcastToAll("No Ambition points projected.", {0.8, 0.8, 0.8})
      return
    end
    
    broadcastToAll(" ", {0.9, 0.9, 0.9})

    -- Group tokens by ambition name
    local grouped = {}
    for _, token in ipairs(breakdown.tokens or {}) do
        local ambition_name = token.ambition or ""
        if not grouped[ambition_name] then
            grouped[ambition_name] = {
                prize_sets = {},  -- list of prize arrays from each marker
                per_player = {}
            }
        end
        -- Collect all prize sets
        if #(token.prizes or {}) > 0 then
            table.insert(grouped[ambition_name].prize_sets, token.prizes)
        end
        -- Sum per-player points
        for color, pts in pairs(token.per_player or {}) do
            grouped[ambition_name].per_player[color] = (grouped[ambition_name].per_player[color] or 0) + pts
        end
    end

    -- Output grouped by ambition in order
    local ambition_order = {"Tycoon", "Tyrant", "Warlord", "Keeper", "Empath"}
    local count = 0
    for _, ambition_name in ipairs(ambition_order) do
        if grouped[ambition_name] then
            count = count + 1
            local entry = grouped[ambition_name]
            
            broadcastToAll(ambition_name .. ":", {0.45, 0.8, 1})
            
            -- Sort players by their points in descending order
            local player_scores = {}
            for color, pts in pairs(entry.per_player or {}) do 
                table.insert(player_scores, { color = color, points = pts, ambition = ambition_name })
            end
            table.sort(player_scores, function(a, b) return a.points > b.points end)
            
            -- Display results by place
            local place_labels = {[1] = "1st", [2] = "2nd", [3] = "3rd"}
            for place, entry_data in ipairs(player_scores) do
                local color = entry_data.color
                local pts = entry_data.points

              local note = ""
              if breakdown.ambition_notes and breakdown.ambition_notes[ambition_name] and breakdown.ambition_notes[ambition_name][color] then
                note = " " .. breakdown.ambition_notes[ambition_name][color]
              end

              -- Show 0-point entries only when they have an explanation (for example, demoted or blocked leaders)
              if pts > 0 or note ~= "" then
                local bonus = 0
                if breakdown.ambition_bonuses and breakdown.ambition_bonuses[ambition_name] and breakdown.ambition_bonuses[ambition_name][color] then
                  bonus = breakdown.ambition_bonuses[ambition_name][color]
                end

                local place_label = place_labels[place] or place .. "th"
                local bonus_text = ""
                if bonus > 0 then
                  bonus_text = " (+" .. tostring(bonus) .. " city bonus)"
                end

                local player_color_rgb = color_name_to_rgb(color)
                broadcastToAll("  " .. place_label .. ": " .. color .. " → " .. tostring(pts) .. bonus_text .. note, player_color_rgb)
              end
            end
            
            broadcastToAll(" ", {0.9, 0.9, 0.9})
        end
    end
end

-- Callback function for ambition marker context menu
function show_ambition_scores_menu(player_color, position, clicked_object)
    Global.call("print_ambition_estimates")
end

-- Reset/reseed ambition markers:
-- 1) Return all markers to their base slots,
-- 2) Flip the marker with the lowest current first-power,
-- 3) Move the top 3 markers by first-power to staging positions.
function reset_ambition_markers_menu(player_color, position, clicked_object)
  local reach_map = getObjectFromGUID(reach_board_GUID)
  if not reach_map then
    broadcastToColor("Could not reset ambition markers: reach board not found.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  if not ambition_marker_GUIDs or #ambition_marker_GUIDs == 0 then
    broadcastToColor("Could not reset ambition markers: marker GUID list is empty.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  local base_slots = {
    [1] = Vector({-0.83, 0.2, -1.07}),
    [2] = Vector({-0.92, 0.2, -1.07}),
    [3] = Vector({-1.00, 0.21, -1.07}),
    [4] = Vector({-0.83, 0.2, -1.07}),
    [5] = Vector({-0.92, 0.2, -1.07}),
    [6] = Vector({-1.00, 0.21, -1.07})
  }

  local first_power_by_index = {
    [1] = { [false] = 5, [true] = 9 },
    [2] = { [false] = 3, [true] = 6 },
    [3] = { [false] = 2, [true] = 4 },
    [4] = { [false] = 10, [true] = 6 },
    [5] = { [false] = 7, [true] = 4 },
    [6] = { [false] = 3, [true] = 5 }
  }

  local staging_positions = {
    Vector({16.28, 1.08, 5.81}),
    Vector({17.61, 1.08, 5.81}),
    Vector({18.94, 1.08, 5.82})
  }

  local function marker_first_power(idx, obj)
    local face = false
    if obj and obj.is_face_down ~= nil then face = obj.is_face_down end
    local by_face = first_power_by_index[idx] or {}
    return by_face[face] or 0
  end

  local function marker_first_power_with_face(idx, face_down)
    local by_face = first_power_by_index[idx] or {}
    return by_face[face_down] or 0
  end

  local marker_entries = {}

  -- Choose which trio to seed based on active player count:
  -- <5 players => first 3 marker GUIDs, >=5 players => last 3 marker GUIDs.
  local active_count = 0
  if type(active_players) == "table" then
    active_count = #active_players
  end
  if active_count == 0 then
    active_count = #getSeatedPlayers()
  end

  local selected = {}
  local want_low = (active_count >= 5) and 4 or 1
  local want_high = (active_count >= 5) and 6 or 3
  -- Only use the selected trio for this player count.
  for i = want_low, want_high do
    local guid = ambition_marker_GUIDs[i]
    local obj = guid and getObjectFromGUID(guid) or nil
    if obj and obj.getPosition then
      -- Return selected marker to its base slot first.
      local slot_local = base_slots[i] or base_slots[1]
      local world = reach_map.positionToWorld(slot_local)
      world.y = world.y + 0.45
      obj.setPositionSmooth(world)
      local entry = { idx = i, guid = guid, obj = obj }
      table.insert(marker_entries, entry)
      table.insert(selected, entry)
    end
  end

  if #selected == 0 then
    broadcastToColor("No selected ambition markers found for this player count.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  -- Flip the lowest-power marker, but only if it is not already flipped.
  local lowest = nil
  for _, entry in ipairs(selected) do
    local is_flipped = (entry.obj and entry.obj.is_face_down == true)
    if not is_flipped then
      local p = marker_first_power(entry.idx, entry.obj)
      if not lowest or p < lowest.power then
        lowest = { entry = entry, power = p }
      end
    end
  end
  local flipped_guid = nil
  if lowest and lowest.entry and lowest.entry.obj and lowest.entry.obj.flip then
    pcall(function() lowest.entry.obj.flip() end)
    flipped_guid = lowest.entry.guid
  end

  -- Re-rank selected trio based on POST-FLIP values (deterministic; doesn't depend on flip timing).
  local projected_power = {}
  for _, entry in ipairs(selected) do
    local face = false
    if entry.obj and entry.obj.is_face_down ~= nil then face = entry.obj.is_face_down end
    if flipped_guid and flipped_guid == entry.guid then
      face = not face
    end
    projected_power[entry.guid] = marker_first_power_with_face(entry.idx, face)
  end

  table.sort(selected, function(a, b)
    local pa = projected_power[a.guid] or 0
    local pb = projected_power[b.guid] or 0
    if pa == pb then
      return a.idx < b.idx
    end
    return pa > pb
  end)

  for i = 1, math.min(3, #selected) do
    local entry = selected[i]
    local target = staging_positions[i]
    if entry and entry.obj and target then
      entry.obj.setPositionSmooth(target)
    end
  end

  -- Also move chapter pawn to the right when resetting ambition markers.
  -- If pawn is high (y > 1.1), use a smaller shift to align with snaps.
  local chapter_pawn = getObjectFromGUID(chapter_pawn_GUID)
  if chapter_pawn and chapter_pawn.getPosition then
    local cp = chapter_pawn.getPosition()
    local chapter_shift = (cp.y and cp.y > 1.1) and 0.83333 or 0.9075
    cp.x = cp.x + chapter_shift
    chapter_pawn.use_snap_points = true
    chapter_pawn.setPositionSmooth(cp, false, true)
  end

  Wait.time(function()
    pcall(function() AmbitionMarkers.refresh_all_ambitions() end)
  end, 0.8)

  broadcastToAll("Ambition markers reset and re-seeded.", {0.6, 1, 0.6})
end

-- Compute ambition gains and move each player's power cube to the right by total gain.
function apply_ambition_scores_to_power_menu(player_color, position, clicked_object)
  score_ambitions_run_id = score_ambitions_run_id + 1
  local run_id = score_ambitions_run_id
  Global.call("update_player_scores")
  local breakdown = Global.getVar("ambition_point_estimates_detailed")
  if not breakdown or not breakdown.totals then
    broadcastToColor("Could not compute ambition scores.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  pcall(function()
    Global.call("print_ambition_estimates")
  end)

  local moved_parts = {}
  local power_step = 0.655
  local power_zero_x = -13.26
  local power_cubes = getObjectsWithTag("power") or {}
  local function power_from_x(x)
    local p = math.floor((x + 13.26) / 0.655)
    if p < 0 then p = 0 end
    return p
  end
  local function x_from_power(power_value)
    -- Small epsilon keeps us inside the intended floor bucket.
    return power_zero_x + (power_value * power_step) + 0.001
  end

  for color, gain in pairs(breakdown.totals) do
    local delta = tonumber(gain) or 0
    if delta ~= 0 then
      local cube = nil
      local color_tag = tostring(color) .. "Piece"
      for _, obj in ipairs(power_cubes) do
        if obj and obj.hasTag and obj.hasTag(color_tag) then
          cube = obj
          break
        end
      end

      if cube and cube.getPosition then
        local pos = cube.getPosition()
        local start_power = power_from_x(pos.x)
        local target_power = start_power + delta
        if target_power < 0 then target_power = 0 end
        pos.x = x_from_power(target_power)
        local end_power = power_from_x(pos.x)
        cube.setPosition(pos)
        table.insert(moved_parts, tostring(color) .. ": " .. tostring(start_power) .. " -> " .. tostring(end_power) .. " (+" .. tostring(delta) .. ")")
      else
        table.insert(moved_parts, tostring(color) .. ": no power cube found")
      end
    end
  end

  if #moved_parts == 0 then
    broadcastToAll("No ambition power gain to apply.", {0.8, 0.8, 0.8})
  else
    -- Recompute displayed scores after moving power cubes.
    -- Run multiple delayed passes to handle slower physics/snap settling.
    local refresh_delays = {0.35, 0.9, 1.8}
    for _, delay in ipairs(refresh_delays) do
      Wait.time(function()
        Global.call("update_player_scores")
      end, delay)
    end

    -- After score updates settle, check win threshold and prompt result submission.
    Wait.time(function()
      if run_id ~= score_ambitions_run_id then
        return
      end

      pcall(function()
        Global.call("update_player_scores")
      end)

      -- Skip win-congrats + submission prompt during campaign games.
      local is_campaign_game = false
      pcall(function()
        local campaign_rules = getObjectFromGUID(Campaign.guids.rules)
        if campaign_rules and campaign_rules.getDescription and campaign_rules.getDescription() == "active" then
          is_campaign_game = true
        end
      end)
      if is_campaign_game then
        return
      end

      local player_count = #active_players
      local win_threshold = 27
      if player_count == 2 then
        win_threshold = 33
      elseif player_count == 3 then
        win_threshold = 30
      end

      local contenders = {}
      for _, p in ipairs(active_players) do
        local score = tonumber(p and p.power) or 0
        if score > win_threshold then
          table.insert(contenders, { color = tostring(p.color or "Player"), score = score })
        end
      end

      if #contenders == 0 then
        return
      end

      local best_score = -999999
      for _, c in ipairs(contenders) do
        if c.score > best_score then
          best_score = c.score
        end
      end

      local tied = {}
      for _, c in ipairs(contenders) do
        if c.score == best_score then
          table.insert(tied, c)
        end
      end

      local winner = tied[1]
      if #tied > 1 then
        local initiative_color = tostring(initiative_player or "")
        if initiative_color ~= "" then
          for _, c in ipairs(tied) do
            if c.color == initiative_color then
              winner = c
              break
            end
          end

          if winner == tied[1] and winner.color ~= initiative_color then
            local tied_by_color = {}
            for _, c in ipairs(tied) do
              tied_by_color[c.color] = c
            end
            local ordered = getOrderedPlayersStartingWith(initiative_color)
            for _, p in ipairs(ordered or {}) do
              local color = tostring(p and p.color or "")
              if tied_by_color[color] then
                winner = tied_by_color[color]
                break
              end
            end
          end
        end
      end

      if winner then
        broadcastToAll("Congrats " .. winner.color .. " - you win with " .. tostring(winner.score) .. " Power!", Color.Green)
      end

      if _G["open_sheets_preview_ui"] then
        pcall(function()
          _G["open_sheets_preview_ui"](player_color, "", "")
        end)
      end

      broadcastToAll("Do you want to submit the game result now? The Sheets window is open.", {0.6, 1, 0.6})
    end, 2.1)
  end
end

-- Attach context menu items to all ambition markers.
function attach_ambition_marker_menus()
    if not ambition_marker_GUIDs or #ambition_marker_GUIDs == 0 then
        print("[DEBUG] attach_ambition_marker_menus: ambition_marker_GUIDs is empty or nil")
        return
    end
    
    local function try_attach(attempt)
        attempt = attempt or 1
        local attached_count = 0
        local markers_found = 0
        
        for i = 1, #ambition_marker_GUIDs do
            local guid = ambition_marker_GUIDs[i]
            local marker = getObjectFromGUID(guid)
            if marker then
                markers_found = markers_found + 1
                local ok, err = pcall(function()
                    marker.addContextMenuItem("Show Ambition Scores", show_ambition_scores_menu)
                marker.addContextMenuItem("Score Ambitions", apply_ambition_scores_to_power_menu)
                marker.addContextMenuItem("Reset Markers", reset_ambition_markers_menu)
                end)
                if ok then
                    attached_count = attached_count + 1
                else
                    print("[DEBUG] Failed to attach menu to marker " .. guid .. ": " .. tostring(err))
                end
            end
        end
        
        -- Also attach to chapter pawn
        local chapter_pawn = getObjectFromGUID(chapter_pawn_GUID)
        if chapter_pawn then
            markers_found = markers_found + 1
            local ok, err = pcall(function()
                chapter_pawn.addContextMenuItem("Show Ambition Scores", show_ambition_scores_menu)
          chapter_pawn.addContextMenuItem("Score Ambitions", apply_ambition_scores_to_power_menu)
          chapter_pawn.addContextMenuItem("Reset Markers", reset_ambition_markers_menu)
            end)
            if ok then
                attached_count = attached_count + 1
            else
                print("[DEBUG] Failed to attach menu to chapter pawn: " .. tostring(err))
            end
        end
        
        LOG.DEBUG("attempt " .. attempt .. "] Found " .. markers_found .. " objects, attached to " .. attached_count)
        
        -- If we didn't find all markers, retry in a moment
        if markers_found < (#ambition_marker_GUIDs + 1) and attempt < 5 then
            Wait.time(function()
                try_attach(attempt + 1)
            end, 0.5)
        end
    end
    
    try_attach(1)
end


function onObjectDrop(player_color, object) -- this is being called from orig later to fix other edifice tokens spawn
    DropActionEvents.handle_object_drop(player_color, object)
end

function onPlayerAction(player, action, targets)
    DropActionEvents.handle_player_action(player, action, targets, onObjectDrop)
end

function onObjectEnterScriptingZone(zone, object)
  if not zone or not object then return end

  -- Only care about decks entering the action deck zone
  if zone.getGUID and zone.getGUID() == action_deck_zone_GUID then
    local is_deck = false
    if object.tag and object.tag == "Deck" then is_deck = true end
    if object.getName and object.getName() == "Deck" then is_deck = true end
    if object.name == "Deck" then is_deck = true end
    if not is_deck then return end
    local guid = nil
    if object.getGUID then guid = object.getGUID() end
    if not guid and object.guid then guid = object.guid end
    if not guid then return end
    if draw_bottom_patched[guid] then return end
    pcall(function()
      object.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
    end)
    draw_bottom_patched[guid] = true
    LOG.DEBUG("Attached Draw-bottom to deck " .. guid)
  end
end

function onPlayerTurn(player, previous_player)

    turn_count = turn_count + 1
    if is_auto_end_round_enabled then
        if turn_count > #getSeatedPlayers() then
            RoundManager.endRound() -- turn count is reset within RoundManager.endRound()
        end
    end
  -- If overlay sending is enabled, push an update each time the turn advances
  if overlay_sending_enabled then
    if _G["send_overlay_update_ui"] then
      pcall(function() _G["send_overlay_update_ui"]() end)
    end
  end

end

local function is_overlay_hand_card(obj)
  if not obj then return false end
  local tag = obj.tag or obj.type
  return tag == "Card" or tag == "Deck"
end

function onObjectEnterZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    if ((object.getGUID() == initiative_GUID or object.getGUID() ==
        seized_initiative_GUID) and zone_name == "initiative_zone") then
        local zone_color = zone.getDescription()
        Global.setVar("initiative_player", zone_color)
    end

    if zone_name == "hand" and overlay_sending_enabled and is_overlay_hand_card(object) then
      if _G["send_overlay_update_ui"] then
        _G["send_overlay_update_ui"]()
      end
    end
end

function onObjectSpawn(object)
    Initiative.add_menu()
    Supplies.addMenuToObject(object)
  ErrataFaqService.add_menu_to_card(object)
  -- If the zero marker spawns (or finishes loading), ensure its ambition button is attached
  local ok, guid = pcall(function() return object.getGUID and object.getGUID() end)
  if ok and guid and guid == zero_marker_GUID then
    pcall(function() AmbitionMarkers.add_button() end)
  end
end

function onObjectLeaveZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    -- create a unique wait ID
    local wait_id = zone.getGUID() .. object.getGUID()

    -- check for and remove the Wait.condition if it exists
    if zoneWaits[wait_id] then
        Wait.stop(zoneWaits[wait_id])
    end

    if zone_name == "hand" and overlay_sending_enabled and is_overlay_hand_card(object) then
      if _G["send_overlay_update_ui"] then
        _G["send_overlay_update_ui"]()
      end
    end
end

function onObjectEnterContainer(container, object)
    Counters.update(container)
end

function onObjectLeaveContainer(container, leave_object)
    Counters.update(container)
    local container_tags = container.getTags()
    if #container_tags > 0 then
        if container.type == "Bag" or container.type == "Infinite" then
            leave_object.setTags(container.getTags())

            -- set snap
            leave_object.use_snap_points = true

            -- ships pulled from supply should always be fresh
            Wait.time(function()
                if leave_object.hasTag('Ship') and leave_object.getStateId() == 2 then
                    leave_object.setState(1)
                end
            end, 0.1)
        end
    end
end

function onObjectNumberTyped(number_object, player_color, number_typed)
    if number_object.type == "Deck" then
        print(player_color .. " tried to deal a card to themselves from top of deck, which is unusual, please do it manually")
        return true
    end

    if number_object.hasTag("Action") then
        if number_typed == 1 then
            local player_pieces = {
                ["White"] = {
                    hand_zone = "c832bf"
                },
                ["Yellow"] = {
                    hand_zone = "856b9d"
                },
                ["Teal"] = {
                    hand_zone = "c9dd8d"
                },
                ["Red"] = {
                    hand_zone = "54730a"
                },
                ["Pink"] = {
                    hand_zone = "965437"
                }
            }
            local hand_zone_guid = player_pieces[player_color].hand_zone
            local hand_zone = getObjectFromGUID(hand_zone_guid)
            local hand_pos = hand_zone.getPosition()

            local card_rotation = number_object.getRotation()
            number_object.setPositionSmooth(hand_pos, false, false)
            Wait.time(function()
                number_object.setRotation({0, 180, card_rotation[3]})
            end, 0.25)
            -- we set a slight delay on turning the card face up in hand
            -- this avoids revealing the card when it passes through the played zone
            Wait.time(function()
                number_object.setRotation({0, 180, 0})
            end, 0.75)

        elseif number_typed >= 2 then
            print(player_color .. ", you're only allowed to pull 1 card at a time to yourself, use key 1 only")
        end
        return true
    end
end

function tryObjectEnterContainer(container, object)
  -- Only block objects from entering if the container is a locked Bag/Infinite.
  -- Otherwise allow entry. This prevents unrelated stacking restrictions
  -- from interfering with normal table interactions.

  if not container then return false end

  local ctype = container.type
  if not ctype then
    return true
  end

  -- Only enforce for Bags/Infinite containers
  if ctype ~= "Bag" and ctype ~= "Infinite" then
    return true
  end

  -- If bag is unlocked, allow entry
  local locked = false
  if container.getLock then
    local ok, res = pcall(function() return container.getLock() end)
    if ok and res then locked = true end
  end
  if not locked then return true end

  -- For locked bags, require at least one matching tag (preserve original behavior)
  -- First, enforce supply-bag color matching for ships/agents/starports.
  -- If the container GUID matches any player supply bag, only allow objects
  -- whose name contains that color (e.g., 'White Agent', 'Red Ship').
  local ok_guid, cguid = pcall(function() return container.getGUID and container.getGUID() or container.guid end)
    if ok_guid and cguid then
      -- If this is the imperial ships supply, only allow Imperial Ship objects
      if cguid == imperial_ships_GUID then
        local ok_name, name = pcall(function() return object.getName and object.getName() end)
        if not ok_name or not name then
          return false
        end
        local name_lower = string.lower(tostring(name))
        if string.find(name_lower, "imperial ship") then
          return true
        else
          return false
        end
      end

      for color, tbl in pairs(player_pieces_GUIDs) do
      -- check keys that represent supply bags
      local bag_keys = {"agents", "mini_agents", "ships", "mini_ships", "starports"}
      -- map bag key to allowed object type
      local allowed_type_for_key = {
        agents = "agent",
        mini_agents = "agent",
        ships = "ship",
        mini_ships = "ship",
        starports = "starport",
      }
      for _, key in ipairs(bag_keys) do
        local bag_guid = tbl[key]
        if bag_guid and bag_guid == cguid then
          -- enforce color and type match based on object name
          local ok_name, name = pcall(function() return object.getName and object.getName() end)
          if not ok_name or not name then
            return false
          end
          local name_lower = string.lower(tostring(name))
          local color_lower = string.lower(color)
          -- color must match
          if not string.find(name_lower, color_lower) then
            return false
          end
          -- determine object type from name
          local obj_type = nil
          if string.find(name_lower, "ship") then obj_type = "ship" end
          if string.find(name_lower, "agent") then obj_type = "agent" end
          if string.find(name_lower, "starport") then obj_type = "starport" end
          -- disallow placing when type doesn't match bag purpose
          local allowed = allowed_type_for_key[key]
          if allowed then
            if obj_type == allowed then
              return true
            else
              return false
            end
          end
          -- if no specific allowed type, fall back to color-only match
          return true
        end
      end
    end
  end

  -- Fallback: For other locked bags, require at least one matching tag (preserve original behavior)
  for _, tag in ipairs(container.getTags()) do
    if tag == "TealPiece" or tag == "YellowPiece" or tag == "RedPiece" or tag ==
      "WhitePiece" or tag == "lock" then
      goto continue
    end

    if object.hasTag and object.hasTag(tag) then
      return true
    end
    ::continue::
  end

  return false

  --[[ Original implementation (commented out per request):
  -- allow objects with at least one shared container tag to enter, with exceptions
  for _, tag in ipairs(container.getTags()) do
    if tag == "TealPiece" or tag == "YellowPiece" or tag == "RedPiece" or tag ==
      "WhitePiece" or tag == "lock" then
      goto continue
    end
            
    if object.hasTag(tag) then
      return true
    end
    ::continue::
  end

  return false -- stop card deck stop stacking function or bag stop
  ]]--
end

----------------------------------------------------
-- returns a table of colors in order
function getOrderedPlayers(silent)
  local seated_players = getSeatedPlayers()
    if (debug and #seated_players == 1) then
        broadcastToAll("\nDebugging enabled for " .. debug_player_count ..
                           " players.")
        if (debug_player_count > 3) then
          seated_players = {"White", "Yellow", "Teal", "Red", "Pink"}
        else
          local all_colors = {"White", "Yellow", "Teal", "Red", "Pink"}
            -- remove seated players from all_colors
            for _, seated in ipairs(seated_players) do
                for i, all in ipairs(all_colors) do
                    if (seated == all) then
                        table.remove(all_colors, i)
                    end
                end
            end
            -- insert random color in seated_players
            for i = 1, debug_player_count - 1, 1 do
                local rng = math.random(#all_colors)
                local random_color = all_colors[rng]
                table.insert(seated_players, random_color)
                table.remove(all_colors, rng)
            end
        end
    end

    local player_count = #seated_players
    if (player_count > 5 or player_count < 2) then
      if not silent then
        msg = "This multiplayer game will only start with 2-5 players. " ..
          "\nTo explore the mod solo, return to main menu, create the game as 'hotseat', " ..
          "load the mod from the Games menu, then pick player colors last."
        broadcastToAll(msg, {
            r = 1,
            g = 0,
            b = 0
        })
      end
      return {""}
    end

    local clockwise_order = {"White", "Pink", "Yellow", "Teal", "Red"}
    local ordered_players = {}
    local start_index = math.random(player_count)

    for i = 1, #clockwise_order do
        local color = clockwise_order[(start_index + i - 2) % #clockwise_order +
                          1]
        for _, seated_color in ipairs(seated_players) do
            if color == seated_color then
                table.insert(ordered_players, ArcsPlayer:new{
                    color = color
                })
                break
            end
        end
    end

   -- broadcastToAll("Randomly choosing first player...", Color.Purple)

    return ordered_players
end


  -- Returns ordered players but rotated so that `start` is first.
  -- `start` may be a color string (e.g., "Red") or a 1-based index.
  function getOrderedPlayersStartingWith(start)
    local ordered = getOrderedPlayers()
    if not start or #ordered == 0 then return ordered end

    local start_index = nil
    if type(start) == "string" then
      for i, p in ipairs(ordered) do
        if p.color == start then start_index = i; break end
      end
    elseif type(start) == "number" then
      if start >= 1 and start <= #ordered then start_index = start end
    end

    if not start_index then return ordered end

    local rotated = {}
    for j = start_index, #ordered do table.insert(rotated, ordered[j]) end
    for j = 1, start_index - 1 do table.insert(rotated, ordered[j]) end
    return rotated
  end


----------------------------------------------------

starting_locations = {
    [frontiers_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "a"
            },
            B = {
                cluster = 5,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 4,
                system = "a"
            }
        }
    },
    [homelands_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 5,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 2,
                system = "a"
            }
        }
    },
    [mix_up_1_2P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "a"
            }
        },
        [2] = {
            A = {
                cluster = 6,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            },
            D = {
                cluster = 1,
                system = "b"
            }
        }
    },
    [mix_up_2_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "b"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        }
    },
    [homelands_3P_GUID] = {
        [1] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [frontiers_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        }
    },
    [core_conflict_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_3P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [frontiers_4P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_1_4P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 4,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 6,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_2_4P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_3_4P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    -- 5P starting locations
    [frontiers_5P_GUID] = {
      [1] = {
        A = {cluster = 1, system = "c"},
        B = {cluster = 3, system = "b"}, 
        C = {cluster = 2, system = "gate"}
      },
      [2] = {
        A = { cluster = 2, system = "c" },
        B = { cluster = 6, system = "c" },
        C = { cluster = 3, system = "gate" }
      },
      [3] = {
        A = { cluster = 4, system = "b" },
        B = { cluster = 2, system = "a" },
        C = { cluster = 6, system = "gate" }
      },
      [4] = {
        A = { cluster = 1, system = "a" },
        B = { cluster = 6, system = "a" },
        C = { cluster = 4, system = "gate" }
      },
      [5] = {
        A = { cluster = 5, system = "c" },
        B = { cluster = 4, system = "c" },
        C = { cluster = 1, system = "gate" }
      }
    },
    [empires_5P_GUID] = {
      [1] = {
        A = { cluster = 1, system = "c" },
        B = { cluster = 1, system = "b" },
        C = { cluster = 6, system = "gate" }
      },
      [2] = {
        A = { cluster = 2, system = "c" },
        B = { cluster = 2, system = "b" },
        C = { cluster = 6, system = "gate" }
      },
      [3] = {
        A = { cluster = 3, system = "c" },
        B = { cluster = 3, system = "b" },
        C = { cluster = 6, system = "gate" }
      },
      [4] = {
        A = { cluster = 4, system = "a" },
        B = { cluster = 4, system = "c" },
        C = { cluster = 6, system = "gate" }
      },
      [5] = {
        A = { cluster = 5, system = "b" },
        B = { cluster = 5, system = "a" },
        C = { cluster = 6, system = "gate" }
      }
    },
    [mix_up_1_5P_GUID] = {
      [1] = {
        A = { cluster = 6, system = "c" },
        B = { cluster = 4, system = "a" },
        C = { cluster = 1, system = "gate" }
      },
      [2] = {
        A = { cluster = 4, system = "c" },
        B = { cluster = 5, system = "c" },
        C = { cluster = 3, system = "gate" }
      },
      [3] = {
        A = { cluster = 5, system = "a" },
        B = { cluster = 3, system = "c" },
        C = { cluster = 4, system = "gate" }
      },
      [4] = {
        A = { cluster = 6, system = "a" },
        B = { cluster = 1, system = "a" },
        C = { cluster = 5, system = "gate" }
      },
      [5] = {
        A = { cluster = 1, system = "c" },
        B = { cluster = 3, system = "b" },
        C = { cluster = 6, system = "gate" }
      }
    },
    [mix_up_2_5P_GUID] = {
      [1] = {
        A = { cluster = 5, system = "c" },
        B = { cluster = 3, system = "a" },
        C = { cluster = 1, system = "gate" }
      },
      [2] = {
        A = { cluster = 3, system = "c" },
        B = { cluster = 5, system = "b" },
        C = { cluster = 2, system = "gate" }
      },
      [3] = {
        A = { cluster = 4, system = "c" },
        B = { cluster = 1, system = "c" },
        C = { cluster = 3, system = "gate" }
      },
      [4] = {
        A = { cluster = 1, system = "a" },
        B = { cluster = 2, system = "a" },
        C = { cluster = 5, system = "gate" }
      },
      [5] = {
        A = { cluster = 2, system = "b" },
        B = { cluster = 6, system = "b" },
        C = { cluster = 4, system = "gate" }
      }
    },
    [extension_5P_GUID] = {
      [1] = {
        A = { cluster = 2, system = "c" },
        B = { cluster = 3, system = "b" },
        C = { cluster = 2, system = "gate" }
      },
      [2] = {
        A = { cluster = 1, system = "c" },
        B = { cluster = 2, system = "a" },
        C = { cluster = 1, system = "gate" }
      },
      [3] = {
        A = { cluster = 3, system = "c" },
        B = { cluster = 5, system = "a" },
        C = { cluster = 3, system = "gate" }
      },
      [4] = {
        A = { cluster = 5, system = "c" },
        B = { cluster = 6, system = "c" },
        C = { cluster = 5, system = "gate" }
      },
      [5] = {
        A = { cluster = 6, system = "b" },
        B = { cluster = 1, system = "b" },
        C = { cluster = 6, system = "gate" }
      }
    }
}
  
starting_pieces = {
    Default = {
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        }
    },
    ["bcc792"] = { -- Elder
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "material"}
    },
    ["a7e9eb"] = { -- Fuel-Drinker
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "fuel"}
    },
    ["8109e1"] = { -- Upstart
        A = {
            building = "city",
            ships = 4
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "material"}
    },
    ["aa0e68"] = { -- Mystic
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "relic"}
    },
    ["c37bb3"] = { -- Demagogue
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "weapon"}
    },
    ["996b9d"] = { -- Feastbringer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["da8b99"] = { -- Rebel
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"material", "weapon"}
    },
    ["639b42"] = { -- Warrior
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"weapon", "material"}
    },
    ["1848eb"] = { -- Noble
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "psionic"}
    },
    ["2a5b6f"] = { -- Archivist
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "relic"}
    },
    ["942aaa"] = { -- Quartermaster
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["4363db"] = { -- Agitator
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    },
    ["003bc2"] = { -- Anarchist
        A = {
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "weapon"}
    },
    ["843e46"] = { -- Shaper
        A = {
            building = "city",
            ships = 3
        },
        B = {
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["a1b65d"] = { -- Corsair
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["2409c0"] = { -- Overseer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    }
}

-- params = {obj, is_visible}
function move_and_lock_object(params)
    local y_pos = params.is_visible and 1 or -2
    local pos = params.obj.getPosition()
    pos.y = y_pos
    params.obj.setPosition(pos)
    if (params.obj.hasTag("Lock")) then
        params.obj.locked = true
    else
        params.obj.locked = not params.is_visible
    end
    -- Ensure the lost-vaults rules object remains locked when it is made visible
    pcall(function()
      local obj_guid = nil
      if params.obj.getGUID then obj_guid = params.obj.getGUID() elseif params.obj.guid then obj_guid = params.obj.guid end
      if obj_guid and lost_vaults_rules_GUID and obj_guid == lost_vaults_rules_GUID and params.is_visible then
        params.obj.locked = true
      end
    end)
end

function set_active_players(players)
    active_players = players
end

function save_game_starting_players()
  starting_players = {}
  if type(active_players) ~= "table" then
    Global.setVar("starting_players", starting_players)
    return
  end

  for _, player in ipairs(active_players) do
    table.insert(starting_players, player)
  end

  Global.setVar("starting_players", starting_players)
  
  -- Cache player steam names at the point of setup
  cache_player_steam_names()
end

function setup_custom_game()

    BaseGame.destroy_grey_setup_menu_objects()

    -- Build active_players from seated players if present; otherwise use all five.
    active_players = {}
    local seated = getSeatedPlayers()
    if seated and #seated > 0 then
      for _, color in ipairs(seated) do
        table.insert(active_players, ArcsPlayer:new{ color = color })
      end
    else
      for _, v in ipairs({"Red", "White", "Yellow", "Teal", "Pink"}) do
        table.insert(active_players, ArcsPlayer:new{ color = v })
      end
    end
    
    -- Cache player steam names early so they survive if players leave
    cache_player_steam_names()
    
    local active_player_colors = {}
    for _, v in ipairs(active_players) do
      table.insert(active_player_colors, v.color)
      ArcsPlayer.components_visibility(v.color, true, true)
    end

    with_miniatures = Global.getVar("with_miniatures")
    BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)

    local player_count = #active_players
    local p = {
      is_campaign = true,
      is_4p = (player_count >= 4),
      leaders_and_lore = true,
      leaders_and_lore_expansion = true,
      with_faceup_discard = true,
      with_miniatures = with_miniatures,
      players = active_player_colors
    }
    set_game_in_progress(p)

    BaseGame.base_exclusive_components_visibility(true)
    BaseGame.setupOutOfPlayForCustom()
    if player_count >= 5 then -- also happens for 4? -- fix this?
      BaseGame.adjust_action_deck_for_5p()
    end

    -- Ensure initiative is initialized for custom setups: scan each player's initiative zone
    pcall(function()
      local initiative_guids = { initiative_GUID, seized_initiative_GUID }
      for _, p in ipairs(active_players) do
        local color = p.color
        local zone_guid = nil
        -- try player_pieces_GUIDs table first (works for custom setups)
        if player_pieces_GUIDs and player_pieces_GUIDs[color] and player_pieces_GUIDs[color].initiative_zone then
          zone_guid = player_pieces_GUIDs[color].initiative_zone
        end
        -- fallback: try arcs player's components if present
        if not zone_guid and p.components and p.components.initiative_zone then zone_guid = p.components.initiative_zone end
        if zone_guid then
          local zone = getObjectFromGUID(zone_guid)
          if zone and type(zone.getObjects) == "function" then
            local ok, objs = pcall(function() return zone.getObjects() end)
            if ok and objs then
              for _, obj in ipairs(objs) do
                local guid = nil
                pcall(function() if obj.getGUID then guid = obj.getGUID() end end)
                if not guid and obj.guid then guid = obj.guid end
                if guid then
                  for _, target in ipairs(initiative_guids) do
                    if tostring(guid) == tostring(target) then
                      initiative_player = color
                      Global.setVar("initiative_player", initiative_player)
                      broadcastToAll("Initiative initialized to " .. tostring(color) .. " (custom setup)", {0.2,0.8,0.2})
                      return
                    end
                  end
                end
              end
            end
          end
        end
      end
    end)

    -- Attach context menus to ambition markers for new custom game setups
    pcall(function() attach_ambition_marker_menus() end)
end

----------------------------------------------------
-- params = {
--     is_campaign = false,
--     is_4p = #active_players == 4,
--     leaders_and_lore = with_leaders,
--     leaders_and_lore_expansion = with_ll_expansion,
--     faceup_discard = ActionCards.is_face_up_discard_active(),
--     players = active_players
-- }
function set_game_in_progress(params)
    Counters.setup()
    local reach_board = getObjectFromGUID(reach_board_GUID)
    reach_board.setDescription("in progress")

    local visibility = {"Red", "White", "Yellow", "Teal", "Black", "Pink", "Grey"}

    if (params.with_faceup_discard) then
        ActionCards.faceup_discard_visibility(true)
        local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
        fud_marker.setDescription("active")
    end

    BaseGame.core_components_visibility(true)
    if (params.is_campaign) then
        local campaign_rules = getObjectFromGUID(Campaign.guids.rules)
        campaign_rules.setDescription("active")

        Campaign.components_visibility(true)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    else
        BaseGame.base_exclusive_components_visibility(true)
    end
    if (params.is_4p or player_count) then
        BaseGame.four_player_cards_visibility(true)
    end
    if (params.leaders_and_lore) then
        BaseGame.leaders_visibility(true, params.leaders_and_lore_expansion)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    end

    -- player components visibility
    for _, color in ipairs(params.players) do
        ArcsPlayer.components_visibility(color, true, params.is_campaign)
        local player_board = getObjectFromGUID(
            player_pieces_GUIDs[color].player_board)
        player_board.setDescription("active")
    end
    -- for _, v in ipairs(getOrderedPlayers()) do
    --     ArcsPlayer.components_visibility(v.color, true, params.is_campaign)
    --     local player_board = getObjectFromGUID(v.components.board)
    --     player_board.setDescription("active")
    -- end
end

function onLoad(script_state)
  overlay_sending_enabled = false
  overlay_cards_hidden = false
  overlay_align = "left"
  pcall(function()
    if _G["clear_overlay_ui"] then
      _G["clear_overlay_ui"]()
    end
  end)

  -- Restore persistent state saved by onSave (if present)
  local loaded_state = nil
  if script_state and script_state ~= "" then
    local ok, state = pcall(function()
      return JSON.decode(script_state)
    end)
    if ok and state then
      -- Don't immediately overwrite `game_id` here: onLoad can be invoked
      -- during a script reload as well as when loading a saved game. We'll
      -- apply the saved `game_id` only if the table is actually loading a
      -- game in-progress (detected below by the reach board description).
      loaded_state = state
      if state.initiative then
        initiative_player = state.initiative.player or initiative_player
        initiative_player_position = state.initiative.position or initiative_player_position
      end
      if state.settings then
        is_face_up_discard_active = state.settings.is_face_up_discard_active or is_face_up_discard_active
        is_basegame_setup = state.settings.is_basegame_setup or is_basegame_setup
       end
       if state.player_steam_name_cache then
         player_steam_name_cache = state.player_steam_name_cache
         Global.setVar("player_steam_name_cache", player_steam_name_cache)
      end
    end
  end
  -- Generate a new game ID if not already present
  if not game_id or game_id == "" then
    game_id = generate_game_id()
    LOG.INFO("Game ID: " .. game_id, {0.8, 0.8, 0.2})
  end
  -- Store initial game_id in Global so other modules can access it.
  -- If we later detect we're loading a saved 'in progress' game, we'll
  -- override this with the saved ID below.
  Global.setVar("game_id", game_id)
    -- create a blank table to store the Wait.conditions in
    zoneWaits = {}

    -- Hide/disable helper snaps object at startup.
    pcall(function() BaseGame.hide_and_disable_5p_snaps() end)

    Initiative.add_menu()

    -- Reattach supply/context menus for all existing objects after load
    Supplies.addMenuToAllObjects()
    -- Recreate visible counters (numbers) on supply containers and similar
    Counters.setup()

    -- Ensure zero marker ambition button exists at startup
    pcall(function() AmbitionMarkers.add_button() end)

    -- Attach context menus to ambition markers and chapter pawn (always available)
    pcall(function() attach_ambition_marker_menus() end)

    -- start periodic scan to ensure Draw-bottom is attached to any new decks
    schedule_scan()

    local reach_board = getObjectFromGUID(reach_board_GUID)
    if (reach_board.getDescription() == "in progress") then
        -- If we have a saved state and it contains a game_id, use it now.
        if loaded_state and loaded_state.game_id then
          game_id = loaded_state.game_id
          LOG.INFO("Restored Game ID: " .. game_id, {0.2, 0.8, 0.8})
          Global.setVar("game_id", game_id)
        end
        broadcastToAll("Loading game in progress")
        active_players = {}
        local loaded_colors = nil
        if loaded_state and type(loaded_state.active_player_colors) == "table" and #loaded_state.active_player_colors > 0 then
          loaded_colors = loaded_state.active_player_colors
        end

        if loaded_colors then
          for _, v in ipairs(loaded_colors) do
            if v and v ~= "" then
              local arcs_player = ArcsPlayer:new{ color = v }
              table.insert(active_players, arcs_player)
            end
          end
        else
          for _, v in ipairs({"Red", "White", "Yellow", "Teal", "Pink"}) do
            local player_board = getObjectFromGUID(
                player_pieces_GUIDs[v].player_board)
            if player_board and (player_board.getDescription() == "active") then
                local arcs_player = ArcsPlayer:new{
                    color = v
                }
                table.insert(active_players, arcs_player)
            end
          end
        end

        -- Rebuild starting_players from restored active players so external modules
        -- keep a stable roster even if players disconnect.
        starting_players = {}
        for _, p in ipairs(active_players) do
          table.insert(starting_players, p)
        end
        Global.setVar("starting_players", starting_players)
              -- Update cache with currently seated players (preserves saved names as fallback)
              local seated = getSeatedPlayers()
              if seated and #seated > 0 then
                for _, color in ipairs(seated) do
                  local ok, player = pcall(function() return Player[color] end)
                  if ok and player and player.steam_name and player.steam_name ~= "" then
                    player_steam_name_cache[color] = player.steam_name
                    Global.setVar("player_steam_name_cache", player_steam_name_cache)
                  end
                end
              end

        -- Ensure player boards for colors not active remain hidden
        local all_colors = {"Red", "White", "Yellow", "Teal", "Pink"}
        for _, col in ipairs(all_colors) do
          local pb = getObjectFromGUID(player_pieces_GUIDs[col].player_board)
          if pb then
            if pb.getDescription() == "active" then
              ArcsPlayer.components_visibility(col, true, false)
            else
              ArcsPlayer.components_visibility(col, false, false)
            end
          end
        end

        -- Ensure 4p action cards visibility matches active player count
        local player_count = #active_players
        if player_count >= 4 then
          BaseGame.four_player_cards_visibility(true)
        else
          BaseGame.four_player_cards_visibility(false)
        end

        -- Safe reattachment of various UI helpers and object onload handlers
        local setup_obj = getObjectFromGUID(SetupControl.setup_control_guid)
        if setup_obj then pcall(function() setup_obj.call("onload") end) end

        local ctrl_obj = getObjectFromGUID(Global.getVar("control_GUID"))
        if ctrl_obj then pcall(function() ctrl_obj.call("onload") end) end

        pcall(function() AmbitionMarkers.add_button() end)
        pcall(function() LawBook.setup() end)

        -- for _, tag in ipairs({"DiceCounter", "DiceBoard"}) do
        --   for _, o in pairs(getObjectsWithTag(tag)) do
        --     pcall(function() o.call("onload") end)
        --     pcall(function() o.call("onLoad") end)
        --   end
        -- end

    elseif debug then
        Campaign.components_visibility(true)
        BaseGame.components_visibility({
            is_visible = true,
            is_campaign = true,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true,
            with_faceup_discard = true
        })
    else
        -- Hide components
        Campaign.components_visibility(false)
        BaseGame.components_visibility({
            is_visible = false,
            is_campaign = false,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true -- ,
            -- faceup_discard = true
        })

        for _, v in pairs(available_colors) do
            ArcsPlayer.components_visibility(v, false, false)
        end
    end

    local action_deck = ActionCards.get_action_deck()
    if action_deck then
      action_deck.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
    else
      LOG.WARNING("Global.onload: action deck not found; skipping Draw bottom card menu")
    end
    ErrataFaqService.proactive_fetch(LOG.INFO, LOG.WARNING)
    Wait.time(function()
      ErrataFaqService.scan_cards_for_menu()
    end, 2)

    for _, obj in pairs(getObjectsWithTag("Noninteractable")) do
        obj.locked = true
        obj.interactable = false
    end

    if (not debug) then
        local face_up_discard_action_deck = getObjectFromGUID(
            face_up_discard_action_deck_GUID)
        face_up_discard_action_deck.setInvisibleTo({
            "Red", "White", "Yellow", "Pink", "Teal", "Black", "Grey"
        })
        face_up_discard_action_deck.interactable = false
        face_up_discard_action_deck.locked = false -- set this to false otherwise it breaks
    end

    -- Initialize turn system
    Turns.enable = true
    Turns.pass_turns = true

    -- Initialize timer system
    resetTimer() -- Reset all player timers
    loadCameraTimerMenu(false) -- Load the UI with menu closed initially
end

  function onSave()
    local active_player_colors = {}
    for _, p in ipairs(active_players or {}) do
      if p and p.color and p.color ~= "" then
        table.insert(active_player_colors, p.color)
      end
    end

    local state = {
      game_id = game_id,
      initiative = {
        player = initiative_player,
        position = initiative_player_position
      },
      settings = {
        is_face_up_discard_active = is_face_up_discard_active,
        is_basegame_setup = is_basegame_setup
       },
       player_steam_name_cache = player_steam_name_cache or {},
       active_player_colors = active_player_colors
    }
    return JSON.encode(state)
  end


-- Generated by tools/yml_to_lua.py from leaders.yml
require("assets/leaders_starting_pieces")
--manually put in here:
require("assets/leaders_pnp2_starting")

--lost vaults markers

-- When a card is flipped face-up or dropped face-up on the table, check the
-- Lost Vaults marker bag and move a matching marker (by name) to the card's
-- position if one exists in the bag. Exposed on _G so other scripts can call it.
-- _G.place_lost_vaults_marker_for_card = function(card)
--     if not card or not card.getName or not card.getPosition then return end
--     local ok, name = pcall(function() return card.getName() end)
--     if not ok or not name or name == "" then return end

--     -- Check whether the card is face-down; be tolerant of API shapes.
--     local is_down = nil
--     pcall(function() is_down = card.is_face_down end)
--     if is_down == nil then pcall(function() is_down = card.is_face_down() end) end
--     if is_down == true then return end

--     local okpos, pos = pcall(function() return card.getPosition() end)
--     if not okpos or not pos then return end

--     local bag_guid = Global.getVar("lost_vaults_marker_bag_GUID") or "7f3e2f"
--     local bag = getObjectFromGUID(bag_guid)
--     if not bag or not bag.getObjects then return end

--     local contents = bag.getObjects()
--     for _, item in ipairs(contents) do
--         if item and item.name and item.name == name then
--             pcall(function()
--                 if bag.takeObject then
--                   -- compute how many existing markers with this name are near the target
--                   local existing = 0
--                   local all_objs = getAllObjects()
--                   for _, o in ipairs(all_objs) do
--                     local okn, oname = pcall(function() return (o.getName and o.getName()) or o.name end)
--                     if okn and oname and oname == name then
--                       local okp, opos = pcall(function() return o.getPosition() end)
--                       if okp and opos then
--                         local dx = opos.x - pos.x
--                         local dz = opos.z - pos.z
--                         if (dx * dx + dz * dz) < 0.5 then existing = existing + 1 end
--                       end
--                     end
--                   end
--                   local place_x = pos.x + (existing * 0.4)
--                   local place_z = pos.z + (existing * 0.2)
--                   bag.takeObject({
--                     guid = item.guid,
--                     position = {place_x, pos.y + 0.5, place_z},
--                     callback_function = function(taken)
--                       Wait.frames(function()
--                         if taken then
--                           pcall(function()
--                             if taken.setRotation then taken.setRotation({0, 180, 0}) end
--                           end)
--                           if taken.setPositionSmooth then
--                             taken.setPositionSmooth({place_x, pos.y + 0.5, place_z})
--                           elseif taken.setPosition then
--                             taken.setPosition({place_x, pos.y + 0.5, place_z})
--                           end
--                         end
--                       end, 1)
--                     end
--                   })
--                 end
--             end)
--             break
--         end
--     end
-- end


-- Chain custom logic with any existing handlers for onObjectDrop/onObjectFlip
local orig_onObjectDrop = onObjectDrop
local orig_onObjectFlip = onObjectFlip

function onObjectDrop(player_color, obj)
  if orig_onObjectDrop and orig_onObjectDrop ~= onObjectDrop then
    pcall(function() orig_onObjectDrop(player_color, obj) end)
  end
  -- pcall(function() _G.place_lost_vaults_marker_for_card(obj) end)
  -- pcall(function() _G.place_veil_on_loom(obj) end)
end

function onObjectFlip(player_color, obj)
  if orig_onObjectFlip and orig_onObjectFlip ~= onObjectFlip then
    pcall(function() orig_onObjectFlip(player_color, obj) end)
  end
  -- pcall(function() _G.place_lost_vaults_marker_for_card(obj) end)
  -- pcall(function() _G.place_veil_on_loom(obj) end)
end

-- If a card named "The Loom" is placed face-up, find up to 4 cards named
-- "Veil" (on-table or inside bags) and move them onto the Loom card.
-- _G.place_veil_on_loom = function(loom_card)
--   if not loom_card or not loom_card.getName or not loom_card.getPosition then return end
--   local ok, name = pcall(function() return loom_card.getName() end)
--   if not ok or not name or name ~= "The Loom" then return end

--   -- Check if veils have already been placed on this Loom card
--   local already_placed = false
--   pcall(function() already_placed = loom_card.getVar("veils_placed_on_loom") or false end)
--   if already_placed then return end

--   local okpos, pos = pcall(function() return loom_card.getPosition() end)
--   if not okpos or not pos then return end

--   -- Mark immediately that we're processing this Loom card to prevent duplicate runs
--   pcall(function() loom_card.setVar("veils_placed_on_loom", true) end)

--   local candidates = {}
--   local all = getAllObjects()
--   for _, o in ipairs(all) do
--     if o then
--       -- on-table Veil cards
--       local okn, nm = pcall(function() return o.getName and o.getName() or o.name end)
--       if okn and nm == "Veil" then
--         table.insert(candidates, {type = "table", obj = o})
--       end
--       -- bags: inspect contents for Veil entries
--       local isBag = false
--       pcall(function() if o.tag and o.tag == "Bag" then isBag = true end end)
--       if isBag and o.getObjects then
--         local okc, contents = pcall(function() return o.getObjects() end)
--         if okc and contents then
--           for _, item in ipairs(contents) do
--             if item and item.name and item.name == "Veil" then
--               table.insert(candidates, {type = "bag", bag = o, guid = item.guid})
--             end
--           end
--         end
--       end
--     end
--   end

--   if #candidates == 0 then return end

--   local want = 4
--   for i = 1, math.min(want, #candidates) do
--     local c = candidates[i]
--     local target_y = pos.y + 0.6 + ((i - 1) * 0.2)
--     if c.type == "table" and c.obj then
--       pcall(function()
--         if c.obj.setRotation then pcall(function() c.obj.setRotation({0,180,0}) end) end
--         if c.obj.setPositionSmooth then
--           c.obj.setPositionSmooth({pos.x, target_y, pos.z})
--         else
--           c.obj.setPosition({pos.x, target_y, pos.z})
--         end
--       end)
--     elseif c.type == "bag" and c.bag and c.guid then
--       pcall(function()
--         if c.bag.takeObject then
--           c.bag.takeObject({
--             guid = c.guid,
--             position = {pos.x, target_y + 0.5, pos.z},
--             callback_function = function(taken)
--               Wait.frames(function()
--                 if taken then
--                   pcall(function() if taken.setRotation then taken.setRotation({0,180,0}) end end)
--                   if taken.setPositionSmooth then
--                     taken.setPositionSmooth({pos.x, target_y, pos.z})
--                   elseif taken.setPosition then
--                     taken.setPosition({pos.x, target_y, pos.z})
--                   end
--                 end
--               end, 1)
--             end
--           })
--         end
--       end)
--     end
--   end
--   LOG.INFO("Placed " .. tostring(math.min(want, #candidates)) .. " Veil card(s) onto The Loom")
-- end

end)
__bundle_register("assets/leaders_pnp2_starting", function(require, _LOADED, __bundle_register, __bundle_modules)
starting_pieces["Imperator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

starting_pieces["Poet"] = {
  A = {
    building = "city",
    ships = 2
  },
  B = {
    building = "starport",
    ships = 2
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

starting_pieces["Diplomat"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Scavenger"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Oracle"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Brainbox"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Saint"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Lightbringer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Firebrand"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Politico"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}
starting_pieces["Edenlord"] = {
  A = {
    building = "None",
    ships = 4
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Profiteer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}
end)
__bundle_register("assets/leaders_starting_pieces", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Generated by tools/yml_to_lua.py from leaders.yml
starting_pieces = starting_pieces or {}

-- Kaiju
starting_pieces["Kaiju"] = {
  A = {
    building = "city",
    ships = 4
  },
  B = {
    building = "city",
    ships = 4
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Shapeshifter
starting_pieces["Shapeshifter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sentient
starting_pieces["Sentient"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "None",
    ships = 2
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Hierarch
starting_pieces["Hierarch"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Smuggler
starting_pieces["Smuggler"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Manipulator
starting_pieces["Manipulator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Necromancer
starting_pieces["Necromancer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Composer
starting_pieces["Composer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Maw
starting_pieces["Maw"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Saint
starting_pieces["Saint"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Seer
starting_pieces["Seer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Terrestrial
starting_pieces["Terrestrial"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- General
starting_pieces["General"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sentinel
starting_pieces["Sentinel"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Prefect
starting_pieces["Prefect"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Ghost
starting_pieces["Ghost"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Chosen
starting_pieces["Chosen"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sage
starting_pieces["Sage"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Gambler
starting_pieces["Gambler"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Engineer
starting_pieces["Engineer"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Magician
starting_pieces["Magician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Weaver
starting_pieces["Weaver"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Dreamer
starting_pieces["Dreamer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Seeker
starting_pieces["Seeker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Augur
starting_pieces["Augur"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Alchemist
starting_pieces["Alchemist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Architect
starting_pieces["Architect"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Martyr
starting_pieces["Martyr"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Scourge
starting_pieces["Scourge"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Beggar
starting_pieces["Beggar"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"None", "None"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Feral
starting_pieces["Feral"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Conduit
starting_pieces["Conduit"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Puppeteer
starting_pieces["Puppeteer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Automaton
starting_pieces["Automaton"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Golem
starting_pieces["Golem"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Solian
starting_pieces["Solian"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Racketeer
starting_pieces["Racketeer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Terraformer
starting_pieces["Terraformer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Trickster
starting_pieces["Trickster"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Nomad
starting_pieces["Nomad"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Iconoclast
starting_pieces["Iconoclast"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Fiend
starting_pieces["Fiend"] = {
  A = {
    building = "None",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"None", "None"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Hustler
starting_pieces["Hustler"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Curator
starting_pieces["Curator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Cartographer
starting_pieces["Cartographer"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Custodian
starting_pieces["Custodian"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Salvager
starting_pieces["Salvager"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Chief
starting_pieces["Chief"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Duelist
starting_pieces["Duelist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Prophet
starting_pieces["Prophet"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Broker
starting_pieces["Broker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Siegebreaker
starting_pieces["Siegebreaker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Courier
starting_pieces["Courier"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Forager
starting_pieces["Forager"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Punter
starting_pieces["Punter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Insurgent
starting_pieces["Insurgent"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Bomber
starting_pieces["Bomber"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Musician
starting_pieces["Musician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Ozymandias
starting_pieces["Ozymandias"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Collector
starting_pieces["Collector"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Samurai
starting_pieces["Samurai"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Assassin
starting_pieces["Assassin"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Witch
starting_pieces["Witch"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Ambassador
starting_pieces["Ambassador"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Shaman
starting_pieces["Shaman"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Mediator
starting_pieces["Mediator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Despot
starting_pieces["Despot"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Viceroy
starting_pieces["Viceroy"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Artificer
starting_pieces["Artificer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Warmonger
starting_pieces["Warmonger"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Extortioner
starting_pieces["Extortioner"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Emperor
starting_pieces["Emperor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Titan
starting_pieces["Titan"] = {
  A = {
    building = "city",
    ships = 4
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Egoist
starting_pieces["Egoist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Enforcer
starting_pieces["Enforcer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Treasurer
starting_pieces["Treasurer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Wayfinder
starting_pieces["Wayfinder"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 4
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Champion
starting_pieces["Champion"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Tribune
starting_pieces["Tribune"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Dissector
starting_pieces["Dissector"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Schemer
starting_pieces["Schemer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Hydra
starting_pieces["Hydra"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Enchanter
starting_pieces["Enchanter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Creator
starting_pieces["Creator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Messiah
starting_pieces["Messiah"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Abomination
starting_pieces["Abomination"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Crusader
starting_pieces["Crusader"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Phantom
starting_pieces["Phantom"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Harbormaster
starting_pieces["Harbormaster"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Investor
starting_pieces["Investor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"None", "None"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Envoy
starting_pieces["Envoy"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Syndic
starting_pieces["Syndic"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Solicitor
starting_pieces["Solicitor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Seraph
starting_pieces["Seraph"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Paragon
starting_pieces["Paragon"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Tactician
starting_pieces["Tactician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Purist
starting_pieces["Purist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Marauder
starting_pieces["Marauder"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Berserker
starting_pieces["Berserker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Underwriter
starting_pieces["Underwriter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Doppelganger
starting_pieces["Doppelganger"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Bulwark
starting_pieces["Bulwark"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Demon
starting_pieces["Demon"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Soulbinder
starting_pieces["Soulbinder"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Vessel
starting_pieces["Vessel"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Conqueror
starting_pieces["Conqueror"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Comedian
starting_pieces["Comedian"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Animator
starting_pieces["Animator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Merchant
starting_pieces["Merchant"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Wretch
starting_pieces["Wretch"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Rascal
starting_pieces["Rascal"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Devourer
starting_pieces["Devourer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Swarm
starting_pieces["Swarm"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Predator
starting_pieces["Predator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Reaver
starting_pieces["Reaver"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Prospector
starting_pieces["Prospector"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Smokecaller
starting_pieces["Smokecaller"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Dragon
starting_pieces["Dragon"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sniper
starting_pieces["Sniper"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Poltergeist
starting_pieces["Poltergeist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Homesteader
starting_pieces["Homesteader"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Instigator
starting_pieces["Instigator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Replicator
starting_pieces["Replicator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Armsdealer
starting_pieces["Armsdealer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Veteran
starting_pieces["Veteran"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Evader
starting_pieces["Evader"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Mathematician
starting_pieces["Mathematician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Underdog
starting_pieces["Underdog"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Mobster
starting_pieces["Mobster"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Glutton
starting_pieces["Glutton"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Contrarian
starting_pieces["Contrarian"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Cat
starting_pieces["Cat"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Cavalier
starting_pieces["Cavalier"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Surveyor
starting_pieces["Surveyor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Jester
starting_pieces["Jester"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

end)
__bundle_register("src/SheetsSenderOverlay", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Sends active players' steam names, colors and hand contents to a localhost overlay

local LOCAL_OVERLAY_URL = "http://127.0.0.1:3000/overlay" -- change if your overlay server listens elsewhere
local overlay_initialized = false

local SheetsSenderOverlay = {}

-- Simple helpers copied/adapted for this module
local function url_encode(str)
    if str == nil then return "" end
    str = tostring(str)
    str = str:gsub("\n", "\r\n")
    return (str:gsub("([^%w%-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end

local function is_card_object(obj)
    if not obj then return false end
    local ok, typ = pcall(function() return obj.type end)
    if ok and typ then
        if typ == "Card" or typ == "Deck" then return true end
    end
    local okTag, hasCardTag = pcall(function() return obj.hasTag and obj.hasTag("Card") end)
    if okTag and hasCardTag then return true end
    local okName, name = pcall(function() return obj.getName and obj.getName() end)
    if okName and name and tostring(name) ~= "" then
        local lname = string.lower(tostring(name))
        if string.find(lname, "card") or string.find(lname, "action") then return true end
    end
    return false
end

local function format_card_label(obj)
    if not obj then return "" end
    local name = ""
    local desc = ""
    if obj.getName then name = obj.getName() end
    if obj.getDescription then desc = obj.getDescription() end
    name = name and tostring(name) or ""
    desc = desc and tostring(desc) or ""
    local lname = string.lower(name)
    -- If the name is a generic placeholder (e.g., "Action Card"), prefer description
    if (lname == "action card" or lname == "card" or string.find(lname, "action card")) and desc ~= "" then
        return desc
    end
    -- If name empty but description present, use description
    if name == "" and desc ~= "" then return desc end
    -- If both present and different, include description in parentheses
    if name ~= "" and desc ~= "" and desc ~= name then
        return name .. " (" .. desc .. ")"
    end
    if name ~= "" then return name end
    if desc ~= "" then return desc end
    return tostring(obj.guid or (obj.getGUID and obj.getGUID()) or "object")
end

-- Try several sources to obtain the active players roster
local function get_active_players()
    local roster = nil
    roster = Global.getTable("active_players")
    if type(roster) == "table" and #roster > 0 then return roster end
    roster = Global.getVar("active_players")
    if type(roster) == "table" and #roster > 0 then return roster end
    local ordered = Global.call("getOrderedPlayers", {true})
    if type(ordered) == "table" and #ordered > 0 then return ordered end
    -- last fallback: try scanning Player table keys
    local players = {}
    for k, v in pairs(Player) do
        if type(k) == "string" and k ~= "White" and v.steam_name then
            table.insert(players, k)
        end
    end
    return players
end

-- Collect hand objects for a given player color; best-effort approach
local function collect_hand_for_color(color)
    local hand_labels = {}
    local hand_count = 0
    -- Try Player[color].getHandObjects() (works in many TTS versions)
    local pl = Player[color]
    if pl then
        local hand_objs = nil
        if pl.getHandObjects then
            hand_objs = pl.getHandObjects()
        end
        if type(hand_objs) == "table" and #hand_objs > 0 then
            for _, o in ipairs(hand_objs) do
                if is_card_object(o) then
                    table.insert(hand_labels, format_card_label(o))
                end
            end
            hand_count = #hand_objs
            return hand_labels, hand_count
        end
        -- Some Player userdata expose getHandCount
        if pl.getHandCount then
            local hc = pl.getHandCount()
            if type(hc) == "number" then hand_count = hc end
        end
    end

    -- Fallback: try to find a stored arcs player with hand_size (best-effort)
    if _G["get_arcs_player"] then
        local ap = get_arcs_player(color)
        if ap and type(ap.hand_size) ~= "nil" then
            hand_count = tonumber(ap.hand_size) or hand_count
        end
    end

    return hand_labels, hand_count
end

-- Build payload and send POST to localhost overlay
local function send_overlay_update(player, value, id)
    -- Initialize overlay on first call with setup instructions
    if not overlay_initialized then
        overlay_initialized = true
        broadcastToAll("Overlay: Active. Streamer: Open http://127.0.0.1:3000 in OBS Browser Source or your browser to display player hands.", {0.2, 0.8, 0.2})
    end

    local hide_cards = _G["overlay_cards_hidden"] == true

    -- Get turn order from Turns object
    local turn_order = {}
    local turn_result = Turns.getTurnOrder()
    if type(turn_result) == "table" then
        turn_order = turn_result
    end

    local roster = get_active_players() or {}
    local rows = {}
    for _, p in ipairs(roster) do
        local color = nil
        local steam_name = nil
        if type(p) == "table" and p.color then color = p.color
            local pl = Player[p.color]
            if pl and pl.steam_name and pl.steam_name ~= "" then steam_name = pl.steam_name else steam_name = p.color end
        elseif type(p) == "string" then
            color = p
            local pl = Player[p]
            if pl and pl.steam_name and pl.steam_name ~= "" then steam_name = pl.steam_name else steam_name = p end
        else
            steam_name = tostring(p)
            color = tostring(p)
        end

        local hand_labels, hand_count = collect_hand_for_color(color)

        table.insert(rows, {
            steam_name = steam_name or "",
            color = color or "",
            hand = hand_labels,
            hand_size = hand_count or 0,
        })
    end

    -- Include overlay alignment (left/right) if set in Global
    local overlay_align = _G["overlay_align"] or "left"
    local payload = { source = "tts", timestamp = os.time(), players = rows, turn_order = turn_order, align = overlay_align, hide_cards = hide_cards }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Overlay sender: WebRequest API not available", {1,0,0})
        return
    end

    -- Send asynchronously to the local overlay server
    WebRequest.custom(LOCAL_OVERLAY_URL, "POST", true, body_json, headers, function(response)
        if response and response.is_error then
            local text = (response and response.text) and response.text or tostring(response)
            broadcastToAll("Overlay send failed - " .. tostring(text), {1,0,0})
        else
           -- broadcastToAll("Overlay: update sent", {0.2, 0.8, 0.2})
        end
    end)
end

_G["send_overlay_update_ui"] = send_overlay_update

local function clear_overlay()
    local payload = { source = "tts", timestamp = os.time(), players = {}, turn_order = {}, align = (_G["overlay_align"] or "left"), hide_cards = true }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    if not WebRequest or not WebRequest.custom then
        return
    end

    WebRequest.custom(LOCAL_OVERLAY_URL, "POST", true, body_json, headers, function(_) end)
end

_G["clear_overlay_ui"] = clear_overlay

return SheetsSenderOverlay

end)
__bundle_register("src/integrations/ErrataFaqService", function(require, _LOADED, __bundle_register, __bundle_modules)
local ErrataFaqService = {}

local ERRATA_URL = "https://raw.githubusercontent.com/buriedgiantstudios/cards/refs/heads/master/content/errata/arcs/en-US.yml"
local ERRATA_CACHE_SECONDS = 86400
local errata_cache_lookup = nil
local errata_cache_time = 0
local errata_fetch_in_flight = false
local errata_pending_callbacks = {}

local FAQ_URL = "https://raw.githubusercontent.com/buriedgiantstudios/cards/refs/heads/master/content/faq/arcs/en-US.yml"
local FAQ_CACHE_SECONDS = 86400
local faq_cache_lookup = nil
local faq_cache_time = 0
local faq_fetch_in_flight = false
local faq_pending_callbacks = {}

local errata_menu_patched = {}

local function trim(s)
  s = tostring(s or "")
  s = s:gsub("^%s+", "")
  s = s:gsub("%s+$", "")
  return s
end

local function strip_outer_quotes(s)
  s = trim(s)
  local first = s:sub(1, 1)
  local last = s:sub(-1)
  if (first == '"' and last == '"') or (first == "'" and last == "'") then
    s = s:sub(2, -2)
  end
  s = s:gsub('\\"', '"')
  s = s:gsub("\\'", "'")
  return s
end

local function normalize_card_name(name)
  local n = trim(name)
  n = n:gsub("%$link:([^%$]+)%$", "%1")
  n = n:gsub("[%*_`]", "")
  n = n:gsub("[^%w%s]", "")
  n = n:lower()
  n = n:gsub("%s+", " ")
  return trim(n)
end

local function split_slash_keys(name)
  local keys = {}
  if not name then return keys end
  local full = normalize_card_name(name)
  table.insert(keys, full)
  local a, b = name:match("^(.-)%s*/%s*(.-)$")
  if a and b then
    local ka = normalize_card_name(a)
    local kb = normalize_card_name(b)
    if ka ~= full then table.insert(keys, ka) end
    if kb ~= full and kb ~= ka then table.insert(keys, kb) end
  end
  return keys
end

local function get_card_label_for_errata(card_obj)
  if not card_obj then return "" end

  local name = ""
  local desc = ""
  pcall(function() if card_obj.getName then name = tostring(card_obj.getName() or "") end end)
  pcall(function() if card_obj.getDescription then desc = tostring(card_obj.getDescription() or "") end end)

  local lname = string.lower(trim(name))
  local label = trim(name)

  if lname == "action card" or lname == "card" then
    label = trim(desc)
  elseif label == "" and trim(desc) ~= "" then
    label = trim(desc)
  end

  return trim(label)
end

local function parse_errata_yaml_lookup(yaml_text)
  local lookup = {}
  if not yaml_text or yaml_text == "" then return lookup end

  local pending_texts = {}
  local current_text = nil
  local collecting_text = false

  local function push_current_text()
    if current_text and trim(current_text) ~= "" then
      table.insert(pending_texts, trim(current_text))
    end
    current_text = nil
    collecting_text = false
  end

  local pos = 1
  while pos <= #yaml_text do
    local nl = yaml_text:find("\n", pos, true)
    local line
    if nl then
      line = yaml_text:sub(pos, nl - 1)
      pos = nl + 1
    else
      line = yaml_text:sub(pos)
      pos = #yaml_text + 1
    end
    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end

    local card_value = line:match("^%s*card:%s*(.+)%s*$")
    if card_value then
      push_current_text()
      local card_name = strip_outer_quotes(card_value)
      local key = normalize_card_name(card_name)
      if key ~= "" then
        if not lookup[key] then
          lookup[key] = { card = card_name, texts = {} }
        end
        for _, t in ipairs(pending_texts) do
          table.insert(lookup[key].texts, t)
        end
      end
      pending_texts = {}
    else
      local text_value = line:match("^%s*-%s*text:%s*(.*)$")
      if text_value == nil then
        text_value = line:match("^%s*text:%s*(.*)$")
      end

      if text_value ~= nil then
        push_current_text()
        current_text = strip_outer_quotes(text_value)
        collecting_text = true
      elseif collecting_text then
        local is_new_key = false
        if line:match("^%s*card:%s*") or line:match("^%s*-%s*errata:%s*$") or line:match("^%s*errata:%s*$") then
          is_new_key = true
        elseif line:match("^%s+[%a_][%w_%-]*:%s*") then
          is_new_key = true
        end

        if is_new_key then
          push_current_text()
        else
          local continuation = trim(line)
          if continuation ~= "" then
            if current_text == "" then
              current_text = continuation
            else
              current_text = current_text .. " " .. continuation
            end
          end
        end
      end
    end
  end

  push_current_text()
  return lookup
end

local function parse_faq_yaml_lookup(yaml_text)
  local lookup = {}
  if not yaml_text or yaml_text == "" then return lookup end

  local pending_card = nil
  local parsed_items = {}
  local current_item = nil
  local current_section = nil
  local current_text = nil
  local current_key_indent = 0

  local function normalize_block_text(value)
    value = trim(value)
    if value == ">" or value == ">-" or value == "|" or value == "|-" then
      return ""
    end
    return strip_outer_quotes(value)
  end

  local function flush_current_text()
    if current_section and current_item and current_text ~= nil then
      current_item[current_section] = trim(current_text)
    end
    current_section = nil
    current_text = nil
    current_key_indent = 0
  end

  local function flush_current_item()
    flush_current_text()
    if current_item and (trim(current_item.q) ~= "" or trim(current_item.a) ~= "") then
      table.insert(parsed_items, { q = trim(current_item.q), a = trim(current_item.a) })
    end
    current_item = nil
  end

  local pos = 1
  while pos <= #yaml_text do
    local nl = yaml_text:find("\n", pos, true)
    local line
    if nl then
      line = yaml_text:sub(pos, nl - 1)
      pos = nl + 1
    else
      line = yaml_text:sub(pos)
      pos = #yaml_text + 1
    end
    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end

    local indent = #line:match("^(%s*)")
    local card_value = line:match("^%s*card:%s*(.+)%s*$")
    if card_value then
      flush_current_item()
      pending_card = strip_outer_quotes(card_value)
      if #parsed_items > 0 then
        local key = normalize_card_name(pending_card)
        if key ~= "" then
          if not lookup[key] then lookup[key] = { card = pending_card, entries = {} } end
          for _, it in ipairs(parsed_items) do
            table.insert(lookup[key].entries, { q = it.q, a = it.a })
          end
        end
        parsed_items = {}
      end
    else
      local q_value = line:match("^%s*%-?%s*q:%s*(.*)$")
      local a_value = line:match("^%s*%-?%s*a:%s*(.*)$")
      if q_value ~= nil or a_value ~= nil then
        if current_section then
          flush_current_text()
        end
        if q_value ~= nil then
          if current_item and (trim(current_item.q) ~= "" or trim(current_item.a) ~= "") then
            flush_current_item()
          end
          if not current_item then current_item = { q = "", a = "" } end
          current_section = "q"
          current_key_indent = indent
          current_text = normalize_block_text(q_value)
        else
          if not current_item then current_item = { q = "", a = "" } end
          current_section = "a"
          current_key_indent = indent
          current_text = normalize_block_text(a_value)
        end
      else
        if current_section and indent > current_key_indent then
          local continuation = trim(line)
          if continuation ~= "" then
            if current_text == "" then
              current_text = continuation
            else
              current_text = current_text .. " " .. continuation
            end
          end
        else
          if current_section then
            flush_current_text()
          end
        end
      end
    end
  end

  flush_current_item()

  if pending_card and #parsed_items > 0 then
    local key = normalize_card_name(pending_card)
    if key ~= "" then
      if not lookup[key] then lookup[key] = { card = pending_card, entries = {} } end
      for _, it in ipairs(parsed_items) do
        table.insert(lookup[key].entries, { q = it.q, a = it.a })
      end
    end
    parsed_items = {}
  end

  return lookup
end

local function finish_errata_fetch(lookup, err)
  errata_fetch_in_flight = false
  local callbacks = errata_pending_callbacks
  errata_pending_callbacks = {}
  for _, cb in ipairs(callbacks) do
    pcall(function() cb(lookup, err) end)
  end
end

local function finish_faq_fetch(lookup, err)
  faq_fetch_in_flight = false
  local callbacks = faq_pending_callbacks
  faq_pending_callbacks = {}
  for _, cb in ipairs(callbacks) do
    pcall(function() cb(lookup, err) end)
  end
end

local function fetch_errata_lookup(callback)
  if callback then
    table.insert(errata_pending_callbacks, callback)
  end

  if errata_cache_lookup and (os.time() - errata_cache_time) < ERRATA_CACHE_SECONDS then
    finish_errata_fetch(errata_cache_lookup, nil)
    return
  end

  if errata_fetch_in_flight then
    return
  end
  errata_fetch_in_flight = true

  if not WebRequest or not WebRequest.custom then
    finish_errata_fetch(nil, "WebRequest API not available")
    return
  end

  local headers = { ["Accept"] = "text/plain, text/yaml, */*" }
  local ok, err = pcall(function()
    WebRequest.custom(ERRATA_URL, "GET", true, "", headers, function(response)
      if response and response.is_error then
        local msg = (response and response.text) and response.text or tostring(response)
        finish_errata_fetch(nil, msg)
        return
      end

      local body = (response and response.text) and tostring(response.text) or ""
      if body == "" then
        finish_errata_fetch(nil, "Empty response")
        return
      end

      local lookup = parse_errata_yaml_lookup(body)
      errata_cache_lookup = lookup
      errata_cache_time = os.time()
      finish_errata_fetch(lookup, nil)
    end)
  end)

  if not ok then
    finish_errata_fetch(nil, tostring(err))
  end
end

local function fetch_faq_lookup(callback)
  if callback then
    table.insert(faq_pending_callbacks, callback)
  end

  if faq_cache_lookup and (os.time() - faq_cache_time) < FAQ_CACHE_SECONDS then
    finish_faq_fetch(faq_cache_lookup, nil)
    return
  end

  if faq_fetch_in_flight then
    return
  end
  faq_fetch_in_flight = true

  if not WebRequest or not WebRequest.custom then
    finish_faq_fetch(nil, "WebRequest API not available")
    return
  end

  local headers = { ["Accept"] = "text/plain, text/yaml, */*" }
  local ok, err = pcall(function()
    WebRequest.custom(FAQ_URL, "GET", true, "", headers, function(response)
      if response and response.is_error then
        local msg = (response and response.text) and response.text or tostring(response)
        finish_faq_fetch(nil, msg)
        return
      end

      local body = (response and response.text) and tostring(response.text) or ""
      if body == "" then
        finish_faq_fetch(nil, "Empty response")
        return
      end

      local lookup = parse_faq_yaml_lookup(body)
      faq_cache_lookup = lookup
      faq_cache_time = os.time()
      finish_faq_fetch(lookup, nil)
    end)
  end)

  if not ok then
    finish_faq_fetch(nil, tostring(err))
  end
end

local function show_card_errata(card_obj, player_color)
  local card_label = get_card_label_for_errata(card_obj)
  if card_label == "" then
    broadcastToColor("Errata: Could not determine this card's name.", player_color, {1, 0.4, 0.4})
    return
  end

  fetch_errata_lookup(function(lookup, err)
    if not lookup then
      broadcastToColor("Errata fetch failed: " .. tostring(err or "unknown error"), player_color, {1, 0.4, 0.4})
      return
    end

    local keys = split_slash_keys(card_label)
    local found = false
    for _, k in ipairs(keys) do
      local entry = lookup[k]
      if entry and entry.texts and #entry.texts > 0 then
        found = true
        local title = "Errata: " .. tostring(entry.card or card_label)
        broadcastToAll("=== " .. title .. " ===", {1, 0.75, 0.15})
        for i, text in ipairs(entry.texts) do
          broadcastToAll("- " .. tostring(text), {1, 0.9, 0.4})
          if i < #entry.texts then Wait.time(function() end, 0.05) end
        end
      end
    end
    if not found then
      broadcastToColor("No errata found for " .. card_label .. ".", player_color, {0.8, 0.8, 0.8})
    end
  end)
end

local function show_card_faq(card_obj, player_color)
  local card_label = get_card_label_for_errata(card_obj)
  if card_label == "" then
    broadcastToColor("FAQ: Could not determine this card's name.", player_color, {1, 0.4, 0.4})
    return
  end

  fetch_faq_lookup(function(lookup, err)
    if not lookup then
      broadcastToColor("FAQ fetch failed: " .. tostring(err or "unknown error"), player_color, {1, 0.4, 0.4})
      return
    end

    local keys = split_slash_keys(card_label)
    local found = false
    local q_color = {0.45, 0.8, 1}
    local a_color = {0.6, 1, 0.6}
    for _, k in ipairs(keys) do
      local entry = lookup[k]
      if entry and entry.entries and #entry.entries > 0 then
        found = true
        local title = "FAQ: " .. tostring(entry.card or card_label)
        broadcastToAll("=== " .. title .. " ===", {0.35, 0.7, 1})
        for idx, pair in ipairs(entry.entries) do
          if pair.q and trim(pair.q) ~= "" then
            broadcastToAll("Q" .. idx .. ": " .. tostring(pair.q), q_color)
          end
          if pair.a and trim(pair.a) ~= "" then
            broadcastToAll("A" .. idx .. ": " .. tostring(pair.a), a_color)
          end
          if idx < #entry.entries then
            broadcastToAll(" ", {0.9, 0.9, 0.9})
          end
        end
      end
    end
    if not found then
      broadcastToColor("No FAQ found for " .. card_label .. ".", player_color, {0.8, 0.8, 0.8})
    end
  end)
end

function ErrataFaqService.add_menu_to_card(object)
  if not object then return end

  local object_type = nil
  pcall(function() object_type = object.type end)
  if object_type ~= "Card" then return end

  local guid = nil
  pcall(function() if object.getGUID then guid = object.getGUID() end end)
  if not guid and object.guid then guid = object.guid end
  if not guid then return end

  if errata_menu_patched[guid] then return end

  local card_label = get_card_label_for_errata(object)
  local keys = split_slash_keys(card_label)

  pcall(function()
    local has_errata = false
    local has_faq = false
    if errata_cache_lookup then
      for _, k in ipairs(keys) do
        if errata_cache_lookup[k] then has_errata = true break end
      end
    end
    if faq_cache_lookup then
      for _, k in ipairs(keys) do
        if faq_cache_lookup[k] then has_faq = true break end
      end
    end

    if has_errata then
      object.addContextMenuItem("Show Errata", function(player_color, position, clicked_object)
        local target = clicked_object or object
        show_card_errata(target, player_color)
      end)
    end
    if has_faq then
      object.addContextMenuItem("Show FAQ", function(player_color, position, clicked_object)
        local target = clicked_object or object
        show_card_faq(target, player_color)
      end)
    end
  end)

  errata_menu_patched[guid] = true
end

function ErrataFaqService.scan_cards_for_menu()
  local seen = {}
  for _, object in ipairs(getObjects()) do
    local guid = nil
    if object and object.type == "Card" then
      if object.getGUID then guid = object.getGUID() end
      if not guid and object.guid then guid = object.guid end
      if guid then seen[guid] = true end
      ErrataFaqService.add_menu_to_card(object)
    end
  end

  for guid, _ in pairs(errata_menu_patched) do
    if not seen[guid] then
      errata_menu_patched[guid] = nil
    end
  end
end

function ErrataFaqService.proactive_fetch(on_info, on_warning)
  fetch_errata_lookup(function(_, err)
    if not err then
      if on_info then on_info("Errata YAML pre-fetched and cached") end
      ErrataFaqService.scan_cards_for_menu()
    elseif on_warning then
      on_warning("Failed to pre-fetch errata YAML: " .. tostring(err))
    end
  end)

  fetch_faq_lookup(function(_, err)
    if not err then
      if on_info then on_info("FAQ YAML pre-fetched and cached") end
      ErrataFaqService.scan_cards_for_menu()
    elseif on_warning then
      on_warning("Failed to pre-fetch FAQ YAML: " .. tostring(err))
    end
  end)
end

return ErrataFaqService

end)
__bundle_register("src/SheetsSender", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Simple Sheets sender for testing
-- This module exposes a global UI callback `send_scores_to_sheet_ui`

local WEBHOOK_URL = "https://script.google.com/macros/s/AKfycbwl4ziuGruDElFuPu9lZw4VNALsXW25wHdzHENO32iCStt_tQa25dl0FE7qJpnIHd3alQ/exec"

local SheetsSender = {}
-- last computed preview rows (table form) so Send Now posts the exact preview
local last_preview_rows = nil
-- remember the last preview player order so reopening the preview does not reshuffle players
local last_preview_order_colors = nil
-- store notes text
local last_notes = ""
-- store selected act
local last_selected_act = "basegame"
-- store anonymize names checkbox state
local last_anonymize_names = false
local ActionCards = require("src/ActionCards")
require("src/GUIDs")
-- special object GUID that indicates the "first regent" tile/object
local FIRST_REGENT_GUID = "e9b0f4"

local function get_player_color(p)
    if type(p) == "table" and p.color then return tostring(p.color) end
    if type(p) == "string" then return tostring(p) end
    return tostring(p)
end

local function get_player_colors(players)
    local colors = {}
    if type(players) ~= "table" then return colors end
    for _, p in ipairs(players) do
        table.insert(colors, get_player_color(p))
    end
    return colors
end

local function get_sheets_player_roster()
    local roster = nil
    pcall(function()
        roster = Global.getTable("starting_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    pcall(function()
        roster = Global.getVar("starting_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    pcall(function()
        roster = Global.getVar("active_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    pcall(function()
        roster = Global.getTable("active_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    local ok_ordered, ordered = pcall(function() return Global.call("getOrderedPlayers", {true}) end)
    if ok_ordered and ordered and type(ordered) == "table" and #ordered > 0 then
        return ordered
    end

    return roster or {}
end

-- Convert a TTS color name (e.g., "Pink") to a hex string like "#RRGGBB".
local function color_to_hex(color_name)
    if not color_name then return "#999999" end
    local ok, col = pcall(function() return Color.fromString(color_name) end)
    if ok and col and type(col) == "table" and col[1] then
        local r = math.floor((col[1] or 1) * 255 + 0.5)
        local g = math.floor((col[2] or 1) * 255 + 0.5)
        local b = math.floor((col[3] or 1) * 255 + 0.5)
        return string.format("#%02X%02X%02X", r, g, b)
    end
    -- fallback small mapping
    local map = {
        White = "#FFFFFF", Pink = "#FF69B4", Yellow = "#FFFF66", Teal = "#008080", Red = "#FF4444", Blue = "#4488FF", Green = "#44CC44", Black = "#222222"
    }
    return map[color_name] or "#999999"
end

local function same_color_set(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    if #a ~= #b then return false end
    local counts = {}
    for _, color in ipairs(a) do
        counts[color] = (counts[color] or 0) + 1
    end
    for _, color in ipairs(b) do
        local count = counts[color]
        if not count then return false end
        if count == 1 then counts[color] = nil else counts[color] = count - 1 end
    end
    return next(counts) == nil
end

local function order_players_like(players, colors)
    if type(players) ~= "table" or type(colors) ~= "table" or #players == 0 then return players end
    local by_color = {}
    for _, p in ipairs(players) do
        by_color[get_player_color(p)] = p
    end
    local ordered = {}
    local seen = {}
    for _, color in ipairs(colors) do
        local p = by_color[color]
        if p then
            table.insert(ordered, p)
            seen[color] = true
        end
    end
    -- include any newly-seated players at the end without changing the remembered order
    for _, p in ipairs(players) do
        local color = get_player_color(p)
        if not seen[color] then
            table.insert(ordered, p)
        end
    end
    return ordered
end

-- Resolve player GUIDs from available sources: local player_pieces, Global var player_pieces_GUIDs, or global player_pieces_GUIDs
local function get_player_guid(color, key)
    -- try local player_pieces (used in ArcsPlayer.lua)
    if player_pieces and player_pieces[color] then
        -- direct key (e.g., area_zone, hand_zone)
        if player_pieces[color][key] then return player_pieces[color][key] end
        -- components table (e.g., score_board)
        if player_pieces[color]["components"] and player_pieces[color]["components"][key] then
            return player_pieces[color]["components"][key]
        end
    end

    -- try Global stored GUIDs
    local ok, pp_guids = pcall(function() return Global.getVar("player_pieces_GUIDs") end)
    if ok and pp_guids and pp_guids[color] then
        if pp_guids[color][key] then return pp_guids[color][key] end
        if pp_guids[color]["components"] and pp_guids[color]["components"][key] then return pp_guids[color]["components"][key] end
        -- some modules expose player_pieces_GUIDs as a global table
        if _G["player_pieces_GUIDs"] and _G["player_pieces_GUIDs"][color] then
            if _G["player_pieces_GUIDs"][color][key] then return _G["player_pieces_GUIDs"][color][key] end
        end
    end

    -- final fallback to global player_pieces_GUIDs
    if _G["player_pieces_GUIDs"] and _G["player_pieces_GUIDs"][color] then
        if _G["player_pieces_GUIDs"][color][key] then return _G["player_pieces_GUIDs"][color][key] end
        if _G["player_pieces_GUIDs"][color]["components"] and _G["player_pieces_GUIDs"][color]["components"][key] then
            return _G["player_pieces_GUIDs"][color]["components"][key]
        end
    end

    return nil
end

local SCORE_BUTTON_LABEL_INDICES = {
    power = 0,
    objective = 14,
    hand_size = 2,
    tycoon = 4,
    captives = 6,
    trophies = 8,
    keeper = 10,
    empath = 12,
}

local function read_score_button_labels(score_board, scores)
    if not score_board or type(score_board.getButtons) ~= "function" then
        return scores
    end

    local ok, buttons = pcall(function() return score_board.getButtons() end)
    if not ok or not buttons then
        return scores
    end

    local labels_by_index = {}
    for _, button in ipairs(buttons) do
        if button.index ~= nil then
            labels_by_index[button.index] = button.label
        end
    end

    for key, index in pairs(SCORE_BUTTON_LABEL_INDICES) do
        local label = labels_by_index[index]
        if label ~= nil and tostring(label) ~= "" then
            scores[key] = tostring(label)
        end
    end

    return scores
end

local function resolve_initiative_player_color()
    local initiative_guids = { initiative_GUID, seized_initiative_GUID }
    local seated = {}
    pcall(function()
        local players = Global.getVar("active_players") or Global.getTable("active_players") or {}
        seated = players
    end)

    -- broadcastToAll("Sheets: resolve_initiative_player_color() called, initiative_GUID=" .. tostring(initiative_GUID) .. ", seized=" .. tostring(seized_initiative_GUID), {0.8, 0.8, 0.2})

    -- First: scan each player's initiative zone for the marker
    for _, p in ipairs(seated) do
        local color = get_player_color(p)
        
        -- Try get_player_guid first (for normal setup), then fall back to global player_pieces_GUIDs (for custom setup)
        local zone_guid = get_player_guid(color, "initiative_zone")
        if not zone_guid and player_pieces_GUIDs and player_pieces_GUIDs[color] and player_pieces_GUIDs[color].initiative_zone then
            zone_guid = player_pieces_GUIDs[color].initiative_zone
        end
        
        -- broadcastToAll("Sheets: checking " .. tostring(color) .. " zone_guid=" .. tostring(zone_guid), {0.6, 0.6, 0.9})
        if zone_guid then
            local zone = getObjectFromGUID(zone_guid)
            if zone and type(zone.getObjects) == "function" then
                local ok_zone, objs = pcall(function() return zone.getObjects() end)
                if ok_zone and objs then
                    -- broadcastToAll("Sheets: zone has " .. tostring(#objs) .. " objects", {0.6, 0.6, 0.9})
                    for _, obj in ipairs(objs) do
                        local guid = nil
                        pcall(function() if obj.getGUID then guid = obj.getGUID() end end)
                        if not guid and obj.guid then guid = obj.guid end
                        if guid then
                            -- broadcastToAll("Sheets: found object guid=" .. tostring(guid), {0.6, 0.6, 0.9})
                            for _, target in ipairs(initiative_guids) do
                                if tostring(guid) == tostring(target) then
                                    -- broadcastToAll("Sheets: MATCHED initiative for " .. tostring(color), {0.2, 0.8, 0.2})
                                    return color
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback: try to get the initiative objects directly by GUID and find which player zone contains them
    for _, init_guid in ipairs(initiative_guids) do
        local init_obj = getObjectFromGUID(tostring(init_guid))
        if init_obj then
            -- broadcastToAll("Sheets: found initiative object " .. tostring(init_guid) .. " directly", {0.8, 0.6, 0.2})
            -- Now check which player's initiative zone contains this object
            for _, p in ipairs(seated) do
                local color = get_player_color(p)
                local zone_guid = get_player_guid(color, "initiative_zone")
                if not zone_guid and player_pieces_GUIDs and player_pieces_GUIDs[color] and player_pieces_GUIDs[color].initiative_zone then
                    zone_guid = player_pieces_GUIDs[color].initiative_zone
                end
                if zone_guid then
                    local zone = getObjectFromGUID(zone_guid)
                    if zone and type(zone.getObjects) == "function" then
                        local ok_zone, objs = pcall(function() return zone.getObjects() end)
                        if ok_zone and objs then
                            for _, obj in ipairs(objs) do
                                local guid = nil
                                pcall(function() if obj.getGUID then guid = obj.getGUID() end end)
                                if not guid and obj.guid then guid = obj.guid end
                                if guid and tostring(guid) == tostring(init_guid) then
                                    -- broadcastToAll("Sheets: MATCHED initiative (fallback) for " .. tostring(color), {0.2, 0.8, 0.2})
                                    return color
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- broadcastToAll("Sheets: NO initiative player detected", {0.8, 0.2, 0.2})
    return nil
end

-- Return true if the given object appears to be a card (Card/Deck or tagged/ named as a card)
local function is_card_object(obj)
    if not obj then return false end
    -- Exclude objects that are actually player boards (some setups tag them)
    local ok_ex, is_player_board = pcall(function() if obj.hasTag then return obj.hasTag("player board") end end)
    if ok_ex and is_player_board then return false end
    local ok_ex2, is_player_board2 = pcall(function() if obj.hasTag then return obj.hasTag("playerboard") end end)
    if ok_ex2 and is_player_board2 then return false end
    local ok_ex3, is_player_board3 = pcall(function() if obj.hasTag then return obj.hasTag("Player Board") end end)
    if ok_ex3 and is_player_board3 then return false end
    local ok, typ = pcall(function() return obj.type end)
    if ok and typ then
        if typ == "Card" or typ == "Deck" then return true end
    end
    local okTag, hasCardTag = pcall(function() return obj.hasTag and obj.hasTag("Card") end)
    if okTag and hasCardTag then return true end
    local okName, name = pcall(function() return obj.getName and obj.getName() end)
    if okName and name and tostring(name) ~= "" then
        local lname = string.lower(tostring(name))
        if string.find(lname, "card") or string.find(lname, "action") then return true end
    end
    return false
end

-- Return string like "face-down" / "face-up" or nil if unknown
local function card_face_str(obj)
    if not obj then return nil end
    local is_down = nil
    pcall(function() is_down = obj.is_face_down end)
    if is_down == nil then pcall(function() is_down = obj.is_face_down() end) end
    if is_down == nil then return nil end
    if is_down == true then return "face-down" end
    return "face-up"
end

local function format_card_label(obj, label, area_obj)
    if not label or label == "" then return label end
    -- determine tag prefix (Leader/Fate) when present
    local prefix = ""
    pcall(function()
        if obj and obj.hasTag and obj.hasTag("Leader") then prefix = "Leader: " end
        if obj and obj.hasTag and obj.hasTag("Fate") then prefix = "Fate: " end
    end)
    -- fallback: check table-style tags (use pcall for userdata safety)
    if prefix == "" and obj then
        local ok_tags, tags = pcall(function() return obj.tags end)
        if ok_tags and tags and type(tags) == "table" then
            for _, t in ipairs(tags) do
                if tostring(t) == "Leader" then prefix = "Leader: " ; break end
                if tostring(t) == "Fate" then prefix = "Fate: " ; break end
            end
        end
    end
    -- don't duplicate if label already contains the prefix
    local upcheck = string.upper(tostring(label))
    if prefix ~= "" and (string.find(upcheck, "^LEADER") or string.find(upcheck, "^FATE")) then
        prefix = ""
    end
    local up = string.upper(tostring(label))
    -- Only append face state for specific cards
    if string.find(up, "IMPERIAL REGENT") or string.find(up, "OUTLAW") then
        local state = card_face_str(obj)
        if state then
            label = label .. " (" .. state .. ")"
        end
    end
    -- If provided area_obj matches the FIRST_REGENT_AREA_GUID, mark as first regent
    if area_obj then
        -- area_obj may be a zone; don't treat it as first regent. Detection is done per-object.
    end
    return prefix .. label
end

-- URL-encode a string for form-encoding
local function url_encode(str)
    if str == nil then return "" end
    str = tostring(str)
    -- normalize newlines
    str = str:gsub("\n", "\r\n")
    return (str:gsub("([^%w%-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end

local function _broadcast_response(response)
    -- Prefer explicit error flag if present
    if response and response.is_error then
        local text = (response and response.text) and response.text or tostring(response)
        broadcastToAll("Sheets: send failed - " .. tostring(text), {1, 0, 0})
        return
    end

    -- If no explicit error, consider it successful (some WebRequest responses
    -- don't expose numeric responseCode). Show OK and optionally the text.
    local text = (response and response.text) and response.text or tostring(response)
    broadcastToAll("Sheets: sent OK", {0, 1, 0})
    if text and tostring(text) ~= "table: 0x0" and tostring(text) ~= "nil" and tostring(text) ~= "" then
        broadcastToAll("Sheets response: " .. tostring(text), {0, 1, 0})
    end
end

local function send_simple_test(player, value, id)
    -- Simple payload matching the Apps Script: send a single `word` field
    local payload = {
        word = "hello from TTS"
    }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Debug: show what we're about to send (shorten if extremely long)
    local dbg = body_json
    if #dbg > 1200 then dbg = dbg:sub(1, 1200) .. "... (truncated)" end
    broadcastToAll("Sheets: sending JSON payload (truncated): " .. tostring(dbg), {0.2,0.5,1})

    -- Ensure WebRequest API is available
    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available in this environment", {1,0,0})
        return
    end

    -- Use WebRequest.custom with JSON body (matches the working example pattern)
    -- Append URL-encoded JSON as a `payload` query param too, to support appscripts
    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            _broadcast_response(response)
        end)
    end)
    if not ok then
        broadcastToAll("Sheets: WebRequest.custom error: " .. tostring(err), {1,0,0})
    end
    return
end

-- Expose as a global function so UI onClick can call it by name
_G["send_scores_to_sheet_ui"] = send_simple_test

-- Open a preview UI showing the payload to be sent (sample data for now)
local function generate_preview_xml(active)
    -- Prefer the stored game roster so players who leave mid-game still appear in the sheet payload.
    local roster = get_sheets_player_roster()
    if roster and type(roster) == "table" and #roster > 0 then
        local roster_colors = get_player_colors(roster)
        if last_preview_order_colors and same_color_set(last_preview_order_colors, roster_colors) then
            active = order_players_like(roster, last_preview_order_colors)
        else
            active = roster
            last_preview_order_colors = roster_colors
        end
    else
        active = active or {}
    end
    -- broadcastToAll("Sheets preview: generate_preview_xml active count=" .. tostring(#active), {0.6,0.6,0.9})

    -- Get game ID from Global
    local game_id = ""
    pcall(function()
        game_id = Global.getVar("game_id") or ""
    end)

    -- reset stored preview rows
    last_preview_rows = {}
    local rows = {}
    table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')
    table.insert(rows, [[
        <HorizontalLayout spacing="8">
            <Panel preferredWidth="40" preferredHeight="18" color="#00000000" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Player" color="#dcdcdc" fontSize="16" preferredWidth="260" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Color" color="#dcdcdc" fontSize="16" preferredWidth="80" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Init" color="#dcdcdc" fontSize="16" preferredWidth="40" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Area" color="#dcdcdc" fontSize="16" preferredWidth="480" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Power" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Objective" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Hand#" color="#dcdcdc" fontSize="16" preferredWidth="70" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Tycoon" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Captives" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Trophies" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Keeper" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Empath" color="#dcdcdc" fontSize="16" preferredWidth="90" />
        </HorizontalLayout>
    ]])
    table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')

    if #active == 0 then
        -- fallback sample row
        table.insert(rows, [[
        <HorizontalLayout spacing="8">
            <Panel preferredWidth="40" preferredHeight="18" color="#FF69B4" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Alice" color="white" fontSize="14" preferredWidth="260" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Pink" color="white" fontSize="14" preferredWidth="80" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="✓" color="white" fontSize="14" preferredWidth="40" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Leader: Duke; Hand: Noble, Spy" color="white" fontSize="14" preferredWidth="480" />
        </HorizontalLayout>
        ]])
        table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')
    else
        for _, p in ipairs(active) do
            local name = nil
            local power = ""
            local objective = ""
            local hand_size = ""
            local tycoon = ""
            local captives = ""
            local trophies = ""
            local keeper = ""
            local empath = ""

            local arcs_player = nil
            if type(p) == "table" and p.color then
                -- If the ordered players returned an ArcsPlayer-like table, try to
                -- resolve the authoritative ArcsPlayer instance (may have score_board refs)
                local okap, ap = pcall(function() return get_arcs_player(p.color) end)
                if okap and ap then
                    arcs_player = ap
                else
                    arcs_player = p
                end
                -- Try cached steam name first (survives player leaving), then live Player reference
                local cached_name = nil
                pcall(function() cached_name = Global.call("get_cached_steam_name", (arcs_player and arcs_player.color) or p.color) end)
                if cached_name and cached_name ~= "" and cached_name ~= ((arcs_player and arcs_player.color) or p.color) then
                    name = cached_name
                else
                    local ok, pl = pcall(function() return Player[(arcs_player and arcs_player.color) or p.color] end)
                    if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                        name = pl.steam_name
                    else
                        name = (arcs_player and arcs_player.color) or p.color
                    end
                end
            elseif type(p) == "string" then
                -- try to resolve ArcsPlayer by color
                local ok, ap = pcall(function() return get_arcs_player(p) end)
                if ok and ap then
                    arcs_player = ap
                end
                -- Try cached steam name first, then live Player reference
                local cached_name = nil
                pcall(function() cached_name = Global.call("get_cached_steam_name", p) end)
                if cached_name and cached_name ~= "" and cached_name ~= p then
                    name = cached_name
                else
                    local ok2, pl = pcall(function() return Player[p] end)
                    if ok2 and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
                end
            else
                name = tostring(p)
            end

            if arcs_player and type(arcs_player.update_score) == "function" then
                pcall(function() arcs_player:update_score() end)
                power = arcs_player.power or ""
                objective = arcs_player.objective or ""
                hand_size = arcs_player.hand_size or ""
                tycoon = arcs_player.tycoon or ""
                captives = arcs_player.captives or ""
                trophies = arcs_player.trophies or ""
                keeper = arcs_player.keeper or ""
                empath = arcs_player.empath or ""

                -- Try to read the actual labels from the player's score_board buttons
                local sb = arcs_player.score_board
                if not sb and arcs_player.color then
                    local sb_guid = get_player_guid(arcs_player.color, "score_board")
                    if sb_guid then
                        pcall(function() sb = getObjectFromGUID(sb_guid) end)
                    end
                end
                local score_labels = read_score_button_labels(sb, {
                    power = power,
                    objective = objective,
                    hand_size = hand_size,
                    tycoon = tycoon,
                    captives = captives,
                    trophies = trophies,
                    keeper = keeper,
                    empath = empath,
                })
                power = score_labels.power
                objective = score_labels.objective
                hand_size = score_labels.hand_size
                tycoon = score_labels.tycoon
                captives = score_labels.captives
                trophies = score_labels.trophies
                keeper = score_labels.keeper
                empath = score_labels.empath
            end

            -- Gather cards from the player's area and hand (use ActionCards.get_info when available)
            local cards_list = {}
            local function push_card_obj(obj, source, area_obj)
                if not obj then return end
                local added = false
                if ActionCards and type(ActionCards.get_info) == "function" then
                    local ok, info = pcall(function() return ActionCards.get_info(obj) end)
                    if ok and info and info.type then
                        local lbl = tostring(info.type) .. (info.number and ("#" .. tostring(info.number)) or "")
                        table.insert(cards_list, format_card_label(obj, lbl, area_obj))
                        added = true
                    end
                end
                if not added then
                        local nm = nil
                        local ok1 = pcall(function() if obj.getName then nm = obj.getName() end end)
                        if (not nm or tostring(nm) == "") and obj.name then nm = obj.name end
                        if ok1 and nm and tostring(nm) ~= "" then
                            table.insert(cards_list, format_card_label(obj, tostring(nm), area_obj))
                        added = true
                    end
                end
                if not added then
                        local desc = nil
                        local ok2 = pcall(function() if obj.getDescription then desc = obj.getDescription() end end)
                        if (not desc or tostring(desc) == "") and obj.description then desc = obj.description end
                        if ok2 and desc and tostring(desc) ~= "" then
                            table.insert(cards_list, format_card_label(obj, tostring(desc), area_obj))
                    end
                end
            end

            -- area_zone
            local area_zone_obj = nil
            pcall(function()
                if arcs_player and arcs_player.color then
                    local area_guid = get_player_guid(arcs_player.color, "area_zone")
                    if area_guid then area_zone_obj = getObjectFromGUID(area_guid) end
                end
            end)
            if area_zone_obj and type(area_zone_obj.getObjects) == "function" then
                local ok, objs = pcall(function() return area_zone_obj.getObjects() end)
                if ok and objs then
                    -- broadcastToAll("Sheets preview: found " .. tostring(#objs) .. " area objects for " .. tostring(name), {0.3,0.6,0.9})
                    for _, o in ipairs(objs) do
                        -- detect object GUID robustly
                        local og = nil
                        pcall(function() if o.getGUID then og = o.getGUID() end end)
                        if (not og) and o.guid then og = o.guid end
                        local is_first_regent_obj = og and tostring(og) == FIRST_REGENT_GUID
                        if is_first_regent_obj then
                            -- explicitly add a user-friendly label for the first regent
                            table.insert(cards_list, "First Regent")
                        elseif is_card_object(o) then
                            -- treat normal card objects as before
                            local nm = nil
                            pcall(function() if o.getName then nm = o.getName() end end)
                            if (not nm or tostring(nm) == "") and o.name then nm = o.name end
                            if nm and tostring(nm) ~= "" then
                                table.insert(cards_list, format_card_label(o, tostring(nm)))
                            else
                                push_card_obj(o, "area")
                            end
                        else
                            -- skip any other non-card objects
                        end
                    end
                else
                    -- broadcastToAll("Sheets preview: could not read area objects for " .. tostring(name), {1,0.4,0.2})
                end
            else
                -- broadcastToAll("Sheets preview: no area zone object for " .. tostring(name), {1,0.4,0.2})
            end

            -- hand_zone
            local hand_zone_obj = nil
            pcall(function()
                if arcs_player and arcs_player.color then
                    local hand_guid = get_player_guid(arcs_player.color, "hand_zone")
                    if hand_guid then hand_zone_obj = getObjectFromGUID(hand_guid) end
                end
            end)
            if hand_zone_obj and type(hand_zone_obj.getObjects) == "function" then
                local ok, objs = pcall(function() return hand_zone_obj.getObjects() end)
                if ok and objs then
                    -- broadcastToAll("Sheets preview: found " .. tostring(#objs) .. " hand objects for " .. tostring(name), {0.3,0.6,0.9})
                    for _, o in ipairs(objs) do
                        if is_card_object(o) then
                            push_card_obj(o, "hand", hand_zone_obj)
                        end
                    end
                else
                    -- broadcastToAll("Sheets preview: could not read hand objects for " .. tostring(name), {1,0.4,0.2})
                end
            else
                -- broadcastToAll("Sheets preview: no hand zone object for " .. tostring(name), {1,0.4,0.2})
            end

            -- initiative detection
            local initiative_player = resolve_initiative_player_color()
            local has_initiative = false
            if initiative_player and arcs_player and arcs_player.color and tostring(initiative_player) == tostring(arcs_player.color) then has_initiative = true end

            -- clean cards list: remove stray tokens like "active"/"area"/"hand" and empty entries
            local clean_cards = {}
            for _, c in ipairs(cards_list) do
                local ok, s = pcall(function() return tostring(c) end)
                if not ok then s = "" end
                s = s or ""
                s = s:gsub("^%s+", ""):gsub("%s+$", "")
                local ls = string.lower(s)
                if s ~= "" and ls ~= "active" and ls ~= "area" and ls ~= "hand" then
                    table.insert(clean_cards, s)
                end
            end

            -- store a structured row so send uses exactly the preview content (include cleaned cards array)
            local color_name = (arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p)
            table.insert(last_preview_rows, {
                full_name = name,
                name = name,
                color = color_name,
                initiative = has_initiative,
                power = tostring(power),
                objective = tostring(objective),
                hand_size = tostring(hand_size),
                tycoon = tostring(tycoon),
                captives = tostring(captives),
                trophies = tostring(trophies),
                keeper = tostring(keeper),
                empath = tostring(empath),
                cards = clean_cards,
            })

            local init_display = has_initiative and "✓" or ""
            -- split cards into area / hand for display (best-effort)
            local area_str = table.concat(clean_cards, " | ")
            table.insert(rows, string.format([[ 
        <HorizontalLayout spacing="8">
            <Panel preferredWidth="40" preferredHeight="18" color="%s" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="260" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="80" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="40" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="480" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="70" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
        </HorizontalLayout>
            ]], color_to_hex(((arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p))), name, (arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p), init_display, area_str, tostring(power), tostring(objective), tostring(hand_size), tostring(tycoon), tostring(captives), tostring(trophies), tostring(keeper), tostring(empath)))
            table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')
        -- replace the fields above: show initiative marker as check if present
        end
    end

    local rows_xml = table.concat(rows, "\n")

    return string.format([[ 
    <Canvas>
        <Panel id="sheetsPreviewPanel" rectAlignment="MiddleCenter" allowDragging="true" width="1400" height="900" color="#222222CC" childForceExpandWidth="false" childForceExpandHeight="false">
            <VerticalLayout spacing="8" padding="10" childForceExpandHeight="false" childForceExpandWidth="false">
                <Text text="ARCS - Game Results Preview" fontSize="24" color="white" />
                <Text text="Game ID: %s - You can view collected data here: https://laurens1234.github.io/arcs-arsenal/data" fontSize="14" color="#dcdcdc" />
                <Text text="Send results to help collect game data." fontSize="13" color="#cfcfcf" />
                <Text text="You may submit these results at the end of the game or at the end of each Act." fontSize="13" color="#cfcfcf" />
                %s
                <HorizontalLayout spacing="8" childForceExpandWidth="false">
                    <Button text="Send Result" onClick="send_preview_to_sheet_ui" color="#2e8b57" textColor="white" width="120" height="36" preferredWidth="120" preferredHeight="36" fontSize="16" />
                    <Text text="Notes:" color="#dcdcdc" fontSize="14" preferredWidth="60" />
                    <InputField id="sheetsNotesInput" text="" characterLimit="500" contentType="TextArea" placeholder="Add notes here..." preferredWidth="400" preferredHeight="18" onValueChanged="update_notes_field" />
                    <Text text="Mode/Act:" color="#dcdcdc" fontSize="14" preferredWidth="40" />
                    <Dropdown id="sheetsActDropdown" onValueChanged="update_act_dropdown" preferredWidth="120" preferredHeight="28">
                        <Option value="basegame">Base</Option>
                        <Option value="Lost Vaults">Lost Vaults</Option>
                        <Option value="Act I">Act I</Option>
                        <Option value="Act II">Act II</Option>
                        <Option value="Act III">Act III</Option>
                        <Option value="Other">Other</Option>                        
                    </Dropdown>
                    <Toggle id="sheetsAnonymizeToggle" isOn="%s" onValueChanged="update_anonymize_checkbox" />
                    <Text text="Anonymize" color="#dcdcdc" fontSize="12" preferredWidth="80" />
                    <Panel preferredWidth="1" flexibleWidth="1" />
                    <Button text="Request Remove &#10;Last Submission" onClick="send_remove_request_ui" color="#bb1717d0" textColor="white" width="120" height="36" preferredWidth="120" preferredHeight="36" fontSize="14" />
                    <Button text="Close" onClick="loadCameraTimerMenu" color="#888888" textColor="white" width="80" height="36" preferredWidth="80" preferredHeight="36" fontSize="16" />
                </HorizontalLayout>
            </VerticalLayout>
        </Panel>
    </Canvas>
    ]], game_id, rows_xml, (last_anonymize_names and "true" or "false"))
end

local function update_notes_field(player, value, id)
    last_notes = tostring(value or "")
end

local function update_act_dropdown(player, value, id)
    last_selected_act = tostring(value or "basegame")
end

local function update_anonymize_checkbox(player, value, id)
    -- Debug: log what we actually received
   -- broadcastToAll("Sheets: update_anonymize_checkbox called with value=" .. tostring(value) .. " (type=" .. type(value) .. ")", {1, 1, 0})
    -- Ignore the initial UI setup call (player is empty when UI is first set)
    if not player or tostring(player) == "" then
        return
    end

    -- Handle various Toggle value formats coming from an actual user action
    if value == true or value == "true" or value == "True" or value == 1 or value == "1" then
        last_anonymize_names = true
        broadcastToAll("Sheets: anonymize names = TRUE", {0.2, 0.8, 0.2})
    else
        last_anonymize_names = false
        broadcastToAll("Sheets: anonymize names = FALSE", {0.8, 0.2, 0.2})
    end
end

local function open_preview(player, value, id)
    -- broadcastToAll("Sheets preview: open_preview called", {0.3,0.7,0.3})
    -- Clear tooltip so it doesn't persist
    pcall(function()
        UI.setAttribute("sheetsSendBtn", "tooltip", "")
        UI.setAttribute("sheetsSendBtn", "tooltipBackgroundColor", "")
    end)
    pcall(function() Global.call("refresh_player_steam_name_cache_from_seated") end)
    -- Prefer the stored game roster so a player leaving does not drop them from the sheet snapshot.
    local active = get_sheets_player_roster()
    -- broadcastToAll("Sheets preview: open_preview active count=" .. tostring(#active), {0.3,0.7,0.3})
    -- Debug: broadcast resolved names to help diagnose empty name issue
    local resolved = {}
    for _, p in ipairs(active) do
        local name = nil
        if type(p) == "table" and p.color then
            -- Try cached steam name first, then live Player reference
            local cached_name = nil
            pcall(function() cached_name = Global.call("get_cached_steam_name", p.color) end)
            if cached_name and cached_name ~= "" and cached_name ~= p.color then
                name = cached_name
            else
                local ok, pl = pcall(function() return Player[p.color] end)
                if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                    name = pl.steam_name
                else
                    name = p.color
                end
            end
        elseif type(p) == "string" then
            -- Try cached steam name first, then live Player reference
            local cached_name = nil
            pcall(function() cached_name = Global.call("get_cached_steam_name", p) end)
            if cached_name and cached_name ~= "" and cached_name ~= p then
                name = cached_name
            else
                local ok, pl = pcall(function() return Player[p] end)
                if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
            end
        else
            name = tostring(p)
        end
        table.insert(resolved, name)
    end
    if #resolved == 0 then
        -- broadcastToAll("Sheets Preview: no active players found", {1,0.5,0})
    else
        -- broadcastToAll("Sheets Preview players: " .. table.concat(resolved, ", "), {0.2,0.8,0.2})
    end
    local previewXml = generate_preview_xml(active)
    -- Announce where collected game data/results can be viewed when opening preview
    pcall(function()
        broadcastToAll("All collected data / game results can be viewed here: https://laurens1234.github.io/arcs-arsenal/data")
    end)
    UI.setXml(previewXml)
end

_G["open_sheets_preview_ui"] = open_preview

-- Build payload from active players and send to the webhook (used by preview Send Now)
local function send_preview_to_sheet(player, value, id)
    pcall(function() Global.call("refresh_player_steam_name_cache_from_seated") end)
    local active = get_sheets_player_roster()
    local rows = {}
    for _, p in ipairs(active) do
        local color = nil
        local name = nil
        if type(p) == "table" and p.color then
            color = p.color
            local ok, pl = pcall(function() return Player[p.color] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p.color end
        elseif type(p) == "string" then
            color = p
            local ok, pl = pcall(function() return Player[p] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
        else
            name = tostring(p)
        end

        local arcs_player = nil
        if color then
            local ok, ap = pcall(function() return get_arcs_player(color) end)
            if ok and ap then arcs_player = ap end
        elseif type(p) == "table" and p.color then arcs_player = p end

        local power = ""; local objective = ""; local hand_size = ""; local tycoon = ""; local captives = ""; local trophies = ""; local keeper = ""; local empath = ""
        if arcs_player and type(arcs_player.update_score) == "function" then
            pcall(function() arcs_player:update_score() end)
            power = arcs_player.power or ""
            objective = arcs_player.objective or ""
            hand_size = arcs_player.hand_size or ""
            tycoon = arcs_player.tycoon or ""
            captives = arcs_player.captives or ""
            trophies = arcs_player.trophies or ""
            keeper = arcs_player.keeper or ""
            empath = arcs_player.empath or ""

            -- try to read actual score_board labels if present
            local sb = arcs_player.score_board
            if not sb and arcs_player.color then
                local sb_guid = get_player_guid(arcs_player.color, "score_board")
                if sb_guid then pcall(function() sb = getObjectFromGUID(sb_guid) end) end
            end
            local score_labels = read_score_button_labels(sb, {
                power = power,
                objective = objective,
                hand_size = hand_size,
                tycoon = tycoon,
                captives = captives,
                trophies = trophies,
                keeper = keeper,
                empath = empath,
            })
            power = score_labels.power
            objective = score_labels.objective
            hand_size = score_labels.hand_size
            tycoon = score_labels.tycoon
            captives = score_labels.captives
            trophies = score_labels.trophies
            keeper = score_labels.keeper
            empath = score_labels.empath
        end

        -- detect initiative for this row as well
        local initiative_player = resolve_initiative_player_color()
        local has_initiative = false
        if initiative_player and color and tostring(initiative_player) == tostring(color) then has_initiative = true end

        table.insert(rows, {
            full_name = name,
            name = name,
            color = color,
            initiative = has_initiative,
            power = power,
            objective = objective,
            hand_size = hand_size,
            tycoon = tycoon,
            captives = captives,
            trophies = trophies,
            keeper = keeper,
            empath = empath,
        })
    end

    -- Prefer using the last preview rows if available so the posted payload matches the preview
    local rows_to_send = nil
    if last_preview_rows and type(last_preview_rows) == "table" and #last_preview_rows > 0 then
        rows_to_send = last_preview_rows
    else
        rows_to_send = rows
    end

    -- Always refresh names from current cache/live seat state so seat-takeovers
    -- override any stale preview name values for the same color.
    if rows_to_send and type(rows_to_send) == "table" then
        for _, row in ipairs(rows_to_send) do
            local color = row and row.color
            if color and color ~= "" then
                local updated_name = nil
                local cached_name = nil
                pcall(function() cached_name = Global.call("get_cached_steam_name", color) end)
                if cached_name and cached_name ~= "" and cached_name ~= color then
                    updated_name = cached_name
                else
                    local ok, pl = pcall(function() return Player[color] end)
                    if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                        updated_name = pl.steam_name
                    else
                        updated_name = color
                    end
                end
                row.full_name = updated_name
                row.name = updated_name
            end
        end
    end

    -- Apply anonymization if checkbox is enabled
    if last_anonymize_names and rows_to_send and type(rows_to_send) == "table" and #rows_to_send > 0 then
    --    broadcastToAll("Sheets: applying anonymization to " .. tostring(#rows_to_send) .. " rows", {0.2, 0.8, 0.2})
        local anon_rows = {}
        for i, row in ipairs(rows_to_send) do
            local anon_row = {}
            for k, v in pairs(row) do
                if k == "full_name" or k == "name" then
                    anon_row[k] = "Player " .. tostring(i)
                else
                    anon_row[k] = v
                end
            end
            table.insert(anon_rows, anon_row)
        end
        rows_to_send = anon_rows
    else
   --     broadcastToAll("Sheets: anonymize_names=" .. tostring(last_anonymize_names) .. ", rows=" .. tostring(rows_to_send and #rows_to_send or 0), {0.8, 0.6, 0.2})
    end

    -- Capture notes from the stored global
    local notes = last_notes or ""
    broadcastToAll("Sheets: notes being sent: " .. tostring(notes), {0.8, 0.8, 0.2})

    -- Get game ID from Global
    local game_id = ""
    pcall(function()
        game_id = Global.getVar("game_id") or ""
    end)
    broadcastToAll("Sheets: game_id being sent: " .. tostring(game_id), {0.8, 0.8, 0.2})

    local payload = { game_id = game_id, players = rows_to_send, notes = notes, act = last_selected_act }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Debug: show payload being sent (truncated)
    local dbg = body_json
    if #dbg > 1200 then dbg = dbg:sub(1,1200) .. "... (truncated)" end
    broadcastToAll("Sheets: sending JSON payload (truncated): " .. tostring(dbg), {0.2,0.5,1})

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available", {1,0,0})
        return
    end

    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            _broadcast_response(response)
        end)
    end)
    if not ok then broadcastToAll("Sheets: WebRequest.custom error: " .. tostring(err), {1,0,0}) end
    -- close preview after send
    pcall(function() loadCameraTimerMenu(true) end)
end

_G["send_preview_to_sheet_ui"] = send_preview_to_sheet
_G["update_notes_field"] = update_notes_field
_G["update_act_dropdown"] = update_act_dropdown
_G["update_anonymize_checkbox"] = update_anonymize_checkbox

local function send_remove_request(player, value, id)
    -- `player` is the color string of the requester when called from UI
    local requester_color = ""
    local requester_name = ""
    local pt = type(player)
    -- `player` may be a color string, a table, or a Player userdata object
    if pt == "string" then
        requester_color = tostring(player)
    elseif pt == "table" or pt == "userdata" then
        -- try to read `.color` and `.steam_name` safely
        pcall(function()
            if player.color then requester_color = tostring(player.color) end
        end)
        pcall(function()
            if player.steam_name and player.steam_name ~= "" then requester_name = player.steam_name end
        end)
        -- some userdata may offer getColor()
        if requester_color == "" then
            pcall(function()
                if player.getColor then requester_color = tostring(player.getColor()) end
            end)
        end
    else
        requester_color = tostring(player or "")
    end

    -- fallback: try Player[color] lookup for steam_name
    if (not requester_name or requester_name == "") and requester_color and requester_color ~= "" then
        pcall(function()
            local pl = Player[requester_color]
            if pl and pl.steam_name and pl.steam_name ~= "" then requester_name = pl.steam_name end
        end)
    end

    -- final fallback to something readable
    if not requester_name or requester_name == "" then
        if requester_color and requester_color ~= "" then requester_name = requester_color else requester_name = tostring(player or "") end
    end

    -- Apply anonymization to requester name if checkbox is enabled
    if last_anonymize_names then
        requester_name = "Requester"
    end

    local game_id = ""
    pcall(function() game_id = Global.getVar("game_id") or "" end)

    local payload = {
        action = "remove_request",
        game_id = game_id,
        notes = last_notes or "",
        requester = requester_name,
        requester_color = requester_color,
        timestamp = os.time()
    }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    broadcastToAll("Sheets: sending remove request for game " .. tostring(game_id) .. " from " .. tostring(requester_name), {1,0.6,0.6})

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available; cannot send remove request", {1,0,0})
        return
    end

    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            if response and response.is_error then
                local text = (response and response.text) and response.text or tostring(response)
                broadcastToAll("Sheets: remove request failed - " .. tostring(text), {1,0,0})
            else
                broadcastToAll("Sheets: remove request sent", {0.8, 0.9, 1})
                if response and response.text then broadcastToAll("Sheets response: " .. tostring(response.text), {0.8,0.9,1}) end
            end
        end)
    end)
    if not ok then broadcastToAll("Sheets: WebRequest.custom error sending remove request: " .. tostring(err), {1,0,0}) end
    -- close preview after request
    pcall(function() loadCameraTimerMenu(true) end)
end

_G["send_remove_request_ui"] = send_remove_request

function SheetsSender.generateButtonXml()
    return [[
        <VerticalLayout
    id="sheetsSenderLayout"
    allowDragging="true"
    returnToOriginalPositionWhenReleased="false"
    rectAlignment="UpperRight"
    anchorMin="1 1"
    anchorMax="1 1"
    offsetXY="0 -150"
        width="105"
    height="60"
        childForceExpandHeight="false"
        childForceExpandWidth="false"
        >
        <Button
            id="sheetsSendBtn"
            onClick="open_sheets_preview_ui"
            text="Submit Results"
            textColor="white"
            color="#2e8b57"
            tooltipBackgroundColor="#2e8b57"
            tooltipTextColor="Black"
            width="95"
            height="40"
            preferredWidth="95"
            preferredHeight="40"
            fontSize="14"
            />
    </VerticalLayout>
    ]]
end

return SheetsSender

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
__bundle_register("src/Timer", function(require, _LOADED, __bundle_register, __bundle_modules)
local Timer = {}

Timer.player_timers = {}
Timer.running = false
Timer.start_time = 0
Timer.timer_id = nil

function startTimer() Timer.start(active_players); loadCameraTimerMenu() end
function pauseTimer() Timer.pause(); loadCameraTimerMenu(true) end
function resetTimer() Timer.reset(); loadCameraTimerMenu(true) end

function onPlayPauseTimer(player, value, id)
    if Timer.running then
        pauseTimer()
    else
        startTimer()
    end
    loadCameraTimerMenu(true)
end

function Timer.start(active_players)    
    if Timer.running then return end

    if not Turns.turn_color or Turns.turn_color == "" then
        broadcastToAll("No active turn - please use the turn system", {1, 0, 0})
        return
    end

    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
    end
    
    Timer.running = true
    Timer.start_time = os.time()
    Timer.timer_id = Wait.time(function() Timer.update(active_players) end, 1, -1)
end

function Timer.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function Timer.pause()
    if not Timer.running then return end

    Timer.running = false

    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
        Timer.timer_id = nil
    end
end

function Timer.reset()
    Timer.running = false
    Timer.start_time = 0
    for _, color in ipairs({"Red", "White", "Yellow", "Teal", "Pink"}) do
        Timer.player_timers[color] = 0
        Timer.updateDisplay(color)
    end
    UI.setValue("totalTime", Timer.formatTime(0))
    if Timer.timer_id then
        Wait.stop(Timer.timer_id)
        Timer.timer_id = nil
    end
end

function Timer.update(active_players)
    if Timer.running and Turns.turn_color then
        -- Update the current player's total time
        if not Timer.player_timers[Turns.turn_color] then
            Timer.player_timers[Turns.turn_color] = 0
        end
        Timer.player_timers[Turns.turn_color] = Timer.player_timers[Turns.turn_color] + 1
        
        -- Update display for all players
        for _, player in ipairs(active_players) do
            local timerId = player.color:lower() .. "Timer"
            Timer.updateDisplay(player.color)
            if player.color == Turns.turn_color then
                UI.setAttribute(timerId, "fontStyle", "Bold")
                UI.setAttribute(timerId, "fontSize", "16")
            else
                UI.setAttribute(timerId, "fontStyle", "Normal")
                UI.setAttribute(timerId, "fontSize", "12")
            end
        end

        UI.setValue("totalTime", Timer.formatTime(Timer.getTotalTime()))
    end
end

function Timer.updateDisplay(color)
    local seconds = Timer.player_timers[color] or 0
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    local display = string.format("%02d:%02d", minutes, seconds)
    UI.setValue(color:lower() .. "Timer", display)
end

function Timer.generatePlayerTimerDisplays(active_players)
    local playerTimersXml = ""
    local buttonColors = {
        Red = "#FF0000",
        White = "#FFFFFF",
        Yellow = "#FFFF00",
        Teal = "#00FFFF",
        Pink = "#FF69B4"
    }

    for _, player in ipairs(active_players) do
        local isActive = player.color == Turns.turn_color
        local currentTime = Timer.player_timers[player.color] or 0
        local timeDisplay = Timer.formatTime(currentTime)
        
        playerTimersXml = playerTimersXml .. string.format(
            [[<HorizontalLayout spacing="5">
                <Text id="%sTimer" text="%s" color="%s" fontSize="12" fontStyle="%s" preferredWidth="25" preferredHeight="13"/>
                <Button text="%s" id="%sCamera" textColor="%s" onClick="on%sBoardClick" preferredWidth="28"/>
            </HorizontalLayout>]],
            player.color:lower(),
            timeDisplay,
            buttonColors[player.color],
            isActive and "Bold" or "Normal",
            player.color,
            player.color:lower(),
            buttonColors[player.color],
            player.color
        )
    end
    
    return playerTimersXml
end

function Timer.getTotalTime()
    local total = 0
    for _, color in ipairs({"Red", "White", "Yellow", "Teal", "Pink"}) do
        total = total + (Timer.player_timers[color] or 0)
    end
    return total
end

function Timer.generateTimerControls(timer_running, active_players)
    -- Only show timer controls if there are 2 or more players
    if not active_players or #active_players < 2 then
        return ""
    end

    return string.format([[
        <!-- Timer Controls at bottom -->
        <HorizontalLayout spacing="5">
            <Text id="totalTime" text="%s" color="#808080" fontSize="12" preferredWidth="25" preferredHeight="13"/>
            <Button text="%s" id="playPauseButton" textColor="White" onClick="onPlayPauseTimer" width="30" flexibleWidth="0"/>
            <Button text="↺" id="resetTimer" textColor="Grey" onClick="resetTimer" width="30" fontStyle="Normal" tooltip="Reset all timers back to 0"/>
        </HorizontalLayout>
    ]], Timer.formatTime(Timer.getTotalTime()), timer_running and "||" or "▶")
end

return Timer
end)
__bundle_register("src/Camera", function(require, _LOADED, __bundle_register, __bundle_modules)
local Timer = require("src/Timer")
local SheetsSender = require("src/SheetsSender")

local Camera = {}

-- note that these onClick functions are used by wrapper functions in Global.lua
function onCourtClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=22.26, y=1.49, z=0.0},
        pitch = 70,
        yaw = 90,
        distance = 10
    })
end

function onActionCardsClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-14.0, y=1.49, z=-1.65},
        pitch = 70,
        yaw = 270,
        distance = 12
    })
end

function onDiceBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-28.0, y=1.07, z=-15.22},
        pitch = 80,
        yaw = 0,
        distance = 18
    })
end

function onMapClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=2.79, y=0.98, z=-3.0},
        pitch = 70,
        yaw = 0,
        distance = 42
    })
end

function onRedBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-10.6, y=1.48, z=14.92},
        pitch = 80,
        yaw = 0,
        distance = 13
    })
end

function onWhiteBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=13.14, y=1.48, z=14.92},
        pitch = 80,
        yaw = 0,
        distance = 13
    })
end

function onYellowBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=13.14, y=1.48, z=-16.12},
        pitch = 80,
        yaw = 0,
        distance = 13
    })
end

function onTealBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=-10.6, y=1.48, z=-16.12},
        pitch = 80,
        yaw = 0,
        distance = 13
    })
end

function onPinkBoardClick(player, value, id)
    Player[player.color].lookAt({
        position = {x=36.7, y=1.48, z=-16.5},
        pitch = 80,
        yaw = 0,
        distance = 13
    })
end

function loadCameraTimerMenu(menuOpen)
    -- if menuOpen is nil, leave the cameraControls active state alone
    if menuOpen == nil then
        menuOpen = UI.getAttribute("cameraControls", "active")
    end

    local controlsXml = Camera.generateControlsXml(active_players, Timer.running)
    local sheetsXml = SheetsSender.generateButtonXml()
    local menuXml = Camera.generateMenuXml(menuOpen, controlsXml, sheetsXml)
    UI.setXml(menuXml)
end

function toggleCameraControls(player, value, id)
    local isOpen = UI.getAttribute("cameraControls", "active") == "true"
    loadCameraTimerMenu(not isOpen)
end

-- note that these onClick functions reference the wrapper functions in Global.lua
function Camera.generateControlsXml(active_players, timer_running)
    return string.format([[
        <VerticalLayout spacing="10">
            <!-- Camera Controls in pairs -->
            <HorizontalLayout spacing="5">
                <Button text="Action" id="actionCardsCamera" textColor="Grey" onClick="onActionCardsClick" width="85"/>
                <Button text="Court" id="courtCamera" textColor="Grey" onClick="onCourtClick" width="85"/>
            </HorizontalLayout>
            <HorizontalLayout spacing="5">
                <Button text="Dice" id="diceCamera" textColor="Grey" onClick="onDiceBoardClick" width="85"/>
                <Button text="Map" id="mapCamera" textColor="Grey" onClick="onMapClick" width="85"/>
            </HorizontalLayout>

            <!-- Player Timer Displays -->
            %s

            %s
        </VerticalLayout>
    ]], Timer.generatePlayerTimerDisplays(active_players),
        Timer.generateTimerControls(timer_running, active_players)
    )
end

function Camera.generateMenuXml(menuOpen, controlsXml, sheetsXml)
    return string.format([[
        <Defaults>
            <Button color="black" fontSize="12" />
            <Button class="cameraControl" onClick="onCameraClick" />
        </Defaults>

        <VerticalLayout
            id="cameraLayout"
            height="320"
            width="95"
            allowDragging="true"
            returnToOriginalPositionWhenReleased="false"
            rectAlignment="UpperRight"
            anchorMin="1 1"
            anchorMax="1 1"
            offsetXY="-7 -250"
            spacing="5"
            childForceExpandHeight="false"
            childForceExpandWidth="true"
            >
            <Button
                onClick="toggleCameraControls"
                text="Camera Controls"
                textColor="white"
                color="Grey"
                tooltip="Toggle camera controls / timer"
                tooltipBackgroundColor="Grey"
                tooltipTextColor="Black"
                >
            </Button>
            
            <VerticalLayout
                id="cameraControls"
                height="320"
                width="95"
                active="%s"
                >
                %s
            </VerticalLayout>
        </VerticalLayout>

        %s
    ]], tostring(menuOpen), controlsXml, sheetsXml)
end

return Camera
end)
__bundle_register("src/SetupControl", function(require, _LOADED, __bundle_register, __bundle_modules)
local ArcsPlayer = require("src/ArcsPlayer")
local ActionCards = require("src/ActionCards")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Counters = require("src/Counters")

local GOLD = {0.8, 0.58, 0.27}
local BLACK = {0.05, 0.05, 0.05}
local GREEN = {0.2, 0.5, 0.2}
local PURPLE = {0.5, 0.3, 0.7}
local RED = {0.8, 0.3, 0.2}
local LIGHT_GREY = {0.8, 0.8, 0.8}
local HEADER_FONT_SIZE = 170
local HEADER_SCALE = {0.6, 0.6, 0.6}
local HEADER_WIDTH = 0
local HEADER_HEIGHT = 0
local BUTTON_FONT_SIZE = 140
local BUTTON_SCALE = {0.3, 0.6, 0.6}
local BUTTON_WIDTH = 1500
local BUTTON_HEIGHT = 380

local setupTableImageOptions = {
    {
        name = "Default",
        diffuse = "https://steamusercontent-a.akamaihd.net/ugc/15297536227112862/B09A1DE0302BFED6AFF653116F56B110B73F024B/"
    },
    {
        name = "Planets 1",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_1.png"
    },
    {
        name = "Planets 2",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_2.png"
    },
    {
        name = "Planets 3",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_3.png"
    },
    {
        name = "Planets 4",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_4.png"
    },
    {
        name = "Planets 5",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_5.png"
    },
    {
        name = "Beyond",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/Beyond_1.png"
    },
}

local setupBackgroundOptions = {
    {
        name = "Custom Sky",
        kind = "custom",
        value = "https://steamusercontent-a.akamaihd.net/ugc/2128570108363703240/7C119AE30B36149F36C42DFD03F43566BD5E18EC/"
    }
}

local optionsText_params = {
    click_function = "doNothing",
    function_owner = self,
    label = "Options",
    tooltip = "Toggle the below options to modify the game setup",
    position = {-0.52, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}


local toggleLeadersWITHOUT_params = {
    index = 1,
    click_function = "toggle_leaders",
    function_owner = self,
    label = " Leaders & Lore ",
    tooltip = "Enable Leaders & Lore mode for base game (8 leaders, 14 lore)",
    position = {-0.51, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleLeadersWITH_params = {
    index = 1,
    click_function = "toggle_leaders",
    function_owner = self,
    label = " Leaders & Lore ",
    tooltip = "Disable Leaders & Lore mode for base game",
    position = {-0.51, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local toggleExpansionEXCLUDE_params = {
    index = 2,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion Pack",
    tooltip = "Enable Leaders & Lore Expansion Pack (16 total leaders, 28 total lore)",
    position = {-0.51, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleExpansionINCLUDE_params = {
    index = 2,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion Pack",
    tooltip = "Disable Leaders & Lore Expansion Pack",
    position = {-0.51, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local splitDiscardFACEDOWN_params = {
    index = 3,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Reveal face-up played action cards to all players throughout the game",
    position = {-0.51, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local splitDiscardFACEUP_params = {
    index = 3,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Use single face-down discard pile for action cards",
    position = {-0.51, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local miniaturesDISABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Enable Miniatures",
    position = {-0.51, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local miniaturesENABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Disable Miniatures",
    position = {-0.51, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}

local toggleLaurensEXCLUDE_params = {
    index = 9,
    click_function = "toggle_laurens_custom",
    function_owner = self,
    label = " Celestial Leaders\n Expansion",
    tooltip = "Include Celestial Leaders Expansion made by Laurens https://laurens1234.github.io/arcs-arsenal/custom-cards",
    position = {-1.54, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleLaurensINCLUDE_params = {
    index = 9,
    click_function = "toggle_laurens_custom",
    function_owner = self,
    label = "Celestial Leaders\n Expansion",
    tooltip = "Exclude Celestial Leaders Expansion made by Laurens https://laurens1234.github.io/arcs-arsenal/custom-cards",
    position = {-1.54, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local toggleDontUseBasePackEXCLUDE_params = {
    index = 10,
    click_function = "toggle_dont_use_base_pack",
    function_owner = self,
    label = " Don't use\n Base & Pack Leaders",
    tooltip = "Remove base and pack leaders from setup",
    position = {-1.54, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = RED
}
local toggleDontUseBasePackINCLUDE_params = {
    index = 10,
    click_function = "toggle_dont_use_base_pack",
    function_owner = self,
    label = " Don't use\n Base & Pack Leaders",
    tooltip = "Restore base and pack leaders in setup",
    position = {-1.54, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = RED,
    font_color = BLACK,
    hover_color = GREEN
}
local leaderCountDec_params = {
    index = 11,
    click_function = "leader_count_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease leader draft count",
    position = {-1.85, 0.5, 0},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local leaderCountDisplay_params = {
    index = 12,
    click_function = "doNothing",
    function_owner = self,
    label = "",
    tooltip = "Leader draft count",
    position = {-1.54, 0.5, 0},
    width = 300,
    height = 220,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local leaderCountInc_params = {
    index = 13,
    click_function = "leader_count_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase leader draft count",
    position = {-1.23, 0.5, 0},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local loreCountDec_params = {
    index = 14,
    click_function = "lore_count_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease lore draft count",
    position = {-1.85, 0.5, 0.59},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local loreCountDisplay_params = {
    index = 15,
    click_function = "doNothing",
    function_owner = self,
    label = "",
    tooltip = "Lore draft count",
    position = {-1.54, 0.5, 0.59},
    width = 300,
    height = 220,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local loreCountInc_params = {
    index = 16,
    click_function = "lore_count_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase lore draft count",
    position = {-1.23, 0.5, 0.59},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local setDefault_params = {
    index = 17,
    click_function = "set_default_counts",
    function_owner = self,
    label = "Set default\nL&L count",
    tooltip = "Set Leaders and Lore to player_count + 1",
    position = {-1.54, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}
local setupChoice_params = {
    index = 21,
    click_function = "cycle_setup_choice",
    function_owner = self,
    label = "Setup: Random",
    tooltip = "Cycle chosen setup for current player count (Random -> option -> ... -> Random)",
    position = {-2.56, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}
local setupTableImage_params = {
    index = 27,
    click_function = "cycle_setup_table_image",
    function_owner = self,
    label = "Table Image:\nDefault",
    tooltip = "Choose the table surface",
    position = {-2.56, 0.5, 1.18},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}

local setupBackground_params = {
    index = 31,
    click_function = "cycle_setup_background",
    function_owner = self,
    label = "Background:\nSky Field",
    tooltip = "Choose the sky/background image",
    position = {-2.56, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}

local setupTableBrightnessDec_params = {
    index = 28,
    click_function = "setup_table_brightness_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease setup table brightness",
    position = {-2.87, 0.5, 1.77},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local setupTableBrightnessDisplay_params = {
    index = 29,
    click_function = "doNothing",
    function_owner = self,
    label = "Brightness:\n1.00",
    tooltip = "Current setup table brightness",
    position = {-2.56, 0.5, 1.77},
    width = 600,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local setupTableBrightnessInc_params = {
    index = 30,
    click_function = "setup_table_brightness_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase setup table brightness",
    position = {-2.25, 0.5, 1.77},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local initiativeChoice_params = {
    index = 22,
    click_function = "cycle_initiative_choice",
    function_owner = self,
    label = "Initiative: Random",
    tooltip = "Choose which player color gets initiative at game start (Random -> player -> ...)",
    position = {-2.56, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}
local setupStartGame_params = {
    click_function = "doNothing",
    function_owner = self,
    label = "Start",
    tooltip = "Once all players have joined, and options are set",
    position = {0.52, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local setupBaseGame_params = {
    index = 6,
    click_function = "setup_base_game",
    function_owner = self,
    label = "Base Game \nSetup",
    position = {0.52, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local setupCampaignGame_params = {
    index = 7,
    click_function = "setup_campaign",
    function_owner = self,
    label = "Campaign \nSetup",
    position = {0.52, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local customSetup_params = {
    index = 8,
    function_owner = self,
    click_function = "custom_setup",
    label = "Manual \nSetup",
    tooltip = "",
    position = {0.52, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local toggleScavengersEXCLUDE_params = {
    index = 18,
    click_function = "toggle_scavengers",
    function_owner = self,
    label = "PnP#1 Scavengers\n & Scouts Deck",
    tooltip = "Include PnP#1 Scavengers & Scouts deck in setup intead of base court deck",
    position = {-0.51, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    -- border = {0.4235294117647059, 0.13725490196078433, 0.08627450980392157},
    hover_color = GREEN
}
local toggleScavengersINCLUDE_params = {
    index = 18,
    click_function = "toggle_scavengers",
    function_owner = self,
    label = "PnP#1 Scavengers\n & Scouts Deck",
    tooltip = "Exclude PnP#1 Scavengers & Scouts deck from setup",
    position = {-0.51, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local togglePnp3EXCLUDE_params = {
    index = 20,
    click_function = "toggle_pnp3_custom",
    function_owner = self,
    label = " PnP#3\n Fated Leaders",
    tooltip = "Include PnP#3 fated leader deck in setup",
    position = {-0.51, 0.5, 3.47},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local togglePnp3INCLUDE_params = {
    index = 20,
    click_function = "toggle_pnp3_custom",
    function_owner = self,
    label = " PnP#3\n Fated Leaders",
    tooltip = "Exclude PnP#3 fated leader deck from setup",
    position = {-0.51, 0.5, 3.47},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local togglePnp2EXCLUDE_params = {
    index = 19,
    click_function = "toggle_pnp2_custom",
    function_owner = self,
    label = " PnP#2\n Lost Vaults",
    tooltip = "Include PnP#2 Lost Vaults in setup",
    position = {-0.51, 0.5, 2.9},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local togglePnp2INCLUDE_params = {
    index = 19,
    click_function = "toggle_pnp2_custom",
    function_owner = self,
    label = " PnP#2\n Lost Vaults",
    tooltip = "Exclude PnP#2 Lost Vaults from setup",
    position = {-0.51, 0.5, 2.9},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}

local beyondTheReach_params = {
    index = 23,
    click_function = "doNothing",
    function_owner = self,
    label = "Beyond \nthe Reach",
    tooltip = "",
    position = {-0.51, 0.5, 1.77},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local celestial_params = {
    index = 24,
    click_function = "doNothing",
    function_owner = self,
    label = "Celestial",
    tooltip = "",
    position = {-1.54, 0.5, 1.77},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local leader_lore_controls_header_params = {
    index = 25,
    click_function = "doNothing",
    function_owner = self,
    label = "L&L\nOptions",
    tooltip = "",
    position = {-1.54, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local setup_controls_header_params = {
    index = 26,
    click_function = "doNothing",
    function_owner = self,
    label = "Setup\nOptions",
    tooltip = "",
    position = {-2.56, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
SetupControl = {
    setup_control_guid = "7299d7",
    setup_control = {},
    teal = {0.4, 0.6, 0.6}
}

function SetupControl:new(o)
    o = o or SetupControl -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function onload()
    -- compute sensible defaults for leader/lore counts so display buttons start with numbers
    local function initial_resolved_default_count()
        -- Count seated players whose colors are in `available_colors`
        local ordered = Global.call("getOrderedPlayers", {true}) or {}
        local n = 0
        local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
        for _, p in ipairs(ordered) do
            for _, c in ipairs(colors) do
                if p.color == c then
                    n = n + 1
                    break
                end
            end
        end
        if n >= 2 and n <= 5 then
            return n + 1
        end
        local dbg = Global.getVar("debug_player_count") or 3
        return dbg + 1
    end
    local stored_lcount = Global.getVar("leader_draft_count")
    local stored_locount = Global.getVar("lore_draft_count")
    leaderCountDisplay_params.label = "Leaders:\n" .. (stored_lcount and tostring(stored_lcount) or "Default")
    loreCountDisplay_params.label = "Lore:\n" .. (stored_locount and tostring(stored_locount) or "Default")

    self.createButton(optionsText_params)
    self.createButton(toggleLeadersWITHOUT_params)
    self.createButton(toggleExpansionEXCLUDE_params)
    self.createButton(splitDiscardFACEDOWN_params)
    self.createButton(miniaturesDISABLED_params)
    self.createButton(setupStartGame_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    self.createButton(customSetup_params)
    self.createButton(toggleLaurensEXCLUDE_params)
    self.createButton(toggleDontUseBasePackEXCLUDE_params)
    -- Leader/Lore draft count controls
    self.createButton(leaderCountDec_params)
    self.createButton(leaderCountDisplay_params)
    self.createButton(leaderCountInc_params)
    self.createButton(loreCountDec_params)
    self.createButton(loreCountDisplay_params)
    self.createButton(loreCountInc_params)
    self.createButton(setDefault_params)
    self.createButton(toggleScavengersEXCLUDE_params)
    self.createButton(togglePnp2EXCLUDE_params)
    self.createButton(togglePnp3EXCLUDE_params)
    self.createButton(setupChoice_params)
    self.createButton(initiativeChoice_params)
    self.createButton(beyondTheReach_params)
    self.createButton(celestial_params)
    self.createButton(leader_lore_controls_header_params)
    self.createButton(setup_controls_header_params)
    self.createButton(setupTableImage_params)
    self.createButton(setupTableBrightnessDec_params)
    self.createButton(setupTableBrightnessDisplay_params)
    self.createButton(setupTableBrightnessInc_params)
    -- self.createButton(setupBackground_params)

    -- must add buttons in the order of the actual indices !!!!!!!!!! lowest in here must have highest index

    -- Initialize numeric display labels from globals (resolve default if nil)
    local function resolved_default_count()
        -- Prefer seated players in allowed `available_colors` for defaults
        local ordered = Global.call("getOrderedPlayers", {true}) or {}
        local n = 0
        local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
        for _, p in ipairs(ordered) do
            for _, c in ipairs(colors) do
                if p.color == c then
                    n = n + 1
                    break
                end
            end
        end
        if n >= 2 and n <= 5 then
            return n + 1
        end
        local dbg = Global.getVar("debug_player_count") or 3
        return dbg + 1
    end
    local lcount = Global.getVar("leader_draft_count")
    local locount = Global.getVar("lore_draft_count")
    -- Ensure buttons reflect stored values; show "Default" when unset
    if lcount then
        self.editButton({index=12, label = "Leaders:\n" .. tostring(lcount)})
    else
        self.editButton({index=12, label = "Leaders:\nDefault"})
    end
    if locount then
        self.editButton({index=15, label = "Lore:\n" .. tostring(locount)})
    else
        self.editButton({index=15, label = "Lore:\nDefault"})
    end
    -- Initialize setup choice display
    do
        local sc_index = Global.getVar("setup_choice_index") or 0
        local sc_pcount = Global.getVar("setup_choice_player_count")
        local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
        local pcount = #active
        local display_label = "Setup: Random"
        if sc_index and sc_index >= 1 and sc_pcount == pcount then
            local opts = BaseGame.getSetupOptions(pcount) or {}
            if opts[sc_index] and opts[sc_index].name then
                display_label = "Setup: " .. tostring(sc_index) .. "\n" .. tostring(opts[sc_index].name)
            end
        end
        self.editButton({index=21, label = display_label})
    end
    -- Initialize table image display
    do
        local table_image_index = Global.getVar("setup_table_image_index") or 0
        local option = setupTableImageOptions[table_image_index + 1] or setupTableImageOptions[1]
        self.editButton({index=27, label = "Table Image:\n" .. tostring(option.name or "Default")})
    end
    -- Initialize brightness (default 1.0) and display
    do
        local b = Global.getVar("setup_table_brightness") or 1.0
        Global.setVar("setup_table_brightness", b)
        self.editButton({index=29, label = "Brightness:\n" .. string.format("%.2f", b)})
    end
    -- Initialize background display
    -- do
    --     local bg_name = "Sky Field"
    --     pcall(function()
    --         local custom_url = Backgrounds.getCustomURL()
    --         if custom_url and custom_url ~= "" then
    --             bg_name = "Custom Sky"
    --         else
    --             local current_bg = Backgrounds.getBackground()
    --             if current_bg and current_bg ~= "" then
    --                 bg_name = tostring(current_bg)
    --             end
    --         end
    --     end)
    --     self.editButton({index=31, label = "Background:\n" .. tostring(bg_name)})
    -- end
    -- Initialize initiative choice display
    do
        local ic_index = Global.getVar("initiative_choice_index") or 0
        local ic_pcount = Global.getVar("initiative_choice_player_count")
        local ic_color = Global.getVar("initiative_choice_color")
        local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
        local pcount = #active
        local display_label = "Initiative: Random"
        if ic_color and ic_pcount == pcount then
            display_label = "Initiative: " .. tostring(ic_index) .. "\n" .. tostring(ic_color)
        elseif ic_index and ic_index >= 1 and ic_pcount == pcount then
            local colorname = (active[ic_index] and active[ic_index].color) or nil
            if colorname then
                display_label = "Initiative: " .. tostring(ic_index) .. "\n" .. tostring(colorname)
            end
        end
        self.editButton({index=22, label = display_label})
    end
end

function toggle_leaders(obj, color, alt_click)
    local toggle = Global.getVar("with_leaders")
    local expansion_toggle = Global.getVar("with_more_to_explore")

    toggle = not toggle
    Global.setVar("with_leaders", toggle)

    if (toggle) then
        self.editButton(toggleLeadersWITH_params)
    else
        self.editButton(toggleLeadersWITHOUT_params)
        if expansion_toggle then
            toggle_expansion()
        end
    end
end

function toggle_expansion()
    local toggle = Global.getVar("with_more_to_explore")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_more_to_explore", toggle)

    if (toggle) then
        self.editButton(toggleExpansionINCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(toggleExpansionEXCLUDE_params)
    end
end

function toggle_split_discard()
    local is_faceup_active = ActionCards.toggle_face_up_discard()
    if (is_faceup_active) then
        self.editButton(splitDiscardFACEUP_params)
    else
        self.editButton(splitDiscardFACEDOWN_params)
    end
end

function toggle_miniatures()
    local toggle = Global.getVar("with_miniatures")
    toggle = not toggle 
    Global.setVar("with_miniatures", toggle)
    if (toggle) then
        self.editButton(miniaturesENABLED_params)
        -- Hide meeples, show miniatures
        BaseGame.miniatures_visibility(true)
    else
        self.editButton(miniaturesDISABLED_params)
        -- Show meeples, hide miniatures
        BaseGame.miniatures_visibility(false)
    end
end

function toggle_laurens_custom()
    local toggle = Global.getVar("with_laurens_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_laurens_custom_leader", toggle)

    if (toggle) then
        self.editButton(toggleLaurensINCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(toggleLaurensEXCLUDE_params)
    end
end

function toggle_pnp2_custom()
    local toggle = Global.getVar("with_pnp2_lost_vaults")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_pnp2_lost_vaults", toggle)

    if (toggle) then
        self.editButton(togglePnp2INCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(togglePnp2EXCLUDE_params)
    end
end

function toggle_pnp3_custom()
    local toggle = Global.getVar("with_pnp3_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_pnp3_custom_leader", toggle)

    if (toggle) then
        self.editButton(togglePnp3INCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(togglePnp3EXCLUDE_params)
    end
end

function toggle_dont_use_base_pack()
    local toggle = Global.getVar("dont_use_base_and_pack_leaders")
    toggle = not toggle
    Global.setVar("dont_use_base_and_pack_leaders", toggle)

    if (toggle) then
        self.editButton(toggleDontUseBasePackINCLUDE_params)
    else
        self.editButton(toggleDontUseBasePackEXCLUDE_params)
    end
end

function toggle_scavengers()
    local toggle = Global.getVar("use_scavengers_scouts_deck")

    toggle = not toggle
    Global.setVar("use_scavengers_scouts_deck", toggle)

    if (toggle) then
        self.editButton(toggleScavengersINCLUDE_params)
        
    else
        self.editButton(toggleScavengersEXCLUDE_params)
    end
end
-- Leader/Lore draft count controls
-- Resolve a sensible default (player_count + 1) using active players or debug fallback
local function resolved_default_count()
    -- Prefer seated players in allowed `available_colors` for defaults
    local ordered = Global.call("getOrderedPlayers", {true}) or {}
    local n = 0
    local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
    for _, p in ipairs(ordered) do
        for _, c in ipairs(colors) do
            if p.color == c then
                n = n + 1
                break
            end
        end
    end
    if n >= 2 and n <= 5 then
        return n + 1
    end
    local dbg = Global.getVar("debug_player_count") or 3
    return dbg + 1
end

local function display_count_label(count)
    return tostring(count)
end

function change_leader_count(obj, color, delta)
    local current = Global.getVar("leader_draft_count")
    if not current then current = resolved_default_count() end
    local count = math.max(1, math.min(100, current + delta))
    Global.setVar("leader_draft_count", count)
    self.editButton({index=12, label="Leaders:\n" .. display_count_label(count)})
end

function change_lore_count(obj, color, delta)
    local current = Global.getVar("lore_draft_count")
    if not current then current = resolved_default_count() end
    local count = math.max(1, math.min(28, current + delta))
    Global.setVar("lore_draft_count", count)
    self.editButton({index=15, label="Lore:\n" .. display_count_label(count)})
end

function leader_count_dec(obj, color, alt_click)
    change_leader_count(obj, color, -1)
end

function leader_count_inc(obj, color, alt_click)
    change_leader_count(obj, color, 1)
end

function lore_count_dec(obj, color, alt_click)
    change_lore_count(obj, color, -1)
end

function lore_count_inc(obj, color, alt_click)
    change_lore_count(obj, color, 1)
end

function set_default_counts(obj, color, alt_click)
    local def = resolved_default_count()
    Global.setVar("leader_draft_count", def)
    Global.setVar("lore_draft_count", def)
    -- Update displays with prefixes
    self.editButton({index=12, label = "Leaders:\n" .. tostring(def)})
    self.editButton({index=15, label = "Lore:\n" .. tostring(def)})
end

function cycle_setup_choice(obj, color, alt_click)
    -- Determine active players (use ordered players if available)
    local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
    local player_count = #active
    if player_count < 2 or player_count > 5 then
        broadcastToAll("Setup chooser requires 2-5 active players.", {r=1, g=0, b=0})
        return
    end

    local opts = BaseGame.getSetupOptions(player_count) or {}
    local N = #opts
    if N == 0 then
        broadcastToAll("No setup options configured for " .. tostring(player_count) .. " players", {r=1, g=0.5, b=0})
        return
    end

    local cur = Global.getVar("setup_choice_index") or 0
    local next_index = (cur + 1) % (N + 1) -- cycles 0..N (0 == random)
    Global.setVar("setup_choice_index", next_index)
    Global.setVar("setup_choice_player_count", player_count)

    local label
    if next_index == 0 then
        label = "Setup: Random"
    else
        local name = opts[next_index].name or tostring(next_index)
        label = "Setup: " .. "\n" .. tostring(name)
    end
    self.editButton({index=21, label = label})
end

local function get_setup_table_object()
    return getObjectFromGUID(setup_table_GUID)
end

local function get_setup_table_image_index()
    local index = Global.getVar("setup_table_image_index") or 0
    if index < 0 or index >= #setupTableImageOptions then
        return 0
    end
    return index
end

local function set_setup_table_noninteractable()
    local table_obj = get_setup_table_object()
    if not table_obj then
        return
    end

    table_obj.setLock(true)
    table_obj.interactable = false
end

local function apply_setup_table_tint(table_obj, option)
    if not table_obj then
        return
    end
    local base = (option and option.tint) or {r = 1, g = 1, b = 1}
    local brightness = Global.getVar("setup_table_brightness") or 1.0
    local final = {
        r = math.min(1, (base.r or 1) * brightness),
        g = math.min(1, (base.g or 1) * brightness),
        b = math.min(1, (base.b or 1) * brightness)
    }
    table_obj.setColorTint(final)
end

local function apply_setup_table_image(index)
    local table_obj = get_setup_table_object()
    if not table_obj then
        broadcastToAll("Setup table object not found.", {r=1, g=0, b=0})
        return false
    end

    local custom = table_obj.getCustomObject()
    if not custom then
        broadcastToAll("Setup table is not a custom model.", {r=1, g=0, b=0})
        return false
    end

    local option = setupTableImageOptions[index + 1] or setupTableImageOptions[1]
    custom.diffuse = option.diffuse
    table_obj.setCustomObject(custom)
    apply_setup_table_tint(table_obj, option)
    table_obj.reload()
    Wait.frames(function()
        set_setup_table_noninteractable()
    end, 1)
    return true
end

local function change_setup_table_brightness(delta)
    local cur = Global.getVar("setup_table_brightness") or 1.0
    local next = math.max(0, math.min(1, cur + delta))
    Global.setVar("setup_table_brightness", next)
    -- update display
    self.editButton({index=29, label = "Brightness:\n" .. string.format("%.2f", next)})
    -- reapply tint for current table option
    local idx = get_setup_table_image_index()
    local option = setupTableImageOptions[idx + 1] or setupTableImageOptions[1]
    local table_obj = get_setup_table_object()
    apply_setup_table_tint(table_obj, option)
end

function setup_table_brightness_dec(obj, color, alt_click)
    change_setup_table_brightness(-0.05)
end

function setup_table_brightness_inc(obj, color, alt_click)
    change_setup_table_brightness(0.05)
end

local function apply_setup_background(option)
    if not option then
        return false
    end

    local ok = false
    if option.kind == "custom" then
        ok = pcall(function()
            Backgrounds.setCustomURL(option.value)
        end)
    else
        ok = pcall(function()
            Backgrounds.setBackground(option.value)
        end)
    end

    if ok then
        Global.setVar("setup_background_index", option.kind == "custom" and 1 or 0)
        -- self.editButton({index=31, label = "Background:\n" .. tostring(option.name or option.value or "Sky Field")})
        return true
    end

    broadcastToAll("Could not update background image.", {r=1, g=0, b=0})
    return false
end

function cycle_setup_background(obj, color, alt_click)
    local current = Global.getVar("setup_background_index") or 0
    local next_index = (current + 1) % #setupBackgroundOptions
    if apply_setup_background(setupBackgroundOptions[next_index + 1]) then
        Global.setVar("setup_background_index", next_index)
    end
end

function cycle_setup_table_image(obj, color, alt_click)
    local current = get_setup_table_image_index()
    local next_index = (current + 1) % #setupTableImageOptions

    if apply_setup_table_image(next_index) then
        Global.setVar("setup_table_image_index", next_index)
        local option = setupTableImageOptions[next_index + 1] or setupTableImageOptions[1]
        self.editButton({index=27, label = "Table Image:\n" .. tostring(option.name or "Default")})
    end
end

function cycle_initiative_choice(obj, color, alt_click)
    local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
    local player_count = #active
    if player_count < 2 or player_count > 5 then
        broadcastToAll("Initiative chooser requires 2-5 active players.", {r=1, g=0, b=0})
        return
    end

    local N = player_count
    local cur = Global.getVar("initiative_choice_index") or 0
    local next_index = (cur + 1) % (N + 1) -- cycles 0..N (0 == random)
    -- store both index and explicit color for robustness when players join/leave
    Global.setVar("initiative_choice_index", next_index)
    Global.setVar("initiative_choice_player_count", player_count)
    if next_index == 0 then
        Global.setVar("initiative_choice_color", nil)
    else
        local player = active[next_index]
        local color_name = (player and player.color) or nil
        Global.setVar("initiative_choice_color", color_name)
    end

    local label
    if next_index == 0 then
        label = "Initiative: Random"
    else
        local color_name = Global.getVar("initiative_choice_color") or tostring(next_index)
        label = "Initiative: " .. "\n" .. tostring(color_name)
    end
    self.editButton({index=22, label = label})
end

function setup_base_game()
    Global.setVar("is_basegame_setup", true)
    local base_setup_success = BaseGame.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (base_setup_success and Global.getVar("with_leaders")) then
        Global.call("save_game_starting_players")
        local sc2obj = nil
        if setup_control_2 ~= nil then
            sc2obj = getObjectFromGUID(setup_control_2)
        end
        if sc2obj then
            destroyObject(sc2obj)
        end
        local sc3obj = nil
        if setup_control_3 ~= nil then
            sc3obj = getObjectFromGUID(setup_control_3)
        end
        if sc3obj then
            destroyObject(sc3obj)
        end
        leader_buttons()
        return
    end

    if (base_setup_success) then
        Global.call("save_game_starting_players")
        local sc2obj = nil
        if setup_control_2 ~= nil then
            sc2obj = getObjectFromGUID(setup_control_2)
        end
        if sc2obj then
            destroyObject(sc2obj)
        end
        local sc3obj = nil
        if setup_control_3 ~= nil then
            sc3obj = getObjectFromGUID(setup_control_3)
        end
        if sc3obj then
            destroyObject(sc3obj)
        end
        destroyObject(self)
    end

end

function setup_leaders()
   -- Global.setVar("is_basegame_setup", false)
    if BaseGame.setup_leaders() == false then
        broadcastToAll("\nPlace chosen leader near player board to continue.", {
            r = 1,
            g = 0,
            b = 0
        })
        return
    end

    destroyObject(self)
end

function setup_campaign()
    Global.setVar("is_basegame_setup", false)
    local campaign_setup_success = Campaign.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (campaign_setup_success) then
        Global.call("save_game_starting_players")
        local sc2obj = nil
        if setup_control_2 ~= nil then
            sc2obj = getObjectFromGUID(setup_control_2)
        end
        if sc2obj then
            destroyObject(sc2obj)
        end
        local sc3obj = nil
        if setup_control_3 ~= nil then
            sc3obj = getObjectFromGUID(setup_control_3)
        end
        if sc3obj then
            destroyObject(sc3obj)
        end
        destroyObject(self)
    end
end

function custom_setup()
    Global.setVar("is_basegame_setup", false)
    Global.call("setup_custom_game")
    Global.call("save_game_starting_players")
    local sc2obj = nil
    if setup_control_2 ~= nil then
        sc2obj = getObjectFromGUID(setup_control_2)
    end
    if sc2obj then
        destroyObject(sc2obj)
    end
    local sc3obj = nil
    if setup_control_3 ~= nil then
        sc3obj = getObjectFromGUID(setup_control_3)
    end
    if sc3obj then
        destroyObject(sc3obj)
    end
    destroyObject(self)
end

function leader_buttons()
    self.setPositionSmooth({54.25, 1.2, 0})

    self.editButton({
        index = 2,
        click_function = "setup_leaders",
        label = "Setup Leaders",
        color = GREEN,
        font_color = BLACK,
        hover_color = PURPLE,
        tooltip = "Setup ship placements and acquire resources based on the leader detected to the left of each player board"
    })

    -- Clear all other buttons
    local empty_button = {
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    }

    for i = 0, 30 do
        if i ~= 2 then  -- Skip the leader button
            empty_button.index = i
            self.editButton(empty_button)
        end
    end
end

function doNothing()
end

return SetupControl
end)
__bundle_register("src/Counters", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/GUIDs")
local LOG = require("src/LOG")

-- Create counters that can be attached to containers or zones to count the objects contained inside.

local ObjectCounters = {}
local the_counters
local player_pieces_guids
local has_counter = {}

local function initializeCounters()
    player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    return {
        {
            container_GUID = player_pieces_guids["White"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["White"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["White"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Pink"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Pink"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Pink"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = Global.getVar("imperial_ships_GUID"),
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.8, 0.58, 0.27}
        }, {
            container_GUID = blight_GUID,
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.7, 0.9, 0.7}
        }, {
            container_GUID = Global.getVar("free_cities_GUID"),
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0.06, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.7, 0.7, 0.7}
        }, {
            container_GUID = Global.getVar("free_starports_GUID"),
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0.06, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.7, 0.7, 0.7}
        }
    }
end

function ObjectCounters.setup()
    the_counters = initializeCounters()
    for _, counter in pairs(the_counters) do
        local container = nil
        if counter and counter.container_GUID then
            container = getObjectFromGUID(counter.container_GUID)
        end
        if not container then
            LOG.WARNING("ObjectCounters.setup: missing container for GUID " .. tostring(counter and counter.container_GUID))
        else
            ObjectCounters.add(container, counter)
        end
    end
end

function ObjectCounters.add(container, button)
    if not container then
        LOG.WARNING("ObjectCounters.add called with nil container")
        return
    end
    local ok, guid = pcall(function() return container.getGUID() end)
    if not ok or not guid then
        LOG.WARNING("ObjectCounters.add: could not get GUID from container")
        return
    end
    local existing = container.getButtons() or {}

    if (container.type == "Infinite") then
        -- If buttons already exist, edit them instead of creating duplicates
        if #existing >= 2 then
            has_counter[guid] = true
            container.editButton({index = 0, label = "∞"})
            container.editButton({index = 1, label = "∞"})
            return
        end

        container.createButton({
            function_owner = self,
            click_function = "doNothing",
            label = "∞",
            position = Vector(button.shadow) + Vector(button.position),
            rotation = button.rotation and button.rotation or {0, 0, 0},
            width = 0,
            height = 0,
            scale = button.scale,
            font_size = button.font_size,
            font_color = {0, 0, 0}
        })
        container.createButton({
            function_owner = self,
            click_function = "doNothing",
            label = "∞",
            position = button.position,
            rotation = button.rotation and button.rotation or {0, 0, 0},
            width = 0,
            height = 0,
            scale = button.scale,
            font_size = button.font_size,
            font_color = button.font_color
        })
        has_counter[guid] = true
        return
    end

    local label = "" .. #container.getObjects()
    if #existing >= 2 then
        has_counter[guid] = true
        container.editButton({index = 0, label = label})
        container.editButton({index = 1, label = label})
        return
    end

    has_counter[guid] = true
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = label,
        position = Vector(button.shadow) + Vector(button.position),
        rotation = button.rotation and button.rotation or {0, 0, 0},
        width = 0,
        height = 0,
        scale = button.scale,
        font_size = button.font_size,
        font_color = {0, 0, 0}
    })
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = label,
        position = button.position,
        rotation = button.rotation and button.rotation or {0, 0, 0},
        width = 0,
        height = 0,
        scale = button.scale,
        font_size = button.font_size,
        font_color = button.font_color
    })
    -- log("Attached counter to: "..container.getName())
end

function ObjectCounters.update(container)
    if has_counter[container.getGUID()] then
        container.editButton({
            index = 0,
            label = "" .. #container.getObjects()
        })
        container.editButton({
            index = 1,
            label = "" .. #container.getObjects()
        })
    end
end

return ObjectCounters

end)
__bundle_register("src/Campaign", function(require, _LOADED, __bundle_register, __bundle_modules)
local LOG = require("src/LOG")

local Campaign = {
    guids = {
        -- A Plots
        a_plots = "0ac7d1",
        steward = "111666",
        magnate = "77dbd5",
        caretaker = "7d2e2f",
        partisan = "ffca5f",
        advocate = "0a2f8b",
        founder = "e60ae0",
        admiral = "1c96a7",
        believer = "132ec8",
        -- B Plots
        b_plots = "34808c",
        pathfinder = "2a11a7",
        hegemon = "958e7e",
        planet_breaker = "c2d3f6",
        pirate = "1cd72e",
        blight_speaker = "027b8d",
        pacifist = "1c35fe",
        peacemaker = "6a4456",
        warden = "ac3550",
        -- C Plots
        c_plots = "284e7b",
        overlord = "e0c9fa",
        survivalist = "42e8ad",
        redeemer = "2868af",
        guardian = "1239bb",
        naturalist = "e417c1",
        gate_wraith = "364937",
        conspirator = "3747fe",
        judge = "6dc4a9",

        event_die = "684608",
        number_die = "d5e298",
        chapter_card = "4d34d7",

        first_regent = "e9b0f4",
        book_of_law = "f0362b",
        in_session = "89ddf3",
        guild_envoys_depart = "ba6fc8",
        govern_edicts = "df60d0",
        regent_cards = "9c8d55",

        free_starports = "c79cb8",
        free_cities = "80742e",
        imperial_ships = "beb54d",
        mini_imperial_ships = "31121e",
        blight = "ff61a8",

        court = "fb55bf",
        event_cards = "ad423d",
        flagships = "ea53d9",
        mini_flagships = "36f5c0",
        rules = "f1dd49",
        intermission_help = "b25b55",
        empire_help = "dad146",
        imperial_council_backer = "65a823"
    }
}

local BaseGame = require("src/BaseGame")
local Counters = require("src/Counters")
local Supplies = require("src/Supplies")
local ActionCards = require("src/ActionCards")
local resource = require("src/Resource")
local merchant = require("src/Merchant")

function Campaign.components_visibility(is_visible)
    local visibility = is_visible and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}

    for _, id in pairs(Campaign.guids) do
        local obj = getObjectFromGUID(id)
        if (obj) then
            obj.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = obj,
                is_visible = is_visible
            })
        end
    end
end

function Campaign.setup(with_leaders, with_ll_expansion, with_miniatures)

    local init_choice_color = Global.getVar("initiative_choice_color")
    local init_choice_index = Global.getVar("initiative_choice_index") or 0

    local active_players
    if init_choice_color then
        active_players = Global.call("getOrderedPlayersStartingWith", init_choice_color)
    elseif init_choice_index and init_choice_index >= 1 then
        active_players = Global.call("getOrderedPlayersStartingWith", init_choice_index)
    else
        active_players = Global.call("getOrderedPlayers")
    end

    if (#active_players < 2 or #active_players > 5) then
        return false
    end

    BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)

    -- determine initiative recipient (respect stored choice or random)
    local initiative = require("src/InitiativeMarker")
    local init_choice_color = Global.getVar("initiative_choice_color")
    local init_choice_index = Global.getVar("initiative_choice_index") or 0
    local init_choice_pcount = Global.getVar("initiative_choice_player_count")

    local chosen_color
    if init_choice_color then
        for _, p in ipairs(active_players) do
            if p.color == init_choice_color then chosen_color = p.color; break end
        end
    elseif init_choice_index and init_choice_index >= 1 and init_choice_pcount == #active_players and init_choice_index <= #active_players then
        chosen_color = active_players[init_choice_index].color
    else
        -- random mode: pick random player to receive initiative and rotate
        chosen_color = active_players[math.random(#active_players)].color
        active_players = Global.call("getOrderedPlayersStartingWith", chosen_color)
    end

    -- store finalized order and set up player boards
    Global.setVar("active_players", active_players)
    local active_player_colors = {}
    for _, p in pairs(active_players) do
        ArcsPlayer.setup(p, true)
        table.insert(active_player_colors, p.color)
    end

    local p = {
        is_campaign = true,
        is_4p = #active_players >= 4,
        leaders_and_lore = with_leaders,
        leaders_and_lore_expansion = with_ll_expansion,
        with_faceup_discard = ActionCards.is_face_up_discard_active(),
        players = active_player_colors
    }
    Global.call("set_game_in_progress", p)

    -- Place initiative and give first regent to player 1
    local initiative = require("src/InitiativeMarker")
    initiative.take(chosen_color)
    Campaign.setup_regents(active_players)

    -- C, D, E
    ActionCards.setup_deck(#active_players)
    ActionCards.setup_events(#active_players)

    if #active_players >= 5 then
        BaseGame.adjust_action_deck_for_5p()
    end

    Campaign.setupChapterTrack()
    LOG.INFO("setupChapterTrack Complete")
    Campaign.setupCampaignGuildCards(#active_players, with_ll_expansion)
    LOG.INFO("setupCampaignGuildCards Complete")
    Campaign.setupImperialCouncil()
    LOG.INFO("setupImperialCouncil Complete")
    Campaign.setup_imperial_edicts(#active_players)
    LOG.INFO("setup_imperial_edicts Complete")
    Campaign.setupClusters(#active_players)
    LOG.INFO("setupClusters Complete")

    Wait.time(function()
        Campaign.dealPlayerFates()
    end, 5)

    Turns.type = 2
    Turns.order = active_player_colors
    Turns.turn_color = active_players[1].color

    return true
end

function Campaign.setup_regents(players)
    local regent_cards = getObjectFromGUID(Campaign.guids.regent_cards)
    if not regent_cards then
        LOG.ERROR("Could not find regent cards object")
        return
    end

    local regent_pos = {
        Red = {-16.04, 0.97, 13.03},
        White = {7.61, 0.97, 13.03},
        Yellow = {7.62, 0.97, -12.31},
        Teal = {-16.0, 0.97, -12.32},
        Pink = {31.24, 0.97, -12.32}
    }

    for i, p in ipairs(players) do
        local pos = regent_pos[p.color]
        if pos then
            regent_cards.takeObject({
                position = pos
            })
        else
            LOG.ERROR("No regent position defined for color: " .. tostring(p.color))
        end

        if i == 1 then
            local first_regent = getObjectFromGUID(Campaign.guids.first_regent)
            if first_regent then
                local player_board = getObjectFromGUID(player_pieces_GUIDs[p.color]["player_board"])
                if player_board then
                    first_regent.setPositionSmooth(player_board.positionToWorld({-2, 0, 0}))
                else
                    LOG.ERROR("Could not find player board for first regent placement")
                end
            else
                LOG.ERROR("Could not find first regent object")
            end
        end
    end
end

-- G
function Campaign.setupChapterTrack()

    local chapter_track = getObjectFromGUID(Global.getVar("chapter_track_GUID"))
    local chapter_zone = getObjectFromGUID(Global.getVar("chapter_zone_GUID"))
    local chapter_zone_pos = chapter_zone.getPosition()

    chapter_track.setPosition(chapter_zone_pos)

    local pawn = getObjectFromGUID(Global.getVar("chapter_pawn_GUID"))
    pawn.setPositionSmooth({16.79, 1.8, -8.23})

end

-- I,J
function Campaign.setupCampaignGuildCards(player_count, with_ll_expansion)
    local court_zone = getObjectFromGUID(Global.getVar("court_deck_zone_GUID"))
    local court_zone_pos = court_zone.getPosition()
    local campaign_court = getObjectFromGUID(
        Global.getVar("campaign_court_GUID"))

    campaign_court.setPosition(court_zone_pos)
    campaign_court.setRotation({0, 270, 180})

    local lore_deck = getObjectFromGUID(Global.getVar("lore_GUID"))

    if (with_ll_expansion) then
        broadcastToAll("Playing with the Leaders & Lore Expansion")

        local mte_lore = getObjectFromGUID(Global.getVar(
            "more_to_explore_lore_GUID"))

        lore_deck.putObject(mte_lore)
    end

    lore_deck.randomize()

    Wait.time(function()
        local qty = (player_count == 2 and 3 or 4)

        campaign_court.randomize()
        local court_deck_pos = campaign_court.getPosition()
        court_deck_pos_z = court_deck_pos.z + 0.35

        for i = 1, qty do
            campaign_court.takeObject({
                flip = true,
                position = {
                    court_deck_pos.x, court_deck_pos.y,
                    court_deck_pos_z - (i * -2.41)
                }
            })
        end
    end, 1)

    Wait.time(function()
        for i = 1, player_count, 1 do
            lore_deck.takeObject({
                position = {
                    court_zone_pos.x, court_zone_pos.y + 1, court_zone_pos.z
                },
                rotation = {0, 270, 180},
                flip = false,
                smooth = false
            })
        end
    end, 3)

    Wait.time(function()
        campaign_court.randomize()
    end, 5)
end

-- K
function Campaign.setupImperialCouncil()

    local imperial_council = getObjectFromGUID(Global.getVar(
        "imperial_council_GUID"))
    imperial_council.setPositionSmooth({22, 1, 7.46})
    imperial_council.setRotation({0, 270, 0})

end

-- L,M
function Campaign.setup_imperial_edicts(player_count)

    local laws = getObjectFromGUID(Global.getVar("laws_GUID"))
    laws.setPositionSmooth({31.19, 0.97, 3.50})
    laws.setRotation({0, 180, 0})
    laws.setScale({2.21, 0.2, 3.46})

    if (player_count == 2) then
        local guild_envoys_depart = getObjectFromGUID(Global.getVar(
            "guild_envoys_depart_GUID"))
        guild_envoys_depart.setRotation({0, 180, 0})
        guild_envoys_depart.setPositionSmooth({33.54, 1, 7.0})
    end

    local govern = getObjectFromGUID(Global.getVar("govern_GUID"))
    govern.setRotation({0, 180, 0})
    govern.setPositionSmooth({31.19, 1, 7.0})
    govern.randomize()

end

-- N,O,P
function Campaign.setupClusters(player_count)
    -- Roll Dice
    local number_die = getObjectFromGUID(Global.getVar("number_die_GUID"))
    local die_zone_pos =
        getObjectFromGUID(Global.getVar("die_zone_GUID")).getPosition()
    number_die.setPosition({
        x = die_zone_pos.x - 1.2,
        y = die_zone_pos.y,
        z = die_zone_pos.z
    })

    local event_die = getObjectFromGUID(Global.getVar("event_die_GUID"))
    local die_zone_pos =
        getObjectFromGUID(Global.getVar("die_zone_GUID")).getPosition()
    event_die.setPosition({
        x = die_zone_pos.x + 1.2,
        y = die_zone_pos.y,
        z = die_zone_pos.z
    })

    number_die.randomize()
    event_die.randomize()

    -- Imperial Cluster
    local is_imperial_cluster = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false
    }

    Wait.condition(function() -- Executed after our condition is met
        local imperial_clusters = {}
        local cluster_zones = Global.getVar("cluster_zone_GUIDs")
        local system_ship_zone

        if number_die.isDestroyed() or event_die.isDestroyed() then
            LOG.ERROR("Die was destroyed before it came to rest.")
        else
            imperial_clusters[1] = number_die.getRotationValue()
            imperial_clusters[2] = imperial_clusters[1] == 6 and 1 or
                                       imperial_clusters[1] + 1

            LOG.INFO("Setup Imperial Ships")
            local imperial_ships = getObjectFromGUID(Global.getVar(
                "imperial_ships_GUID"))
            imperial_ships.setPosition({-19.45, 1, 6.40})

            for i = 1, 2, 1 do
                for system, v in pairs(cluster_zones[imperial_clusters[i]]) do
                    system_ship_zone = (system == "gate") and
                                           getObjectFromGUID(v) or
                                           getObjectFromGUID(v["ships"])
                    local pos = system_ship_zone.getPosition()
                    imperial_ships.takeObject({
                        position = {pos.x, pos.y + 0.5, pos.z}
                    })
                end
            end

            is_imperial_cluster[imperial_clusters[1]] = true
            is_imperial_cluster[imperial_clusters[2]] = true

            local system_city_zone

            local event_die_planets = {"b", "c", "a", "a", "b", "c"}

            LOG.INFO("Setup Free Cities and Blight")
            local free_cities_supply = getObjectFromGUID(Global.getVar(
                "free_cities_GUID"))
            free_cities_supply.setPosition({-16.25, 1, 6.40})

            local free_starports_supply =
                getObjectFromGUID(Global.getVar("free_starports_GUID"))
            free_starports_supply.setPosition({-16.25, 1, 7.85})

            local blight_supply =
                getObjectFromGUID(Global.getVar("blight_GUID"))
            blight_supply.setPosition({-19.45, 1, 7.85})

            for cluster, value in pairs(cluster_zones) do
                if (not is_imperial_cluster[cluster]) then
                    for system, system_value in pairs(value) do
                        -- Free Cities
                        local free_system =
                            event_die_planets[event_die.getRotationValue()]
                        if (system == free_system) then
                            system_city_zone = getObjectFromGUID(
                                system_value["buildings"][1])
                            local pos = system_city_zone.getPosition()
                            free_cities_supply.takeObject({
                                position = {pos.x, pos.y + 0.5, pos.z},
                                rotation = {
                                    x = 0,
                                    y = 180,
                                    z = 0
                                }
                            })
                        end

                        -- Blight
                        if (system == "gate") then
                            system_ship_zone = getObjectFromGUID(system_value)
                        else
                            system_ship_zone = getObjectFromGUID(
                                system_value["ships"])
                        end

                        local blight_pos = system_ship_zone.getPosition()

                        local blight = getObjectFromGUID(Global.getVar(
                            "blight_GUID"))
                        blight.takeObject({
                            position = {
                                blight_pos.x, blight_pos.y + 0.5, blight_pos.z
                            },
                            rotation = {
                                x = 0,
                                y = 180,
                                z = 180
                            }
                        })

                    end
                end
            end

            -- Merchant
            if (player_count == 2) then
                LOG.INFO("imperial merchant setup")
                merchant:setup(imperial_clusters)
            end
        end
    end, function() -- Condition function
        return number_die.isDestroyed() or event_die.isDestroyed() or
                   (number_die.resting and event_die.resting)
    end)

end

-- O
function Campaign.setupFreeCities()

end

-- P
function Campaign.setupBlight()

end

-- Setup Players

-- B
function Campaign.dealPlayerFates()
    local A_Fates = getObjectFromGUID(Global.getVar("A_Fates_GUID"))

    A_Fates.shuffle()
    A_Fates.deal(2)

    broadcastToAll("Choose a Fate secretly, discard the other.", {
        r = 1,
        g = 0.1,
        b = 0.1
    })

    Wait.time(function()
        broadcastToAll(
            "When everyone has chosen one, reveal them and take the matching fate bag.",
            {
                r = 1,
                g = 0.1,
                b = 0.1
            })
    end, 5)
end

-- D
function Campaign.dealObjectiveMarkers()

end

-- F
function Campaign.takeTitleCard()

end

-- G, H
function Campaign.playersPlacePieces()

end

-- I
function Campaign.placeFreeCities()

end

return Campaign

end)
__bundle_register("src/InitiativeMarker", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/GUIDs")

local InitiativeMarker = {}

local initiative_pos = {-2, 0, -2.2}

-- Initiative marker has an unseized and seized state.
-- If initiative marker exists then initiative is unseaized
-- If seized initiative marker exists then initiative is seized

function InitiativeMarker.add_menu()
    local initiative = getObjectFromGUID(initiative_GUID)
    local initiative_seized = getObjectFromGUID(seized_initiative_GUID)
    if (initiative) then
        initiative.addContextMenuItem("Take Initiative", InitiativeMarker.take)
        initiative.addContextMenuItem("Seize Initiative", InitiativeMarker.seize)
    elseif (initiative_seized) then
        initiative_seized.addContextMenuItem("Unseize Initiative",
            InitiativeMarker.unseize)
        initiative_seized.setLock(true)
    end
end

function InitiativeMarker.is_seized()
    local initiative_seized = getObjectFromGUID(seized_initiative_GUID)
    return initiative_seized
end

function InitiativeMarker.unseize()
    local initiative_seized = getObjectFromGUID(seized_initiative_GUID)
    if (initiative_seized) then
        initiative_seized.setState(1)
    end
end

function InitiativeMarker.take(player_color, silent)
    InitiativeMarker._move_initiative(player_color, silent, false)
end

function InitiativeMarker.seize(player_color, silent)
    InitiativeMarker._move_initiative(player_color, silent, true)
end

function InitiativeMarker._move_initiative(player_color, silent, is_seize)
    local initiative = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["player_board"])

    local pos_z = (player_color == "Red" or player_color == "White") and 2.2 or -2.2
    local rot_y = (player_color == "Red" or player_color == "White") and 180 or 0
    local pos = player_board.positionToWorld({-2, 0, pos_z})

    if (initiative) then
        initiative.setPositionSmooth(pos)
        initiative.setRotationSmooth({0, rot_y, 0})
        if is_seize then
            Wait.time(function()
                initiative.setState(2)
            end, 1.5)
            if not silent then
                broadcastToAll(player_color .. " has seized the initiative", player_color)
            end
        elseif not silent then
            broadcastToAll(player_color .. " takes the initiative", player_color)
        end
    else
        broadcastToAll("Initiative has already been seized.", Color.Red)
    end
    Global.setVar("initiative_player", player_color)
end

return InitiativeMarker

end)
__bundle_register("src/Merchant", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/GUIDs")
local LOG = require("src/LOG")
local resource = require("src/Resource")

local Merchant = {
    ambition_pos = {
        material = {-0.76, 1.00, -0.83},
        fuel = {-0.76, 1.00, -0.62},
        weapon = {-0.76, 1.00, 0.05},
        relic = {-0.76, 1.00, 0.43},
        psionic = {-0.76, 1.00, 0.83}
    }
}

function Merchant:setup(clusters)
    local board = getObjectFromGUID(reach_board_GUID)
    for _, cluster in pairs(clusters) do
        for _, merch_resource in pairs(resource:name_from_cluster(cluster)) do
            local pos = board.positionToWorld(self.ambition_pos[merch_resource])
            resource:take(merch_resource, pos).addTag("Merchant")
        end
    end
end

return Merchant
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
__bundle_register("src/BaseGame", function(require, _LOADED, __bundle_register, __bundle_modules)
local LOG = require("src/LOG")

local BaseGame = {
    components = {
        base_exclusive = {
            setup_cards = "f02e75",
            court = "9ac2b3",
            scavengers_scouts_deck = "94dd8f",
        },
        leaders = "2d243a",
        leaders_expansion = "768d3d",
        laurens_custom_leaders = "4fcf71",
        pnp3_leaders = "1c80ee",
        pnp3_leaders_extra = "1fed4a", -- no leader cards in here
        lore = "0d8ede",
        lore_expansion = "3441e5",
        -- faceup_discard_cards = "a8e929",
        action_cards_4p = "13bedd",

        core = {
            control_board = "6e21fe",
            reach_board = "bb7d21",
            dice_board = "af1f85",
            dice_help = "f96808",
            dice_counter1 = "069307",
            dice_counter2 = "4798a5",
            action_help = "28a621",
            rules = "bdf1aa",
            round_help = "bcb75f",
            ambition_high = "c9e0ee",
            ambition_medium = "a9b02a",
            ambition_low = "b0b4d0",
            ambition_high_5p = "5b499a",
            ambition_medium_5p = "d7d474",
            ambition_low_5p = "0f526d",
            action_cards = "227406",
            ambition_declared = "0289cb",
            chapter_pawn = "9c3ac8",
            psionic_placeholder = "a89706",
            psionic_stack = "1b4b0b",
            relic_placeholder = "473675",
            relic_stack = "5895b5",
            weapon_placeholder = "2fdfa3",
            weapon_stack = "1c2d2a",
            fuel_placeholder = "5cb321",
            fuel_stack = "ed2820",
            material_placeholder = "eb1cba",
            material_stack = "57c2c6",
            initiative = "b3b3d0",
            event_die = "684608",
            number_die = "d5e298",
            court_discard_backer = "2840db",
            court_deck_backer = "93690a",
            artifact_deck = "9c97c9",
            edifice_deck = "a5e8a7",
            mandate_cards = "c549b5",
            lost_vaults_marker_bag = "7c24cf",
            lost_vaults_rules = "952d62",
            winfall_deck = "8cfcb9"
        }
    }
}

local ArcsPlayer = require("src/ArcsPlayer")
local Counters = require("src/Counters")
local Supplies = require("src/Supplies")
local ActionCards = require("src/ActionCards")
local resource = require("src/Resource")
local merchant = require("src/Merchant")

local leader_setup_markers = {
    White = {
        A = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204323/C2AB80A86A05E6D091EEEFC3BBC37750441C8458/",
        B = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204362/040363BB8DEFF3E79EEF4E9F022346006808DAF1/",
        C = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204408/C404410F6AFD3AA2AA563EF27D796C4E8F872B00/",
        D = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204408/C404410F6AFD3AA2AA563EF27D796C4E8F872B00/"
    },
    Yellow = {
        A = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801217991/3B4F2203FBE1A85FA4E892F1B9D453FE72923393/",
        B = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801218068/F51FD5724585838D7D451AE7E89CF89081E96ACA/",
        C = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801218131/2CD7AB119161AC27C9EB8CA834FF9B748DCCBC45/",
        D = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801218131/2CD7AB119161AC27C9EB8CA834FF9B748DCCBC45/"
    },
    Teal = {
        A = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801203960/A4DC5AF4F4F5E8BB63CDF8B09C11A58F3DA8EA40/",
        B = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204036/E06E07F519CA19F4EE40BFF2E728103A233D402B/",
        C = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204130/8DBC24130B163534CCF2BD3377B74FF04D9F8A5F/",
        D = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204130/8DBC24130B163534CCF2BD3377B74FF04D9F8A5F/"
    },
    Red = {
        A = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204187/D190E74F4A0ADBA81C50A4E328B904A236B7C742/",
        B = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204242/98F1219A748CF32B8094DF04264245366977D678/",
        C = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204273/D14267BB17B5B5F5A0EB5D41DDE2180A8972F7F0/",
        D = "https://steamusercontent-a.akamaihd.net/ugc/2470859798801204273/D14267BB17B5B5F5A0EB5D41DDE2180A8972F7F0/"
    },
    Pink = {
        A = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-a.png",
        B = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-b.png",
        C = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-c.png",
        D = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/pink-c.png"
    },
    guids = {}
}

function BaseGame.leaders_visibility(show, with_expansion)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    if (with_expansion) then
        local expansion = getObjectFromGUID(BaseGame.components
                                                .leaders_expansion)
        if (expansion) then
            expansion.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = expansion,
                is_visible = show
            })
        end
    end
    local leaders = getObjectFromGUID(BaseGame.components.leaders)
    if (leaders) then
        leaders.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = leaders,
            is_visible = show
        })
    end
    -- Also apply visibility to Laurens' and PnP#3 custom leader decks (if present)
    if Global.getVar("with_laurens_custom_leader") then
        local laurens = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
        if (laurens) then
            laurens.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = laurens,
                is_visible = show
            })
        end
    end
    if Global.getVar("with_pnp3_leaders") then
        local pnp3 = getObjectFromGUID(BaseGame.components.pnp3_leaders)
        if (pnp3) then
            pnp3.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = pnp3,
                is_visible = show
            })
        end
        local pnp3_extra = getObjectFromGUID(BaseGame.components.pnp3_leaders_extra)
        if (pnp3_extra) then
            pnp3_extra.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = pnp3_extra,
                is_visible = show
            })
        end
    end
end

function BaseGame.lore_visibility(show, with_expansion)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    if (with_expansion) then
        local expansion = getObjectFromGUID(BaseGame.components.lore_expansion)
        if (expansion) then
            expansion.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = expansion,
                is_visible = show
            })
        end
    end
    local lore = getObjectFromGUID(BaseGame.components.lore)
    if (lore) then
        lore.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = lore,
            is_visible = show
        })
    end
    -- Also apply visibility to Laurens' and PnP#3 custom leader decks (if present)
    local laurens = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
    if (laurens) then
        laurens.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = laurens,
            is_visible = show
        })
    end
    local pnp3 = getObjectFromGUID(BaseGame.components.pnp3_leaders)
    if (pnp3) then
        pnp3.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = pnp3,
            is_visible = show
        })
    end
    local pnp3_extra = getObjectFromGUID(BaseGame.components.pnp3_leaders_extra)
    if (pnp3_extra) then
        pnp3_extra.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = pnp3_extra,
            is_visible = show
        })
    end
end

function BaseGame.core_components_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    for _, id in pairs(BaseGame.components.core) do
        local obj = getObjectFromGUID(id)
        if (obj) then
            obj.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = obj,
                is_visible = show
            })
        else
        end
    end

    -- adjust court row backers so they don't interfere
    -- when players attempts to bury a card under the court deck
    if show then
        Wait.frames(function()
            local court_deck_backer = getObjectFromGUID(BaseGame.components.core.court_deck_backer)
            local court_discard_backer = getObjectFromGUID(BaseGame.components.core.court_discard_backer)

            for _, backer in ipairs({court_deck_backer, court_discard_backer}) do
                if backer then
                    local pos = backer.getPosition()
                    backer.setPosition({pos.x, 0.85, pos.z})
                end
            end
        end, 1)
    end
end

function BaseGame.four_player_cards_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    local obj = getObjectFromGUID(BaseGame.components.action_cards_4p)
    if (obj) then
        obj.setInvisibleTo(visibility)
        Global.call("move_and_lock_object", {
            obj = obj,
            is_visible = show
        })
    end
end

-- Return the list of available setup option tables for a given player count (2..5)
function BaseGame.getSetupOptions(player_count)
    local two_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_2P_GUID"), out_of_play_clusters = {1, 6}, player_colors = 2 },
        { name = "HOMELANDS", guid = Global.getVar("homelands_2P_GUID"), out_of_play_clusters = {1, 4}, player_colors = 2 },
        { name = "MIX UP 1", guid = Global.getVar("mix_up_1_2P_GUID"), out_of_play_clusters = {2, 5}, player_colors = 2 },
        { name = "MIX UP 2", guid = Global.getVar("mix_up_2_2P_GUID"), out_of_play_clusters = {1, 4}, player_colors = 2 }
    }

    local three_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_3P_GUID"), out_of_play_clusters = {2, 3}, player_colors = 3 },
        { name = "HOMELANDS", guid = Global.getVar("homelands_3P_GUID"), out_of_play_clusters = {5, 6}, player_colors = 3 },
        { name = "CORE CONFLICT", guid = Global.getVar("core_conflict_3P_GUID"), out_of_play_clusters = {3, 6}, player_colors = 3 },
        { name = "MIX UP", guid = Global.getVar("mix_up_3P_GUID"), out_of_play_clusters = {1, 4}, player_colors = 3 }
    }

    local four_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_4P_GUID"), out_of_play_clusters = {5}, player_colors = 4 },
        { name = "MIX UP 1", guid = Global.getVar("mix_up_1_4P_GUID"), out_of_play_clusters = {3}, player_colors = 4 },
        { name = "MIX UP 2", guid = Global.getVar("mix_up_2_4P_GUID"), out_of_play_clusters = {4}, player_colors = 4 },
        { name = "MIX UP 3", guid = Global.getVar("mix_up_3_4P_GUID"), out_of_play_clusters = {6}, player_colors = 4 }
    }

    local five_player_setup_cards = {
        { name = "FRONTIERS", guid = Global.getVar("frontiers_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "EMPIRES", guid = Global.getVar("empires_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "MIX UP 1", guid = Global.getVar("mix_up_1_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "MIX UP 2", guid = Global.getVar("mix_up_2_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 },
        { name = "EXTENSION", guid = Global.getVar("extension_5P_GUID"), out_of_play_clusters = {}, player_colors = 5 }
    }

    local setup_cards = { two_player_setup_cards, three_player_setup_cards, four_player_setup_cards, five_player_setup_cards }
    return setup_cards[player_count - 1]
end

function BaseGame.base_exclusive_components_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"}
    for _, id in pairs(BaseGame.components.base_exclusive) do
        local obj = getObjectFromGUID(id)
        if (obj) then
            obj.setInvisibleTo(visibility)
            Global.call("move_and_lock_object", {
                obj = obj,
                is_visible = show
            })
        end
    end
end

-- params = {
--     is_visible = true,
--     is_campaign = true,
--     is_4p = true,
--     leaders_and_lore = true,
--     leaders_and_lore_expansion = true,
--     faceup_discard = true,
--     miniatures = true
-- }
function BaseGame.components_visibility(params)
    BaseGame.core_components_visibility(params.is_visible)
    if (not params.is_campaign) then
        BaseGame.base_exclusive_components_visibility(params.is_visible)
    end
    local player_count = params.players and #params.players or 0
    if (params.is_4p or player_count >= 4) then
        BaseGame.four_player_cards_visibility(params.is_visible)
    end
    if (params.leaders_and_lore) then
        BaseGame.leaders_visibility(params.is_visible,
            params.leaders_and_lore_expansion)
        BaseGame.lore_visibility(params.is_visible,
            params.leaders_and_lore_expansion)
    end
    if (params.faceup_discard) then
        ActionCards.faceup_discard_visibility(params.is_visible)
    end
    if (params.miniatures) then
        BaseGame.miniatures_setup(params.is_visible)
    end
end
function shift_ambition_markers() --5p
    local first_pos = {}
    local height_offset = 0.3  -- adjust this if needed

    -- Step 1: store positions of first 3
    for i = 1, 3 do
        local obj = getObjectFromGUID(ambition_marker_GUIDs[i])
        if obj then
            local pos = obj.getPosition()
            first_pos[i] = {x = pos.x, y = pos.y + height_offset, z = pos.z}
        end
    end

    -- Step 2: delete first 3
    for i = 1, 3 do
        local obj = getObjectFromGUID(ambition_marker_GUIDs[i])
        if obj then
            obj.destruct()
        end
    end

    -- Step 3 + 4: wait, then move last 3
    Wait.time(function()
        for i = 1, 3 do
            local obj = getObjectFromGUID(ambition_marker_GUIDs[i + 3])
            if obj and first_pos[i] then
                obj.setPositionSmooth(first_pos[i], false, true)
            else
                print("Missing object or position at index " .. i)
            end
        end
    end, 0.2)
end

-- Move/scale action deck and related zones for 5-player layout
function BaseGame.hide_and_disable_5p_snaps()
    local snaps_obj = getObjectFromGUID(snaps_5p_GUID)
    if not snaps_obj then
        return
    end

    -- If we're running in debug mode, keep the snaps visible and usable
    -- so developers can inspect and manipulate the 5P helper snaps.
    local debug_mode = false
    pcall(function() debug_mode = Global.getVar("debug") end)
    if debug_mode then
        snaps_obj.setInvisibleTo({})
        snaps_obj.interactable = true
        return
    end

    -- Keep helper snaps hidden and non-interactable for players.
    snaps_obj.setInvisibleTo({"Red", "White", "Yellow", "Teal", "Pink", "Black", "Grey"})
    snaps_obj.setLock(true)
    snaps_obj.interactable = false
end

function BaseGame.adjust_action_deck_for_5p()
    pcall(function()
        local target = {-12.14, 1.08, 8.52}
        local target_zone = {-12.14, 1.3, 8.52}

        -- Move the physical action deck (if present)
        local ok, deck = pcall(function() return ActionCards.get_action_deck() end)
        if ok and deck then
            if deck.setPositionSmooth then
                deck.setPositionSmooth(target)
            elseif deck.setPosition then
                deck.setPosition(target)
            end
        end

        -- Move the action deck zone object so zone coordinates match
        local zone = getObjectFromGUID(action_deck_zone_GUID)
        if zone then
            if zone.setPositionSmooth then
                zone.setPositionSmooth(target_zone)
            elseif zone.setPosition then
                zone.setPosition(target_zone)
            end
        end

        -- Move and scale the action card zone for 5P
        local action_card_zone = getObjectFromGUID(action_card_zone_GUID)
        if action_card_zone then
            local action_card_pos = {-12.13, 3.54, 0.34}
            local action_card_scale = {3.84, 5.10, 12.65}
            if action_card_zone.setPositionSmooth then
                action_card_zone.setPositionSmooth(action_card_pos)
            elseif action_card_zone.setPosition then
                action_card_zone.setPosition(action_card_pos)
            end
            pcall(function()
                if action_card_zone.setScale then
                    action_card_zone.setScale(action_card_scale)
                end
            end)
        end
        -- Move or create snaps object for 5P layout
        local snaps_obj = getObjectFromGUID(snaps_5p_GUID)
        if snaps_obj then
            local snaps_target = {-12.18, 0.73, 5.26}
            if snaps_obj.setPositionSmooth then
                snaps_obj.setPositionSmooth(snaps_target)
            elseif snaps_obj.setPosition then
                snaps_obj.setPosition(snaps_target)
            end
            BaseGame.hide_and_disable_5p_snaps()
        end
    end)
end

function BaseGame.setup(with_leaders, with_ll_expansion, with_miniatures)

    local init_choice_color = Global.getVar("initiative_choice_color")
    local init_choice_index = Global.getVar("initiative_choice_index") or 0

    -- Prefer using Global to compute the ordered players starting with
    -- the chosen player (if present) so rotation happens in the Global
    -- script and avoids cross-script resource operations.
    local active_players
    if init_choice_color then
        active_players = Global.call("getOrderedPlayersStartingWith", init_choice_color)
    elseif init_choice_index and init_choice_index >= 1 then
        active_players = Global.call("getOrderedPlayersStartingWith", init_choice_index)
    else
        active_players = Global.call("getOrderedPlayers")
    end

    if #active_players >= 5 then
        shift_ambition_markers()
        -- Adjust action deck and related objects for 5P layout
        BaseGame.adjust_action_deck_for_5p()
    else
        -- Ensure the 5P snaps object is removed when not using 5P layout
        pcall(function()
            local snaps_obj = getObjectFromGUID(snaps_5p_GUID)
            if snaps_obj then
                local debug_mode = false
                pcall(function() debug_mode = Global.getVar("debug") end)
                if debug_mode then
                    -- In debug mode keep the snaps visible and interactable for inspection
                    snaps_obj.setInvisibleTo({})
                    snaps_obj.setLock(false)
                    snaps_obj.interactable = true
                else
                    destroyObject(snaps_obj)
                end
            end
        end)
    end

    -- B: determine initiative recipient (respect stored choice or random)
    local initiative = require("src/InitiativeMarker")
    local init_choice_color = Global.getVar("initiative_choice_color")
    local init_choice_index = Global.getVar("initiative_choice_index") or 0
    local init_choice_pcount = Global.getVar("initiative_choice_player_count")

    -- determine chosen_color: prefer stored choice, else pick randomly
    local chosen_color
    if init_choice_color then
        for _, p in ipairs(active_players) do
            if p.color == init_choice_color then chosen_color = p.color; break end
        end
    elseif init_choice_index and init_choice_index >= 1 and init_choice_pcount == #active_players and init_choice_index <= #active_players then
        chosen_color = active_players[init_choice_index].color
    else
        -- random mode: pick a random seated player to receive initiative and
        -- rotate the active players so that player 1 is that chosen player
        chosen_color = active_players[math.random(#active_players)].color
        active_players = Global.call("getOrderedPlayersStartingWith", chosen_color)
    end

    -- Now that we've finalized `active_players`, store it and validate
    Global.setVar("active_players", active_players)
    if (#active_players < 2 or #active_players > 5) then
        return false
    end

    BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)

    -- Set up per-player boards/objects now that active_players order is final
    local active_player_colors = {}
    for _, p in pairs(active_players) do
        ArcsPlayer.setup(p, false)
        table.insert(active_player_colors, p.color)
    end
    local p = {
        is_campaign = false,
        is_4p = #active_players == 4 or 5,
        leaders_and_lore = with_leaders,
        leaders_and_lore_expansion = with_ll_expansion,
        with_faceup_discard = ActionCards.is_face_up_discard_active(),
        players = active_player_colors
    }
    -- mark that we're performing the initial base setup so modules
    -- (like ArcsPlayer) can perform one-time actions (e.g., destroy objectives)
    Global.setVar("is_initial_setup", true)
    Global.call("set_game_in_progress", p)
    -- Clear the flag after setup to avoid affecting reloads or later calls
    Global.setVar("is_initial_setup", false)

    -- Place initiative marker for chosen player (chosen_color computed earlier)
    initiative.take(chosen_color)

    -- D
    ActionCards.setup_deck(#active_players)
    BaseGame.setupBaseCourt(#active_players)
    if (not Global.getVar("with_pnp2_lost_vaults")) then
        LOG.INFO("no vaults")
        chosen_setup_card = BaseGame.chooseSetupCard(#active_players)
        BaseGame.setupOutOfPlayClusters(chosen_setup_card)
        if (#active_players == 2) then
            merchant:setup(chosen_setup_card.out_of_play_clusters)
        end

        if (Global.getVar("with_leaders")) then
            BaseGame.dealLeaders(#active_players)
            BaseGame.place_player_markers(active_players, chosen_setup_card)
        else
            BaseGame.setupPlayers(active_players, chosen_setup_card)
        end
    else
        LOG.INFO("vaults")
        chosen_setup_card = BaseGame.chooseSetupCard(#active_players)
        BaseGame.setupOutOfPlayClusters(chosen_setup_card)
        if (#active_players == 2) then
            merchant:setup(chosen_setup_card.out_of_play_clusters)
        end

        if (Global.getVar("with_leaders")) then
            BaseGame.dealLeaders(#active_players)
            BaseGame.place_player_markers(active_players, chosen_setup_card)
        else
            BaseGame.setupPlayers(active_players, chosen_setup_card)
        end
        --reach feature
        local reach_feature_deck = getObjectFromGUID("a5e8a7")
        local die_zone = getObjectFromGUID("1b45bb")

        if reach_feature_deck and die_zone then
            reach_feature_deck.randomize()

            Wait.frames(function()
                local base_pos = die_zone.getPosition()
                local spacing = 2.3

                for i = 1, 2 do
                    reach_feature_deck.takeObject({
                        flip = true,
                        position = {
                            base_pos.x + ((i - 1) * spacing) - 1.3,
                            base_pos.y + 1,
                            base_pos.z
                        }
                    })
                end
            end, 15)
        end


        -- Lost Vaults enabled: instead of placing leaders on table, include
        -- any enabled custom leader decks and deal 2 leader cards into each
        -- player's hand.
        -- local leader_deck = getObjectFromGUID(Global.getVar("fate_GUID"))
        -- local lore_deck = getObjectFromGUID(Global.getVar("lore_GUID"))
        -- local mte_fate = getObjectFromGUID(Global.getVar("more_to_explore_fate_GUID"))
        -- local mte_lore = getObjectFromGUID(Global.getVar("more_to_explore_lore_GUID"))
        -- local artifact_deck = getObjectFromGUID(Global.getVar("artifact_deck_GUID"))

        -- if not leader_deck then
        --     LOG.INFO("Leader deck not found; cannot deal leaders to hands")
        --     return
        -- end

        -- -- Include Leaders & Lore expansion cards if enabled
        -- if (Global.getVar("with_more_to_explore")) then
        --     leader_deck.putObject(mte_fate)
        --     if lore_deck and mte_lore then lore_deck.putObject(mte_lore) end
        -- end

        -- -- If the user requested to not use the base and pack leader objects,
        -- -- remove those physical objects so custom decks fully replace them.
        -- local base_leaders_pos, base_leaders_rot
        -- if (Global.getVar("dont_use_base_and_pack_leaders")) then
        --     local base_leaders_obj = getObjectFromGUID(BaseGame.components.leaders)
        --     if (base_leaders_obj) then
        --         base_leaders_pos = base_leaders_obj.getPosition()
        --         base_leaders_rot = base_leaders_obj.getRotation()
        --         destroyObject(base_leaders_obj)
        --         broadcastToAll("Removed base leaders from the table")
        --     end
        --     local expansion_leaders_obj = getObjectFromGUID(BaseGame.components.leaders_expansion)
        --     if (expansion_leaders_obj) then
        --         destroyObject(expansion_leaders_obj)
        --         broadcastToAll("Removed expansion leaders from the table")
        --     end
        -- end

        -- -- Optionally include custom leader decks (Laurens, PnP#3, etc.)
        -- local custom_decks = {}
        -- local custom_names = {}
        -- if Global.getVar("with_laurens_custom_leader") then
        --     local d = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
        --     if d then table.insert(custom_decks, d); table.insert(custom_names, "Laurens") end
        -- end
        -- if Global.getVar("with_pnp3_custom_leader") then
        --     local d = getObjectFromGUID(BaseGame.components.pnp3_leaders)
        --     if d then table.insert(custom_decks, d); table.insert(custom_names, "PnP#3") end
        -- end

        -- if #custom_decks > 0 then
        --     if Global.getVar("dont_use_base_and_pack_leaders") then
        --         -- Use the first custom deck as the leader deck: move it to the
        --         -- base leaders' position if available, then merge any others into it.
        --         local target = custom_decks[1]
        --         if base_leaders_pos then
        --             target.setPosition({base_leaders_pos.x, base_leaders_pos.y, base_leaders_pos.z})
        --             if base_leaders_rot then target.setRotation(base_leaders_rot) end
        --         elseif leader_deck and leader_deck.getPosition then
        --             local p = leader_deck.getPosition()
        --             target.setPosition({p.x, p.y, p.z})
        --         end
        --         for i = 2, #custom_decks do
        --             pcall(function() target.putObject(custom_decks[i]) end)
        --         end
        --         leader_deck = target
        --         for i, name in ipairs(custom_names) do
        --             if name == "Laurens" then
        --                 broadcastToAll("Including Celestial Leader Expansion by Laurens")
        --             elseif name == "PnP#3" then
        --                 broadcastToAll("Including PnP#3 Leader Deck")
        --             else
        --                 broadcastToAll("Including " .. name .. "'s custom leader deck")
        --             end
        --         end
        --     else
        --         -- Merge selected custom decks into the base fate deck
        --         for i, d in ipairs(custom_decks) do
        --             pcall(function() leader_deck.putObject(d) end)
        --             if custom_names[i] == "Laurens" then
        --                 broadcastToAll("Including Celestial Leader Expansion by Laurens")
        --             elseif custom_names[i] == "PnP#3" then
        --                 broadcastToAll("Including PnP#3 Leader Deck")
        --             else
        --                 broadcastToAll("Including " .. custom_names[i] .. "'s leader deck")
        --             end
        --         end
        --     end
        -- end

        -- leader_deck.randomize()
        -- Wait.time(function()
        --     leader_deck.deal(2)
        -- end, 1)


        -- local edifice_guid = Global.getVar("edifice_deck_GUID") or "becb7c"
        -- local edifice = getObjectFromGUID(edifice_guid)
        -- if edifice and edifice.setPosition then
        --     pcall(function()
        --         edifice.setPosition({2.37, 1.12, -0.29})
        --         if edifice.randomize then edifice.randomize() end
        --     end)
        --     LOG.INFO("Moved and shuffled edifice deck (GUID=" .. tostring(edifice_guid) .. ") for Lost Vaults setup")
        -- else
        --     LOG.INFO("Edifice deck not found for Lost Vaults (GUID=" .. tostring(edifice_guid) .. ")")
        -- end
        -- LOG.INFO("with_pnp2_lost_vaults enabled: randomized base court; skipping card draws")

        -- for i = 1, 2 do
        --     edifice.takeObject({
        --         position = {x = -62.36, y = 1.02, z = -38.22}
        --     })
        -- end
        -- -- Place 6 random lore cards and 6 random artifact cards on top of the
        -- -- edifice deck, using the same randomize/wait/take pattern used when
        -- -- dealing leaders. Artifact cards are moved alongside lore cards.
        -- if edifice and (lore_deck or artifact_deck) then
        --     pcall(function()
        --         if lore_deck and lore_deck.randomize then lore_deck.randomize() end
        --         if artifact_deck and artifact_deck.randomize then artifact_deck.randomize() end
        --         local ed_pos = edifice.getPosition and edifice.getPosition() or {x=0,y=1,z=0}

        --         -- Wait a frame like leader dealing, then take cards and place them into edifice
        --         Wait.time(function()
        --             for i = 1, 6 do
        --                 -- take a lore card (if available)
        --                 if lore_deck and lore_deck.takeObject then
        --                     lore_deck.takeObject({
        --                         flip = false,
        --                         position = {ed_pos.x, ed_pos.y + 1 + (i * 0.02), ed_pos.z},
        --                         callback_function = function(card)
        --                             Wait.frames(function()
        --                                 if card and not (card.isDestroyed and card.isDestroyed()) then
        --                                     pcall(function()
        --                                         if edifice.putObject then
        --                                             edifice.putObject(card)
        --                                         else
        --                                             local p = edifice.getPosition and edifice.getPosition() or ed_pos
        --                                             card.setPositionSmooth({p.x, p.y + 1, p.z})
        --                                         end
        --                                     end)
        --                                 end
        --                             end, 1)
        --                         end
        --                     })
        --                 end

        --                 -- take an artifact card (if available)
        --                 if artifact_deck and artifact_deck.takeObject then
        --                     artifact_deck.takeObject({
        --                         flip = false,
        --                         -- slight x offset so spawned objects don't collide visually
        --                         position = {ed_pos.x + 0.03, ed_pos.y + 1 + (i * 0.02), ed_pos.z},
        --                         callback_function = function(card)
        --                             Wait.frames(function()
        --                                 if card and not (card.isDestroyed and card.isDestroyed()) then
        --                                     pcall(function()
        --                                         if edifice.putObject then
        --                                             edifice.putObject(card)
        --                                         else
        --                                             local p = edifice.getPosition and edifice.getPosition() or ed_pos
        --                                             card.setPositionSmooth({p.x, p.y + 1, p.z})
        --                                         end
        --                                     end)
        --                                 end
        --                             end, 1)
        --                         end
        --                     })
        --                 end
        --             end

        --             -- After a short delay, shuffle the edifice deck to mix the added cards.
        --             Wait.time(function()
        --                 if edifice then
        --                     pcall(function()
        --                         if edifice.randomize then
        --                             edifice.randomize()
        --                         elseif edifice.shuffle then
        --                             edifice.shuffle()
        --                         end
        --                     end)
        --                     LOG.INFO("Placed 6 lore and 6 artifact cards on top of edifice and shuffled (Lost Vaults setup)")

        --                     -- After shuffling, take one card for each of two random planets
        --                     local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs") or {}
        --                     local planet_candidates = {}
        --                     for cluster = 1, 6 do
        --                         local entry = cluster_zone_guids[cluster]
        --                         if entry then
        --                             for _, sys in ipairs({"a", "b", "c"}) do
        --                                 local sys_entry = entry[sys]
        --                                 if sys_entry and sys_entry["buildings"] and #sys_entry["buildings"] > 0 then
        --                                     local bguid = sys_entry["buildings"][1]
        --                                     local obj = getObjectFromGUID(bguid)
        --                                     if obj and obj.getPosition then
        --                                         table.insert(planet_candidates, {cluster = cluster, system = sys, pos = obj.getPosition(), building_guid = bguid})
        --                                     end
        --                                 end
        --                             end
        --                         end
        --                     end

        --                     if #planet_candidates >= 2 and edifice.takeObject then
        --                         -- pick two distinct random indices
        --                         local function pick_two(n)
        --                             local i = math.random(n)
        --                             local j = math.random(n-1)
        --                             if j >= i then j = j + 1 end
        --                             return i, j
        --                         end
        --                         local i, j = pick_two(#planet_candidates)
        --                         local targets = {planet_candidates[i], planet_candidates[j]}
        --                         local remaining = {}
        --                         for idx, p in ipairs(planet_candidates) do
        --                             if idx ~= i and idx ~= j then table.insert(remaining, p) end
        --                         end

        --                         local clusters_with_cards = {}
        --                         for _, entry in ipairs(targets) do
        --                             local pos = entry.pos
        --                             table.insert(clusters_with_cards, entry.cluster)
        --                             pcall(function()
        --                                 edifice.takeObject({
        --                                     flip = true,
        --                                     position = {pos.x, pos.y + 1, pos.z},
        --                                     callback_function = function(card)
        --                                         Wait.frames(function()
        --                                             if card and card.setPositionSmooth and pos then
        --                                                 card.setPositionSmooth({pos.x, pos.y + 0.5, pos.z})
        --                                             end
        --                                             -- If the script placed this card, also place a matching
        --                                             -- Lost Vaults marker from the bag (if present).
        --                                             -- marker placement handled centrally in Global.lua detection
        --                                         end, 1)
        --                                     end
        --                                 })
        --                             end)
        --                         end
        --                         LOG.INFO("Placed 1 edifice card onto 2 random planets")

        --                         -- Move the existing initiative marker (by GUID) to a remaining
        --                         -- planet (do not spawn a new copy). Choose one remaining entry.
        --                         local initiative_cluster = nil
        --                         if #remaining > 0 then
        --                             local target_entry = remaining[math.random(#remaining)]
        --                             local target_pos = target_entry.pos
        --                             initiative_cluster = target_entry.cluster
        --                             pcall(function()
        --                                 local init_guid = BaseGame.components and BaseGame.components.core and BaseGame.components.core.initiative
        --                                     or Global.getVar("initiative_GUID")
        --                                 local init_obj = init_guid and getObjectFromGUID(init_guid)
        --                                 if init_obj and (init_obj.setPositionSmooth or init_obj.setPosition) then
        --                                     if init_obj.setPositionSmooth then
        --                                         init_obj.setPositionSmooth({target_pos.x, target_pos.y + 0.5, target_pos.z})
        --                                     else
        --                                         init_obj.setPosition({target_pos.x, target_pos.y + 0.5, target_pos.z})
        --                                     end

        --                                     -- Move the event and number dice to the die zone instead (a bit higher)
        --                                     local die_zone_guid = Global.getVar("die_zone_GUID") or "1b45bb"
        --                                     local die_zone = getObjectFromGUID(die_zone_guid)
        --                                     local die_x, die_y, die_z = nil, nil, nil
        --                                     if die_zone and die_zone.getPosition then
        --                                         local dz = die_zone.getPosition()
        --                                         die_x, die_y, die_z = dz.x - 2, dz.y + 1.2, dz.z
        --                                     else
        --                                         -- fallback to the planet target if die zone missing
        --                                         die_x, die_y, die_z = target_pos.x, target_pos.y + 1.2, target_pos.z
        --                                     end

        --                                     local event_die_guid = Global.getVar("event_die_GUID") or "684608"
        --                                     local number_die_guid = Global.getVar("number_die_GUID") or "d5e298"
        --                                     local event_die = getObjectFromGUID(event_die_guid)
        --                                     local number_die = getObjectFromGUID(number_die_guid)

        --                                     -- pcall(function()
        --                                     --     if event_die and event_die.setPositionSmooth then
        --                                     --         event_die.setPositionSmooth({die_x + 0.18, die_y, die_z})
        --                                     --     elseif event_die and event_die.setPosition then
        --                                     --         event_die.setPosition({die_x + 0.18, die_y, die_z})
        --                                     --     end
        --                                     -- end)
        --                                     pcall(function()
        --                                         if number_die and number_die.setPositionSmooth then
        --                                             number_die.setPositionSmooth({die_x - 0.18, die_y, die_z})
        --                                         elseif number_die and number_die.setPosition then
        --                                             number_die.setPosition({die_x - 0.18, die_y, die_z})
        --                                         end
        --                                     end)
        --                                     LOG.INFO("Moved initiative marker (" .. tostring(init_guid) .. ") and dice to die zone " .. tostring(die_zone_guid) .. " (cluster " .. tostring(initiative_cluster) .. ")")
        --                                 else
        --                                     LOG.INFO("Initiative marker not found or cannot be moved")
        --                                 end
        --                             end)
        --                         else
        --                             LOG.INFO("No remaining planet to place initiative marker")
        --                         end

        --                         if initiative_cluster then table.insert(clusters_with_cards, initiative_cluster) end

        --                         -- Now mark clusters out of play based on player count, excluding
        --                         -- clusters we placed cards or initiative on.
        --                         local players_count = #active_players
        --                         local clusters_to_remove
        --                         if players_count == 5 then
        --                             clusters_to_remove = 0
        --                         elseif players_count >= 4 then
        --                             clusters_to_remove = 1
        --                         else
        --                             clusters_to_remove = 2
        --                         end
        --                         local candidates = {}
        --                         for cluster = 1, 6 do
        --                             local skip = false
        --                             for _, c in ipairs(clusters_with_cards) do
        --                                 if c == cluster then skip = true; break end
        --                             end
        --                             if not skip then table.insert(candidates, cluster) end
        --                         end

        --                         if #candidates >= clusters_to_remove then
        --                             local chosen = {}
        --                             while #chosen < clusters_to_remove do
        --                                 local idx = math.random(#candidates)
        --                                 table.insert(chosen, candidates[idx])
        --                                 table.remove(candidates, idx)
        --                             end
        --                             local fake_setup = { out_of_play_clusters = chosen }
        --                             BaseGame.setupOutOfPlayClusters(fake_setup)
        --                             LOG.INFO("Marked clusters out of play: " .. table.concat(chosen, ", "))
        --                             -- After marking clusters out of play, move Vault cards per request.
        --                             -- First move the lost vaults rules object into position.
        --                             pcall(function()
        --                                 local rules_guid = Global.getVar("lost_vaults_rules_GUID") or "952d62"
        --                                 local ok, rules_obj = pcall(function() return getObjectFromGUID(rules_guid) end)
        --                                 if ok and rules_obj then
        --                                     pcall(function()
        --                                         if rules_obj.setPositionSmooth then
        --                                             rules_obj.setPositionSmooth({36.48, 0.96, -0.20})
        --                                         elseif rules_obj.setPosition then
        --                                             rules_obj.setPosition({36.48, 0.96, -0.20})
        --                                         end
        --                                     end)
        --                                 end
        --                             end)
        --                             pcall(function()
        --                                 local target_v1 = {22.00, 0.97, 3.99}
        --                                 local moved_v1 = 0
        --                                 local bag_guid = Global.getVar("lost_vaults_marker_bag_GUID") or "7f3e2f"
        --                                 local bag = getObjectFromGUID(bag_guid)
        --                                 if bag and bag.getObjects then
        --                                     local okc, contents = pcall(function() return bag.getObjects() end)
        --                                     if okc and contents then
        --                                         for _, item in ipairs(contents) do
        --                                             if moved_v1 >= 2 then break end
        --                                             if item and item.name and item.name == "Vault 1" and item.guid then
        --                                                 moved_v1 = moved_v1 + 1
        --                                                 pcall(function()
        --                                                     if bag.takeObject then
        --                                                         local place_x = target_v1[1] + ((moved_v1 - 1) * 0.4)
        --                                                         local place_z = target_v1[3] + ((moved_v1 - 1) * 0.2)
        --                                                         bag.takeObject({
        --                                                             guid = item.guid,
        --                                                             position = {place_x, target_v1[2] + 0.5, place_z},
        --                                                             callback_function = function(taken)
        --                                                                 Wait.frames(function()
        --                                                                     if taken then
        --                                                                         pcall(function()
        --                                                                             if taken.setRotation then taken.setRotation({0, 180, 0}) end
        --                                                                         end)
        --                                                                         if taken.setPositionSmooth then
        --                                                                             taken.setPositionSmooth({place_x, target_v1[2], place_z})
        --                                                                         elseif taken.setPosition then
        --                                                                             taken.setPosition({place_x, target_v1[2], place_z})
        --                                                                         end
        --                                                                     end
        --                                                                 end, 1)
        --                                                             end
        --                                                         })
        --                                                     end
        --                                                 end)
        --                                             end
        --                                         end
        --                                     end
        --                                 else
        --                                     LOG.INFO("Vault 1 bag not found; could not move Vault 1 cards")
        --                                 end
        --                                 LOG.INFO("Moved " .. tostring(moved_v1) .. " Vault 1 card(s) to {22.00,0.97,3.99}")

        --                                 -- Move 2 cards named Vault 2 from the bag named "Vault 2"
        --                                 local target_v2 = {22.00, 0.97, 1.58}
        --                                 local moved_v2 = 0
        --                                 local vault2_bag_guid = Global.getVar("lost_vaults_marker_bag_GUID") or "7f3e2f"
        --                                 local vault2_bag = getObjectFromGUID(vault2_bag_guid)
        --                                 if vault2_bag and vault2_bag.getObjects then
        --                                     local okc, contents = pcall(function() return vault2_bag.getObjects() end)
        --                                     if okc and contents then
        --                                         for _, item in ipairs(contents) do
        --                                             if moved_v2 >= 2 then break end
        --                                             if item and item.name and item.name == "Vault 2" and item.guid then
        --                                                 moved_v2 = moved_v2 + 1
        --                                                 pcall(function()
        --                                                     if vault2_bag.takeObject then
        --                                                         local place_x2 = target_v2[1] + ((moved_v2 - 1) * 0.4)
        --                                                         local place_z2 = target_v2[3] + ((moved_v2 - 1) * 0.2)
        --                                                         vault2_bag.takeObject({
        --                                                             guid = item.guid,
        --                                                             position = {place_x2, target_v2[2] + 0.5, place_z2},
        --                                                             callback_function = function(taken)
        --                                                                 Wait.frames(function()
        --                                                                     if taken then
        --                                                                         pcall(function()
        --                                                                             if taken.setRotation then taken.setRotation({0, 180, 0}) end
        --                                                                         end)
        --                                                                         if taken.setPositionSmooth then
        --                                                                             taken.setPositionSmooth({place_x2, target_v2[2], place_z2})
        --                                                                         elseif taken.setPosition then
        --                                                                             taken.setPosition({place_x2, target_v2[2], place_z2})
        --                                                                         end
        --                                                                     end
        --                                                                 end, 1)
        --                                                             end
        --                                                         })
        --                                                     end
        --                                                 end)
        --                                             end
        --                                         end
        --                                     end
        --                                 else
        --                                     LOG.INFO("Vault 2 bag not found; could not move Vault 2 cards")
        --                                 end
        --                                 LOG.INFO("Moved " .. tostring(moved_v2) .. " Vault 2 card(s) to {22.00,0.97,1.58}")
        --                                 pcall(function()
        --                                     broadcastToAll("Continue at step 5 of the Lost Vaults Setup: Choose leader and establish home.", Color.Blue)
        --                                 end)
        --                             end)
        --                         else
        --                             LOG.INFO("Not enough available clusters to mark out of play")
        --                         end
        --                     else
        --                         LOG.INFO("Not enough planet positions or edifice.takeObject missing; cannot place planet cards")
        --                     end
        --                 end
        --             end, 2)
        --         end, 1)
        --     end)
        -- else
        --     LOG.INFO("Could not place lore/artifact cards on edifice (missing objects)")
        -- end
    end

    if #active_players >= 5 then
        BaseGame.adjust_action_deck_for_5p()
    end

    Turns.type = 2
    Turns.order = active_player_colors
    Turns.turn_color = active_players[1].color

    return true
end

function BaseGame.setup_leaders()
    LOG.INFO("Setup Leaders")

    local active_players = Global.getTable("active_players")

    -- check if leader is in player area
    local leader_count = 0
    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local placed_leaders = {}
    for i, player in ipairs(active_players) do
        placed_leaders[i] = nil
        local player_zones = getObjectFromGUID(
                                 player_pieces_guids[player.color]["area_zone"]).getObjects()

        for _, obj in pairs(player_zones) do
            if (obj.hasTag("Leader")) then
                leader_count = leader_count + 1
                placed_leaders[i] = obj
                break
            end
        end
    end
    if leader_count < #active_players then
        local msg = "Setup Leaders: " .. tostring(leader_count) .. " placed of " .. tostring(#active_players) .. " expected"
        LOG.DEBUG(msg)
        broadcastToAll(msg, {r=1, g=0.6, b=0.2})
        return false
    end

    -- Award any immediate effects for leaders placed in player areas
    for i, player in ipairs(active_players) do
        local leader_obj = placed_leaders[i]
        if leader_obj and leader_obj.getName then
            local name = leader_obj.getName()
            local guid = leader_obj.getGUID and leader_obj.getGUID() or leader_obj.guid
            local display_name = player.color
            local info = "Player " .. tostring(display_name) .. " placed leader: " .. tostring(name) .. " (" .. tostring(guid) .. ")"
            LOG.DEBUG(info)
           -- broadcastToAll(info, {r=0.9, g=0.9, b=0.5})
            -- if name == "Seer" then
            --     local dbg = "Awarding 1 Fuel to " .. tostring(display_name) .. " for Seer"
            --     LOG.DEBUG(dbg)
            --     broadcastToAll(dbg, {r=0.8, g=0.58, b=0.27})
            --     local player_proxy = ArcsPlayer
            --     player_proxy.color = player.color
            --     player_proxy:take_resource("Fuel", 3)
            -- end
        end
    end

    -- delete setup markers
    for _, marker_guid in pairs(leader_setup_markers["guids"]) do
        local marker = getObjectFromGUID(marker_guid)
        destroyObject(marker)
    end

    -- setup players
    BaseGame.setupPlayers(active_players, chosen_setup_card)
    return true
end

-- H
function BaseGame.setupBaseCourt(player_count)
    LOG.INFO("Setup Base Court")

    local court_zone = getObjectFromGUID(Global.getVar("court_deck_zone_GUID"))
    local court_zone_pos = court_zone.getPosition()

    local use_scavengers = Global.getVar("use_scavengers_scouts_deck")
    local base_court_guid
    if use_scavengers then
        base_court_guid = Global.getVar("scavengers_scouts_deck_GUID") or BaseGame.components.base_exclusive.scavengers_scouts_deck or Global.getVar("base_court_deck_GUID")
    else
        base_court_guid = Global.getVar("base_court_deck_GUID")
    end

    local base_court = getObjectFromGUID(base_court_guid)
    if not base_court then
        broadcastToAll("Warning: court deck object not found (using default).", {r=1,g=0.5,b=0})
        base_court = getObjectFromGUID(Global.getVar("base_court_deck_GUID"))
        if not base_court then return end
    end

    base_court.setPosition(court_zone_pos)
    base_court.setRotation({0, 270, 180})

    Wait.time(function()
        local qty = (player_count == 2 and 3 or 4)

        -- Always shuffle/randomize the base court deck after placing it
        base_court.randomize()

        -- -- If Lost Vaults (PnP#2) is enabled, do not move or flip any cards
        -- -- from the base court during setup; leave the deck in place.
        -- if Global.getVar("with_pnp2_lost_vaults") then
        --     -- Move the edifice deck to the requested position and shuffle it
        --     return
        -- end

        local court_deck_pos = base_court.getPosition()
        court_deck_pos_z = court_deck_pos.z + 0.35

        for i = 1, qty do
            base_court.takeObject({
                flip = true,
                position = {
                    court_deck_pos.x, court_deck_pos.y,
                    court_deck_pos_z - (i * -2.41)
                }
            })
        end
    end, 1)
end

-- I
function BaseGame.chooseSetupCard(player_count)
    LOG.INFO("Choose Setup Card")

    local player_colors = {"White", "Yellow", "Teal", "Red", "Pink"}

    local two_player_setup_cards = {
        {
            name = "FRONTIERS",
            guid = Global.getVar("frontiers_2P_GUID"),
            out_of_play_clusters = {1, 6},
            player_colors = 2
        }, {
            name = "HOMELANDS",
            guid = Global.getVar("homelands_2P_GUID"),
            out_of_play_clusters = {1, 4},
            player_colors = 2
        }, {
            name = "MIX UP 1",
            guid = Global.getVar("mix_up_1_2P_GUID"),
            out_of_play_clusters = {2, 5},
            player_colors = 2
        }, {
            name = "MIX UP 2",
            guid = Global.getVar("mix_up_2_2P_GUID"),
            out_of_play_clusters = {1, 4},
            player_colors = 2
        }
    }

    local three_player_setup_cards = {
        {
            name = "FRONTIERS",
            guid = Global.getVar("frontiers_3P_GUID"),
            out_of_play_clusters = {2, 3},
            player_colors = 3
        }, {
            name = "HOMELANDS",
            guid = Global.getVar("homelands_3P_GUID"),
            out_of_play_clusters = {5, 6},
            player_colors = 3
        }, {
            name = "CORE CONFLICT",
            guid = Global.getVar("core_conflict_3P_GUID"),
            out_of_play_clusters = {3, 6},
            player_colors = 3
        }, {
            name = "MIX UP",
            guid = Global.getVar("mix_up_3P_GUID"),
            out_of_play_clusters = {1, 4},
            player_colors = 3
        }
    }

    local four_player_setup_cards = {
        {
            name = "FRONTIERS",
            guid = Global.getVar("frontiers_4P_GUID"),
            out_of_play_clusters = {5},
            player_colors = 4
        }, {
            name = "MIX UP 1",
            guid = Global.getVar("mix_up_1_4P_GUID"),
            out_of_play_clusters = {3},
            player_colors = 4
        }, {
            name = "MIX UP 2",
            guid = Global.getVar("mix_up_2_4P_GUID"),
            out_of_play_clusters = {4},
            player_colors = 4
        }, {
            name = "MIX UP 3",
            guid = Global.getVar("mix_up_3_4P_GUID"),
            out_of_play_clusters = {6},
            player_colors = 4
        }
    }

    local five_player_setup_cards = {
        {
            name = "FRONTIERS",
            guid = Global.getVar("frontiers_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }, {
            name = "EMPIRES",
            guid = Global.getVar("empires_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }, {
            name = "MIX UP 1",
            guid = Global.getVar("mix_up_1_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }, {
            name = "MIX UP 2",
            guid = Global.getVar("mix_up_2_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        },{
            name = "EXTENSION",
            guid = Global.getVar("extension_5P_GUID"),
            out_of_play_clusters = {},
            player_colors = 5
        }
    }

    local setup_cards = {
        two_player_setup_cards, three_player_setup_cards,
        four_player_setup_cards, five_player_setup_cards
    }

    -- Allow an external selection to override randomness. Global var
    -- 'setup_choice_index' stores 0 for random or 1..N to pick a specific
    -- option. 'setup_choice_player_count' keeps the player count the
    -- selection was made for.
    local options = BaseGame.getSetupOptions(player_count) or setup_cards[player_count - 1]
    local N = #options
    local choice_index = Global.getVar("setup_choice_index") or 0
    local choice_pcount = Global.getVar("setup_choice_player_count")
    local chosen_setup_card
    if choice_index and choice_index >= 1 and choice_pcount == player_count and choice_index <= N then
        chosen_setup_card = options[choice_index]
    else
        chosen_setup_card = options[math.random(N)]
    end

    -- If a chosen 5P setup card has no GUID configured, fall back to a 4P card
    if player_count == 5 and not chosen_setup_card.guid then
        LOG.WARN("5P setup card '" .. tostring(chosen_setup_card.name) .. "' has no GUID; falling back to a 4P setup card")
        chosen_setup_card = four_player_setup_cards[math.random(#four_player_setup_cards)]
        chosen_setup_card.out_of_play_clusters = {}
    end

    local setup_deck = getObjectFromGUID(Global.getVar("setup_deck_GUID"))
    setup_deck.takeObject({
        guid = chosen_setup_card.guid,
        flip = true,
        position = {0, 4, 0},
        callback_function = function(spawnedObject)
            Wait.frames(function()
                -- We've just waited a frame, which has given the object time to unfreeze.
                -- However, it's also given the object time to enter another container, if
                -- it spawned on one. Thus, we must confirm the object is not destroyed.
                if not spawnedObject.isDestroyed() then
                    spawnedObject.setPositionSmooth({-49.4, 2, 11})
                end
            end)
        end
    })

    getObjectFromGUID(chosen_setup_card.guid).setScale({3, 1, 3})
    return chosen_setup_card

end

-- J
function BaseGame.setupOutOfPlayClusters(setup_card)
    LOG.INFO("Setup Out of Play Clusters")
    local oop_components = Global.getTable("oop_components")
    local board = getObjectFromGUID(Global.getVar("reach_board_GUID"))

    for _, cluster_num in pairs(setup_card.out_of_play_clusters) do
        for _, component in pairs(oop_components[cluster_num]) do
            local object = spawnObject({
                type = "Custom_Token",
                position = board.positionToWorld(component.pos),
                rotation = component.rot,
                scale = component.scale,
                sound = false
            })
            object.setCustomObject({
                image = component.img
            })
            object.setLock(true)

            object.setPosition({object.getPosition().x, 0.93, object.getPosition().z})
        end
    end

end

function BaseGame.setupOutOfPlayForCustom()
    local oop_components = Global.getTable("oop_components")
    
    local bag = spawnObject({
        type = "Bag",
        position = {-52.7995567, 0.7801895, -24.3295612},
        sound = false
    })
    bag.setName("Out of Play Tokens")
    bag.setColorTint({r=1, g=0.7472, b=0})

    local function spawnAndBagToken(tokenData, shouldTagAsGate)
        local token = spawnObject({
            type = "Custom_Token",
            position = bag.getPosition() + Vector(0, 2, 0),
            rotation = tokenData.rot,
            scale = tokenData.scale,
            sound = false
        })
        token.setCustomObject({image = tokenData.img})
        if shouldTagAsGate then token.addTag("oop_gate") end
        Wait.frames(function() bag.putObject(token) end, 1)
    end

    Wait.frames(function()
        for _, cluster in ipairs(oop_components) do
            spawnAndBagToken(cluster.Sector, false)
            spawnAndBagToken(cluster.Gate, true)
        end
    end, 1)
    
    return bag
end

function BaseGame.place_player_markers(ordered_players, setup_card)
    LOG.INFO("Place Player Markers")

    local locations = Global.getVar("starting_locations")[setup_card.guid]
    local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")
    local board = getObjectFromGUID(Global.getVar("reach_board_GUID"))

    for player_number, ABC in pairs(locations) do
        local player_color = ordered_players[player_number].color
        local player_marker_images = leader_setup_markers[player_color]

        -- iterate through setup card's ABCs
        LOG.DEBUG("iterate through setup card's ABCs")
        for starting_letter, cluster_system in pairs(ABC) do
            local cluster = cluster_system["cluster"]
            local system = cluster_system["system"]

            local move_pos
            if (system == "gate") then -- a gate system
                LOG.DEBUG("a gate system")
                move_pos =
                    getObjectFromGUID(cluster_zone_guids[cluster][system]).getPosition()
            else -- this is a planetary system
                LOG.DEBUG("a planetary system")
                move_pos = getObjectFromGUID(
                               cluster_zone_guids[cluster][system]["ships"]).getPosition()
            end

            LOG.DEBUG("spawn marker")
            local marker = spawnObject({
                type = "Custom_Token",
                position = move_pos,
                rotation = {0, 180, 0},
                scale = {0.5, 0.5, 0.5},
                sound = false
            })
            marker.setCustomObject({
                image = player_marker_images[starting_letter]
            })
            marker.setLock(true)
            table.insert(leader_setup_markers["guids"], marker.guid)
            -- marker.reload()
        end
    end
    return true
end

function BaseGame.dealLeaders(player_count)

    local leader_deck = getObjectFromGUID(Global.getVar("fate_GUID"))
    local lore_deck = getObjectFromGUID(Global.getVar("lore_GUID"))
    local mte_fate = getObjectFromGUID(
        Global.getVar("more_to_explore_fate_GUID"))
    local mte_lore = getObjectFromGUID(
        Global.getVar("more_to_explore_lore_GUID"))

    if (Global.getVar("with_more_to_explore")) then
        broadcastToAll("Playing with the Leaders & Lore Expansion")

        leader_deck.putObject(mte_fate)
        lore_deck.putObject(mte_lore)
    end

    -- Optionally remove the base and expansion leader objects entirely.
    -- Capture their position/rotation first so we can move the custom deck
    -- to that location even after deletion.
    local base_leaders_pos, base_leaders_rot
    if (Global.getVar("dont_use_base_and_pack_leaders")) then
        local base_leaders_obj = getObjectFromGUID(BaseGame.components.leaders)
        if (base_leaders_obj) then
            base_leaders_pos = base_leaders_obj.getPosition()
            base_leaders_rot = base_leaders_obj.getRotation()
            destroyObject(base_leaders_obj)
            broadcastToAll("Removed base leaders from the table")
        end
        local expansion_leaders_obj = getObjectFromGUID(BaseGame.components.leaders_expansion)
        if (expansion_leaders_obj) then
            destroyObject(expansion_leaders_obj)
            broadcastToAll("Removed expansion leaders from the table")
        end
    end

    -- Optionally include custom leader decks (Laurens, PnP#3, etc.)
    local custom_decks = {}
    local custom_names = {}
    if Global.getVar("with_laurens_custom_leader") then
        local d = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
        if d then table.insert(custom_decks, d); table.insert(custom_names, "Laurens") end
    end
    if Global.getVar("with_pnp3_custom_leader") then
        local d = getObjectFromGUID(BaseGame.components.pnp3_leaders)
        if d then table.insert(custom_decks, d); table.insert(custom_names, "PnP#3") end
    end

    if #custom_decks > 0 then
        if Global.getVar("dont_use_base_and_pack_leaders") then
            -- Move first custom deck to base leaders position (if recorded),
            -- then put all other custom decks into that deck so they are shuffled together.
            local target = custom_decks[1]
            if base_leaders_pos then
                target.setPosition({base_leaders_pos.x, base_leaders_pos.y, base_leaders_pos.z})
                if base_leaders_rot then target.setRotation(base_leaders_rot) end
            else
                if leader_deck and leader_deck.getPosition then
                    local p = leader_deck.getPosition()
                    target.setPosition({p.x, p.y, p.z})
                end
            end
            for i = 2, #custom_decks do
                leader_deck = target
                leader_deck.putObject(custom_decks[i])
            end
            leader_deck = target
            for i, name in ipairs(custom_names) do
                if name == "Laurens" then
                    broadcastToAll("Including Celestial Leader Expansion by Laurens")
                elseif name == "PnP#3" then
                    broadcastToAll("Including PnP#3 Leader Deck")
                else
                    broadcastToAll("Including " .. name .. "'s custom leader deck")
                end
            end
        else
            -- Merge selected custom decks into the base fate deck
            for i, d in ipairs(custom_decks) do
                leader_deck.putObject(d)
                if custom_names[i] == "Laurens" then
                    broadcastToAll("Including Celestial Leader Expansion by Laurens")
                elseif custom_names[i] == "PnP#3" then
                    broadcastToAll("Including PnP#3 Leader Deck")
                else
                    broadcastToAll("Including " .. custom_names[i] .. "'s custom leader deck")
                end
            end
        end
    end

    leader_deck.randomize()
    lore_deck.randomize()

    -- If Laurens' custom deck exists but is NOT selected for inclusion,
    -- move it to the left of the starting leader deck so it's visible but not used.
    -- If custom decks exist but are NOT selected for inclusion, move them aside
    -- local laurens_obj = getObjectFromGUID(BaseGame.components.laurens_custom_leaders)
    -- if laurens_obj and not Global.getVar("with_laurens_custom_leader") then
    --     if leader_deck and leader_deck.getPosition then
    --         local p = leader_deck.getPosition()
    --         local left_x = p.x - 3.2
    --         laurens_obj.setPosition({left_x, p.y, p.z})
    --     end
    -- end
    -- local pnp3_obj = getObjectFromGUID(BaseGame.components.pnp3_leaders)
    -- if pnp3_obj and not Global.getVar("with_pnp3_custom_leader") then
    --     if leader_deck and leader_deck.getPosition then
    --         local p = leader_deck.getPosition()
    --         local left_x = p.x - 3.2
    --         pnp3_obj.setPosition({left_x, p.y, p.z})
    --     end
    -- end
    if not Global.getVar("with_pnp2_lost_vaults") then
        LOG.INFO("no vaults leaders")
        local leader_pos = {
            x = 25,
            y = 1,
            z = 2
        }
        local lore_pos = {
            x = 25,
            y = 1,
            z = -2.5
        }

        local leader_qty = Global.getVar("leader_draft_count")
        local lore_qty = Global.getVar("lore_draft_count")
        if not leader_qty or not lore_qty then
            local ordered = Global.call("getOrderedPlayers") or {}
            local n = 0
            local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
            for _, p in ipairs(ordered) do
                for _, c in ipairs(colors) do
                    if p.color == c then
                        n = n + 1
                        break
                    end
                end
            end
            local default_count
            if n >= 1 then
                default_count = n + 1
            else
                default_count = (Global.getVar("debug_player_count") or 3) + 1
            end
            leader_qty = leader_qty or default_count
            lore_qty = lore_qty or default_count
        end

        -- Place leaders in rows of 5. If >5, wrap to a row above (increasing z).
        local cols = 5
        local spacing = 3.2
        -- shift all cards one column to the right (so card 1 appears where card 2 was)
        local start_x_offset = spacing
        -- increase vertical separation between rows
        local row_spacing_leaders = 5.5
        local row_spacing_lore = 3.3
        for i = 1, leader_qty do
            local idx = i - 1
            local row = math.floor(idx / cols)
            local col = idx % cols
            local pos = {leader_pos.x + (col * spacing) + start_x_offset, leader_pos.y, leader_pos.z + (row * row_spacing_leaders)}
            leader_deck.takeObject({
                flip = true,
                position = pos,
                callback_function = function(spawnedObject)
                    Wait.frames(function()
                        if not spawnedObject or spawnedObject.isDestroyed and spawnedObject.isDestroyed() then return end
                        local card_name = nil
                        if spawnedObject.getName then
                            card_name = spawnedObject.getName()
                        end
                        local card_guid = nil
                        if spawnedObject.getGUID then
                            card_guid = spawnedObject.getGUID()
                        elseif spawnedObject.guid then
                            card_guid = spawnedObject.guid
                        end

                        -- Explicit checks for special leaders by name or GUID.
                        -- Add or duplicate blocks here for each leader you want to handle.

                        -- Example: Seer
                        if (card_name and card_name == "Seer") or (card_guid and card_guid == "SEER_GUID_PLACEHOLDER") then
                            local match_msg = "Seer drawn while dealing: " .. tostring(card_name) .. " (" .. tostring(card_guid) .. ")"
                            LOG.DEBUG(match_msg)
                        -- broadcastToAll(match_msg, {r=0.2, g=0.9, b=0.2})
                            pcall(function() Global.call("on_special_leader_drawn", {card = spawnedObject, name = card_name, guid = card_guid, leader = "Seer"}) end)
                        end

                        -- Add more if-blocks above as needed for other leaders.
                            -- Explicit card stacks for specific leaders
                            local function placeCardsOnTop(guids)
                                local sd = getObjectFromGUID(BaseGame.components.pnp3_leaders_extra) or lore_deck
                                if not sd or not sd.takeObject then return end
                                local base_pos = spawnedObject.getPosition()
                                -- Place GUIDs in reverse order so the last GUID in the list
                                -- becomes the bottom card and the first becomes the top card.
                                local n = #guids
                                for i = n, 1, -1 do
                                    local g = guids[i]
                                    local stack_index = n - i + 1 -- 1 = bottom, increases upward
                                    -- First try to find the object directly on the table
                                    local obj = getObjectFromGUID(g)
                                    if obj and not (obj.isDestroyed and obj.isDestroyed()) then
                                        if spawnedObject and spawnedObject.getPosition then
                                            local top_pos = spawnedObject.getPosition()
                                            obj.setPositionSmooth({top_pos.x, top_pos.y + 0.6 + ((stack_index - 1) * 0.2), top_pos.z})
                                            if obj.getRotation and spawnedObject.getRotation then
                                                obj.setRotation(spawnedObject.getRotation())
                                            end
                                        end
                                    else
                                        -- Otherwise attempt to take the specific GUID from the source deck.
                                        if sd and sd.takeObject then
                                            pcall(function()
                                                sd.takeObject({
                                                    guid = g,
                                                    flip = true,
                                                    position = {base_pos.x, base_pos.y + 1 + (stack_index * 0.2), base_pos.z},
                                                    callback_function = function(card)
                                                        Wait.frames(function()
                                                            if not card or card.isDestroyed and card.isDestroyed() then return end
                                                            if spawnedObject and spawnedObject.getPosition then
                                                                local top_pos = spawnedObject.getPosition()
                                                                card.setPositionSmooth({top_pos.x, top_pos.y + 0.6 + ((stack_index - 1) * 0.2), top_pos.z})
                                                                card.setRotation(spawnedObject.getRotation())
                                                            end
                                                        end, 1)
                                                    end
                                                })
                                            end)
                                        end
                                    end
                                end
                            end

                            local name_lower = card_name and string.lower(card_name) or nil

                            if (name_lower and name_lower == string.lower("Lightbringer")) then
                                placeCardsOnTop({"b72e0f", "f11960", "8e5a37", "10793b", "c5f33f", "d7d6ef", "4b4145", "0d0bf7"})
                            end

                            -- Firebrand
                            if (name_lower and name_lower == string.lower("Firebrand")) then
                                placeCardsOnTop({"a70559","b92284","58e2d9","bb34d5","bb9f10"})
                            end

                            -- -- Ancient Wraith
                            -- if (name_lower and name_lower == string.lower("Ancient Wraith")) or (card_guid and card_guid == "68b727") then
                            --     placeCardsOnTop({"68b727"})
                            -- ends

                            if (name_lower and name_lower == string.lower("Edenlord")) or (card_guid and card_guid == "c1467b") then
                                placeCardsOnTop({"c1467b"})
                                -- pcall(function() --eden marker over tycoon (no longer used pnp kit 2)
                                --     local bag = getObjectFromGUID("1239bb")
                                --     if bag and bag.takeObject and spawnedObject and spawnedObject.getPosition then
                                --         local pal_pos = spawnedObject.getPosition()
                                --         bag.takeObject({
                                --             guid = "123db0",
                                --             flip = true,
                                --             position = {pal_pos.x, pal_pos.y + 1, pal_pos.z},
                                --             callback_function = function(card)
                                --                 Wait.frames(function()
                                --                     if not card or card.isDestroyed and card.isDestroyed() then return end
                                --                     if spawnedObject and spawnedObject.getPosition then
                                --                         local top_pos = spawnedObject.getPosition()
                                --                         card.setPositionSmooth({top_pos.x, top_pos.y + 0.6, top_pos.z})
                                --                         if card.getRotation and spawnedObject.getRotation then
                                --                             card.setRotation(spawnedObject.getRotation())
                                --                         end
                                --                     end
                                --                 end, 1)
                                --             end
                                --         })
                                    -- end
                                -- end)
                            end

                            -- Profiteer
                            if (name_lower and name_lower == string.lower("Profiteer")) then
                                placeCardsOnTop({"f3a103", "b848e1", "f3baa4", "5abd83"})
                            end
                    end, 1)
                end
            })
        end

        -- Place lores in rows of 5. If >5, wrap to a row below (decreasing z).
        for i = 1, lore_qty do
            local idx = i - 1
            local row = math.floor(idx / cols)
            local col = idx % cols
            local pos = {lore_pos.x + (col * spacing) + start_x_offset, lore_pos.y, lore_pos.z - (row * row_spacing_lore)}
            lore_deck.takeObject({
                flip = true,
                position = pos
            })
        end
    else -- lost vaults
        -- Deal 2 leaders to each player
        leader_deck.deal(2)

        -- Count players
        local ordered = Global.call("getOrderedPlayers") or {}
        local playerCount = 0
        local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}

        for _, p in ipairs(ordered) do
            for _, c in ipairs(colors) do
                if p.color == c then
                    playerCount = playerCount + 1
                    break
                end
            end
        end

        if playerCount == 0 then
            playerCount = Global.getVar("debug_player_count") or 3
        end

        -- Lore layout (same as normal setup)
        local lore_pos = {
            x = 25,
            y = 1,
            z = -2.5
        }

        local cols = 5
        local spacing = 3.2
        local start_x_offset = spacing
        local row_spacing_lore = 3.3

        -- Reveal one lore per player
        for i = 1, playerCount do
            local idx = i - 1
            local row = math.floor(idx / cols)
            local col = idx % cols

            local pos = {
                lore_pos.x + (col * spacing) + start_x_offset,
                lore_pos.y,
                lore_pos.z - (row * row_spacing_lore)
            }

            lore_deck.takeObject({
                flip = true,
                position = pos
            })
        end

        -- Reveal one artifact per player, placed after the lore cards
        local artifact_deck = getObjectFromGUID("9c97c9")
        if artifact_deck then
            if artifact_deck.randomize then
                artifact_deck.randomize()
            end

            for i = 1, playerCount do
                local idx = playerCount + i - 1
                local row = math.floor(idx / cols)
                local col = idx % cols

                local pos = {
                    lore_pos.x + (col * spacing) + start_x_offset,
                    lore_pos.y,
                    lore_pos.z - (row * row_spacing_lore)
                }

                artifact_deck.takeObject({
                    flip = true,
                    position = pos
                })
            end
        end

        -- Move the Windfall deck to the next lore slot
        local windfall_deck = getObjectFromGUID("8cfcb9")
        if windfall_deck then
            if windfall_deck.randomize then
                windfall_deck.randomize()
            end

            -- Move the Windfall deck after all lore + artifact cards
            local deck_idx = playerCount * 2
            local deck_row = math.floor(deck_idx / cols)
            local deck_col = deck_idx % cols

            local deck_pos = {
                lore_pos.x + (deck_col * spacing) + start_x_offset,
                lore_pos.y,
                lore_pos.z - (deck_row * row_spacing_lore)
            }
            
            windfall_deck.setPositionSmooth(deck_pos)

            -- Place the revealed Windfall card after the deck
            local card_idx = playerCount * 2 + 1
            local card_row = math.floor(card_idx / cols)
            local card_col = card_idx % cols

            local card_pos = {
                lore_pos.x + (card_col * spacing) + start_x_offset,
                lore_pos.y,
                lore_pos.z - (card_row * row_spacing_lore)
            }

            if windfall_deck and not (windfall_deck.isDestroyed and windfall_deck.isDestroyed()) then
                windfall_deck.takeObject({
                    flip = true,
                    position = card_pos
                })
            end
        end
    end
end



function BaseGame.setupPlayers(ordered_players, setup_card)
    LOG.INFO("Setup Players")

    local player_leaders = {
        [1] = "Default",
        [2] = "Default",
        [3] = "Default",
        [4] = "Default"
    }
    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")

    for i, player in ipairs(ordered_players) do
        local player_zones = getObjectFromGUID(
                                 player_pieces_guids[player.color]["area_zone"]).getObjects()

        for _, obj in pairs(player_zones) do
            if (obj.hasTag("Leader")) then
                player_leaders[i] = obj.guid
            end
        end
    end

    local locations = Global.getVar("starting_locations")[setup_card.guid]

    for player_number, ABC in pairs(locations) do
        local player_color = ordered_players[player_number].color

        LOG.DEBUG("get player ship and starport bags and city objects")
        local ship_bag = getObjectFromGUID(
            player_pieces_guids[player_color]["ships"])
        local starport_bag = getObjectFromGUID(
            player_pieces_guids[player_color]["starports"])
        local city1 = getObjectFromGUID(
            player_pieces_guids[player_color]["cities"][1])
        local city2 = getObjectFromGUID(
            player_pieces_guids[player_color]["cities"][2])

        LOG.DEBUG("get starting pieces")
        local leader_ref = player_leaders[player_number]
        local leader_name = leader_ref
        -- If the stored value is a GUID for the leader object, resolve its name
        if type(leader_ref) == "string" then
            local leader_obj = getObjectFromGUID(leader_ref)
            if leader_obj and leader_obj.getName then
                leader_name = leader_obj.getName()
            end
        end
        local starting_pieces = Global.getVar("starting_pieces")
        local pieces = nil
        if starting_pieces then
            pieces = starting_pieces[leader_name] or starting_pieces[leader_ref] or starting_pieces["Default"]
        end
        if not pieces then
            LOG.DEBUG("No starting_pieces entry for leader: " .. tostring(leader_name) .. " (or GUID: " .. tostring(leader_ref) .. "). Using Default if available.")
            pieces = starting_pieces and starting_pieces["Default"] or {}
        end

        LOG.DEBUG("iterate through setup card's ABCs")
        for starting_letter, cluster_system in pairs(ABC) do
            local cluster = cluster_system["cluster"]
            local system = cluster_system["system"]

            LOG.DEBUG("get building/ship/gate zones in cluster and system")
            local building_zone
            local ship_zone
            local gate_zone

            -- TODO determine a different condition to determine a gate system
            if (system == "gate") then -- a gate system
                gate_zone = getObjectFromGUID(
                                cluster_zone_guids[cluster][system]).getPosition()

                LOG.DEBUG("move ships to gate zone")
                local ship_qty = pieces[starting_letter]["ships"]
                local ship_place_offset = 0
                for i = 1, ship_qty, 1 do
                    ship_bag.takeObject({
                        position = {
                            gate_zone.x, gate_zone.y + 0.5,
                            gate_zone.z + ship_place_offset
                        }
                    })
                    ship_place_offset = ship_place_offset + 0.3
                end
            else -- this is a planetary system
                building_zone = getObjectFromGUID(
                                    cluster_zone_guids[cluster][system]["buildings"][1]).getPosition()

                LOG.DEBUG("get building type to move")
                local building_type = pieces[starting_letter]["building"]

                LOG.DEBUG("move building to building zone one")
                if (building_type == "city") then
                    if (starting_letter == "A") then
                        city1.setPositionSmooth(building_zone)
                    else
                        city2.setPositionSmooth(building_zone)
                    end
                elseif (building_type == "starport") then
                    starport_bag.takeObject({
                        position = {
                            building_zone.x, building_zone.y + 0.5,
                            building_zone.z
                        },
                        rotation = {0, 180, 0}
                    })
                end

                LOG.DEBUG("move ships to ship zone")
                ship_zone = getObjectFromGUID(
                                cluster_zone_guids[cluster][system]["ships"]).getPosition()
                local ship_qty = pieces[starting_letter]["ships"]
                local ship_place_offset = 0
                for i = 1, ship_qty, 1 do
                    ship_bag.takeObject({
                        position = {
                            ship_zone.x, ship_zone.y + 0.5,
                            ship_zone.z + ship_place_offset
                        }
                    })
                    ship_place_offset = ship_place_offset + 0.3
                end
            end
        end

        LOG.INFO("Disperse starting resources")
        -- TODO: refactor the rest of this function to use Player module
        local player = ArcsPlayer
        player.color = player_color

        local starting_resources = pieces["resources"]

        -- If the leader defines no starting resources, do not give any.
        if starting_resources then
            -- Allow a single resource string or a list of resources
            if type(starting_resources) == "string" then
                starting_resources = { starting_resources }
            end

            if type(starting_resources) == "table" and #starting_resources > 0 then
                LOG.DEBUG("starting_resource: " .. tostring(starting_resources[1]))
                player:take_resource(starting_resources[1], 1)
                if starting_resources[2] then
                    player:take_resource(starting_resources[2], 2)
                end
            end
        end

    end
end

function BaseGame.miniatures_visibility(show)
    local DISPLAY_HEIGHT = 7
    
    local function move_object(obj, shouldRaise)
        if obj and not obj.isDestroyed() then
            local pos = obj.getPosition()
            local newY = pos.y + (shouldRaise and DISPLAY_HEIGHT or -DISPLAY_HEIGHT)
            local newPos = {pos.x, newY, pos.z}
            obj.setPosition(newPos)
            obj.setLock(not shouldRaise)  -- Only lock when hiding (not showing) the object
        end
    end

    local miniatures = Global.getVar("setup_miniatures_GUIDs")
    if miniatures then
        for _, guid in pairs(miniatures) do
            local obj = getObjectFromGUID(guid)
            move_object(obj, show)
        end
    end

    local meeples = Global.getVar("setup_meeples_GUIDs")
    if meeples then
        for _, guid in pairs(meeples) do
            local obj = getObjectFromGUID(guid)
            move_object(obj, not show)
        end
    end
end

function BaseGame.destroy_grey_setup_menu_objects()
    local grey_miniatures = Global.getVar("setup_miniatures_GUIDs")
    local grey_meeples = Global.getVar("setup_meeples_GUIDs")
    local grey_unchanged_meeples = Global.getVar("setup_unchanged_meeples_GUIDs")
    local function destroy_objects(guid_table)
        if guid_table then
            for _, guid in pairs(guid_table) do
                local obj = getObjectFromGUID(guid)
                if obj then obj.destroy() end
            end
        end
    end

    destroy_objects(grey_miniatures)
    destroy_objects(grey_meeples)
    destroy_objects(grey_unchanged_meeples)
end

function BaseGame.destroy_unused_miniature_supplies()
    local player_colors = {"White", "Red", "Yellow", "Pink", "Teal"}
    for _, color in ipairs(player_colors) do
        local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
        local ship_bag = getObjectFromGUID(player_pieces_guids[color]["mini_ships"])
        if ship_bag then
            ship_bag.destroy()
        end
        -- Also destroy miniature agent supplies if present
        local agent_bag = getObjectFromGUID(player_pieces_guids[color]["mini_agents"])
        if agent_bag then
            agent_bag.destroy()
        end
    end
    local mini_imperial_ships_bag = getObjectFromGUID(Global.getVar("mini_imperial_ships_GUID"))
    if mini_imperial_ships_bag then
        mini_imperial_ships_bag.destroy()
    end
    local mini_flagships = getObjectFromGUID(Global.getVar("mini_flagships_GUID"))
    if mini_flagships then
        mini_flagships.destroy()
    end
end

function BaseGame.upgrade_to_miniatures(active_players)
    local function replace_piece_bag(regular_guid, mini_guid, update_global)
        local regular_bag = getObjectFromGUID(regular_guid)
        if not regular_bag then return end
        
        local original_pos = regular_bag.getPosition()
        regular_bag.destroy()
        
        local mini_bag = getObjectFromGUID(mini_guid)
        if mini_bag then
            mini_bag.setPosition(original_pos)
        end
        
        if update_global then
            Global.setVar(update_global, mini_guid)
        end
    end

    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local players = active_players or Global.getVar("active_players") or {}
    for _, player in ipairs(players) do
        local pieces = player_pieces_guids[player.color]
        if pieces then
            replace_piece_bag(pieces["ships"], pieces["mini_ships"])
            replace_piece_bag(pieces["agents"], pieces["mini_agents"])
            pieces["ships"] = pieces["mini_ships"]
            pieces["agents"] = pieces["mini_agents"]
        end
    end

    replace_piece_bag(
        Global.getVar("imperial_ships_GUID"),
        Global.getVar("mini_imperial_ships_GUID"),
        "imperial_ships_GUID"
    )

    replace_piece_bag(
        Global.getVar("flagships_GUID"),
        Global.getVar("mini_flagships_GUID")
    )
end

function BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)
    BaseGame.destroy_grey_setup_menu_objects()
    if with_miniatures then
        BaseGame.upgrade_to_miniatures(active_players)
    else
        BaseGame.destroy_unused_miniature_supplies()
    end
end


return BaseGame

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
__bundle_register("src/RoundManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")
local LOG = require("src/LOG")

local RoundManager = {}

function RoundManager.endRound()
    Global.setVar("turn_count", 0)

    LOG.DEBUG("Seize detection")
    -- Seize detection
    local seize_detected = false
    if ActionCards.count_seize_cards() == 1 then
        seize_detected = true
    elseif ActionCards.count_seize_cards() > 1 then
        broadcastToAll(
            "Multiple seize cards detected, please fix the board and try to End Round again",
            Color.Red)
        return
    end

    LOG.DEBUG("Initiative")
    local initiative_player = Global.getVar("initiative_player")
    local all_players = Global.getVar("active_players")

    if not initiative_player then
        LOG.WARNING(
            "Could not determine initiative player. Please ensure initiative marker is near a player board.")
    elseif Initiative.is_seized() and seize_detected then
        -- Someone already manually seized initiative
        Initiative.unseize()
    elseif not Initiative.is_seized() and seize_detected then
        -- Auto seize initiative for player with last played seize card
        local seize_player_color = ActionCards.find_seize_player()
        if seize_player_color then
            Initiative.take(seize_player_color, true)
            broadcastToAll(seize_player_color .. " has seized the initiative",
                seize_player_color)
        else
            broadcastToAll(
                "Whoever is playing the seize card, pick it up and drop it back into place, then hit End Round again.",
                Color.Red)
            return
        end
    else
        -- If initiative is already seized (marker in seized state) then
        -- do not attempt to find a surpassing card; the seizing player
        -- keeps initiative.
        if Initiative.is_seized() then
            if initiative_player then
                broadcastToAll(initiative_player .. " has seized the initiative and keeps it", initiative_player)
            else
                LOG.DEBUG("Initiative seized but initiative_player unknown")
            end
        else
            -- Check for highest surpassing card
            local surpassing = ActionCards.get_surpassing_card()
            if not surpassing then
                broadcastToAll("No surpassing card, " .. initiative_player ..
                                   " keeps the initiative", initiative_player)
            else
                -- Debug: print all last_action_card values and surpassing card
                LOG.DEBUG("Surpassing card: type=" .. tostring(surpassing.type) .. ", number=" .. tostring(surpassing.number))
                for _, p in ipairs(all_players) do
                    if not p.last_action_card then
                        LOG.DEBUG("Player " .. tostring(p.color) .. " has no last_action_card")
                        goto continue
                    end
                    LOG.DEBUG("Player " .. tostring(p.color) .. " last_action_card: type=" .. tostring(p.last_action_card.type) .. ", number=" .. tostring(p.last_action_card.number))
                    if p.last_action_card.type == surpassing.type and p.last_action_card.number == surpassing.number then
                        LOG.INFO("Initiative assigned to " .. tostring(p.color) .. " for surpassing card match.")
                        Initiative.unseize()
                        Initiative.take(p.color, true)
                        broadcastToAll(string.format(
                            "%s has surpassed with %s %d and takes the initiative",
                            p.color, surpassing.type, surpassing.number), p.color)
                        break
                    end
                    ::continue::
                end
            end
        end
    end

    LOG.DEBUG("Cleanup")

    AmbitionMarkers:reset_zero_marker()
    ActionCards.clear_played()
    -- reset p.last_action_card + p.last_seize_card for all players
    -- otherwise weird bugs happen when state carries over to the next round
    for _, p in ipairs(all_players) do
        p.last_action_card = nil
        p.last_seize_card = nil
    end
    broadcastToAll("End Round\n", Color.Purple)

    local next_turn_color = Global.getVar("initiative_player")
    if next_turn_color then
        Turns.turn_color = next_turn_color
    else
        LOG.WARNING("Skipping turn color update because initiative player is unknown")
    end
    Initiative.unseize()
end

return RoundManager

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
__bundle_register("src/Control", function(require, _LOADED, __bundle_register, __bundle_modules)
local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")
local RoundManager = require("src/RoundManager")
require("src/GUIDs")
local SupplyManager = require("src/Supplies")

control_GUID = Global.getVar("control_GUID")

-- font_color = {0.8, 0.58, 0.27}, GOLD
local teal = {0.4, 0.6, 0.6}
local GREEN = {0.2, 0.5, 0.2}
local RED = {0.8, 0.3, 0.2}

-- Button Rows
-- Row 1 - {x, y, -1.17}
-- Row 2 - {x, y, -0.59}
-- Row 3 - {x, y, -0.01}
-- Row 4 - {x, y, 0.57}
-- Row 5 - {x, y, 1.15}

-- Button Columns
-- Full Col   - {0.00, y, z}
-- Left Side  - {-0.45, y, z}
-- Right Side - {0.45, y, z}

-- Dimension
-- Height - height = 260
-- Full Col - width = 820
-- Half Col - width = 440

local controls_params = {
    index = 0,
    function_owner = self,
    click_function = "doNothing",
    label = "Controls",
    height = 1,
    width = 1,
    position = {0, 0.5, -1.17},
    tooltip = "",
    font_size = 160,
    color = {0, 0, 0},
    hover_color = {0, 0, 0},
    font_color = {0.8, 0.58, 0.27}
}

local start_chapter_params = {
    index = 1,
    function_owner = self,
    click_function = "start_chapter",
    label = "Start Chapter",
    tooltip = "Deal action cards",
    height = 260,
    width = 820,
    position = {0, 0.5, -0.59},
    font_size = 90,
    font_color = {0, 0, 0},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local end_round_params = {
    index = 2,
    function_owner = self,
    click_function = "end_round",
    label = "End Round",
    tooltip = "Cleanup action cards",
    height = 260,
    width = 590,
    position = {-0.2, 0.5, -0.01},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local takeInitiative_params = {
    index = 3,
    function_owner = self,
    click_function = "take_initiative",
    label = "Take\nInitiative",
    height = 260,
    width = 440,
    tooltip = "",
    position = {-0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local seizeInitiative_params = {
    index = 4,
    height = 260,
    width = 440,
    function_owner = self,
    click_function = "seize_initiative",
    label = "Seize\nInitiative",
    tooltip = "",
    position = {0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local toggle_auto_end_params = {
    index = 5,
    function_owner = self,
    click_function = "toggle_auto_end",
    label = "Toggle\nAuto\nEnd",
    tooltip = "Toggle Auto End Round.\n\nPlease report any problems to the Steam Workshop or Github page",
    height = 260,
    width = 220,
    position = {0.6, 0.5, -0.01},
    font_size = 50,
    color = RED,
    hover_color = {0.34, 0.48, 0.34}
}

function onload()
    self.createButton(controls_params)
    self.createButton(start_chapter_params)
    self.createButton(end_round_params)
    self.createButton(takeInitiative_params)
    self.createButton(seizeInitiative_params)
    self.createButton(toggle_auto_end_params)
    self.createButton({
        index = 10,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
end

function doNothing()
end

function start_chapter()

    local available_colors = {"White", "Yellow", "Red", "Teal", "Pink"}

    --------------------------------------------------------------------
    -- STEP 1: GET DECK (use ActionCards helper which scans the zone)
    --------------------------------------------------------------------
    local deck = ActionCards.get_action_deck()

    if not deck then
        LOG.ERROR("Action deck not found in action deck zone")
        return
    end

    --------------------------------------------------------------------
    -- STEP 2: SCAN FOR MANDATE CARDS
    --------------------------------------------------------------------
    local mandate_by_color = {}
    local mandate_found = false

    local objects = deck.getObjects()

    for _, obj in ipairs(objects) do
        if obj.description then
            for _, color in ipairs(available_colors) do
                if string.find(obj.description, color .. " Mandate") then
                    mandate_by_color[color] = obj.guid
                    mandate_found = true
                end
            end
        end
    end

    --------------------------------------------------------------------
    -- STEP 3: GIVE MANDATES IF THEY EXIST
    --------------------------------------------------------------------
    if mandate_found then
        for _, color in ipairs(available_colors) do
            local guid = mandate_by_color[color]

            if guid and Player[color] then
                deck.takeObject({
                    guid = guid,
                    position = Player[color].getHandTransform().position,
                    smooth = true,
                    callback_function = function(card)
                        if card then
                            card.setRotationSmooth({0, 180, 0})
                        end
                    end
                })
            end
        end
    end

    --------------------------------------------------------------------
    -- STEP 4: SHUFFLE AFTER MANDATES REMOVAL
    --------------------------------------------------------------------
    if mandate_found then
        Wait.time(function()
            if deck and deck.shuffle then
                deck.shuffle()
            end
        end, 0.3)
    end

    --------------------------------------------------------------------
    -- STEP 5: ORIGINAL GAME CHECKS
    --------------------------------------------------------------------
    if ActionCards.count_action_cards() > 0 then
        broadcastToAll(
            "There are still action cards in play, please End Round and try again.",
            Color.Red
        )
        return
    end

    Initiative.unseize()
    ActionCards.clear_face_up_discard()

    if ActionCards.check_hands() then
        return
    end

    --------------------------------------------------------------------
    -- CARTEL CHECK (protected): if any player has a '* Cartel' card in
    -- their player area, detect matching resources in other players'
    -- area zones and notify players with a reminder.
    --------------------------------------------------------------------
    do
        local ok_cartel, cartel_err = pcall(function()
            local function get_resource_key_from_name(name)
                if not name then return nil end
                local nl = string.lower(name)
                if string.find(nl, "material") then return "materials", "material" end
                if string.find(nl, "fuel") then return "fuel", "fuel" end
                if string.find(nl, "weapon") or string.find(nl, "weapons") then return "weapons", "weapon" end
                if string.find(nl, "psionic") or string.find(nl, "psionics") then return "psionics", "psionic" end
                if string.find(nl, "relic") then return "relics", "relic" end
                return nil
            end

            local cartel_owners = {}
            for colname, pdata in pairs(player_pieces_GUIDs) do
                local area_guid = pdata and pdata.area_zone
                if area_guid then
                            local zone = nil
                            local ok_get_zone, z = pcall(function() return getObjectFromGUID(area_guid) end)
                            if ok_get_zone then zone = z end
                            if zone and zone.getObjects then
                                local ok_objs, objs = pcall(function() return zone.getObjects() end)
                                if ok_objs and objs then
                                    for _, obj in ipairs(objs) do
                                        local ok, nm = pcall(function() return obj.getName and obj.getName() end)
                                        if ok and nm and string.find(string.lower(nm), "cartel") then
                                            local resource_key, match_word = get_resource_key_from_name(nm)
                                            if resource_key then
                                                cartel_owners[colname] = cartel_owners[colname] or {}
                                                table.insert(cartel_owners[colname], {cartel_name = nm, resource_key = resource_key, match_word = match_word, guid = (pcall(function() return obj.getGUID and obj.getGUID() end) and obj.getGUID and obj.getGUID() or "?")})
                                            end
                                        end
                                    end
                                else
                                    broadcastToAll("Warning: failed to read Cartel area zone for " .. tostring(colname), {1, 0.5, 0})
                                end
                            else
                                broadcastToAll("Warning: Cartel area zone not found or invalid for " .. tostring(colname), {1, 0.5, 0})
                            end
                end
            end

            local msgs = {}
            for owner_color, cartels in pairs(cartel_owners) do
                for _, info in ipairs(cartels) do
                    local cartel_name = info.cartel_name
                    local match_word = info.match_word
                    for victim_color, vdata in pairs(player_pieces_GUIDs) do
                        if victim_color ~= owner_color then
                            local vz = nil
                            local ok_get_vz, z2 = pcall(function() return getObjectFromGUID(vdata.area_zone) end)
                            if ok_get_vz then vz = z2 end
                            if vz and vz.getObjects then
                                local ok_objs2, objs2 = pcall(function() return vz.getObjects() end)
                                local found = {}
                                if ok_objs2 and objs2 then
                                    for _, o in ipairs(objs2) do
                                        local ok2, onm = pcall(function() return o.getName and o.getName() end)
                                        if ok2 and onm and string.find(string.lower(onm), match_word) then
                                            table.insert(found, o)
                                        end
                                    end
                                else
                                    broadcastToAll("Warning: failed to read victim Cartel area for " .. tostring(victim_color), {1, 0.5, 0})
                                end
                                
                                if #found > 0 then
                                    for _, robj in ipairs(found) do
                                        local robj_guid = "?"
                                        local ok_guid, g = pcall(function() return robj.getGUID and robj.getGUID() end)
                                        if ok_guid and g then robj_guid = g end
                                        local ok_name, rname = pcall(function() return robj.getName and robj.getName() end)
                                        broadcastToAll("Cartel resource reminder detected in " .. tostring(victim_color) .. ": guid=" .. tostring(robj_guid) .. " name=" .. tostring(ok_name and rname or "?"), {1, 0.5, 0})
                                    end
                                    table.insert(msgs, victim_color .. " has " .. tostring(#found) .. " " .. match_word .. "(s) in their player area because of " .. owner_color .. "'s " .. cartel_name .. ". Please return them to supply (unless Frozen).")
                                end
                            end
                        end
                    end
                end
            end

            if #msgs > 0 then
                local full = "Cartel reminder:\n"
                for _, m in ipairs(msgs) do full = full .. m .. "\n" end
                broadcastToAll(full, {1, 0.5, 0})
            end
        end)
        if not ok_cartel then
            local msg = "Error in start_chapter cartel check: " .. tostring(cartel_err)
            broadcastToAll(msg, {1, 0, 0})
            if debug and debug.traceback then
                broadcastToAll(debug.traceback(), {1, 0, 0})
            end
        end
    end

    --------------------------------------------------------------------
    -- STEP 6: DEAL CARDS (CONDITIONAL)
    --------------------------------------------------------------------
    if ActionCards.deal_hand then
        if mandate_found then
            -- mandates exist → reduce hand to keep balance (5 total feel)
            ActionCards.deal_hand(5)
        else
            -- no mandates → original rule
            ActionCards.deal_hand(6)
        end
    else
        print("ERROR: deal_hand missing in ActionCards")
    end

    --------------------------------------------------------------------
    -- STEP 7: INITIATIVE
    --------------------------------------------------------------------
    local initiative_player = Global.getVar("initiative_player")

    if initiative_player then
        broadcastToAll(initiative_player .. " will start the chapter\n", initiative_player)
        Turns.turn_color = initiative_player
        Global.setVar("turn_count", 0)
    else
        broadcastToAll(
            "\n\n!!Could not determine initiative player!!\nPlease ensure initiative marker is near a player board.\n\n"
        )
    end

    -- Remind if overlay is on
    if Global.getVar("overlay_sending_enabled") then
        broadcastToAll("Reminder: Overlay is ON - player hands are being displayed", {0.2, 0.8, 0.2})
    end
end

function end_round()
    RoundManager.endRound()
end

function toggle_auto_end()
    local toggle = Global.getVar("is_auto_end_round_enabled")

    toggle = not toggle
    Global.setVar("is_auto_end_round_enabled", toggle)

    if (toggle) then
        self.editButton({
            index = 5,
            color = GREEN,
            hover_color = {0.34, 0.48, 0.34}
        })
    else
        self.editButton({
            index = 5,
            color = RED,
            hover_color = {0.48, 0.34, 0.34}
        })
    end
end

function take_initiative(objectButtonClicked, playerColorClicked)
    Initiative.take(playerColorClicked)
end

function seize_initiative(objectButtonClicked, playerColorClicked)
    Initiative.seize(playerColorClicked)
end

end)
__bundle_register("src/events/DropActionEvents", function(require, _LOADED, __bundle_register, __bundle_modules)
local DropActionEvents = {}

local deps = nil
local recent_announcements = {}
local DUPLICATE_WINDOW_SECONDS = 1.25

function DropActionEvents.configure(config)
  deps = config
end

local function should_suppress_duplicate(guid, event_kind, player_color)
  local now = os.clock()
  local key = tostring(guid or "") .. "|" .. tostring(event_kind or "") .. "|" .. tostring(player_color or "")
  local prev = recent_announcements[key]
  recent_announcements[key] = now
  return prev and (now - prev) < DUPLICATE_WINDOW_SECONDS
end

local function is_object_in_zone(object, zone)
  if not object or not zone then return false end
  local zone_objects = zone.getObjects()
  for _, obj in ipairs(zone_objects) do
    if obj.guid == object.guid then
      return true
    end
  end
  return false
end

function DropActionEvents.handle_object_drop(player_color, object)
  if not deps or not object then return end

  local object_name = object.getName()

  if object_name == "Power" or object_name == "Objective" then
    local power_color = object.getDescription()
    local player = deps.get_arcs_player(power_color)
    if player then
      Wait.time(function()
        player:update_score()
      end, 0.5)
    end
  end

  if object and object.tag == "Card" and object.hasTag("Action") then
    local played_zone = getObjectFromGUID(deps.action_card_zone_GUID)
    local played_zone_card = is_object_in_zone(object, played_zone)
    if not played_zone_card then
      return
    end

    local wait_id = object.getGUID()
    if deps.zone_waits[wait_id] then
      Wait.stop(deps.zone_waits[wait_id])
      deps.zone_waits[wait_id] = nil
    end
    deps.zone_waits[wait_id] = Wait.condition(function()
      local player = deps.get_arcs_player(Turns.turn_color)
      if not player then
        deps.log_warning("Could not track last played card for " .. Turns.turn_color)
        return
      end

      local seize_zone = getObjectFromGUID(deps.seize_zone_GUID)
      local seize_zone_card = is_object_in_zone(object, seize_zone)

      if object.is_face_down and seize_zone_card then
        if not should_suppress_duplicate(wait_id, "seize", player.color) then
          player:set_last_played_seize_card(object.getDescription())
          broadcastToAll(player.color .. " is seizing the initiative", player.color)
        end
      elseif not object.is_face_down and played_zone_card then
        if not should_suppress_duplicate(wait_id, "played", player.color) then
          local action_cards = deps.get_action_cards()
          player:set_last_played_action_card(action_cards.get_info(object))
        end
      end
      deps.zone_waits[wait_id] = nil
    end, function()
      return object == nil or object.getGUID == nil or object.resting
    end)
  end

  if object_name == "Ambition" then
    local obj_guid = (object and object.getGUID and object.getGUID()) or object.guid
    Wait.time(function()
      local obj = nil
      if obj_guid then
        obj = getObjectFromGUID(obj_guid)
      end
      if not obj then
        obj = object
      end
      if not obj then
        obj = getObjectFromGUID("c9e0ee")
      end
      if obj and obj.getPosition then
        deps.ambition_get_info(obj)
      else
        deps.log_debug("Ambition callback: object missing for guid " .. tostring(obj_guid))
      end
    end, 0.5)
  end
end

function DropActionEvents.handle_player_action(player, action, targets, on_object_drop)
  if action ~= Player.Action.FlipOver then
    return
  end

  if #targets == 1 and targets[1].hasTag("Action") then
    Wait.time(function()
      on_object_drop(player.color, targets[1])
    end, 0.25)
  end

  for _, obj in ipairs(targets) do
    if obj.hasTag("Ship") then
      obj.setState(obj.getStateId() == 1 and 2 or 1)
    end
  end
end

return DropActionEvents

end)
__bundle_register("src/events/OverlayChatCommands", function(require, _LOADED, __bundle_register, __bundle_modules)
local OverlayChatCommands = {}

local function trigger_overlay_update()
  pcall(function()
    if _G["send_overlay_update_ui"] then
      _G["send_overlay_update_ui"]()
    end
  end)
end

local function clear_overlay()
  pcall(function()
    if _G["clear_overlay_ui"] then
      _G["clear_overlay_ui"]()
    end
  end)
end

function OverlayChatCommands.handle(message)
  local msg = tostring(message or "")
  local s = string.lower(msg)

  if string.match(s, "^!overlay%s+start") then
    overlay_sending_enabled = true
    broadcastToAll("Overlay sending ENABLED. Will send updates on each turn.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+stop") then
    overlay_sending_enabled = false
    broadcastToAll("Overlay sending DISABLED.", {0.8, 0.2, 0.2})
    clear_overlay()
    return true
  elseif string.match(s, "^!overlay%s+once") then
    trigger_overlay_update()
    broadcastToAll("Overlay: one update sent.", {0.2, 0.8, 0.2})
    return true
  elseif string.match(s, "^!overlay%s+status") then
    local st = overlay_sending_enabled and "ENABLED" or "DISABLED"
    broadcastToAll("Overlay sending is currently: " .. st, {0.8, 0.8, 0.2})
    return true
  elseif string.match(s, "^!overlay%s+hidecards") then
    overlay_cards_hidden = true
    broadcastToAll("Overlay card faces are now HIDDEN.", {0.8, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+showcards") then
    overlay_cards_hidden = false
    broadcastToAll("Overlay card faces are now VISIBLE.", {0.8, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+togglecards") then
    overlay_cards_hidden = not overlay_cards_hidden
    local state = overlay_cards_hidden and "HIDDEN" or "VISIBLE"
    broadcastToAll("Overlay card faces are now " .. state .. ".", {0.8, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+align%s+left") then
    overlay_align = "left"
    broadcastToAll("Overlay alignment set to LEFT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+align%s+right") then
    overlay_align = "right"
    broadcastToAll("Overlay alignment set to RIGHT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+left") then
    overlay_align = "left"
    broadcastToAll("Overlay alignment set to LEFT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+right") then
    overlay_align = "right"
    broadcastToAll("Overlay alignment set to RIGHT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+help") then
    broadcastToAll(
      "!overlay start = enable automatic sending\n" ..
      "!overlay stop = disable automatic sending\n" ..
      "!overlay once = send one update now\n" ..
      "!overlay status = show whether sending is enabled\n" ..
      "!overlay hidecards = blank the card images in the overlay\n" ..
      "!overlay showcards = show the card images again\n" ..
      "!overlay togglecards = switch card visibility on or off\n" ..
      "!overlay help = show this message\n" ..
      "!overlay align left = position overlay on the left side (default)\n" ..
      "!overlay align right = position overlay on the right side",
      {0.8, 0.8, 0.2}
    )
    return true
  end

  return false
end

return OverlayChatCommands

end)
return __bundle_require("Global.-1.lua")