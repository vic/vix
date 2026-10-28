# ports: the ports a machine's or a user's services listen on. No element reaches a module directly.
# The unique-port invariant and the portsOf and freePort queries read it. A user's ports also go up to
# the fleet `served` sink with their scope, so an ssh tunnel forwards what runs on the far end (vic/sys/ssh.nix).
# An element is a list (one aspect can open many ports): `ports = [ { port = 8787; what = "headroom"; } ];`
{ sven, lib, ... }:
let
  sink = {
    reduce = sven.lib.reduce.entries;
    of = sven.helpers.listOf (
      sven.lib.is (p: lib.isInt (p.port or null) && lib.isString (p.what or null))
    );
  };
in
{
  sven.kinds.host.sinks.ports = sink;
  sven.kinds.guest.sinks.ports = sink;
  sven.kinds.mac.sinks.ports = sink;
  sven.kinds.user.sinks.ports = sink // {
    served = { ports, ... }: lib.concatMap (e: e.value) ports;
  };
  # entries: each value comes with the user scope that serves it
  sven.kinds.fleet.sinks.served.reduce = sven.lib.reduce.entries;
}
