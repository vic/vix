# dots: pool of dotfiles emitted by features, linked into $HOME; live out-of-store links into the machine's vix checkout, else store copies.
{
  lib,
  ren,
  ...
}:
let
  vix = ren.helpers;
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
  ren.kinds.machine.checkout = vix.maybe lib.types.str;
  ren.kinds.home.checkout = vix.maybe lib.types.str;

  # a feature emits { "<home.file key>" = "<path relative to modules/vic/dots>"; } for each dotfile it owns.
  ren.channels.dots = {
    fold = ren.lib.fold.attrs;
    at = ren.kinds.user;
    to = e: e;
  };

  ren.aspects.vic-dots = {
    at = ren.aspects.vic-headless;
    # rtk is owned by the ai modules, which this pass may not touch.
    dots.".config/rtk" = "config/rtk";
    homeManager =
      {
        parent,
        dots,
        config,
        lib,
        ...
      }:
      let
        checkout = (vix.place parent).checkout;
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
