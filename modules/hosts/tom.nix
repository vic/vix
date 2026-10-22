# tom: CI runner host, no users.
{ ren, ... }:
{
  ren.host.tom.system = ren.system.x86_64-linux;

  ren.aspects.tom-runner.nixos = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/null";
    fileSystems."/".fsType = "auto";
    users.users.runner.isNormalUser = true;
  };
  ren.aspects.tom = {
    at = ren.host.tom;
    includes = [ ren.aspects.tom-runner ];
  };
}
