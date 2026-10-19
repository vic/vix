# emacs: every ren.emacs distribution as packages, fish functions, install activation, daemon and dots.
{
  ren,
  vicAt,
  inputs,
  mod,
  ...
}:
let
  nl = inputs.nixpkgs.lib;
  all = nl.attrValues ren.emacs;
in
{
  ren.aspects.vic-emacs = {
    dots = nl.mapAttrs' (n: e: nl.nameValuePair ".config/${n}" e.configDots) (
      nl.filterAttrs (_: e: e.configDots != null) ren.emacs
    );
    at = vicAt.desktop;
    homeManager = mod (
      {
        pkgs,
        lib,
        inputs',
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
              inputs'.${e.wrapper}.packages.${e.wrapper}.override { emacs = emacsPkg; }
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
      }
    );
  };
}
