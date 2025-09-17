{
  perSystem.treefmt.projectRootFile = "flake.nix";
  perSystem.treefmt.programs = {
    nixfmt.enable = true;
    nixfmt.excludes = [ ".direnv" ];
    deadnix.enable = true;
    fish_indent.enable = true;
    kdlfmt.enable = true;
  };
}
