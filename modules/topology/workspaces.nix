# Workspaces: one per purpose; each becomes an isolated claude guest (microvm) on its host.
# Guests come from this data: ids follow the sorted workspace names, so addr and mac never collide.
{ sven, lib, ... }:
let
  names = lib.attrNames sven.workspace; # sorted
  index = n: lib.lists.findFirstIndex (x: x == n) 0 names;
in
{
  sven.kinds.workspace.fields = {
    repo = lib.types.str; # host path, shared into its guest at the same path
    on = sven.lib.opt sven.kinds.host sven.host.frodo;
  };
  sven.kinds.guest.fields.workspace = sven.lib.maybe sven.kinds.workspace;

  sven.workspace.gen.repo = "/home/vic/hk/gen";
  sven.workspace.dnx.repo = "/home/vic/hk/dnx";

  sven.guest = lib.mapAttrs (n: w: {
    inherit (w) on;
    system = w.on.system;
    users = [ sven.user.vic ];
    workspace = w;
    addr = "10.0.0.${toString (2 + index n)}";
    macAddress = "02:00:00:00:00:${lib.fixedWidthString 2 "0" (toString (1 + index n))}";
  }) sven.workspace;

  sven.aspects.workspace-share = {
    at = sven.lib.all [
      sven.kinds.guest
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
