# bombadil: the USB installer image (installer base comes from the installer role).
{ yen, ... }:
{
  yen.host.bombadil = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    form = "iso";
    workstation = true;
    cpu = "intel";
    wifi = "broadcom";
    keyboard = "macos";
    firmware = "all";
    desktops = [ "xfce" ];
  };
  yen.aspects.trusted.at = yen.host.bombadil;
}
