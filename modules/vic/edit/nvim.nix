# nvim: vic's vim profiles (editors/vim.nix, vic/nvf) on PATH; neovide `<name>-gui` wrappers on the desktop.
{
  vicAt,
  config,
  ...
}:
let
  profiles = builtins.attrNames config.ren.vim;
in
{
  ren.aspects.vic-nvim = {
    at = vicAt.headless;
    homeManager =
      { pkgs, self', ... }:
      {
        home.packages = map (p: self'.packages.${p}) profiles ++ [ pkgs.neovim-remote ];
        home.sessionVariables.EDITOR = "vim";
      };
  };

  ren.aspects.vic-nvim-gui = {
    at = vicAt.gui;
    homeManager =
      { pkgs, self', ... }:
      {
        home.packages =
          map (p: self'.packages."${p}-gui") (builtins.filter (p: self'.packages ? "${p}-gui") profiles)
          ++ [ pkgs.neovide ];
        home.sessionVariables.VISUAL = "vim-gui";
      };
  };
}
