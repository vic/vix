# vim ui: bars, columns, file tree, terminal, cmdline/messages UI.
{ sven, ... }:
{
  sven.aspects.vim-bufferline = {
    at = sven.helpers.vimHas "bufferline";
    nvf.vim.tabline.nvimBufferline.enable = true;
  };

  sven.aspects.vim-dropbar = {
    at = sven.helpers.vimHas "dropbar";
    nvf.vim.ui.dropbar-nvim.enable = true;
  };

  sven.aspects.vim-lualine = {
    at = sven.helpers.vimHas "lualine";
    nvf.vim.statusline.lualine.enable = true;
  };

  sven.aspects.vim-smartcolumn = {
    at = sven.helpers.vimHas "smartcolumn";
    nvf.vim.ui.smartcolumn.enable = true;
  };

  sven.aspects.vim-scope = {
    at = sven.helpers.vimHas "scope";
    unfree = sven.helpers.allowUnfree [ "scope.nvim" ]; # no license upstream
    nvf =
      { pkgs, ... }:
      {
        vim.extraPlugins.scope = {
          package = pkgs.vimPlugins.scope-nvim;
          setup = "require('scope').setup({})";
        };
      };
  };

  sven.aspects.vim-neo-tree = {
    at = sven.helpers.vimHas "neo-tree";
    nvf.vim.filetree.neo-tree.enable = true;
  };

  sven.aspects.vim-toggleterm = {
    at = sven.helpers.vimHas "toggleterm";
    nvf.vim.terminal.toggleterm.enable = true;
  };

  sven.aspects.vim-noice = {
    at = sven.helpers.vimHas "noice";
    nvf.vim.ui.noice.enable = true;
  };
}
