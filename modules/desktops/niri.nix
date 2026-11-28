# Niri session: the compositor, its helpers, and the keyring it expects.
{ yen, at, ... }:
{
  yen.aspects.niri-desktop = {
    at = yen.kinds.host.where { desktops = at.contains yen.desktop.niri; };
    nixos =
      { lib, pkgs, ... }:
      {
        programs.niri.enable = true;
        services.displayManager.defaultSession = lib.mkForce "niri";
        environment.systemPackages = lib.attrVals [
          "gnome-keyring"
          "brightnessctl"
          "swaybg"
          "fuzzel"
          "xwayland-satellite"
          "grim"
          "slurp"
        ] pkgs;
      };
  };

  yen.aspects.vic-niri = {
    at = yen.aspects.vic-gui;
    dots = {
      ".config/niri" = "config/niri";
      ".config/noctalia" = "config/noctalia";
    };
  };
}
