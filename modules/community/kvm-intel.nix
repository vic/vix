# kvm-intel: Intel virtualization and microcode.
{ mod, ... }:
{
  ren.aspects.kvm-intel.nixos = mod (
    { lib, config, ... }:
    {
      boot.kernelModules = [ "kvm-intel" ];
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    }
  );
}
