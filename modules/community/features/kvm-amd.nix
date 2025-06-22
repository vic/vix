{
  flake.modules.nixos.kvm-amd =
    { lib, config, ... }:
    {
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
