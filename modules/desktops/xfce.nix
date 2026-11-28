# xfce-desktop: XFCE session, on hosts that list yen.desktop.xfce.
{ yen, at, ... }:
{
  yen.aspects.xfce-desktop = {
    at = yen.kinds.host.where { desktops = at.contains yen.desktop.xfce; };
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
