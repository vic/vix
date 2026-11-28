# ssh-host: data kind of ssh client hosts; each instance becomes one programs.ssh matchBlock.
{
  lib,
  yen,
  types,
  reduce,
  ...
}:
let
  fwd = types.is (
    v:
    lib.isInt (v.bind.port or null)
    && lib.isString (v.host.address or null)
    && lib.isInt (v.host.port or null)
  ) "ssh port forward";
  vini = {
    hostname = "bitstream.ts.json64.dev";
    proxyJump = "vic@vpn.json64.dev";
    forwardAgent = true;
    controlPersist = "no";
  };
  local = port: {
    bind.port = port;
    host.address = "127.0.0.1";
    host.port = port;
  };
  hostsTree.instances = yen.kinds.ssh-host;
  jumpsOf =
    hs:
    lib.listToAttrs (
      map (
        h:
        lib.nameValuePair (if h.host != null then h.host else h.name) (
          lib.optionals (h.proxyJump != null) (
            map (j: lib.last (lib.splitString "@" j)) (lib.splitString "," h.proxyJump)
          )
        )
      ) hs
    );
in
{
  yen.kinds.root.spawns.ssh-host = _: yen.ssh-host;
  yen.kinds.root.sinks.ssh-blocks.reduce = reduce.merge;

  yen.kinds.ssh-host.fields = {
    host = types.maybe types.str;
    hostname = types.maybe types.str;
    user = types.maybe types.str;
    proxyJump = types.maybe types.str;
    forwardAgent = types.maybe types.bool;
    controlPersist = types.maybe types.str;
    serverAliveInterval = types.maybe types.int;
    serverAliveCountMax = types.maybe types.int;
    extraOptions = types.opt (types.attrsOf types.str) { };
    setEnv = types.opt (types.attrsOf types.str) { };
    localForwards = types.opt (types.listOf fwd) [ ];
    remoteForwards = types.opt (types.listOf fwd) [ ];
    forwardsServedBy = types.maybe yen.kinds.home;
  };

  yen.ssh-host.edge = {
    host = "edge";
    hostname = "192.168.192.168";
  };
  yen.ssh-host.vini = vini // {
    user = "vic";
  };
  yen.ssh-host.vini-tunnel = vini // {
    user = "vic";
    forwardsServedBy = yen.home.bitstream;
  };
  yen.ssh-host.sini = vini // {
    user = "sini";
  };
  yen.ssh-host."uptermd.upterm.dev" = {
    forwardAgent = true;
    serverAliveInterval = 10;
    serverAliveCountMax = 6;
    extraOptions.ControlPath = "~/.ssh/upterm-%C";
    setEnv.TERM = "xterm-256color";
    localForwards = [
      (local 8000)
      (local 5900)
    ];
    remoteForwards = [ (local 5000) ];
  };

  # A proxyJump cycle never connects: caught via `yen.lib.graphs.cycles` at eval time!
  yen.aspects.ssh-jumps = {
    at = yen.root;
    cycle =
      { tree, ... }:
      {
        tree = [ hostsTree ];
        errors = map (c: "ssh: proxyJump cycle ${lib.concatStringsSep " -> " c}") (
          yen.lib.graphs.cycles (jumpsOf (tree.select hostsTree))
        );
      };
  };
}
