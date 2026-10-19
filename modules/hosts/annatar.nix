# annatar: WSL host.
{ ren, ... }:
{
  ren.host.annatar = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    form = "wsl";
  };

  ren.aspects.annatar-distro.nixos = {
    fileSystems."/".device = "/dev/noroot";
    fileSystems."/".fsType = "auto";
    boot.loader.grub.enable = false;
  };

  ren.aspects.annatar = {
    at = ren.host.annatar;
    includes = [
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.annatar-distro
    ];
  };
}
