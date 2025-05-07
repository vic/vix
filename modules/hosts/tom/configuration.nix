{
  flake.modules.nixos.tom = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/null";
    users.users.runner.isNormalUser = true;
  };
}
