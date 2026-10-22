# vix-rdesk: anydesk and the remote-desktop firewall ports (nixos part).
{
  ren.aspects.vix-rdesk.nixos =
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
