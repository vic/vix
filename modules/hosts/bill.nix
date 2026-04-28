{
  den.aspects.bill = {
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
      fileSystems."/".fsType = "auto";
      users.users.runner.isNormalUser = true;
    };
  };
}
