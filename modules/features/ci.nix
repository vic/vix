# CI: every buildable config (host, mac, standalone home, devShell) emits one job record; flake output `ci.matrix` feeds the GitHub matrix.
{ ren, ... }:
let
  inherit (ren.lib) anyOf;
  runners = {
    x86_64-linux = "ubuntu-latest";
    aarch64-linux = "ubuntu-24.04-arm";
    aarch64-darwin = "macos-latest";
    x86_64-darwin = "macos-15-intel";
  };
  # jobs allowed to fail (continue-on-error), one reason each
  knownBroken = [
    "mordor" # unfree nvidia driver
    "yavanna" # x86_64-darwin dropped by nixpkgs
    "varda" # openspec
  ];
  job = system: name: attr: {
    inherit name attr;
    system = system.name;
    runner = runners.${system.name};
    allowFailure = builtins.elem name knownBroken || system.name == "x86_64-darwin"; # x86_64-darwin dropped by nixpkgs
  };
  one = name: j: { ${name} = j; };
in
{
  ren.channels.ci-jobs = {
    fold = ren.lib.fold.attrs;
    at = anyOf [
      ren.kinds.host
      ren.kinds.mac
      ren.kinds.home
      ren.kinds.user
      ren.kinds.env
    ];
    to = _: ren.fleet.vix;
    into = { ... }: jobs: { ci.matrix = builtins.attrValues jobs; };
  };

  ren.aspects.ci-host = {
    at = ren.aspects.metal; # guests build inside their host
    ci-jobs =
      { host, ... }:
      one host.name (
        job host.system host.name "nixosConfigurations.${host.name}.config.system.build.toplevel"
      );
  };

  ren.aspects.ci-mac = {
    at = ren.kinds.mac;
    ci-jobs =
      { mac, ... }:
      one mac.name (
        job mac.system mac.name "darwinConfigurations.${mac.name}.config.system.build.toplevel"
      );
  };

  ren.aspects.ci-home = {
    at = ren.lib.and [
      ren.kinds.user
      (ren.lib.within ren.kinds.home)
    ];
    ci-jobs =
      { home, user, ... }:
      let
        n = "${user.name}@${home.name}";
      in
      one n (job home.system n "homeConfigurations.\"${n}\".activationPackage");
  };

  ren.aspects.ci-env = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.within ren.system.x86_64-linux)
    ]; # devshells are cheap to rebuild elsewhere; CI builds them on linux only
    ci-jobs =
      { env, system, ... }:
      let
        n = "devshell-${env.name}-${system.name}";
      in
      one n (job system n "devShells.${system.name}.${env.name}");
  };
}
