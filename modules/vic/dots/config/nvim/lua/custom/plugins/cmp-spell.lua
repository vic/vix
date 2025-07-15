return {
	"f3fora/cmp-spell",
	event = "VimEnter",
	dependencies = { "hrsh7th/nvim-cmp" },
	cmd = { "Spell", "SpellToggle" },
	config = function()
		vim.opt.spell = false
		vim.opt.spelllang = { "en_us" }

		-- enable spell
		vim.api.nvim_create_user_command("Spell", function()
			vim.cmd("set spell")
		end, {})

		-- disable spell
		vim.api.nvim_create_user_command("NoSpell", function()
			vim.cmd("set nospell")
		end, {})

		-- toggle spell
		vim.api.nvim_create_user_command("SpellToggle", function()
			vim.cmd("set invspell")
		end, {})

		-- Enable spell checking for markdown files by default
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.cmd("Spell")
			end,
		})
	end,
}
-- vim: ts=2 sts=2 sw=2 et
