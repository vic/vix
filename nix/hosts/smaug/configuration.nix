# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ inputs, ... }:
{
  flake.modules.nixos.smaug.imports = with inputs.self.modules.nixos; [
    vic
    xfce-desktop
    macos-keys
    kvm-intel
    wl-broadcom
    nvidia
    all-firmware
  ];
}
