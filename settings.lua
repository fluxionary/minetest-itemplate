local s = minetest.settings

itemplate.settings = {
	return_item = s:get_bool("itemframes.return_item", true),
}
