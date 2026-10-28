# vim theme: a profile's `theme` colorscheme, with the plugin that ships it (keyed by the name's first word).
{ sven, lib, ... }:
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
  sven.aspects.vim-theme = {
    at = sven.lib.all [
      sven.kinds.vim
      (s: s.theme != null)
    ];
    nvf =
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
