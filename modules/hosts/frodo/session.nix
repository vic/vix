# frodo session: apps and desktop of vic's laptop (audio comes from bootable).
{ yen, ... }:
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

  yen.aspects.frodo-desktop = {
    at = yen.host.frodo;
    nixos = {
      services.displayManager.autoLogin.enable = true;
      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
    };
  };

  # vic's laptop packages and autologin: written for the user scope, not for the literal "vic".
  yen.aspects.frodo-user = {
    at = yen.lib.all [
      yen.kinds.user
      (yen.lib.within yen.host.frodo)
    ];
    account =
      { user, pkgs, ... }:
      {
        description = user.name;
        packages = [
          pkgs.chromium
          pkgs.flow-control
          pkgs.lapce
          pkgs.nodejs
          pkgs.power-profiles-daemon
          pkgs.uv
        ];
      };
    os =
      { user, ... }:
      {
        services.displayManager.autoLogin.user = user.name;
      };
  };
}
