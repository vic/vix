# kvm-amd: AMD virtualization and microcode, on amd hosts.
{ ren, ... }:
{
  ren.aspects.kvm-amd = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.cpu == "amd"))
    ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-amd" ];
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
