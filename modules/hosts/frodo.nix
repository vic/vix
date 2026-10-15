{ den, vix, ... }:
let
  # Three axes: what the machine is, what it is for, how it looks.
  machine = [
    den.aspects.frodo.hardware
    vix.macos-keys
    vix.laptop
  ];
  role = [
    den.aspects.frodo.base
    den.aspects.frodo.audio
    den.aspects.frodo.users
    den.aspects.frodo.packages
  ];
  desktop = [
    vix.niri-desktop
    den.aspects.frodo.desktop
  ];
in
{
  # Reads as a sentence: frodo is this machine, this role, this desktop.
  den.aspects.frodo.includes = machine ++ role ++ desktop;
}
