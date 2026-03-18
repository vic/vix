{
  vix.rdesk = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = lib.optionals pkgs.stdenvNoCC.isLinux [
          pkgs.anydesk
        ];
      };

    nixos.networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        24800
        6568
        50001
      ];
      allowedUDPPorts = [
        24800
        6568
        50001
      ];
    };
  };
}
