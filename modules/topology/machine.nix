# Machines: the abstract kind of nixos hosts and macs; `place` finds the machine or home a scope lives on.
{
  ren,
  lib,
  opt,
  ...
}:
let
  inherit (ren.lib) anyOf when;
  place = s: s.host or s.mac or s.home or (if s ? parent then place s.parent else null); # nearest machine or home
  onDarwin = d: when (s: place s != null && (place s).system.darwin == d);
in
{
  _module.args = {
    inherit place;
    darwin = onDarwin true;
    linux = onDarwin false;
  };

  ren.kinds.machine = {
    # abstract: no `below` lists it
    system = ren.kinds.system;
    channel = opt ren.kinds.channel ren.channel.unstable;
    users = opt (lib.types.listOf ren.kinds.user) [ ];
  };

  ren.aspects.hostname = {
    at = anyOf [
      ren.kinds.host
      ren.kinds.mac
    ];
    os =
      { name, ... }: # the machine scope's instance name
      {
        networking.hostName = name;
      };
  };
}
