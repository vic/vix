# annatar: WSL host.
{ yen, ... }:
{
  yen.host.annatar = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    trusted = true;
    form = yen.form.wsl;
  };

  yen.aspects.annatar-distro = {
    at = yen.host.annatar;
    nixos = {
      fileSystems."/".device = "/dev/noroot";
      fileSystems."/".fsType = "auto";
      boot.loader.grub.enable = false;
    };
  };
}
