# Workspaces: one per purpose; each becomes an isolated claude guest (microvm) on its host.
{
  yen,
  at,
  types,
  lib,
  ...
}:
let
  repos = { };
  names = lib.attrNames repos;
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
    repo = types.str;
    on = types.opt yen.kinds.host yen.host.frodo;
  };
  yen.kinds.guest.fields.workspace = types.maybe yen.kinds.workspace;

  yen.workspace = lib.mapAttrs (_: repo: { inherit repo; }) repos;
  yen.guest = lib.mapAttrs (n: _: guestOf n yen.workspace.${n}) repos;

  yen.aspects.workspace-share = {
    at = yen.kinds.guest.where { workspace = at.exists; };
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
