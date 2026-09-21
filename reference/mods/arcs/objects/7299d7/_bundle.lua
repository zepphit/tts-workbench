-- Bundled by luabundle {"rootModuleName":"Setup.7299d7.lua","version":"1.6.0"}
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
__bundle_register("Setup.7299d7.lua", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/SetupControl")
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
return __bundle_require("Setup.7299d7.lua")