{
  den,
  ci,
  lib,
  ...
}:
let
  platform-mismatch =
    system: list: skips:
    lib.map (p: "${lib.getName p} not in system: ${system}") (
      lib.filter (
        p: !(lib.elem (lib.getName p) skips || lib.elem system (p.meta.platforms or [ system ]))
      ) list
    );

  skips.bombadil = [ "zfs" ];

  tests = lib.pipe den.hosts [
    (lib.attrValues)
    (lib.concatMap lib.attrValues)
    (map (host: {
      name = "test-${host.name}-packages";
      value = {
        expr = {
          osPkgs = platform-mismatch host.system ci.${host.name}.environment.systemPackages (
            skips.${host.name} or [ ]
          );
          vicPkgs = platform-mismatch host.system (ci.${host.name}.home-manager.vic.home.packages or [ ]) (
            skips.${host.name} or [ ]
          );
        };
        expected.osPkgs = [ ];
        expected.vicPkgs = [ ];
      };
    }))
    (lib.listToAttrs)
  ];
in
{
  flake.tests.platform-packages = tests;
}
