# Per-home entries (standalone homeConfigurations in den.homes).
{ den, lib, ... }:
{
  perSystem =
    {
      pkgs,
      rc,
      diagram,
      projectOf,
      classesOf,
      ...
    }:
    let
      homes = lib.concatMap (
        system:
        lib.mapAttrsToList (key: home: {
          inherit home;
          safeName = lib.replaceStrings [ "@" ] [ "-at-" ] key;
        }) den.homes.${system}
      ) (builtins.attrNames (den.homes or { }));
    in
    {
      _module.args = {
        allHomes = homes;

        homeEntries = lib.concatMap (
          h:
          let
            entity = projectOf "home" h.home.name;
          in
          diagram.export.entityEntries { inherit pkgs rc; } {
            inherit entity;
            name = "home-${h.safeName}";
            dir = "homes/${h.safeName}";
            viewDefs = rc.views.home ++ rc.views.classViews (classesOf entity);
          }
        ) homes;
      };
    };
}
