# mordor: workstation with an nvidia card.
{ yen, ... }:
{
  yen.host.mordor = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    workstation = true;
    cpu = "amd";
    gpu = "nvidia";
    desktops = [ "xfce" ];
  };
  yen.aspects.trusted.at = yen.host.mordor;

}
