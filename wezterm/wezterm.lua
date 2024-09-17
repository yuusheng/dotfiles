local wezterm = require("wezterm")
return {
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Bold" }),
	macos_window_background_blur = 30,

	window_background_opacity = 0.92,
	window_decorations = "RESIZE",
	keys = {
		{
			key = "f",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = "k",
			mods = "SUPER",
			action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
		},
	},
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
