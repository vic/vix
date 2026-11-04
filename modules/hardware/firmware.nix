# all-firmware: redistributable and non-free firmware, on hosts with firmware = all.
{ yen, ... }:
{
  yen.aspects.all-firmware = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.firmware == "all")
    ];
    unfree = [
      "b43-firmware"
      "broadcom-bt-firmware"
      "facetimehd-calibration"
      "facetimehd-firmware"
      "xone-dongle-firmware"
    ];
    nixos = {
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
    };
  };
}
