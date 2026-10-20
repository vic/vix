# vim theme: a profile's `theme` colorscheme, with the plugin that ships it (keyed by the name's first word).
{
  ren,
  lib,
  ...
}:
let
  themes = p: {
    catppuccin.plugin = p.catppuccin-nvim;
    base16.plugin = p.tinted-vim;
    base24.plugin = p.tinted-vim;
    astrodark = {
      plugin = p.astrotheme;
      setup = "require('astrotheme').setup({})"; # palettes are nil until setup
    };
    tokyonight.plugin = p.tokyonight-nvim;
  };
  themeFor = p: name: (themes p).${builtins.head (lib.splitString "-" name)};
in
{
  ren.aspects.vim-theme = {
    at = ren.lib.and [
      ren.kinds.vim
      (ren.lib.when (s: s.vim.theme != null))
    ];
    vim =
      { vim, pkgs, ... }:
      let
        t = themeFor pkgs.vimPlugins vim.theme;
      in
      {
        vim.startPlugins = [ t.plugin ];
        vim.luaConfigRC.theme = ''
          ${t.setup or ""}
          vim.cmd.colorscheme('${vim.theme}')
        '';
      };
  };
}
