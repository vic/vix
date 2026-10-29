# annatar: WSL host.
{ yen, ... }:
{
  yen.host.annatar = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    form = "wsl";
  };
  yen.aspects.trusted.at = yen.host.annatar;

  yen.aspects.annatar-distro = {
    at = yen.host.annatar;
    nixos = {
      fileSystems."/".device = "/dev/noroot";
      fileSystems."/".fsType = "auto";
      boot.loader.grub.enable = false;
    };
  };
}
