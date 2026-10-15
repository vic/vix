{ inputs, den, ... }:
{
  flake-file.inputs.disko.url = "github:nix-community/disko";

  # Generated hardware facts: disk layout, kernel modules, facter report.
  den.aspects.frodo.hardware.nixos = {
    imports = [
      ./_nixos/hardware-configuration.nix
      ./_nixos/disko.nix
      "${inputs.disko}/module.nix"
    ];

    hardware.facter.reportPath = ./_nixos/facter.json;
  };
}
