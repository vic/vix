# nvim: vic's vim profiles (editors/vim.nix, vic/nvf) on PATH; neovide `<name>-gui` wrappers on the desktop.
{ yen, ... }:
let
  profiles = builtins.attrNames yen.vim;
  own = out: pkgs: out.packages.${pkgs.stdenv.hostPlatform.system}; # this flake's packages (vim profiles)
in
{
  yen.aspects.vic-nvim = {
    at = yen.aspects.vic-headless;
    homeManager =
      { out, pkgs, ... }:
      {
        home.packages = map (p: (own out pkgs).${p}) profiles ++ [ pkgs.neovim-remote ];
        home.sessionVariables.EDITOR = "vim";
      };
  };

  yen.aspects.vic-nvim-gui = {
    at = yen.aspects.vic-gui;
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
