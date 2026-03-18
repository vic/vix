{
  den.aspects.tom = {
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
      users.users.runner.isNormalUser = true;
    };
  };
}
