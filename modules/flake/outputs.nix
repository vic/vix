# Flake output sinks: checks and the CI matrix on the root; packages, devShells and formatter per system.
{ yen, ... }:
let
  inherit (yen.lib.reduce) merge one;
  inherit (yen.lib.batteries) perSystem;
in
{
  yen.kinds.fleet.sinks = {
    # an element is { <system>.<name> = drv; }; any scope gives it
    checks = {
      reduce = merge;
      out = { checks, ... }: { inherit checks; };
    };
  };

  # a system, or a scope below it (a vim profile, an env), gives { <name> = drv; }
  yen.kinds.system.sinks = {
    packages = {
      reduce = merge;
      out = perSystem.out {
        from = yen.kinds.system.sinks.packages;
        group = "packages";
      };
    };
    devshells = {
      reduce = merge;
      out = perSystem.out {
        from = yen.kinds.system.sinks.devshells;
        group = "devShells";
      };
    };
    # one formatter per system: a second one is an error record
    formatter = {
      reduce = one;
      out = perSystem.out {
        from = yen.kinds.system.sinks.formatter;
        group = "formatter";
      };
    };
  };
}
