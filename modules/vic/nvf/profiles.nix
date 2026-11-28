# vim profiles: vic's editors using ref-typed `yen.vimFeature.*` tags (zero string tags!).
{ yen, ... }:
let
  f = yen.vimFeature;
in
{
  yen.vim.neovim = {
    theme = "catppuccin-frappe";
    gui = true;
    features = [
      f.globals
      f.snacks
      f.snacks-header
      f.snacks-keys
      f.jj
      f.mini
      f.which-key
      f.tv
      f.lazy
    ];
  };

  yen.vim.nvim = {
    theme = "base24-rebecca";
    gui = true;
    aliases = [
      "vi"
      "vim"
    ];
    features = [
      f.snacks
      f.snacks-extras
      f.snacks-keys
      f.blink
      f.codecompanion
      f.copilot-chat
      f.haunt
      f.hunk
      f.jj
      f.lsp
      f.mini-files
      f.moonbit
      f.rust
      f.tv-vim
      f.which-key
    ];
  };

  yen.vim.astrovim = {
    theme = "astrodark";
    gui = true;
    features = [
      f.lsp
      f.lua
      f.rust
      f.go
      f.bufferline
      f.dropbar
      f.lualine
      f.scope
      f.smartcolumn
      f.codecompanion
      f.neo-tree
      f.toggleterm
      f.which-key
      f.blink
    ];
  };

  yen.vim.lazyvim = {
    theme = "tokyonight";
    gui = true;
    features = [
      f.lsp
      f.rust
      f.copilot
      f.blink
      f.conform
      f.nvim-lint
      f.noice
      f.flash
      f.grug-far
      f.persistence
      f.trouble
      f.todo-comments
      f.mini-essentials
      f.which-key
    ];
  };

  yen.vim.vscode-vim = { };
}
