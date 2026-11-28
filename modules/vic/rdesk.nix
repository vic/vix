# rdesk: remote desktop, one feature with a system part (anydesk, firewall ports) and a home part (clients).
# DISABLED (as in the old tree): both `at` are empty, active nowhere.
{ yen, ... }:
let
  ports = [
    24800
    6568
    50001
  ];
in
{
  yen.aspects.vix-rdesk = {
    at = [ ];
    ports = map (port: {
      inherit port;
      what = "rdesk";
    }) ports;
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.anydesk ];

        networking.firewall = {
          enable = true;
          allowedTCPPorts = ports;
          allowedUDPPorts = ports;
        };
      };
  };

  yen.aspects.vic-rdesk = {
    at = [ ];
    unfree = [ "anydesk" ];

    homeManager =
      { out, pkgs, ... }:
      {
        home.packages = [
          (yen.helpers.own out pkgs).vic-edge
          pkgs.gsocket
        ];
      };

    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.kdePackages.krdc
          pkgs.xpra
        ];
      };
  };
}
