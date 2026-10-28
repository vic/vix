# annatar: WSL host.
{ sven, ... }:
{
  sven.host.annatar = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    form = "wsl";
  };
  sven.aspects.trusted.at = sven.host.annatar;

  sven.aspects.annatar-distro = {
    at = sven.host.annatar;
    nixos = {
      fileSystems."/".device = "/dev/noroot";
      fileSystems."/".fsType = "auto";
      boot.loader.grub.enable = false;
    };
  };
}
