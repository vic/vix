# xfce-desktop: XFCE session, on hosts that list xfce.
{ lib, ren, ... }:
let
  vix = import ../_lib.nix { inherit lib; };
in
{
  ren.aspects.xfce-desktop = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: builtins.elem "xfce" s.host.desktops))
    ];
    nixos = vix.mod (
      { lib, ... }:
      {
        services.xserver = {
          enable = true;
          desktopManager = {
            xterm.enable = false;
            xfce.enable = true;
          };
        };
        services.displayManager = {
          defaultSession = lib.mkDefault "xfce";
          enable = true;
        };
      }
    );
  };
}
