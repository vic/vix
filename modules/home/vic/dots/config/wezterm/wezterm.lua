local wezterm = require("wezterm")
local config = {}

config.color_scheme = "rebecca"
config.default_prog = { "/etc/profiles/per-user/vic/bin/fish", "-l" }

config.font = wezterm.font("JetBrains Mono")
config.font_size = 24.0

return config
