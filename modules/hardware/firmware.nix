# all-firmware: redistributable and non-free firmware, on hosts with firmware = all.
{ sven, ... }:
{
  sven.aspects.all-firmware = {
    at = sven.lib.all [
      sven.helpers.linux
      (s: s.firmware == "all")
    ];
    nixos = {
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      nixpkgs.config.allowUnfree = true;
    };
  };
}
