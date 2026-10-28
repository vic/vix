# Niri session: the compositor, its helpers, and the keyring it expects.
{ sven, ... }:
{
  sven.aspects.niri-desktop = {
    at = sven.lib.all [
      sven.helpers.linux
      (s: builtins.elem "niri" s.desktops)
    ];
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

  # vic's niri and noctalia configs: on every desktop he uses (old vix linked them everywhere).
  sven.aspects.vic-niri = {
    at = sven.aspects.vic-gui;
    dots = {
      ".config/niri" = "config/niri";
      ".config/noctalia" = "config/noctalia";
    };
  };
}
