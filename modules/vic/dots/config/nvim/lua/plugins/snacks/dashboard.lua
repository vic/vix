return {
	enabled = true,
	sections = {
		{ section = "startup" },
		{ icon = " ", title = "Recent Files", section = "recent_files", indent = 1, height = 20 },
		{ icon = " ", title = "Projects", section = "projects", indent = 1 },
		{
			icon = " ",
			title = "jj status",
			section = "terminal",
			enabled = function()
				return Snacks.git.get_root() ~= nil
			end,
			cmd = "jj --ignore-working-copy status --no-pager",
			ttl = 5 * 60,
			indent = 0,
		},
	},
}
