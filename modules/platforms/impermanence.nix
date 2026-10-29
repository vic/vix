# impermanence: features give the system paths they own on the `persist` sink; a host with `impermanence.enable` bind-mounts them from /nix/persist.
{ yen, lib, ... }:
let
  inherit (yen.lib) opt;
  # sini helpers/mergePersist: unique union of the entries { directories; files; }
  merge = es: {
    directories = lib.unique (builtins.concatMap (e: e.directories or [ ]) es);
    files = lib.unique (builtins.concatMap (e: e.files or [ ]) es);
  };
  reduce = {
    name = "persist";
    __functor = _: es: {
      value = merge (map (e: e.value) es);
      errors = [ ];
    };
  };
in
{
  # both gates default off: `enable` = binds only (nothing deleted), `wipeRoot` = initrd root rollback.
  yen.kinds.machine.fields.impermanence = {
    enable = opt lib.types.bool false;
    wipeRoot = opt lib.types.bool false;
  };

  # user and feature entries reach the host (a guest keeps its own: platforms/microvm.nix)
  yen.kinds.host.sinks.persist = {
    inherit reduce;
    nixos =
      { scope, persist, ... }:
      lib.optionalAttrs scope.impermanence.enable {
        environment.persistence."/nix/persist" = persist // {
          hideMounts = true;
        };
      };
  };
}
