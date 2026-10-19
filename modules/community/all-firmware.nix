# all-firmware: redistributable and non-free firmware for physical machines.
{
  ren.aspects.all-firmware.nixos = {
    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true;
  };
}
