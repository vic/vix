# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  ...
}:

{
  imports = with inputs.self.nixosModules; [
    barrier
    bootable
    kde-desktop
    kvm-amd
    macos-keys
    nix-features
    vic
    vic-autologin
    ./static.nix
    ./filesystems.nix
    ./hardware-configuration.nix
  ];

  vix.features.macos-keys.enable = true;

}
