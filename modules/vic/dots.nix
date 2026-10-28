# dots: pool of dotfiles features give, linked into $HOME; live out-of-store links into the machine's vix checkout, else store copies.
{ lib, sven, ... }:
let
  inherit (sven.helpers) place;
  linker =
    checkout: config: path:
    if checkout != null then
      config.lib.file.mkOutOfStoreSymlink "${checkout}/modules/vic/dots/${path}"
    else
      builtins.path {
        path = ./dots + "/${path}";
        name = "dots-" + builtins.replaceStrings [ "/" ] [ "-" ] path;
      };
in
{
  # absolute path of the vix checkout on this machine or home: its dotfiles link live into it (null: store copies).
  # a host or mac with users has it at the usual place (a guest has no checkout); an explicit value, null too, wins.
  sven.kinds.machine.fields.checkout = sven.lib.derive (sven.lib.maybe lib.types.str) (
    m: if m.kind == "guest" || m.users == [ ] then null else "/home/vic/hk/vix"
  );
  sven.kinds.home.fields.checkout = sven.lib.maybe lib.types.str;

  # a feature gives { "<home.file key>" = "<path relative to modules/vic/dots>"; } for each dotfile it owns.
  sven.kinds.user.sinks.dots = {
    reduce = sven.lib.reduce.merge;
    # every dots source exists in ./dots: a typo is an error record, not a dangling link
    of = sven.helpers.attrsOf (sven.lib.is (p: builtins.pathExists (./dots + "/${p}")));
  };

  sven.aspects.vic-dots = {
    at = sven.aspects.vic-headless;
    # rtk is owned by the ai modules, which this pass may not touch.
    dots.".config/rtk" = "config/rtk";
    homeManager =
      {
        scope,
        dots,
        config,
        lib,
        ...
      }:
      let
        checkout = (place scope).checkout or null;
      in
      {
        home.activation.check-checkout = lib.mkIf (checkout != null) (
          config.lib.dag.entryAfter [ "writeBoundary" ] ''
            if ! test -d "${checkout}/modules/vic/dots"; then
              echo "Missing vix checkout: ${checkout}/modules/vic/dots (set checkout to where vix lives)"
              exit 1
            fi
          ''
        );
        home.file = builtins.mapAttrs (_: path: { source = linker checkout config path; }) dots // {
          # public keys, linked from the flake source on every home (vic-ssh only lands on trusted ones).
          ".ssh" = {
            recursive = true;
            source = ./dots/ssh;
          };
        };
      };
  };
}
