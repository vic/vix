{
  flake.modules.nixos.kvm-intel =
    { lib, config, ... }:
    {
      boot.kernelModules = [ "kvm-intel" ];
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
