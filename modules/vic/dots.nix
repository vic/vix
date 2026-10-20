# dots: pool of dotfiles emitted by features, linked into $HOME; live out-of-store links into ~/.flake on live-dots machines, else store copies.
{
  lib,
  ren,
  ...
}:
let
  vix = import ../_lib.nix { inherit lib; };
  linker =
    live: config: path:
    if live then
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.flake/modules/vic/dots/${path}"
    else
      builtins.path {
        path = ./dots + "/${path}";
        name = "dots-" + builtins.replaceStrings [ "/" ] [ "-" ] path;
      };
in
{
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
        is,
        dots,
        ...
      }:
      vix.mod (
        { config, lib, ... }:
        let
          live = is ren.aspects.live-dots parent;
        in
        {
          home.activation.link-flake = lib.mkIf live (
            config.lib.dag.entryAfter [ "writeBoundary" ] ''
              echo Checking that "$HOME/.flake" exists.
              if ! test -L "$HOME/.flake"; then
                echo "Missing $HOME/.flake link"
                exit 1
              fi
            ''
          );
          home.file = builtins.mapAttrs (_: path: { source = linker live config path; }) dots // {
            # public keys, linked from the flake source on every home (vic-ssh only lands on trusted ones).
            ".ssh" = {
              recursive = true;
              source = ./dots/ssh;
            };
          };
        }
      );
  };
}
