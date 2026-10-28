# vix-sven oracles, in the shape of sven's templates/fleet/tests.nix. Run each under the caps (timeout 300, MemoryMax=12G):
#   nix eval --offline --impure --file tests.nix failed        (expect [ ])
#   nix eval --offline --impure --file tests.nix e2e.failed    (each machine's and home's settings fingerprint vs vix)
let
  flake = builtins.getFlake "path:${toString ./.}";
  inputs = flake.inputs // {
    self = flake;
  };
  inherit (inputs.nixpkgs) lib;
  sven = (import inputs.sven).lib;
  modules = (inputs.import-tree.withLib lib).leafs ./modules;
  fleet = ms: {
    imports = ms;
    _module.args = { inherit inputs lib; };
  };
  r = sven.eval (fleet modules);
  with' = m: sven.eval (fleet (modules ++ [ m ]));
  msgs = q: map (e: e.error) q.errors;
  hasMsg = q: re: lib.any (m: builtins.match re m != null) (msgs q);
  out = r.flake;
  frodo = "fleet:vix/host:frodo";
  varda = "fleet:vix/mac:varda";

  # settings fingerprint (design §0): sorted package names, enabled services, users, home.file targets, hm programs.
  # Order is not compared.
  sorted = xs: lib.sort lib.lessThan (lib.unique xs);
  enabled =
    s:
    sorted (
      lib.attrNames (
        lib.filterAttrs (
          _: v:
          let
            t = builtins.tryEval (lib.isAttrs v && (v.enable or false) == true);
          in
          t.success && t.value
        ) s
      )
    );
  hm = h: {
    packages = sorted (map lib.getName h.home.packages);
    files = sorted (lib.mapAttrsToList (_: f: f.target) (lib.filterAttrs (_: f: f.enable) h.home.file));
    programs = enabled h.programs;
  };
  os = c: {
    packages = sorted (map lib.getName c.environment.systemPackages);
    services = enabled c.services;
    users = lib.attrNames c.users.users;
    homes = lib.mapAttrs (_: hm) (c.home-manager.users or { });
  };
  fingerprints =
    o:
    lib.mapAttrs' (n: c: lib.nameValuePair "nixos-${n}" (os c.config)) (o.nixosConfigurations or { })
    // lib.mapAttrs' (n: c: lib.nameValuePair "darwin-${n}" (os c.config)) (
      o.darwinConfigurations or { }
    )
    // lib.mapAttrs' (n: c: lib.nameValuePair "home-${n}" (hm c.config)) (o.homeConfigurations or { });

  checks = {
    no-errors = msgs r == [ ];
    check-ok = r.check.ok;
    no-undefined = r.undefined == [ ];
    # lanes wrote vix-sven in parallel, so file order is arbitrary: reversing it changes no reduced value and no scope order
    # expected RED on claude-allow: `flat` keeps vix's first-seen order until vic decides V12 (sort)
    vix-permutation-stable =
      let
        rev = sven.eval (fleet (lib.reverseList modules));
        j =
          q:
          builtins.toJSON (
            map (k: sven.jsonSafe (q.reduced.${k} or null)) [
              "claude-allow"
              "unfree"
              "flake-file"
              "dots"
              "ci-jobs"
              "secrets"
            ]
          );
      in
      j rev == j r && map (s: s.id) rev.scopes == map (s: s.id) r.scopes;
    # a broken mac never reaches frodo: frodo's nixos reduces while varda's darwin throws
    vix-sibling-laziness =
      let
        p = with' (
          { sven, ... }:
          {
            sven.aspects.poison = {
              at = sven.mac.varda;
              darwin = throw "poisoned varda";
            };
          }
        );
      in
      p.reduced.nixos.${frodo} != [ ]
      && !(builtins.tryEval (builtins.deepSeq p.reduced.darwin.${varda} true)).success;

    # ── agent surface ──
    labels = (r.labels.ai-headroom.trust or null) == 2 && (r.labels.rdf-pack.trust or null) == 1;
    unfree-on-frodo = r.ask "unfreeOn" { name = "frodo"; } != [ ];
    ports-of-frodo = lib.any (p: p.port == 8787 && p.what == "headroom") (
      r.ask "portsOf" { name = "frodo"; }
    );
    free-port-frodo = ((r.ask "freePort" { name = "frodo"; }).port or null) == 8000;
    rdf-pack =
      lib.stringLength out.rdfPack.sha256 == 64 && lib.hasInfix "sh:NodeShape" out.rdfPack.shacl;
    # negative controls: each rule fires on a planted fault
    port-clash-fires =
      lib.elem "bad:port-clash:${frodo}:8787"
        (with' (
          { sven, ... }:
          {
            sven.aspects.clash = {
              at = sven.aspects.vic-headless;
              ports = [
                {
                  port = 8787;
                  what = "clash";
                }
              ];
            };
          }
        )).check.violations;
    follows-undeclared-fires =
      lib.elem "bad:follows-undeclared:no-such-input:clash"
        (with' (
          { sven, ... }:
          {
            sven.aspects.clash = {
              at = sven.fleet.vix;
              flake-file.inputs.clash = {
                url = "github:example/clash";
                inputs.nixpkgs.follows = "no-such-input";
              };
            };
          }
        )).check.violations;
    ssh-jump-cycle-fires = hasMsg (with' {
      sven.ssh-host.loop-a.proxyJump = "loop-b";
      sven.ssh-host.loop-b.proxyJump = "vic@loop-a";
    }) ".*proxyJump cycle loop-a -> loop-b.*";
  };

  e2e = rec {
    vix = builtins.getFlake "path:/home/vic/hk/vix";
    ours = fingerprints out;
    theirs = fingerprints vix;
    checks = {
      same-outputs = lib.attrNames ours == lib.attrNames theirs;
    }
    // lib.mapAttrs' (
      n: fp: lib.nameValuePair "fingerprint-${n}" (theirs ? ${n} && fp == theirs.${n})
    ) ours;
    failed = lib.filter (n: !checks.${n}) (lib.attrNames checks);
  };
in
{
  inherit
    checks
    e2e
    r
    with'
    ;
  failed = lib.filter (n: !checks.${n}) (lib.attrNames checks);
}
