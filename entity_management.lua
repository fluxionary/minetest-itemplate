local f = string.format

local v_add = vector.add
local v_new = vector.new
local v_sub = vector.subtract

local add_item = minetest.add_item
local get_objects_in_area = minetest.get_objects_in_area

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

function itemplate.return_item(pos, clicker, current_item)
	local inv = clicker:get_inventory()
	local remaining = inv:add_item("name", current_item)
	if not remaining:is_empty() then
		add_item(pos, remaining)
	end
end

function itemplate.get_entity(pos)
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

function itemplate.clear_entity(pos)
	for _, obj in ipairs(get_objects_in_area(v_sub(pos, 0.5), v_add(pos, 0.5))) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "itemframes:item" then
			obj:remove()
		end
	end
end

function itemplate.add_entity(pos)
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

function itemplate.update_entity(pos)
	local meta = minetest.get_meta(pos)
	local item_name = meta:get_string("item")
	local item = ItemStack(item_name)
	local obj = itemplate.get_entity(pos)

	if item:is_empty() and obj then
		itemplate.clear_entity(pos)

	elseif obj then
		local e = obj:get_luaentity()
		if e.item ~= item_name then
			e.item = item_name
			obj:set_properties({textures = {item_name}})
		end

	elseif not item:is_empty() then
		itemplate.add_entity(pos)
	end
end
