# kvm: AMD or Intel virtualization and microcode, on hosts with that cpu.
{ yen, ... }:
{
  yen.aspects.kvm-amd = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.cpu == "amd")
    ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-amd" ];
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };

  yen.aspects.kvm-intel = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.cpu == "intel")
    ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-intel" ];
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
