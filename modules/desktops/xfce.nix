# xfce-desktop: XFCE session, on hosts that list xfce.
{ yen, ... }:
{
  yen.aspects.xfce-desktop = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: builtins.elem "xfce" s.desktops)
    ];
    nixos =
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
      };
  };
}
