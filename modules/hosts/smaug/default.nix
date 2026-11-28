# smaug: macbook workstation with nvidia (ref-typed cpu, gpu, wifi, keyboard, firmware, desktops).
{ yen, ... }:
{
  yen.host.smaug = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    trusted = true;
    workstation = true;
    cpu = yen.cpu.intel;
    gpu = yen.gpu.nvidia;
    wifi = yen.wifi.broadcom;
    keyboard = yen.keyboard.macos;
    firmware = yen.firmware.all;
    desktops = [ yen.desktop.xfce ];
  };
}
