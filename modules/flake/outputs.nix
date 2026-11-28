# Flake output sinks: checks on root; packages, devShells and formatter per system.
{
  reduce,
  ...
}:
{
  yen.kinds.root.sinks.checks = {
    reduce = reduce.merge;
    allowOrphan = true;
    into.out = { checks, ... }: { inherit checks; };
  };

  yen.kinds.system.sinks = {
    packages = {
      reduce = reduce.merge;
      allowOrphan = true;
      into.out =
        { system, packages, ... }:
        {
          packages.${system.name} = packages;
        };
    };
    devshells = {
      reduce = reduce.merge;
      allowOrphan = true;
      into.out =
        { system, devshells, ... }:
        {
          devShells.${system.name} = devshells;
        };
    };
    formatter = {
      reduce = reduce.one;
      allowOrphan = true;
      into.out =
        { system, formatter, ... }:
        {
          formatter.${system.name} = formatter;
        };
    };
  };
}
