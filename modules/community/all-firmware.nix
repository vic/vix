# all-firmware: redistributable and non-free firmware, on hosts with firmware = all.
{ hostWhen, ... }:
{
  ren.aspects.all-firmware = {
    at = hostWhen (h: h.firmware == "all");
    nixos = {
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      nixpkgs.config.allowUnfree = true;
    };
  };
}
