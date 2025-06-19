{ ... }:
let

  flake.modules.homeManager.rdesk =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optionals pkgs.stdenvNoCC.isLinux [
        pkgs.anydesk
        #inputs.versioned.packages.${pkgs.system}.input-leap
        # pkgs.input-leap
      ];
    };

  flake.modules.nixos.rdesk.networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      24800 # inputleap
      6568 # anydesk
      50001 # anydesk
    ];
    allowedUDPPorts = [
      24800 # inputleap
      6568 # anydesk
      50001 # anydesk
    ];
  };

in
{
  inherit flake;
}
