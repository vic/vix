{ vix, ... }:
{
  # Base for every physical NixOS machine: boot/audio/locale, nix config, XFCE.
  vix.workstation.includes = [
    vix.bootable
    vix.nix-settings
    vix.xfce-desktop
  ];
}
