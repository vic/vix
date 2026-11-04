# vix-yen oracles, in the shape of yen's templates/fleet/tests.nix. Run each under the caps (timeout 300, MemoryMax=12G):
#   nix eval --offline --impure --file tests.nix failed        (expect [ ])
#   nix eval --offline --impure --file tests.nix e2e.failed    (each machine's and home's settings fingerprint vs vix)
let
  flake = builtins.getFlake "path:${toString ./.}";
  inputs = flake.inputs // {
    self = flake;
  };
  inherit (inputs.nixpkgs) lib;
  yen = (import inputs.yen).lib;
  modules = (inputs.import-tree.withLib lib).leaves ./modules;
  fleet = ms: {
    imports = ms;
    inherit inputs lib;
    yen.sinks = {
      inputs = { };
      lib = { };
    };
  };
  frodoRef = {
    kind = "host";
    name = "frodo";
  }; # a ref from JSON: what an agent passes to `ask`
  r = yen.eval (fleet modules);
  with' = m: yen.eval (fleet (modules ++ [ m ]));
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
    # lanes wrote vix-yen in parallel, so file order is arbitrary: reversing it changes no reduced value and no scope order
    # expected RED on claude-allow: `flat` keeps vix's first-seen order until vic decides V12 (sort)
    vix-permutation-stable =
      let
        rev = yen.eval (fleet (lib.reverseList modules));
        j =
          q:
          builtins.toJSON (
            map (k: yen.jsonSafe (q.reduced.${k} or null)) [
              "claude-allow"
              "unfree"
              "flake-file"
              "dots"
              "ci-jobs"
              "sops"
            ]
          );
      in
      j rev == j r && map (s: s.id) rev.scopes == map (s: s.id) r.scopes;
    # a broken mac is an error record at varda, never a throw: the fleet gives no outputs and names varda
    vix-broken-mac-blocks =
      let
        p = with' (
          { yen, ... }:
          {
            yen.aspects.poison = {
              at = yen.mac.varda;
              errors = [ "poisoned varda" ];
            };
          }
        );
      in
      lib.any (e: e.error == "poisoned varda" && e.from == varda) p.errors
      && p.flake ? invalid-flake-errors;

    # ── agent surface ──
    labels = (r.labels.ai-headroom.trust or null) == 2 && (r.labels.rdf-pack.trust or null) == 1;
    unfree-on-frodo = r.ask "unfreeOn" { place = frodoRef; } != [ ];
    ports-of-frodo = lib.any (p: p.port == 8787 && p.what == "headroom") (
      r.ask "portsOf" { place = frodoRef; }
    );
    free-port-frodo = ((r.ask "freePort" { place = frodoRef; }).port or null) == 8000;
    rdf-pack =
      lib.stringLength out.rdfPack.sha256 == 64 && lib.hasInfix "sh:NodeShape" out.rdfPack.shacl;
    # negative controls: each rule fires on a planted fault
    port-clash-fires =
      lib.elem [ "bad" "unique-port" "${frodo}:8787" ]
        (with' (
          { yen, ... }:
          {
            yen.aspects.clash = {
              at = yen.aspects.vic-headless;
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
      lib.elem [ "bad" "follows-declared" "no-such-input:clash" ]
        (with' (
          { yen, ... }:
          {
            yen.aspects.clash = {
              at = yen.fleet.vix;
              flake-file.inputs.clash = {
                url = "github:example/clash";
                inputs.nixpkgs.follows = "no-such-input";
              };
            };
          }
        )).check.violations;
    ssh-jump-cycle-fires = hasMsg (with' {
      yen.ssh-host.loop-a.proxyJump = "loop-b";
      yen.ssh-host.loop-b.proxyJump = "vic@loop-a";
    }) ".*proxyJump cycle loop-a -> loop-b.*";
    # a guest's os reaches its own nixos (a sink copied from another kind would give no forward)
    guest-os-forwards = lib.any (
      e: e.sink == "nixos" && e.origin == "sink os" && e.to == "${frodo}/guest:gen"
    ) r.graph.edges;
    # every host is a member of assembly hardware (kit facter); bill, tom and bert of their github-runner assembly
    members =
      map (s: s.id) (
        lib.filter (s: s.kind == "member" && !lib.hasSuffix "member:hardware.default" s.id) r.scopes
      ) == [
        "fleet:vix/host:bill/member:ci-bill.runner"
        "fleet:vix/host:tom/member:ci-tom.runner"
        "fleet:vix/mac:bert/member:ci-bert.runner"
      ]
      &&
        lib.length (lib.filter (s: lib.hasSuffix "member:hardware.default" s.id) r.scopes)
        == lib.length (lib.attrNames r.data.host);
    # each runner machine has the ci-runner role, and no other machine has it
    ci-runner-role =
      lib.sort lib.lessThan (lib.filter (id: r.active.ci-runner.${id}) (lib.attrNames r.active.ci-runner))
      == [
        "fleet:vix/host:bill"
        "fleet:vix/host:tom"
        "fleet:vix/mac:bert"
      ];
    # a second runner on one system is a claim error
    runner-claim-fires = hasMsg (with' (
      { yen, ... }:
      {
        yen.host.tom2.system = yen.system.x86_64-linux;
        yen.assembly.ci-tom2 = {
          kit = yen.kit.github-runner;
          roles.runner = {
            at = yen.host.tom2;
            settings.label = "ubuntu-latest";
          };
        };
      }
    )) "claim: x86_64-linux has 2 owners.*";
    # two hosts on shared pkgs: the second by name follows the first, and the fleet stays clean
    shared-pkgs-follows =
      let
        p = with' (
          { yen, ... }:
          {
            yen.host.frodo.sharedPkgs = true;
            yen.host.nargun.sharedPkgs = true;
          }
        );
      in
      p.errors == [ ]
      && p.flake.sharedPkgs.nargun.follower
      && p.flake.sharedPkgs.nargun.leader == "frodo"
      && !p.flake.sharedPkgs.frodo.follower;
    # a mac's primary user: its one admin (varda), or the runner of kit github-runner (bert)
    mac-primary-users =
      out.darwinConfigurations.varda.config.system.primaryUser == "vic"
      && out.darwinConfigurations.bert.config.system.primaryUser == "runner";
    vocabulary-fires = hasMsg (with' {
      yen.kinds.ghost.fields = { };
    }) ".*kinds `ghost`: a live name with no doc line.*";
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
