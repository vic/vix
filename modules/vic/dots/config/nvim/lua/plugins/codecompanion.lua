return { {
	"olimorris/codecompanion.nvim",
	opts = {
	  display = {
	    action_palette = {
	 	provider = "snacks",
	    },
	    chat = {
	  	window = {
			layout = "buffer",
			fold_context = true,
			fold_reasoning = true,
		},
	    },
	  },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
} }
