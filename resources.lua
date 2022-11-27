itemplate.resources = {
	craftitems = {},
	sounds = {},
	textures = {
		itemplate = {
			"[combine:16x16^[noalpha^[colorize:#FFFFF0",
			"[combine:16x16^[noalpha^[colorize:#FFFFF0",
			"[combine:16x16^[noalpha^[colorize:#888880",
			"[combine:16x16^[noalpha^[colorize:#EEEEE0",
			"[combine:16x16^[noalpha^[colorize:#CCCCC0",
			"[combine:16x16^[noalpha^[colorize:#AAAAA0",
		},
	},
}

if itemplate.has.default then
	futil.table.set_all(itemplate.resources.craftitems, {
		plate_material = "default:clay_lump",
	})

	futil.table.set_all(itemplate.resources.sounds, {
		glass = default.node_sound_glass_defaults(),
	})
end
