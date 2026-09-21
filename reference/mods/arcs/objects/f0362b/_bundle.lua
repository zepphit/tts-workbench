-- Bundled by luabundle {"rootModuleName":"Book of Law.f0362b.lua","version":"1.6.0"}
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
__bundle_register("Book of Law.f0362b.lua", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/LawBook")
end)
__bundle_register("src/LawBook", function(require, _LOADED, __bundle_register, __bundle_modules)
local LawBook = {}

local LAW_BOOK = self

local open_button = {
    click_function = "openLawBook",
    function_owner = LAW_BOOK,
    label = "Open\nBook of Law",
    tooltip = "Open Book of Law",
    position = {0,0.5,.37},
    width = 600,
    height = 10,
    font_size = 60,
    scale = {.8, .8, 0.8},
    color = {1,1,1},
    font_color = {0, 0, 0} 
}

function LawBook.setup()
    LAW_BOOK.createButton(open_button)
end

function LawBook.open(player_color)
    LAW_BOOK.Container.search(player_color)
end

-- Begin Object Code --
function onLoad()                       LawBook.setup()             end
function openLawBook(_,player_color)    LawBook.open(player_color)  end
-- End Object Code --

return LawBook
end)
return __bundle_require("Book of Law.f0362b.lua")