{ pkgs, inputs, ... }:
inputs.treefmt-nix.lib.evalModule pkgs {
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.nixfmt.excludes = [ ".direnv" ];
  programs.deadnix.enable = true;
}
