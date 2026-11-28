# Nix features: any scope asks for experimental features; each machine inherits `nix-features` via `machine`.
{
  yen,
  types,
  reduce,
  ...
}:
{
  yen.kinds.machine.sinks.nix-features = {
    reduce = reduce.flat;
    of = types.listOf types.str;
  };

  yen.aspects.nix-features-base = {
    at = yen.kinds.machine;
    nix-features = [
      "nix-command"
      "flakes"
    ];
  };

  yen.aspects.nix-features = {
    at = yen.kinds.machine;
    os =
      { nix-features, lib, ... }:
      {
        nix.settings.experimental-features = lib.sort lib.lessThan nix-features;
      };
  };
}
