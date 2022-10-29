local f = string.format

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

itemplate = {
	author = "flux",
	license = "AGPL_v3",
	version = os.time({year = 2022, month = 10, day = 28}),
	fork = "flux",

	modname = modname,
	modpath = modpath,
	S = S,

	has = {
		node_entity_queue = minetest.get_modpath("node_entity_queue"),
	},

	log = function(level, messagefmt, ...)
		return minetest.log(level, f("[%s] %s", modname, f(messagefmt, ...)))
	end,

	dofile = function(...)
		return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
	end,
}

itemplate.dofile("settings")
itemplate.dofile("resources")
itemplate.dofile("entity_management")
itemplate.dofile("itemplate")
itemplate.dofile("crafts")
