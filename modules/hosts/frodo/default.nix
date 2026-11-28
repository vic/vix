# frodo: vic's laptop (ref-typed form, keyboard, desktops; cpu derived from facter).
{ yen, ... }:
{
  yen.host.frodo = {
    system = yen.system.x86_64-linux;
    stateVersion = "26.11";
    users = [ yen.user.vic ];
    autologin = yen.user.vic;
    trusted = true;
    form = yen.form.laptop;
    workstation = true;
    keyboard = yen.keyboard.macos;
    desktops = [
      yen.desktop.niri
      yen.desktop.xfce
    ];
    impermanence = {
      enable = false;
      wipeRoot = false;
    };
  };
}
