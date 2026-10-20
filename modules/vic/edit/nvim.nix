# nvim: vic's vim profiles (editors/vim.nix, vic/nvf) on PATH; neovide `<name>-gui` wrappers on the desktop.
{
  ren,
  inputs,
  ...
}:
let
  vix = ren.helpers;
  profiles = builtins.attrNames ren.vim;
  own = pkgs: (vix.perSystem pkgs inputs.self).packages; # this flake's packages (vim profiles)
in
{
  ren.aspects.vic-nvim = {
    at = ren.aspects.vic-headless;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = map (p: (own pkgs).${p}) profiles ++ [ pkgs.neovim-remote ];
        home.sessionVariables.EDITOR = "vim";
      };
  };

  ren.aspects.vic-nvim-gui = {
    at = ren.aspects.vic-gui;
    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          map (p: (own pkgs)."${p}-gui") (builtins.filter (p: own pkgs ? "${p}-gui") profiles)
          ++ [ pkgs.neovide ];
        home.sessionVariables.VISUAL = "vim-gui";
      };
  };
}
