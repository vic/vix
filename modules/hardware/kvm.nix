# kvm: AMD or Intel virtualization and microcode, on hosts with a ref-typed `cpu` (or facter report).
{ yen, at, ... }:
{
  yen.aspects.kvm = {
    at = yen.kinds.host.where { cpu = at.exists; };
    nixos =
      {
        host,
        lib,
        config,
        ...
      }:
      {
        boot.kernelModules = [ "kvm-${host.cpu.name}" ];
        hardware.cpu.${host.cpu.name}.updateMicrocode =
          lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
