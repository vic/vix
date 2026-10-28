# ssh-host: data kind of ssh client hosts; each instance becomes one programs.ssh matchBlock.
{ lib, sven, ... }:
let
  inherit (sven.lib) opt maybe is;
  inherit (sven.helpers) listOf attrsOf;
  t = lib.types;
  fwd = is (
    v:
    lib.isInt (v.bind.port or null)
    && lib.isString (v.host.address or null)
    && lib.isInt (v.host.port or null)
  );
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
  # proxyJump graph by Host match name: each ssh-host jumps to the host part of every hop of its proxyJump
  jumps = lib.mapAttrs' (
    n: h:
    lib.nameValuePair (if h.host != null then h.host else n) (
      lib.optionals (h.proxyJump != null) (
        map (j: lib.last (lib.splitString "@" j)) (lib.splitString "," h.proxyJump)
      )
    )
  ) sven.ssh-host;
in
{
  sven.kinds.ssh-host.fields = {
    host = maybe t.str;
    hostname = maybe t.str;
    user = maybe t.str;
    proxyJump = maybe t.str;
    forwardAgent = maybe t.bool;
    controlPersist = maybe t.str;
    serverAliveInterval = maybe t.int;
    serverAliveCountMax = maybe t.int;
    extraOptions = opt (attrsOf t.str) { };
    setEnv = opt (attrsOf t.str) { };
    localForwards = opt (listOf fwd) [ ];
    remoteForwards = opt (listOf fwd) [ ];
    # forward every port that vic's services on this home serve (fleet `served` sink), local = 10000 + remote
    forwardsServedBy = maybe sven.kinds.home;
  };

  sven.ssh-host.edge = {
    host = "edge";
    hostname = "192.168.192.168";
  };
  sven.ssh-host.vini = vini // {
    user = "vic";
  };
  # Same host, user and controlPath as vini: the vini-ssh master opens these forwards
  # and every later `ssh vini` reuses it. vini is the bitstream home: forward what runs there.
  sven.ssh-host.vini-tunnel = vini // {
    user = "vic";
    forwardsServedBy = sven.home.bitstream;
  };
  sven.ssh-host.sini = vini // {
    user = "sini";
  };
  sven.ssh-host."uptermd.upterm.dev" = {
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

  # a proxyJump cycle never connects: an error record at eval, before any build
  sven.aspects.ssh-jumps = {
    at = sven.fleet.vix;
    errors = map (c: "ssh: proxyJump cycle ${lib.concatStringsSep " -> " c}") (
      sven.lib.graphs.sccs jumps
    );
  };
}
