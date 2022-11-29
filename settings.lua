local s = minetest.settings

-- we're stealing a setting from itemframes, so we can't rely on fmod
itemplate.settings = {
	return_item = s:get_bool("itemframes.return_item", true),
}
