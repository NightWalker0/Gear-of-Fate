local _SETTING = {
	release = false,
	version = 0.3,
	sound = 1.0, --0.3
	music = 0,
	ambient = 0.5,
	fps = 60,
	scene = {
		AXIS_RATIO_Y = 0.6,
	},
	window = {
		w = 960,
		h = 540,
		isFullscreen = false,
	},
	debug = {
		fps = true,
		mouse = true,
		playerPosition = true,
		transform = false,
		position = false,
		collider = false,
		sprite = false,
		uidrag = false,
		skill = false,
		navigation = {
			grid = false,
			obstacle = false,
			path = false,
		},
	},
}

return _SETTING