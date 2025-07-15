return {
	{
		"dfendr/clipboard-image.nvim",
		config = function()
			local home = os.getenv("HOME")
			require("clipboard-image").setup({
				-- Default configuration for all filetype
				default = {
					img_dir = "images",
					img_name = function()
						return vim.fn.input("Name > ")
					end, -- Example result: "2021-04-13-10-04-18"
					affix = "<\n  %s\n>", -- Multi lines affix
				},
				-- You can create configuration for ceartain filetype by creating another field (markdown, in this case)
				-- If you're uncertain what to name your field to, you can run `lua print(vim.bo.filetype)`
				-- Missing options from `markdown` field will be replaced by options from `default` field
				markdown = {
					img_dir = { home, "src", "jarv", "jarv.org", "static", "img" }, -- Use table for nested dir (New feature form PR #20)
					img_dir_txt = "/img",
					img_handler = function(img) -- New feature from PR #22
						local script = string.format("%s/src/jarv/jarv.org/bin/convert %s", home, img.path)
						os.execute(script)
					end,
				},
			})
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
