{ inputs, ... }:
let
  flake.modules.nixos.mordor.imports = with inputs.self.modules.nixos; [
    kvm-amd
    mordor-nvidia
    mordor-unfree
    nvidia
    vic
    xfce-desktop
  ];

  mordor-nvidia = {
    hardware.nvidia.prime.nvidiaBusId = "PCI:9:0:0";
  };
  mordor-unfree = inputs.self.lib.unfree-module [
    "nvidia-x11"
    "nvidia-settings"
  ];

in
{
  inherit flake;
}
