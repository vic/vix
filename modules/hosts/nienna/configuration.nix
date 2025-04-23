# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  ...
}:
let
  flake.modules.nixos.nienna.imports = with inputs.self.modules.nixos; [
    vic
    xfce-desktop
    macos-keys
    kvm-intel
    wl-broadcom
    nienna-unfree
  ];
  nienna-unfree = inputs.self.lib.unfree-module [
    "broadcom-sta"
  ];
in
{
  inherit flake;
}
