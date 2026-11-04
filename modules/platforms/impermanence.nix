# impermanence: features give the system paths they own on the `persist` sink; a host with `impermanence.enable` bind-mounts them from /nix/persist.
{ yen, lib, ... }:
let
  inherit (yen.lib) opt;
  persist = yen.lib.batteries.nixos.persist {
    from = yen.kinds.host.sinks.persist;
    root = "/nix/persist";
    hideMounts = true;
  };
  # a machine bind-mounts its persist paths only when its impermanence is enabled
  persistWhenEnabled =
    { scope, sinks, ... }@args: lib.optionalAttrs scope.impermanence.enable (persist args);
in
{
  # both gates default off: `enable` = binds only (nothing deleted), `wipeRoot` = initrd root rollback.
  yen.kinds.machine.fields.impermanence = {
    enable = opt lib.types.bool false;
    wipeRoot = opt lib.types.bool false;
  };

  # user and feature entries reach the host (a guest keeps its own: platforms/microvm.nix)
  yen.kinds.host.sinks.persist.nixos = persistWhenEnabled;
  yen.kinds.guest.sinks.persist.nixos = persistWhenEnabled;
}
