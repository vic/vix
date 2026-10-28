# vix-rdesk: anydesk and the remote-desktop firewall ports (nixos part). No `at`: active nowhere, as in vix.
let
  ports = [
    24800
    6568
    50001
  ];
in
{
  sven.aspects.vix-rdesk = {
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
}
