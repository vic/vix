# Flake output sinks: checks and the CI matrix on the root; packages, devShells and formatter per system.
{ sven, ... }:
let
  inherit (sven.lib.reduce) merge one;
in
{
  sven.kinds.fleet.sinks = {
    # an element is { <system>.<name> = drv; }; any scope gives it
    checks = {
      reduce = merge;
      out = { checks, ... }: { inherit checks; };
    };
    # an element is { <job name> = job; } (flake/ci.nix)
    ci-jobs = {
      reduce = merge;
      out = { ci-jobs, ... }: { ci.matrix = builtins.attrValues ci-jobs; };
    };
  };

  # a system, or a scope below it (a vim profile, an env), gives { <name> = drv; }
  sven.kinds.system.sinks = {
    packages = {
      reduce = merge;
      out = { system, packages, ... }: { packages.${system.name} = packages; };
    };
    devshells = {
      reduce = merge;
      out = { system, devshells, ... }: { devShells.${system.name} = devshells; };
    };
    # one formatter per system: a second one is an error record
    formatter = {
      reduce = one;
      out = { system, formatter, ... }: { formatter.${system.name} = formatter; };
    };
  };
}
