#  nix build .#.nixosConfigurations.installer.config.system.build.isoImage
{
  modulesPath,
  pkgs,
  config,
  ...
}:
{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
  ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernelModules = [
    "kvm-intel"
    "wl"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    pkgs.vim
    pkgs.git
    pkgs.sops
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
