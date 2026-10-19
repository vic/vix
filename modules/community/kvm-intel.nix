# kvm-intel: Intel virtualization and microcode, on intel hosts.
{ mod, hostWhen, ... }:
{
  ren.aspects.kvm-intel = {
    at = hostWhen (h: h.cpu == "intel");
    nixos = mod (
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-intel" ];
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      }
    );
  };
}
