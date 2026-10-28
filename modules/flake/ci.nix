# CI: every buildable config (host, mac, standalone home, devShell) emits one job record; flake output `ci.matrix` feeds the GitHub matrix.
{ sven, lib, ... }:
let
  inherit (sven.lib)
    all
    within
    maybe
    derive
    ;
  ciFields = {
    ghRunner = maybe lib.types.str; # the GitHub runner label this machine is: the CI runner of its system
    ciBroken = maybe lib.types.str; # why its ci job may fail (continue-on-error); null = must pass
  };
  runnersOf =
    system:
    lib.filter (m: m.ghRunner != null && m.system.name == system.name) (
      lib.concatMap lib.attrValues [
        sven.host
        sven.guest
        sven.mac
        sven.home
      ]
    );
  job =
    {
      system,
      ciBroken ? null,
      ...
    }:
    name: attr: {
      ${name} = {
        inherit name attr;
        system = system.name;
        inherit (system) runner;
        allowFailure = ciBroken != null; # continue-on-error
      };
    };
in
{
  sven.kinds.machine.fields = ciFields;
  sven.kinds.home.fields = ciFields;
  # one runner machine per system gives its label (GitHub matrix `runs-on`)
  sven.kinds.system.fields.runner = derive (maybe lib.types.str) (
    s: if lib.length (runnersOf s) == 1 then (lib.head (runnersOf s)).ghRunner else null
  );

  sven.aspects.ci-runner-labels = {
    at = sven.kinds.system;
    errors =
      { system, ... }:
      let
        n = lib.length (runnersOf system);
      in
      lib.optional (
        n != 1
      ) "ci: system ${system.name} has ${toString n} machines with ghRunner, want exactly 1";
  };

  sven.aspects.ci-host = {
    at = sven.kinds.host; # guests build inside their host
    ci-jobs =
      { host, ... }:
      job host host.name "nixosConfigurations.${host.name}.config.system.build.toplevel";
  };

  sven.aspects.ci-mac = {
    at = sven.kinds.mac;
    ci-jobs =
      { mac, ... }: job mac mac.name "darwinConfigurations.${mac.name}.config.system.build.toplevel";
  };

  sven.aspects.ci-home = {
    at = all [
      sven.kinds.user
      (within sven.kinds.home)
    ];
    ci-jobs =
      { home, user, ... }:
      job home "${user.name}@${home.name}"
        "homeConfigurations.\"${user.name}@${home.name}\".activationPackage";
  };

  sven.aspects.ci-env = {
    at = all [
      sven.kinds.env
      (within sven.system.x86_64-linux)
    ]; # devshells are cheap to rebuild elsewhere; CI builds them on linux only
    ci-jobs =
      { env, system, ... }:
      job {
        inherit system;
      } "devshell-${env.name}-${system.name}" "devShells.${system.name}.${env.name}";
  };
}
