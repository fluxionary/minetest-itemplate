local ci = itemplate.resources.craftitems

if ci.plate_material then
	minetest.register_craft({
		output = "itemplate:itemplate",
		recipe = { { ci.plate_material, ci.plate_material, ci.plate_material } },
	})
end
