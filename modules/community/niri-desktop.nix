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

  # vic's niri and noctalia configs: on every desktop he uses (old vix linked them everywhere).
  ren.aspects.vic-niri = {
    at = vicAt.desktop;
    dots = {
      ".config/niri" = "config/niri";
      ".config/noctalia" = "config/noctalia";
    };
  };
}
