{
  vix.rdesk.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.anydesk ];

      networking.firewall = {
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
