# all-firmware: redistributable and non-free firmware, on hosts with firmware = all.
{ yen, ... }:
{
  yen.aspects.all-firmware = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.firmware == "all")
    ];
    nixos = {
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      nixpkgs.config.allowUnfree = true;
    };
  };
}
