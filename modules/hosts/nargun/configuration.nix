{ inputs, ... }:
let

  flake.modules.nixos.nargun.imports = with inputs.self.modules.nixos; [
    vic
    kde-desktop
    macos-keys
    kvm-amd
  ];

in
{
  inherit flake;
}
