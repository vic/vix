local function clamp(n, lo, hi)
	if n < lo then
		return lo
	end
	if n > hi then
		return hi
	end
	return n
end

local function parse_hex(color)
	local hex = color:gsub("^#", "")
	if #hex ~= 6 then
		return nil
	end
	return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function to_hex(r, g, b)
	return string.format(
		"#%02X%02X%02X",
		clamp(math.floor(r + 0.5), 0, 255),
		clamp(math.floor(g + 0.5), 0, 255),
		clamp(math.floor(b + 0.5), 0, 255)
	)
end

local function lighten(color, pct)
	local r, g, b = parse_hex(color)
	if not r then
		return color
	end
	local t = clamp(pct, 0, 100) / 100.0
	return to_hex(r + (255 - r) * t, g + (255 - g) * t, b + (255 - b) * t)
end

local function darken(color, pct)
	local r, g, b = parse_hex(color)
	if not r then
		return color
	end
	local t = 1.0 - clamp(pct, 0, 100) / 100.0
	return to_hex(r * t, g * t, b * t)
end

local M = {}

function M.setup(primary, config)
	local bright = lighten(primary, 58)
	local mid = lighten(primary, 40)
	local soft = darken(primary, 44)
	local darker = darken(primary, 68)

	-- Adapt selected background to the terminal's actual background color.
	local selected_bg = darker
	local terminal_bg = config.terminal and config.terminal.bg
	if type(terminal_bg) == "string" and terminal_bg ~= "" then
		selected_bg = darken(terminal_bg, 18)
	end

	config.ui = config.ui or {}
	config.ui.colors = config.ui.colors or {}

	config.ui.colors.title = { fg = primary, bold = true }
	config.ui.colors.dimmed = { fg = mid }
	config.ui.colors.shortcut = { fg = bright, bold = true }
	config.ui.colors.selected = { fg = bright, bg = selected_bg, bold = true }
	config.ui.colors.success = { fg = lighten(primary, 55), bold = true }
	config.ui.colors.error = { fg = lighten(primary, 52), bold = true }

	config.ui.colors["revisions selected"] = { fg = bright, bg = selected_bg, bold = true }
	config.ui.colors["revisions dimmed"] = { fg = mid }
end

return M
