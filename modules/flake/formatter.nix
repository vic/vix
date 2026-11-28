# Formatter: treefmt per system as `formatter.<sys>` and the `checks.<sys>.fmt` check.
{ yen, inputs, ... }:
let
  treefmt =
    system:
    inputs.treefmt-nix.lib.evalModule system.legacyPackages {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        nixfmt.excludes = [ ".direnv" ];
        deadnix.enable = true;
        deadnix.no-lambda-pattern-names = true; # module args are selected by name: never drop a declared one
        fish_indent.enable = true;
        kdlfmt.enable = true;
        stylua.enable = true;
      };
      settings.global.excludes = [
        "flake.lock"
        ".envrc"
        ".leaderrc"
        "*.el" # TODO contribute an emacs treefmt
        "**/.gitignore"
        "*/config/ghostty/*"
        "*/config/wezterm/*"
        "*/dots/vscode/*"
        "*/dots/ssh/*"
        "*/secrets/*"
      ];
    };
in
{
  yen.aspects.formatter = {
    at = yen.kinds.system;
    flake-file.inputs.treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    formatter = { system, ... }: (treefmt system).config.build.wrapper;
    checks = { system, ... }: { ${system.name}.fmt = (treefmt system).config.build.check inputs.self; };
  };
}
