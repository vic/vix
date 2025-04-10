{ ... }:
{
  boot.loader.grub.enable = false;
  fileSystems."/".device = "/dev/null";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
  users.users.runner.isNormalUser = true;
}
