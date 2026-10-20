# all-firmware: redistributable and non-free firmware, on hosts with firmware = all.
{ ren, ... }:
{
  ren.aspects.all-firmware = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.firmware == "all"))
    ];
    nixos = {
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      nixpkgs.config.allowUnfree = true;
    };
  };
}
