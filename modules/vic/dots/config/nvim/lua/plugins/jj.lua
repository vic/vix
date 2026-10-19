return {

	{
		"nicolasgb/jj.nvim",
		dependencies = {
			"folke/snacks.nvim", -- Optional only if you use picker's
		},
		config = function()
			require("jj").setup({})
			local cmd = require("jj.cmd")
			vim.keymap.set("n", "<leader>ju", "<cmd>HauntTerm -t jjui jjui<CR>", { desc = "jjui" })

			vim.keymap.set("n", "<leader>jd", cmd.describe, { desc = "JJ describe" })
			vim.keymap.set("n", "<leader>je", cmd.edit, { desc = "JJ edit" })
			vim.keymap.set("n", "<leader>jn", cmd.new, { desc = "JJ new" })
			vim.keymap.set("n", "<leader>jj", cmd.status, { desc = "JJ status" })
			vim.keymap.set("n", "<leader>ji", cmd.diff, { desc = "JJ diff" })
			vim.keymap.set("n", "<leader>jq", cmd.squash, { desc = "JJ squash -i" })

			-- Pickers
			vim.keymap.set("n", "<leader>gj", function()
				require("jj.picker").status()
			end, { desc = "JJ Picker status" })
			vim.keymap.set("n", "<leader>gl", function()
				require("jj.picker").file_history()
			end, { desc = "JJ Picker file history" })

			-- Some functions like `describe` or `log` can take parameters
			vim.keymap.set("n", "<leader>jl", function()
				cmd.log({
					revisions = "all()",
				})
			end, { desc = "JJ log" })

			-- This is an alias i use for moving bookmarks its so good
			vim.keymap.set("n", "<leader>jt", function()
				cmd.j("tug")
				cmd.log({})
			end, { desc = "JJ tug" })
		end,
	},
}
