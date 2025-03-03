{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    anydesk
    input-leap
  ];

  networking.firewall = {
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

}
