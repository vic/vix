# Native Yen kit `facter` + `hardware` assembly: wires `hosts/_facter/<host>.json` to `hardware.facter.reportPath`.
{
  yen,
  types,
  lib,
  ...
}:
{
  yen.kits.facter.roles.default = {
    settings.dir = types.path;
    nixos =
      { host, settings, ... }:
      (
        f:
        lib.optionalAttrs (builtins.pathExists f) {
          hardware.facter.reportPath = f;
        }
      )
        (settings.dir + "/${host.name}.json");
  };

  yen.assemblies.hardware = yen.kits.facter {
    default = {
      at = yen.kinds.host;
      settings.dir = ../hosts/_facter;
    };
  };
}
