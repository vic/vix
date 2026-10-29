# nienna: Intel macbook workstation.
{ yen, ... }:
{
  yen.host.nienna = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    workstation = true;
    cpu = "intel";
    wifi = "broadcom";
    keyboard = "macos";
    desktops = [ "xfce" ];
  };
  yen.aspects.trusted.at = yen.host.nienna;

}
