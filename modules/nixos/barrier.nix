{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    barrier
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      24800 # barrier
    ];
    allowedUDPPorts = [
      24800 # Barrier
    ];
  };

}
