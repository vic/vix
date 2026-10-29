# emacs: every yen.emacs distribution as packages, fish functions, install activation, daemon and dots.
{
  yen,
  inputs,
  lib,
  ...
}:
let
  dists = lib.attrValues yen.emacs;
in
{
  yen.aspects.vic-emacs = {
    at = yen.aspects.vic-gui;
    dots = lib.mapAttrs' (n: e: lib.nameValuePair ".config/${n}" e.configDots) (
      lib.filterAttrs (_: e: e.configDots != null) yen.emacs
    );
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
    homeManager =
      { pkgs, ... }:
      let
        emacsPkg = pkgs.emacs;
        install =
          n: e:
          pkgs.writeShellApplication {
            name = "${n}-install";
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
        ]) (lib.filter (e: e.daemon) dists);
        home.packages =
          lib.concatMap (
            e:
            lib.optional (e.wrapper != null) (
              (yen.helpers.perSystem pkgs inputs.${e.wrapper}).packages.${e.wrapper}.override {
                emacs = emacsPkg;
              }
            )
          ) dists
          ++ lib.concatMap (e: lib.mapAttrsToList pkgs.writeShellScriptBin e.bins) dists;
        programs.fish.functions = lib.mergeAttrsList (
          map (e: lib.mapAttrs (_: body: { inherit body; }) e.fish) dists
        );
        home.activation = lib.mapAttrs' (
          n: e:
          lib.nameValuePair "${n}-install" {
            after = [ "link-ssh-id" ];
            before = [ ];
            data = "run ${lib.getExe (install n e)}\n";
          }
        ) (lib.filterAttrs (_: e: e.bootstrap != null) yen.emacs);
      };
  };
}
