return {
	{
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			delay = 550,
			preset = "helix",
			keys = {
				scroll_down = "<c-n>",
				scroll_up = "<c-p>",
			},
			spec = {
				-- { '<leader>s', group = '[S]earch' },
				-- { '<leader>t', group = '[T]oggle' },
				-- { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
			},
		},
	},
}
-- vim: ts=2 sts=2 sw=2 et
