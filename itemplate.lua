local add_item = minetest.add_item

local S = itemplate.S
local should_return_item = itemplate.settings.return_item

minetest.register_node("itemplate:itemplate", {
	description = S("item plate"),
	tiles = itemplate.resources.textures.itemplate,
	drawtype = "nodebox",
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
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = true,

	groups = {dig_immediate = 2},
	sound = itemplate.resources.sounds.glass,

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
				itemplate.return_item(pos, clicker, current_item)

			else
				add_item(pos, current_item)
			end

			meta:set_string("item", "")
		end

		if not itemstack:is_empty() then
			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())
		end

		itemplate.update_entity(pos)

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

		itemplate.update_entity(pos)
	end,

	on_punch = function(pos, node, puncher)
		itemplate.update_entity(pos)
	end,

	on_blast = function(pos, intensity)
		if minetest.is_protected(pos, "tnt:blast") then
			return
		end

		local to_drop = {"itemplate:itemplate"}
		local meta = minetest.get_meta(pos)
		local current_item = meta:get("item")

		if current_item then
			table.insert(to_drop, current_item)
			meta:set_string("item", "")
		end

		minetest.remove_node(pos)

		return to_drop
	end,
})

-- automatically restore entities lost due to /clearobjects or similar
if itemplate.has.node_entity_queue then
	node_entity_queue.api.register_node_entity_loader("itemplate:itemplate", itemplate.update_entity)

else
	minetest.register_lbm({
		name = "itemplate:itemplate_item_restoration",
		nodenames = {"itemplate:itemplate"},
		run_at_every_load = true,
		action = function(pos, node, active_object_count, active_object_count_wider)
			itemplate.update_entity(pos)
		end,
	})
end
