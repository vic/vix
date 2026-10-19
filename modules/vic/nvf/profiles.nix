# vim profiles: vic's editors, one nvf config each (feature aspects live beside this file).
{
  ren.vim.neovim = {
    theme = "catppuccin-frappe";
    gui = true;
    features = [
      "globals"
      "snacks"
      "snacks-header"
      "snacks-keys"
      "jj"
      "mini"
      "which-key"
      "tv"
      "lazy"
    ];
  };

  ren.vim.nvim = {
    theme = "base24-rebecca";
    gui = true;
    aliases = [
      "vi"
      "vim"
    ];
    features = [
      "snacks"
      "snacks-extras"
      "snacks-keys"
      "blink"
      "codecompanion"
      "copilot-chat"
      "haunt"
      "hunk"
      "jj"
      "lsp"
      "mini-files"
      "moonbit"
      "rust"
      "tv-vim"
      "which-key"
    ];
  };

  # AstroNvim recreated from its features (no distro core).
  ren.vim.astrovim = {
    theme = "astrodark";
    gui = true;
    features = [
      "lsp"
      "lua"
      "rust"
      "go"
      "bufferline"
      "dropbar"
      "lualine"
      "scope"
      "smartcolumn"
      "avante"
      "codecompanion"
      "neo-tree"
      "toggleterm"
      "which-key"
      "blink"
    ];
  };

  # LazyVim recreated from its features (no distro core).
  ren.vim.lazyvim = {
    theme = "tokyonight";
    gui = true;
    features = [
      "lsp"
      "rust"
      "copilot"
      "blink"
      "conform"
      "nvim-lint"
      "noice"
      "flash"
      "grug-far"
      "persistence"
      "trouble"
      "todo-comments"
      "mini-essentials"
      "which-key"
    ];
  };

  ren.vim.vscode-vim = { }; # bare nvim for vscode-neovim
}
