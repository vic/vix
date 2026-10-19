# vim ui: bars, columns, file tree, terminal, cmdline/messages UI.
{ vimFeature, allowUnfree, ... }:
{
  ren.aspects.vim-bufferline = {
    at = vimFeature "bufferline";
    vim.vim.tabline.nvimBufferline.enable = true;
  };

  ren.aspects.vim-dropbar = {
    at = vimFeature "dropbar";
    vim.vim.ui.dropbar-nvim.enable = true;
  };

  ren.aspects.vim-lualine = {
    at = vimFeature "lualine";
    vim.vim.statusline.lualine.enable = true;
  };

  ren.aspects.vim-smartcolumn = {
    at = vimFeature "smartcolumn";
    vim.vim.ui.smartcolumn.enable = true;
  };

  ren.aspects.vim-scope = {
    at = vimFeature "scope";
    unfree = allowUnfree [ "scope.nvim" ]; # no license upstream
    vim =
      { pkgs, ... }:
      {
        vim.extraPlugins.scope = {
          package = pkgs.vimPlugins.scope-nvim;
          setup = "require('scope').setup({})";
        };
      };
  };

  ren.aspects.vim-neo-tree = {
    at = vimFeature "neo-tree";
    vim.vim.filetree.neo-tree.enable = true;
  };

  ren.aspects.vim-toggleterm = {
    at = vimFeature "toggleterm";
    vim.vim.terminal.toggleterm.enable = true;
  };

  ren.aspects.vim-noice = {
    at = vimFeature "noice";
    vim.vim.ui.noice.enable = true;
  };
}
