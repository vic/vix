# kvm-intel: Intel virtualization and microcode, on intel hosts.
{ lib, ren, ... }:
let
  vix = import ../_lib.nix { inherit lib; };
in
{
  ren.aspects.kvm-intel = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.cpu == "intel"))
    ];
    nixos = vix.mod (
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-intel" ];
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      }
    );
  };
}
