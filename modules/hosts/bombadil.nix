# bombadil: the USB installer image (installer base comes from the installer role).
{ sven, ... }:
{
  sven.host.bombadil = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    form = "iso";
    workstation = true;
    cpu = "intel";
    wifi = "broadcom";
    keyboard = "macos";
    firmware = "all";
    desktops = [ "xfce" ];
  };
  sven.aspects.trusted.at = sven.host.bombadil;
}
