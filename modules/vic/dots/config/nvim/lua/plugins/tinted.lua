return {
	{
		"tinted-theming/tinted-vim",
		config = function()
			require("tinted-vim")
			-- vim.cmd.colorscheme("base16-solarized-light")
			vim.cmd.colorscheme("base24-rebecca")
		end,
	},
}
