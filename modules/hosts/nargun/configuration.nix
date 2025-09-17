{ inputs, ... }:
let
  flake.modules.nixos.nargun.imports = with inputs.self.modules.nixos; [
    vic
    kde-desktop
    niri-desktop
    xfce-desktop
    macos-keys
    kvm-amd
    enthium
  ];

in
{
  inherit flake;
}
