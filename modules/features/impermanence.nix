# impermanence: features emit the system paths they own on the `persist` channel; a host with `impermanence.enable` bind-mounts them from /nix/persist.
{ ren, lib, ... }:
let
  vix = ren.helpers;
  t = lib.types;
  # sini helpers/mergePersist: unique union of the entries { directories; files; }
  merge = es: {
    directories = lib.unique (builtins.concatMap (e: e.directories or [ ]) es);
    files = lib.unique (builtins.concatMap (e: e.files or [ ]) es);
  };
in
{
  # both gates default off: `enable` = binds only (nothing deleted), `wipeRoot` = initrd root rollback.
  ren.kinds.machine.impermanence = vix.opt (t.submodule {
    options = {
      enable = vix.opt t.bool false;
      wipeRoot = vix.opt t.bool false;
    };
  }) { };

  ren.channels.persist = {
    fold = ren.lib.fold.list;
    to = e: ren.lib.upTo ren.kinds.host e; # user/feature entries reach the host
    into =
      { host, ... }:
      es:
      lib.optionalAttrs host.impermanence.enable {
        nixos.environment.persistence."/nix/persist" = merge es // {
          hideMounts = true;
        };
      };
  };
}
