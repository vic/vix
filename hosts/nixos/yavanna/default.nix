{ pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "yavanna";
  system.stateVersion = "23.05";

  vix.overlays.nix-from-closure.enable = true;
  vix.features.mbp-2011.enable = true;
  vix.features.workstation.enable = true;
  vix.features.plasma-desktop.enable = true;
  vix.features.macos-keys.enable = true;
  vix.users.vic.enable = true;

}
