# Per-user entries (every user of every host).
{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      rc,
      diagram,
      allHosts,
      projectOf,
      classesOf,
      ...
    }:
    let
      users = lib.concatMap (
        host: lib.mapAttrsToList (userName: _: { inherit host userName; }) (host.users or { })
      ) allHosts;
    in
    {
      _module.args = {
        allUsers = users;

        userEntries = lib.concatMap (
          u:
          let
            entity = projectOf "user" u.userName;
          in
          diagram.export.entityEntries { inherit pkgs rc; } {
            inherit entity;
            name = u.userName;
            dir = "hosts/${u.host.name}/users/${u.userName}";
            viewDefs = rc.views.user ++ rc.views.classViews (classesOf entity);
          }
        ) users;
      };
    };
}
