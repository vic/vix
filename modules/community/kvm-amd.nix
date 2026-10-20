# kvm-amd: AMD virtualization and microcode, on amd hosts.
{ lib, ren, ... }:
let
  vix = import ../_lib.nix { inherit lib; };
in
{
  ren.aspects.kvm-amd = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.cpu == "amd"))
    ];
    nixos = vix.mod (
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-amd" ];
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      }
    );
  };
}
