{ inputs, ... }:
{

  imports = with inputs.self.nixosModules; [
    nix-features
    bootable
    gnome-desktop
    barrier
    vic
    vic-autologin
    ./static.nix
    ./hardware-configuration.nix
  ];

}
