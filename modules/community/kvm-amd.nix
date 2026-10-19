# kvm-amd: AMD virtualization and microcode.
{ mod, ... }:
{
  ren.aspects.kvm-amd.nixos = mod (
    { lib, config, ... }:
    {
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    }
  );
}
