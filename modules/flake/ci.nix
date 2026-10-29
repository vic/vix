# CI: every buildable config (host, mac, standalone home, devShell) emits one job record; flake output `ci.matrix` feeds the GitHub matrix.
{ yen, lib, ... }:
let
  inherit (yen.lib)
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
        yen.host
        yen.guest
        yen.mac
        yen.home
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
  yen.kinds.machine.fields = ciFields;
  yen.kinds.home.fields = ciFields;
  # one runner machine per system gives its label (GitHub matrix `runs-on`)
  yen.kinds.system.fields.runner = derive (maybe lib.types.str) (
    s: if lib.length (runnersOf s) == 1 then (lib.head (runnersOf s)).ghRunner else null
  );

  yen.aspects.ci-runner-labels = {
    at = yen.kinds.system;
    errors =
      { system, ... }:
      let
        n = lib.length (runnersOf system);
      in
      lib.optional (
        n != 1
      ) "ci: system ${system.name} has ${toString n} machines with ghRunner, want exactly 1";
  };

  yen.aspects.ci-host = {
    at = yen.kinds.host; # guests build inside their host
    ci-jobs =
      { host, ... }:
      job host host.name "nixosConfigurations.${host.name}.config.system.build.toplevel";
  };

  yen.aspects.ci-mac = {
    at = yen.kinds.mac;
    ci-jobs =
      { mac, ... }: job mac mac.name "darwinConfigurations.${mac.name}.config.system.build.toplevel";
  };

  yen.aspects.ci-home = {
    at = all [
      yen.kinds.user
      (within yen.kinds.home)
    ];
    ci-jobs =
      { home, user, ... }:
      job home "${user.name}@${home.name}"
        "homeConfigurations.\"${user.name}@${home.name}\".activationPackage";
  };

  yen.aspects.ci-env = {
    at = all [
      yen.kinds.env
      (within yen.system.x86_64-linux)
    ]; # devshells are cheap to rebuild elsewhere; CI builds them on linux only
    ci-jobs =
      { env, system, ... }:
      job {
        inherit system;
      } "devshell-${env.name}-${system.name}" "devShells.${system.name}.${env.name}";
  };
}
