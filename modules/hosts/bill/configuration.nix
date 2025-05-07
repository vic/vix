{
  flake.modules.nixos.bill = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/null";
    users.users.runner.isNormalUser = true;
  };
}
