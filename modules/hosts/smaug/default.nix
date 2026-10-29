# smaug: macbook workstation with nvidia.
{ yen, ... }:
{
  yen.host.smaug = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    workstation = true;
    cpu = "intel";
    gpu = "nvidia";
    wifi = "broadcom";
    keyboard = "macos";
    firmware = "all";
    desktops = [ "xfce" ];
  };
  yen.aspects.trusted.at = yen.host.smaug;

}
