{ mod, ... }:
{
  # Niri session: the compositor, its helpers, and the keyring it expects.
  ren.aspects.niri-desktop = {
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
}
