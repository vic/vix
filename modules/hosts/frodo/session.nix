# frodo session: apps of vic's laptop (audio comes from bootable, autologin from desktops/autologin.nix).
{ yen, at, ... }:
{
  yen.aspects.frodo-apps = {
    at = yen.host.frodo;
    nixos =
      { lib, pkgs, ... }:
      {
        programs.direnv.enable = true;
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
        };
        environment.systemPackages = lib.attrVals [
          "neovim"
          "jujutsu"
          "git"
          "nh"
          "just"
          "direnv"
          "ghostty"
          "niri"
          "wezterm"
          "foot"
          "fzf"
          "ripgrep"
          "fish"
          "fd"
          "jq"
          "noctalia"
        ] pkgs;
      };
  };

  # vic's laptop packages: written for the user scope, not for the literal "vic".
  yen.aspects.frodo-user = {
    at = at.all [
      yen.kinds.user
      (at.under yen.host.frodo)
    ];
    account =
      { user, pkgs, ... }:
      {
        description = user.name;
        packages = [
          pkgs.chromium
          pkgs.flow-control
          pkgs.nodejs
          pkgs.pnpm
          pkgs.power-profiles-daemon
          pkgs.uv
        ];
      };
  };
}
