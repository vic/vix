# vim ui: bars, columns, file tree, terminal, cmdline/messages UI.
{ ren, ... }:
let
  vix = ren.helpers;
in
{
  ren.aspects.vim-bufferline = {
    at = ren.lib.when (s: builtins.elem "bufferline" (s.vim.features or [ ]));
    vim.vim.tabline.nvimBufferline.enable = true;
  };

  ren.aspects.vim-dropbar = {
    at = ren.lib.when (s: builtins.elem "dropbar" (s.vim.features or [ ]));
    vim.vim.ui.dropbar-nvim.enable = true;
  };

  ren.aspects.vim-lualine = {
    at = ren.lib.when (s: builtins.elem "lualine" (s.vim.features or [ ]));
    vim.vim.statusline.lualine.enable = true;
  };

  ren.aspects.vim-smartcolumn = {
    at = ren.lib.when (s: builtins.elem "smartcolumn" (s.vim.features or [ ]));
    vim.vim.ui.smartcolumn.enable = true;
  };

  ren.aspects.vim-scope = {
    at = ren.lib.when (s: builtins.elem "scope" (s.vim.features or [ ]));
    unfree = vix.allowUnfree [ "scope.nvim" ]; # no license upstream
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
    at = ren.lib.when (s: builtins.elem "neo-tree" (s.vim.features or [ ]));
    vim.vim.filetree.neo-tree.enable = true;
  };

  ren.aspects.vim-toggleterm = {
    at = ren.lib.when (s: builtins.elem "toggleterm" (s.vim.features or [ ]));
    vim.vim.terminal.toggleterm.enable = true;
  };

  ren.aspects.vim-noice = {
    at = ren.lib.when (s: builtins.elem "noice" (s.vim.features or [ ]));
    vim.vim.ui.noice.enable = true;
  };
}
