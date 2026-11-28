# dots: pool of dotfiles features give, linked into $HOME.
{
  lib,
  yen,
  types,
  reduce,
  ...
}:
let
  inherit (yen.helpers) place;
  linker =
    checkout: config: path:
    if checkout != null then
      config.lib.file.mkOutOfStoreSymlink "${checkout}/modules/vic/dots/${path}"
    else
      builtins.path {
        path = ./dots + "/${path}";
        name = "dots-" + builtins.replaceStrings [ "/" ] [ "-" ] path;
      };
  withUsers = types.derive (types.maybe types.str) (
    m: if m.users == [ ] then null else "/home/vic/hk/vix"
  );
in
{
  yen.kinds.host.fields.checkout = withUsers;
  yen.kinds.mac.fields.checkout = withUsers;
  yen.kinds.guest.fields.checkout = types.maybe types.str;
  yen.kinds.home.fields.checkout = types.maybe types.str;

  yen.kinds.user.sinks.dots = {
    reduce = reduce.merge;
    of = types.attrsOf (types.is (p: builtins.pathExists (./dots + "/${p}")) "existing dotfile path");
  };

  yen.aspects.vic-dots = {
    at = yen.aspects.vic-headless;
    dots.".config/rtk" = "config/rtk";
    homeManager =
      {
        scope,
        dots,
        config,
        lib,
        ...
      }:
      (checkout: {
        home.activation.check-checkout = lib.mkIf (checkout != null) (
          config.lib.dag.entryAfter [ "writeBoundary" ] ''
            if ! test -d "${checkout}/modules/vic/dots"; then
              echo "Missing vix checkout: ${checkout}/modules/vic/dots (set checkout to where vix lives)"
              exit 1
            fi
          ''
        );
        home.file = builtins.mapAttrs (_: path: { source = linker checkout config path; }) dots // {
          ".ssh" = {
            recursive = true;
            source = ./dots/ssh;
          };
        };
      })
        ((place scope).checkout or null);
  };
}
