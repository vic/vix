# bombadil: USB installer image (ref-typed hardware & form).
{ yen, ... }:
{
  yen.host.bombadil = {
    system = yen.system.x86_64-linux;
    stateVersion = "26.05";
    users = [ yen.user.vic ];
    trusted = true;
    form = yen.form.iso;
    workstation = true;
    cpu = yen.cpu.intel;
    wifi = yen.wifi.broadcom;
    keyboard = yen.keyboard.macos;
    firmware = yen.firmware.all;
    desktops = [ yen.desktop.xfce ];
  };
}
