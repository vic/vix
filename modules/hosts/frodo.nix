{ vix, inputs, ... }:
{
  den.aspects.frodo = {
    includes = [
      vix.macos-keys
      vix.laptop
      vix.niri-desktop
    ];

    nixos = {
      imports = [
        ./frodo/_nixos/hardware-configuration.nix
        ./frodo/_nixos/disko.nix
        "${inputs.disko}/module.nix"
      ];

      hardware.facter.reportPath = ./frodo/_nixos/facter.json;

      nix.settings.experimental-features = [
        "flakes"
        "nix-command"
      ];
    };
  };
}
