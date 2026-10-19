local config = function()
	require("mini.files").setup({
		mappings = {
			close = "<ESC>",
			go_in_plus = "<CR>",
			reset = "-",
		},
	})

	local set_mark = function(id, path, desc)
		MiniFiles.set_bookmark(id, path, { desc = desc })
	end
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniFilesExplorerOpen",
		callback = function()
			set_mark("c", vim.fn.stdpath("config"), "Config") -- path
			set_mark("w", vim.fn.getcwd, "Working directory") -- callable

			set_mark("~", "~", "Home directory")
		end,
	})
end

return {
	{
		"nvim-mini/mini.nvim",
		version = false,
		lazy = true,
		keys = {
			{
				"<leader>E",
				function()
					require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
				end,
				desc = "Explore",
			},
		},
		config = config,
	},
}
