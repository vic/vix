# Formatter: treefmt per system as `formatter.<sys>` and the `checks.<sys>.fmt` check.
{
  ren,
  inputs,
  ...
}:
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
  perSystem = {
    at = ren.kinds.system;
    to =
      e:
      ren.lib.and [
        ren.kinds.system
        e
      ];
  };
in
{
  ren.channels.formatter = perSystem // {
    fold = ren.lib.fold.attrs;
    into = { system, ... }: f: { formatter.${system.name} = f.treefmt; };
  };

  ren.aspects.formatter = {
    at = ren.kinds.system;
    flake-inputs =
      { ... }:
      {
        treefmt-nix = {
          url = "github:numtide/treefmt-nix/0d6d739a833ba9a9c93034862e4a7b061a062a1c";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    formatter = { system, ... }: { treefmt = (treefmt system).config.build.wrapper; };
    checks = { system, ... }: { ${system.name}.fmt = (treefmt system).config.build.check inputs.self; };
  };
}
