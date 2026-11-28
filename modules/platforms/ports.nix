# ports: service ports per machine/user (inherited via `machine`), forwarded to root `served` for SSH tunnels.
{
  types,
  reduce,
  lib,
  ...
}:
let
  sink = {
    reduce = reduce.elements;
    allowOrphan = true;
    of = types.listOf (
      types.is (p: lib.isInt (p.port or null) && lib.isString (p.what or null)) "port entry"
    );
  };
in
{
  yen.kinds.machine.sinks.ports = sink;
  yen.kinds.user.sinks.ports = sink // {
    into.served = { ports, ... }: lib.concatMap (e: e.value) ports;
  };
  yen.kinds.root.sinks.served = {
    reduce = reduce.elements;
    allowOrphan = true;
  };
}
