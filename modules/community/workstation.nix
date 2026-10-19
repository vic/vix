# workstation: base for every physical NixOS machine: boot/audio/locale, nix config, XFCE.
{ ren, ... }:
{
  ren.aspects.workstation.includes = [
    ren.aspects.bootable
    ren.aspects.nix-settings
    ren.aspects.xfce-desktop
  ];
}
