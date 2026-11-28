# impermanence: features give system paths on the `persist` sink (inherited by host & guest via `linux`).
{
  reduce,
  lib,
  ...
}:
let
  dirsOf = es: lib.concatMap (e: if lib.isString e then [ e ] else e.directories or [ ]) es;
  filesOf = es: lib.concatMap (e: if lib.isString e then [ ] else e.files or [ ]) es;
in
{
  yen.kinds.linux.sinks.persist = {
    reduce = reduce.list;
    allowOrphan = true;
    into.nixos =
      { scope, persist, ... }:
      lib.optionalAttrs scope.impermanence.enable {
        environment.persistence."/nix/persist" = {
          hideMounts = true;
          directories = dirsOf persist;
          files = filesOf persist;
        };
      };
  };
}
