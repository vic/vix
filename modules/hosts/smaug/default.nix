# smaug: macbook workstation with nvidia.
{ sven, ... }:
{
  sven.host.smaug = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    workstation = true;
    cpu = "intel";
    gpu = "nvidia";
    wifi = "broadcom";
    keyboard = "macos";
    firmware = "all";
    desktops = [ "xfce" ];
  };
  sven.aspects.trusted.at = sven.host.smaug;

}
