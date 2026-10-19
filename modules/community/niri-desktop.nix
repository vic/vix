{
  ren,
  vicAt,
  mod,
  hostWhen,
  ...
}:
{
  # Niri session: the compositor, its helpers, and the keyring it expects.
  ren.aspects.niri-desktop = {
    at = hostWhen (h: builtins.elem "niri" h.desktops);
    nixos = mod (
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
      }
    );
  };

  # vic's niri and noctalia configs, on his desktop users of niri machines.
  ren.aspects.vic-niri = {
    at = ren.lib.and [
      vicAt.desktop
      (ren.lib.within ren.aspects.niri-desktop)
    ];
    dots = {
      ".config/niri" = "config/niri";
      ".config/noctalia" = "config/noctalia";
    };
  };
}
