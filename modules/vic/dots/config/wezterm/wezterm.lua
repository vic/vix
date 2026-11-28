local wezterm = require("wezterm")
local config = {}

config.color_scheme = "rebecca"
config.default_prog = { "/home/vic/.nix-profile/bin/fish", "-l" }

config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.0

return config
