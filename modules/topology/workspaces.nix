# Workspaces: one per purpose; each becomes an isolated claude guest (microvm) on its host.
# Guests come from this data: ids follow the sorted workspace names, so addr and mac never collide.
{ yen, lib, ... }:
let
  names = lib.attrNames yen.workspace; # sorted
  index = n: lib.lists.findFirstIndex (x: x == n) 0 names;
in
{
  yen.kinds.workspace.fields = {
    repo = lib.types.str; # host path, shared into its guest at the same path
    on = yen.lib.opt yen.kinds.host yen.host.frodo;
  };
  yen.kinds.guest.fields.workspace = yen.lib.maybe yen.kinds.workspace;

  yen.workspace.gen.repo = "/home/vic/hk/gen";
  yen.workspace.dnx.repo = "/home/vic/hk/dnx";

  yen.guest = lib.mapAttrs (n: w: {
    inherit (w) on;
    system = w.on.system;
    users = [ yen.user.vic ];
    workspace = w;
    addr = "10.0.0.${toString (2 + index n)}";
    macAddress = "02:00:00:00:00:${lib.fixedWidthString 2 "0" (toString (1 + index n))}";
  }) yen.workspace;

  yen.aspects.workspace-share = {
    at = yen.lib.all [
      yen.kinds.guest
      (s: s.workspace != null)
    ];
    nixos =
      { guest, ... }:
      {
        microvm.shares = [
          {
            source = guest.workspace.repo;
            mountPoint = guest.workspace.repo;
            tag = "ws-${guest.name}";
            proto = "virtiofs";
          }
        ];
      };
  };
}
