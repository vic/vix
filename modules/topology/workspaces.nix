# Workspaces: one per purpose; each becomes an isolated claude guest (microvm) on its host.
# Guests come from this table: ids follow the sorted workspace names, so addr and mac never collide.
{ yen, lib, ... }:
let
  # the workspaces, name to host repo path: guest keys are static, so they come from this table, not from `yen.workspace`
  repos = {
    gen = "/home/vic/hk/gen";
    dnx = "/home/vic/hk/dnx";
  };
  names = lib.attrNames repos; # sorted
  index = n: lib.lists.findFirstIndex (x: x == n) 0 names;
  guestOf = n: w: {
    inherit (w) on;
    system = w.on.system;
    users = [ yen.user.vic ];
    workspace = w;
    addr = "10.0.0.${toString (2 + index n)}";
    macAddress = "02:00:00:00:00:${lib.fixedWidthString 2 "0" (toString (1 + index n))}";
  };
in
{
  yen.kinds.workspace.fields = {
    repo = yen.lib.str; # host path, shared into its guest at the same path
    on = yen.lib.opt yen.kinds.host yen.host.frodo;
  };
  yen.kinds.guest.fields.workspace = yen.lib.maybe yen.kinds.workspace;

  yen.workspace = lib.mapAttrs (_: repo: { inherit repo; }) repos;
  yen.guest = lib.mapAttrs (n: _: guestOf n yen.workspace.${n}) repos;

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
