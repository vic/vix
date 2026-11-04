# hardware: every host's nixos-facter report, from kit facter. A host with hosts/_facter/<host>.json gets
# `hardware.facter.reportPath`; a host without one gets nothing. The install of a new host writes its report there.
{ yen, inputs, ... }:
{
  imports = [ (import inputs.yen).lib.kits.facter ];
  yen.assembly.hardware = {
    kit = yen.kit.facter;
    roles.default = {
      at = yen.kinds.host;
      settings.dir = ../hosts/_facter;
    };
  };
}
