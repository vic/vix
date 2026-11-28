# vim ui: bars, columns, file tree, terminal, cmdline/messages UI.
{ yen, ... }:
{
  yen.aspects.vim-bufferline = {
    at = yen.helpers.vimHas yen.vimFeature.bufferline;
    nvf.vim.tabline.nvimBufferline.enable = true;
  };

  yen.aspects.vim-dropbar = {
    at = yen.helpers.vimHas yen.vimFeature.dropbar;
    nvf.vim.ui.dropbar-nvim.enable = true;
  };

  yen.aspects.vim-lualine = {
    at = yen.helpers.vimHas yen.vimFeature.lualine;
    nvf.vim.statusline.lualine.enable = true;
  };

  yen.aspects.vim-smartcolumn = {
    at = yen.helpers.vimHas yen.vimFeature.smartcolumn;
    nvf.vim.ui.smartcolumn.enable = true;
  };

  yen.aspects.vim-scope = {
    at = yen.helpers.vimHas yen.vimFeature.scope;
    unfree = [ "scope.nvim" ]; # no license upstream
    nvf =
      { pkgs, ... }:
      {
        vim.extraPlugins.scope = {
          package = pkgs.vimPlugins.scope-nvim;
          setup = "require('scope').setup({})";
        };
      };
  };

  yen.aspects.vim-neo-tree = {
    at = yen.helpers.vimHas yen.vimFeature.neo-tree;
    nvf.vim.filetree.neo-tree.enable = true;
  };

  yen.aspects.vim-toggleterm = {
    at = yen.helpers.vimHas yen.vimFeature.toggleterm;
    nvf.vim.terminal.toggleterm.enable = true;
  };

  yen.aspects.vim-noice = {
    at = yen.helpers.vimHas yen.vimFeature.noice;
    nvf.vim.ui.noice.enable = true;
  };
}
