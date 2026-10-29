# Nix features: any scope asks for experimental features; each machine enables what it and its users ask for.
{ yen, lib, ... }:
let
  inherit (yen.helpers) machines;
  list = {
    reduce = yen.helpers.flat;
    of = yen.helpers.listOf lib.types.str;
  };
in
{
  # an element is a list of feature names; it goes to the nearest machine
  yen.kinds.host.sinks.nix-features = list;
  yen.kinds.mac.sinks.nix-features = list;

  # every machine: flakes and the nix command
  yen.aspects.nix-features-base = {
    at = machines;
    nix-features = [
      "nix-command"
      "flakes"
    ];
  };

  yen.aspects.nix-features = {
    at = machines;
    os =
      { nix-features, lib, ... }:
      {
        nix.settings.experimental-features = lib.sort lib.lessThan nix-features;
      };
  };
}
