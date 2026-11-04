# CI: every buildable config (host, mac, standalone home, devShell) emits one job record; flake output `ci.matrix` feeds the GitHub matrix.
# A member of kit github-runner (kits/github-runner.nix) claims its system's runner: one owner per system, a second is an error record.
{ yen, lib, ... }:
let
  inherit (yen.lib)
    all
    within
    maybe
    str
    ;
  ciFields = {
    ciBroken = maybe str; # why its ci job may fail (continue-on-error); null = must pass
  };
  job = place: name: attr: {
    ${name} = {
      inherit name attr;
      system = place.system.name;
      allowFailure = place.ciBroken or null != null; # continue-on-error
    };
  };
in
{
  yen.kinds.machine.fields = ciFields;
  yen.kinds.home.fields = ciFields;

  yen.kinds.fleet.sinks = {
    # { <system> = { system; machine; label; }; }: the runner machine of each system
    runners.reduce = yen.lib.batteries.claim { key = r: r.system; };
    # an element is { <job name> = job; }; the matrix gets each job's runner from its system
    ci-jobs = {
      reduce = yen.lib.reduce.merge;
      out =
        { ci-jobs, runners, ... }:
        {
          # a job of a system with no runner is left out: that system already has an error record
          ci.matrix = map (j: j // { runner = runners.${j.system}.label; }) (
            lib.filter (j: runners ? ${j.system}) (builtins.attrValues ci-jobs)
          );
        };
    };
  };

  # every system builds on one runner
  yen.aspects.ci-runner-labels = {
    at = yen.kinds.system;
    errors =
      { system, runners, ... }:
      lib.optional (
        !runners ? ${system.name}
      ) "ci: system ${system.name} has no member of kit github-runner";
  };

  yen.aspects.ci-host = {
    at = yen.kinds.host; # guests build inside their host
    ci-jobs =
      { host, ... }: job host host.name "nixosConfigurations.${host.name}.config.system.build.toplevel";
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
