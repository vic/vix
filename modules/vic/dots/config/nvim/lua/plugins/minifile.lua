return {
  { 
    'nvim-mini/mini.nvim', 
    version = false,
    lazy = true,
    keys = {
      { '<leader>E', function() require('mini.files').open() end, desc = "Explore" },
    },
    config = function()
      require('mini.files').setup({
	mappings = {
	  close = '<ESC>', 
	  go_in_plus = '<CR>',
	},
      })
    end,
  },
}
