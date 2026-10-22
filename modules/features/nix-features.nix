# Nix features: any scope asks for experimental features; each machine enables what it and its users ask for.
{ ren, ... }:
let
  inherit (ren.lib) and anyOf has;
  machines = anyOf [
    ren.kinds.host
    ren.kinds.mac
  ];
in
{
  ren.channels.nix-features = {
    fold = ren.lib.fold.list;
    to =
      e:
      and [
        machines
        (anyOf [
          e
          (has e)
        ])
      ];
  };

  # every machine: flakes and the nix command
  ren.aspects.nix-features-base = {
    at = machines;
    nix-features = { ... }: [
      "nix-command"
      "flakes"
    ];
  };

  ren.aspects.nix-features = {
    at = machines;
    os = { nix-features, lib, ... }: {
      # deduped (guests emit to their host too), sorted
      nix.settings.experimental-features = lib.sort lib.lessThan (
        lib.unique (lib.concatLists nix-features)
      );
    };
  };
}
