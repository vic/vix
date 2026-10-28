# kvm: AMD or Intel virtualization and microcode, on hosts with that cpu.
{ sven, ... }:
{
  sven.aspects.kvm-amd = {
    at = sven.lib.all [
      sven.helpers.linux
      (s: s.cpu == "amd")
    ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "kvm-amd" ];
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };

  sven.aspects.kvm-intel = {
    at = sven.lib.all [
      sven.helpers.linux
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
