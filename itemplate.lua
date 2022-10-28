local f = string.format

local v_add = vector.add
local v_new = vector.new
local v_sub = vector.subtract

local add_item = minetest.add_item
local get_objects_in_area = minetest.get_objects_in_area

local should_return_item = minetest.settings:get_bool("itemframes.return_item", true)

local facedir = {
	[0] = -0.4,
	[1] = -0.4,
	[2] = -0.4,
	[3] = -0.4,

	[4] = v_new(0, 0, -1),
	[5] = v_new(0, 0, -1),
	[6] = v_new(0, 0, -1),
	[7] = v_new(0, 0, -1),

	[8] = v_new(0, 0, 1),
	[9] = v_new(0, 0, 1),
	[10] = v_new(0, 0, 1),
	[11] = v_new(0, 0, 1),

	[12] = v_new(-1, 0, 0),
	[13] = v_new(-1, 0, 0),
	[14] = v_new(-1, 0, 0),
	[15] = v_new(-1, 0, 0),

	[16] = v_new(1, 0, 0),
	[17] = v_new(1, 0, 0),
	[18] = v_new(1, 0, 0),
	[19] = v_new(1, 0, 0),

	[20] = 0.4,
	[21] = 0.4,
	[22] = 0.4,
	[23] = 0.4,
}

local function return_item(pos, clicker, current_item)
	local inv = clicker:get_inventory()
	local remaining = inv:add_item("name", current_item)
	if not remaining:is_empty() then
		add_item(pos, remaining)
	end
end

local function get_entity(pos)
	local meta = minetest.get_meta(pos)
	local item = meta:get_string("item")

	local to_return

	for _, obj in ipairs(get_objects_in_area(v_sub(pos, 0.5), v_add(pos, 0.5))) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "itemframes:item" then
			local ent_item = ent.texture

			if item == "" or ent_item ~= item or to_return then
				obj:remove()

			else
				to_return = obj
			end
		end
	end

	return to_return
end

local function clear_entity(pos)
	for _, obj in ipairs(get_objects_in_area(v_sub(pos, 0.5), v_add(pos, 0.5))) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "itemframes:item" then
			obj:remove()
		end
	end
end

local function add_entity(pos)
	local meta = minetest.get_meta(pos)
	local item = meta:get_string("item")

	if not item then
		return
	end

	local node = minetest.get_node(pos)

	local pitch = 0
	local p2 = node.param2
	local posad = facedir[p2]

	if not posad then return end

	if type(posad) == "table" then
		pos.x = pos.x + posad.x * 6.5 / 16
		pos.y = pos.y + posad.y * 6.5 / 16
		pos.z = pos.z + posad.z * 6.5 / 16

	else
		pitch = 4.7
		pos.y = pos.y + posad
	end

	local staticdata = f("%s;%s;%s", "itemframes:frame", item, "")

	local e = minetest.add_entity(pos, "itemframes:item", staticdata)
	local yaw = 6.28 - p2 * 1.57

	e:set_rotation({
		x = pitch, -- pitch
		y = yaw, -- yaw
		z = 0 -- roll
	})
end

local function update_entity(pos)
	local meta = minetest.get_meta(pos)
	local item_name = meta:get_string("item")
	local item = ItemStack(item_name)
	local obj = get_entity(pos)

	if item:is_empty() and obj then
		clear_entity(pos)

	elseif obj then
		local e = obj:get_luaentity()
		if e.item ~= item_name then
			e.item = item_name
			obj:set_properties({textures = {item_name}})
		end

	elseif not item:is_empty() then
		add_entity(pos)
	end
end

minetest.register_node("itemplate:itemplate", {
	description = "Plate",
	tiles = {
		"[combine:16x16^[noalpha^[colorize:#FFFFF0",
		"[combine:16x16^[noalpha^[colorize:#FFFFF0",
		"[combine:16x16^[noalpha^[colorize:#888880",
		"[combine:16x16^[noalpha^[colorize:#EEEEE0",
		"[combine:16x16^[noalpha^[colorize:#CCCCC0",
		"[combine:16x16^[noalpha^[colorize:#AAAAA0",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125},
			{-0.4375, -0.4375, -0.5, 0.4375, -0.375, -0.3125},
			{-0.4375, -0.4375, 0.3125, 0.4375, -0.375, 0.5},
			{0.3125, -0.4375, -0.4375, 0.5, -0.375, 0.4375},
			{-0.5, -0.4375, -0.4375, -0.3125, -0.375, 0.4375},
		}
	},
	sunlight_propagates = true,
	walkable = true,
	groups = {dig_immediate = 2},
	on_rightclick = function(pos, node, clicker, itemstack)
		if not (pos and node and clicker and itemstack) then
			return
		end

		if not minetest.is_player(clicker) then
			return
		end

		local clicker_name = clicker:get_player_name()
		if minetest.is_protected(pos, clicker_name) then
			return
		end

		local meta = minetest.get_meta(pos)
		local current_item = meta:get("item")

		if current_item then
			if should_return_item then
				return_item(pos, clicker, current_item)

			else
				add_item(pos, current_item)
			end

			meta:set_string("item", "")
		end

		if not itemstack:is_empty() then
			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())
		end

		update_entity(pos)

		return itemstack
	end,

	can_dig = function(pos, digger)
		local meta = minetest.get_meta(pos)
		return not meta:get("item")
	end,

	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local current_item = meta:get("item")
		if current_item then
			add_item(pos, current_item)
			meta:set_string("item", "")
		end

		update_entity(pos)
	end,

	on_punch = function(pos, node, puncher)
		update_entity(pos)
	end,

	on_blast = function(pos, intensity)
		if minetest.is_protected(pos, "tnt:blast") then
			return
		end

		local meta = minetest.get_meta(pos)
		local current_item = meta:get("item")

		if current_item then
			add_item(pos, current_item)
		end

		add_item(pos, "itemplate:itemplate")

		minetest.remove_node(pos)
	end,
})

-- automatically restore entities lost due to /clearobjects or similar
if itemplate.has.node_entity_queue then
	node_entity_queue.api.register_node_entity_loader("itemplate:itemplate", update_entity)

else
	minetest.register_lbm({
		name = "itemplate:itemplate_item_restoration",
		nodenames = {"itemplate:itemplate"},
		run_at_every_load = true,
		action = function(pos, node, active_object_count, active_object_count_wider)
			update_entity(pos)
		end,
	})
end
