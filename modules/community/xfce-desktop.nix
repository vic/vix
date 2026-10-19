# xfce-desktop: XFCE session.
{ mod, ... }:
{
  ren.aspects.xfce-desktop.nixos = mod (
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
}
