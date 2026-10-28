# mordor: workstation with an nvidia card.
{ sven, ... }:
{
  sven.host.mordor = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    workstation = true;
    cpu = "amd";
    gpu = "nvidia";
    desktops = [ "xfce" ];
  };
  sven.aspects.trusted.at = sven.host.mordor;

}
