{ den, lib, ... }:
{
  systems = lib.attrNames den.hosts;
  flake.lib.hostsBySystem = system: builtins.attrNames den.hosts.${system};
}
