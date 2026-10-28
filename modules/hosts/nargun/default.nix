# nargun: workstation with KDE and niri.
{ sven, ... }:
{
  sven.host.nargun = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    workstation = true;
    cpu = "amd";
    keyboard = "macos";
    desktops = [
      "xfce"
      "kde"
      "niri"
    ];
    layouts = [ "enthium" ];
  };
  sven.aspects.trusted.at = sven.host.nargun;

}
