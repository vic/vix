return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
      require('mini.indentscope').setup()
      -- Provide icons with their highlighting via a single MiniIcons.get() for various categories: filetype, file/directory path, extension, operating system, LSP kind values. Icons and category defaults can be overridden.
      require('mini.icons').setup()
      require('mini.files').setup()
      vim.api.nvim_create_user_command(
        'E',
        function(opts)
          require('mini.files').open(opts.args)
        end,
        {
          nargs = 1,
          complete = 'file',
        } -- This ensures the command takes one argument (the directory)
      )
      --  keymaps (Press '=' to sync)
      vim.keymap.set('n', '<leader>e', ":lua require('mini.files').open()<CR>", { noremap = true, silent = true })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
