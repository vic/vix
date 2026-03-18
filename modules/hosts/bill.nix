{
  den.aspects.bill = {
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
      users.users.runner.isNormalUser = true;
    };
  };
}
