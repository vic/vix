return {
	{
		enabled = false,
		"rose-pine/neovim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("rose-pine")
		end,
		config = function()
			require("rose-pine").setup({

				styles = {
					bold = true,
					italic = false,
					transparency = false,
				},

				variant = "auto", -- auto, main, moon, or dawn
				dark_variant = "main", -- main, moon, or dawn
				dim_inactive_windows = false,
				extend_background_behind_borders = true,
			})
		end,
	},
}
-- vim: ts=2 sts=2 sw=2 et
