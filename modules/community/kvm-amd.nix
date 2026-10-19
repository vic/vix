# kvm-amd: AMD virtualization and microcode, on amd hosts.
{ mod, hostWhen, ... }:
{
  ren.aspects.kvm-amd = {
    at = hostWhen (h: h.cpu == "amd");
    nixos = mod (
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-amd" ];
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      }
    );
  };
}
