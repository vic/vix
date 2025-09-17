{ inputs, ... }:
let
  niri-desktop.programs.niri.enable = true;

  flake.modules.nixos.nargun.imports = with inputs.self.modules.nixos; [
    vic
    niri-desktop
    xfce-desktop
    macos-keys
    kvm-amd
  ];

in
{
  inherit flake;
}
