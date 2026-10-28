# nvim: vic's vim profiles (editors/vim.nix, vic/nvf) on PATH; neovide `<name>-gui` wrappers on the desktop.
{ sven, ... }:
let
  profiles = builtins.attrNames sven.vim;
  own = out: pkgs: out.packages.${pkgs.stdenv.hostPlatform.system}; # this flake's packages (vim profiles)
in
{
  sven.aspects.vic-nvim = {
    at = sven.aspects.vic-headless;
    homeManager =
      { out, pkgs, ... }:
      {
        home.packages = map (p: (own out pkgs).${p}) profiles ++ [ pkgs.neovim-remote ];
        home.sessionVariables.EDITOR = "vim";
      };
  };

  sven.aspects.vic-nvim-gui = {
    at = sven.aspects.vic-gui;
    homeManager =
      { out, pkgs, ... }:
      {
        home.packages =
          map (p: (own out pkgs)."${p}-gui") (builtins.filter (p: own out pkgs ? "${p}-gui") profiles)
          ++ [ pkgs.neovide ];
        home.sessionVariables.VISUAL = "vim-gui";
      };
  };
}
