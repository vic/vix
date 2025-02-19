{ inputs, pkgs, ... }:
{

  imports = with inputs.self.nixosModules; [
    nix-features
    bootable
    kde-desktop
    barrier
    vic
    vic-autologin
    ./static.nix
    ./hardware-configuration.nix
  ];

}
