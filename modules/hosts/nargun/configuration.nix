{ inputs, ... }:
let

  flake.modules.nixos.nargun.imports = with inputs.self.modules.nixos; [
    vic
    xfce-desktop
    macos-keys
    kvm-amd
  ];

in
{
  inherit flake;
}
