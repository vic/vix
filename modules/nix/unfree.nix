# Unfree: any scope allows unfree packages by name; machines inherit `unfree` via `machine`!
{
  yen,
  at,
  types,
  reduce,
  lib,
  ...
}:
let
  names = {
    reduce = reduce.flat;
    allowOrphan = true;
    of = types.listOf types.str;
  };
  accept =
    { unfree, ... }:
    lib.optionalAttrs (unfree != [ ]) {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfree;
    };
in
{
  yen.kinds.machine.sinks.unfree = names;
  yen.kinds.vim.sinks.unfree = names;
  yen.kinds.user.sinks.unfree = names // {
    intoParent.unfree = { unfree, ... }: unfree;
  };

  yen.aspects.unfree = {
    at = at.anyOf [
      yen.kinds.machine
      yen.kinds.user
    ];
    os = accept;
    homeManager = accept;
  };
}
