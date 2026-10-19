return {
	{
		"https://git.sr.ht/~adigitoleo/haunt.nvim",
		lazy = true,
		cmd = { "Haunt", "HauntTerm", "HauntLs" },
		config = function()
			require("haunt").setup({})
		end,
	},
}
