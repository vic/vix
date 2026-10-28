# xfce-desktop: XFCE session, on hosts that list xfce.
{ sven, ... }:
{
  sven.aspects.xfce-desktop = {
    at = sven.lib.all [
      sven.helpers.linux
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
