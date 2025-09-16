return {
	{
		"https://git.sr.ht/~adigitoleo/haunt.nvim",
		lazy = true,
		config = function()
			require("haunt").setup({})
		end,
	},
}
