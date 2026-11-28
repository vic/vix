# nienna: Intel macbook workstation (ref-typed cpu, wifi, keyboard, desktops).
{ yen, ... }:
{
  yen.host.nienna = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    trusted = true;
    workstation = true;
    cpu = yen.cpu.intel;
    wifi = yen.wifi.broadcom;
    keyboard = yen.keyboard.macos;
    desktops = [ yen.desktop.xfce ];
  };
}
