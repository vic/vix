# all-firmware: redistributable and non-free firmware, on hosts with yen.firmware.all.
{ yen, ... }:
{
  yen.aspects.all-firmware = {
    at = yen.kinds.host.where { firmware = yen.firmware.all; };
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
