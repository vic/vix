{
  ren,
  ...
}:
{
  # Niri session: the compositor, its helpers, and the keyring it expects.
  ren.aspects.niri-desktop = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: builtins.elem "niri" s.host.desktops))
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
  ren.aspects.vic-niri = {
    at = ren.aspects.vic-gui;
    dots = {
      ".config/niri" = "config/niri";
      ".config/noctalia" = "config/noctalia";
    };
  };
}
