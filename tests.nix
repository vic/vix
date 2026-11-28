# vix-clean oracle & negative-control test suite on the new Yen engine (zero import-tree, zero string tags).
# Run:
#   nix eval --impure --json --file tests.nix summary
let
  b = builtins;
  vixOrig = b.getFlake "path:/home/vic/hk/vix";
  yen = import /home/vic/hk/yen-clean;
  inherit (vixOrig.inputs.nixpkgs) lib;
  inputs = vixOrig.inputs // {
    yen = /home/vic/hk/yen-clean;
    self = ./.;
  };

  evalWith =
    extra:
    yen.eval {
      args = {
        inherit inputs lib;
      };
      modules = [ ./modules ] ++ extra;
    };

  r = evalWith [ ];
  with' = m: evalWith [ m ];
  msgs = q: map (e: e.error) q.errors;
  hasMsg = q: re: lib.any (m: b.match re m != null) (msgs q);
  out = r.flake;
  frodoRef = {
    __inst = {
      kind = [ "host" ];
      name = "frodo";
    };
  };

  poisonedVarda = with' (
    { yen, ... }:
    {
      yen.aspects.poison = {
        at = yen.mac.varda;
        errors = [ "poisoned varda" ];
      };
    }
  );

  portClash = with' (
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
  );

  followsClash = with' (
    { yen, ... }:
    {
      yen.aspects.clash = {
        at = yen.root;
        flake-file.inputs.clash = {
          url = "github:example/clash";
          inputs.nixpkgs.follows = "no-such-input";
        };
      };
    }
  );

  sshCycle = with' {
    yen.ssh-host.loop-a.proxyJump = "loop-b";
    yen.ssh-host.loop-b.proxyJump = "vic@loop-a";
  };

  runnerClaim = with' (
    { yen, ... }:
    {
      yen.host.tom2.system = yen.system.x86_64-linux;
      yen.assemblies.ci-tom2 = yen.kits.github-runner {
        runner = {
          at = yen.host.tom2;
          settings.label = "ubuntu-latest";
        };
      };
    }
  );

  runnerWithUser = with' (
    { yen, ... }:
    {
      yen.host.tom.users = [ yen.user.vic ];
    }
  );

  sharedPkgs = with' (
    { yen, ... }:
    {
      yen.host.frodo.sharedPkgs = true;
      yen.host.nargun.sharedPkgs = true;
    }
  );

  memberIds = map (s: s.id) (lib.filter (s: lib.hasInfix "/_member:" s.id) r.scopes);
  runnerMemberIds = lib.sort lib.lessThan (
    lib.filter (id: !lib.hasSuffix "/_member:hardware.default" id) memberIds
  );
  facterMemberIds = lib.filter (id: lib.hasSuffix "/_member:hardware.default" id) memberIds;
  ciRunnerActive = lib.sort lib.lessThan (
    lib.filter (id: r.active.ci-runner.${id}) (lib.attrNames r.active.ci-runner)
  );

  checks = {
    no-errors = r.ok && r.errors == [ ];
    check-ok = r.check.ok && r.check.violations == [ ];
    no-undefined = r.undefined == [ ];
    no-opaque = r.check.opaque == [ ];
    vix-broken-mac-blocks =
      lib.any (e: e.error == "poisoned varda" && e.from == "mac:varda") poisonedVarda.errors
      && poisonedVarda.flake ? invalid-flake-errors;
    labels = (r.labels.ai-headroom.trust or null) == 2;
    unfree-on-frodo = r.ask.unfreeOn { place = frodoRef; } != [ ];
    ports-of-frodo = lib.any (p: p.port == 8787 && p.what == "headroom") (
      r.ask.portsOf { place = frodoRef; }
    );
    free-port-frodo = ((r.ask.freePort { place = frodoRef; }).port or null) == 8000;
    port-clash-fires = hasMsg portClash ".*unique-port: clash at host:frodo:8787.*";
    follows-undeclared-fires = hasMsg followsClash ".*follows-declared:.*no-such-input.*";
    ssh-jump-cycle-fires = hasMsg sshCycle ".*proxyJump cycle.*loop-a.*loop-b.*";
    runners-no-users-fires =
      !runnerWithUser.ok
      && lib.any (v: v.invariant == "runners-no-users") runnerWithUser.check.violations;
    members =
      runnerMemberIds == [
        "host:bill/_member:ci-bill.runner"
        "host:tom/_member:ci-tom.runner"
        "mac:bert/_member:ci-bert.runner"
      ]
      && lib.length facterMemberIds == lib.length (lib.attrNames r.data.host);
    ci-runner-role =
      ciRunnerActive == [
        "host:bill"
        "host:tom"
        "mac:bert"
      ];
    runner-claim-fires = lib.any (e: (e.code or "") == "key-conflict") runnerClaim.errors;
    shared-pkgs-follows =
      sharedPkgs.ok
      && sharedPkgs.flake.sharedPkgs.nargun.follower
      && sharedPkgs.flake.sharedPkgs.nargun.leader == "frodo"
      && !sharedPkgs.flake.sharedPkgs.frodo.follower;
    mac-primary-users =
      out.darwinConfigurations.varda.config.system.primaryUser == "vic"
      && out.darwinConfigurations.bert.config.system.primaryUser == "runner";
    frodo-hostname = out.nixosConfigurations.frodo.config.networking.hostName == "frodo";
    all-configs-present =
      lib.length (lib.attrNames out.nixosConfigurations) == 9
      && lib.length (lib.attrNames out.darwinConfigurations) == 2
      && lib.length (lib.attrNames out.homeConfigurations) == 8;
  };

  failed = lib.filter (n: !checks.${n}) (lib.attrNames checks);
  total = lib.length (lib.attrNames checks);
in
{
  inherit checks failed;
  summary = {
    ok = failed == [ ];
    inherit total failed;
    passed = total - lib.length failed;
  };
}
