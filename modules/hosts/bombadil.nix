# bombadil: the USB installer image (installer base comes from the installer role).
{ ren, ... }:
{
  ren.host.bombadil = {
    checkout = "/home/vic/hk/vix";
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    form = "iso";
    workstation = true;
    cpu = "intel";
    wifi = "broadcom";
    keyboard = "macos";
    firmware = "all";
    desktops = [ "xfce" ];
  };

  ren.aspects.bombadil = {
    at = ren.host.bombadil;
    includes = [
      ren.aspects.trusted
    ];
  };
}
