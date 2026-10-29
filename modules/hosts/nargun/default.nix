# nargun: workstation with KDE and niri.
{ yen, ... }:
{
  yen.host.nargun = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
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
  yen.aspects.trusted.at = yen.host.nargun;

}
