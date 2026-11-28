# CI: every buildable config emits one job record; `runners` uses `reduce.keyed` (one owner per system!).
{
  yen,
  at,
  types,
  reduce,
  lib,
  ...
}:
let
  job = system: allowFailure: name: attr: {
    ${name} = {
      inherit name attr allowFailure;
      system = system.name;
    };
  };
  mayFail = place: place.ciBroken != null;
in
{
  yen.kinds.place.fields.ciBroken = types.maybe types.str;

  yen.kinds.root.sinks = {
    runners = {
      reduce = reduce.keyed (r: r.system);
      allowOrphan = true;
    };
    ci-jobs = {
      reduce = reduce.merge;
      into.out =
        { ci-jobs, runners, ... }:
        {
          ci.matrix = map (j: j // { runner = runners.${j.system}.label; }) (
            lib.filter (j: runners ? ${j.system}) (builtins.attrValues ci-jobs)
          );
        };
    };
  };

  yen.aspects.ci-runner-labels = {
    at = yen.kinds.system;
    errors =
      { system, runners, ... }:
      lib.optional (
        !(runners ? ${system.name})
      ) "ci: system ${system.name} has no member of kit github-runner";
  };

  yen.aspects.ci-host = {
    at = yen.kinds.host;
    ci-jobs =
      { host, ... }:
      job host.system (mayFail host) host.name
        "nixosConfigurations.${host.name}.config.system.build.toplevel";
  };

  yen.aspects.ci-mac = {
    at = yen.kinds.mac;
    ci-jobs =
      { mac, ... }:
      job mac.system (mayFail mac) mac.name
        "darwinConfigurations.${mac.name}.config.system.build.toplevel";
  };

  yen.aspects.ci-home = {
    at = at.all [
      yen.kinds.user
      (at.under yen.kinds.home)
    ];
    ci-jobs =
      { home, user, ... }:
      job home.system (mayFail home) "${user.name}@${home.name}"
        "homeConfigurations.\"${user.name}@${home.name}\".activationPackage";
  };

  yen.aspects.ci-env = {
    at = at.all [
      yen.kinds.env
      (at.under yen.system.x86_64-linux)
    ];
    ci-jobs =
      { env, system, ... }:
      job system false "devshell-${env.name}-${system.name}" "devShells.${system.name}.${env.name}";
  };
}
