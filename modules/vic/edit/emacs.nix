# emacs: every ren.emacs distribution as packages, fish functions, install activation, daemon and dots.
{
  ren,
  inputs,
  ...
}:
let
  vix = ren.helpers;
  nl = inputs.nixpkgs.lib;
  all = nl.attrValues ren.emacs;
in
{
  ren.aspects.vic-emacs = {
    dots = nl.mapAttrs' (n: e: nl.nameValuePair ".config/${n}" e.configDots) (
      nl.filterAttrs (_: e: e.configDots != null) ren.emacs
    );
    at = ren.aspects.vic-gui;
    flake-inputs =
      { ... }:
      {
        SPC = {
          url = "github:vic/SPC/7217d72e2b2a6053fbb7e3ea3f5bdaac65d69327";
          inputs = {
            bats-assert.follows = "bats-assert";
            bats-support.follows = "bats-support";
            blueprint.follows = "blueprint";
            nixpkgs.follows = "nixpkgs";
            treefmt-nix.follows = "treefmt-nix";
          };
        };
        bats-assert.url = "github:bats-core/bats-assert/123860c029685bc0a4150ed57ee97fc7f7cc9d31";
        bats-assert.flake = false;
        bats-support.url = "github:ztombol/bats-support/64e7436962affbe15974d181173c37e1fac70073";
        bats-support.flake = false;
        blueprint.url = "github:numtide/blueprint/7865bc350e583799db5473e7b4f7b280d8df2546";
        blueprint.inputs.nixpkgs.follows = "nixpkgs";
        blueprint.inputs.systems.follows = "systems";
        systems.url = "github:nix-systems/default/d36eeed142f88b5a636f2e3856a53c61654cf29b";
      };
    homeManager =
      {
        pkgs,
        lib,
        ...
      }:
      let
        emacsPkg = pkgs.emacs;
        install =
          n: e:
          pkgs.writeShellApplication {
            name = "${n}-install";
            runtimeInputs = with pkgs; [
              git
              emacsPkg
              ripgrep
              openssh
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
        ]) (lib.filter (e: e.daemon) all);
        home.packages =
          lib.concatMap (
            e:
            lib.optional (e.wrapper != null) (
              (vix.perSystem pkgs inputs.${e.wrapper}).packages.${e.wrapper}.override { emacs = emacsPkg; }
            )
          ) all
          ++ lib.concatMap (e: lib.mapAttrsToList pkgs.writeShellScriptBin e.bins) all;
        programs.fish.functions = lib.mergeAttrsList (
          map (e: lib.mapAttrs (_: body: { inherit body; }) e.fish) all
        );
        home.activation = lib.mapAttrs' (
          n: e:
          lib.nameValuePair "${n}-install" {
            after = [ "link-ssh-id" ];
            before = [ ];
            data = "run ${lib.getExe (install n e)}\n";
          }
        ) (lib.filterAttrs (_: e: e.bootstrap != null) ren.emacs);
      };
  };
}
