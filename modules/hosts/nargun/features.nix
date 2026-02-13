{ vix, den, ... }:
let
  features = with vix; [
    bootable
    mexico
    niri-desktop
    xfce-desktop
    gnome-desktop
    bluetooth
    hw-detect
    hostname
    macos-keys
    networking
    vix.system'
  ];
in
{
  den.aspects.nargun.includes = features;
}
