# Nix features: any scope asks for experimental features; each machine enables what it and its users ask for.
{ sven, lib, ... }:
let
  inherit (sven.helpers) machines;
  list = {
    reduce = sven.helpers.flat;
    of = sven.helpers.listOf lib.types.str;
  };
in
{
  # an element is a list of feature names; it goes to the nearest machine
  sven.kinds.host.sinks.nix-features = list;
  sven.kinds.mac.sinks.nix-features = list;

  # every machine: flakes and the nix command
  sven.aspects.nix-features-base = {
    at = machines;
    nix-features = [
      "nix-command"
      "flakes"
    ];
  };

  sven.aspects.nix-features = {
    at = machines;
    os =
      { nix-features, lib, ... }:
      {
        nix.settings.experimental-features = lib.sort lib.lessThan nix-features;
      };
  };
}
