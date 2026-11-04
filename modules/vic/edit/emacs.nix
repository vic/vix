# emacs: every yen.emacs distribution as packages, fish functions, install activation, daemon and dots.
{
  yen,
  inputs,
  lib,
  ...
}:
let
  dists.instances = yen.kinds.emacs; # a tree request: every emacs distribution, with its data
  # the dots, the home-manager module of the distributions ds (the answer of `dists`)
  dotsOf =
    ds:
    lib.listToAttrs (
      map (e: lib.nameValuePair ".config/${e.name}" e.configDots) (
        lib.filter (e: e.configDots != null) ds
      )
    );
  homeOf =
    ds:
    { pkgs, ... }:
    let
      emacsPkg = pkgs.emacs;
      install =
        e:
        pkgs.writeShellApplication {
          name = "${e.name}-install";
          runtimeInputs = [
            pkgs.git
            emacsPkg
            pkgs.ripgrep
            pkgs.openssh
          ];
          text = e.bootstrap;
        };
    in
    {
      programs.emacs.enable = true;
      programs.emacs.package = emacsPkg;
      services.emacs.package = emacsPkg;
      services.emacs.extraOptions = lib.concatMap (e: [
        "--init-directory"
        e.initDir
      ]) (lib.filter (e: e.daemon) ds);
      home.packages =
        lib.concatMap (
          e:
          lib.optional (e.wrapper != null) (
            (yen.helpers.perSystem pkgs inputs.${e.wrapper}).packages.${e.wrapper}.override {
              emacs = emacsPkg;
            }
          )
        ) ds
        ++ lib.concatMap (e: lib.mapAttrsToList pkgs.writeShellScriptBin e.bins) ds;
      programs.fish.functions = lib.mergeAttrsList (
        map (e: lib.mapAttrs (_: body: { inherit body; }) e.fish) ds
      );
      home.activation = lib.listToAttrs (
        map (
          e:
          lib.nameValuePair "${e.name}-install" {
            after = [ "link-ssh-id" ];
            before = [ ];
            data = "run ${lib.getExe (install e)}\n";
          }
        ) (lib.filter (e: e.bootstrap != null) ds)
      );
    };
in
{
  yen.aspects.vic-emacs = {
    at = yen.aspects.vic-gui;
    cycle =
      { tree, ... }:
      {
        tree = [ dists ];
        dots = [ (dotsOf (tree.select dists)) ];
        homeManager = [ (homeOf (tree.select dists)) ];
      };
    flake-file.inputs = {
      SPC = {
        url = "github:vic/SPC";
        inputs = {
          bats-assert.follows = "bats-assert";
          bats-support.follows = "bats-support";
          blueprint.follows = "blueprint";
          nixpkgs.follows = "nixpkgs";
          treefmt-nix.follows = "treefmt-nix";
        };
      };
      bats-assert = {
        url = "github:bats-core/bats-assert";
        flake = false;
      };
      bats-support = {
        url = "github:ztombol/bats-support";
        flake = false;
      };
      blueprint = {
        url = "github:numtide/blueprint";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.systems.follows = "systems";
      };
      systems.url = "github:nix-systems/default";
    };
  };
}
