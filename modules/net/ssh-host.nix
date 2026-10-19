# ssh-host: kind of ssh client hosts; each instance becomes one programs.ssh matchBlock.
{
  lib,
  opt,
  maybe,
  ...
}:
let
  t = lib.types;
  fwd = t.submodule {
    options = {
      bind.port = lib.mkOption { type = t.int; };
      host.address = lib.mkOption { type = t.str; };
      host.port = lib.mkOption { type = t.int; };
    };
  };
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
in
{
  _module.args.dataOf = kind: builtins.intersectAttrs kind.module.options; # the declared fields of an instance

  ren.kinds.ssh-host = {
    host = maybe t.str;
    hostname = maybe t.str;
    user = maybe t.str;
    proxyJump = maybe t.str;
    forwardAgent = maybe t.bool;
    controlPersist = maybe t.str;
    serverAliveInterval = maybe t.int;
    serverAliveCountMax = maybe t.int;
    extraOptions = opt (t.attrsOf t.str) { };
    setEnv = opt (t.attrsOf t.str) { };
    localForwards = opt (t.listOf fwd) [ ];
    remoteForwards = opt (t.listOf fwd) [ ];
  };

  ren.ssh-host.edge = {
    host = "edge";
    hostname = "192.168.192.168";
  };
  ren.ssh-host.vini = vini // {
    user = "vic";
  };
  # Same host, user and controlPath as vini: the vini-ssh master opens these forwards
  # and every later `ssh vini` reuses it. Ports: local = 10000 + remote.
  ren.ssh-host.vini-tunnel = vini // {
    user = "vic";
    localForwards =
      map
        (
          port:
          (local port)
          // {
            bind.port = 10000 + port;
          }
        )
        [
          8080 # agentsview
          8787 # headroom dashboard
          8001 # sqlite-web omni.db
        ];
  };
  ren.ssh-host.sini = vini // {
    user = "sini";
  };
  ren.ssh-host."uptermd.upterm.dev" = {
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
}
