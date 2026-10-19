# xfce-desktop: XFCE session, on hosts that list xfce.
{ mod, hostWhen, ... }:
{
  ren.aspects.xfce-desktop = {
    at = hostWhen (h: builtins.elem "xfce" h.desktops);
    nixos = mod (
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
