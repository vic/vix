# nienna: Intel macbook workstation.
{ sven, ... }:
{
  sven.host.nienna = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    workstation = true;
    cpu = "intel";
    wifi = "broadcom";
    keyboard = "macos";
    desktops = [ "xfce" ];
  };
  sven.aspects.trusted.at = sven.host.nienna;

}
