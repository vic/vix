# nargun: workstation with KDE and niri (ref-typed cpu, keyboard, desktops, layouts).
{ yen, ... }:
{
  yen.host.nargun = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    trusted = true;
    workstation = true;
    cpu = yen.cpu.amd;
    keyboard = yen.keyboard.macos;
    desktops = [
      yen.desktop.xfce
      yen.desktop.kde
      yen.desktop.niri
    ];
    layouts = [ yen.layout.enthium ];
  };
}
