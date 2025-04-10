{ ... }:
{
  boot.loader.grub.enable = false;
  fileSystems."/".device = "/dev/null";
  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.05";
  users.users.runner.isNormalUser = true;
}
