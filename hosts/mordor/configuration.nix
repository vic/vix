{ inputs, ... }:
{

  imports = with inputs.self.nixosModules; [
    nix-features
    bootable
    xfce-desktop
    barrier
    vic
    vic-autologin
    kvm-amd
    nvidia
    ./static.nix
    ./filesystems.nix
    ./hardware-configuration.nix
  ];

}
