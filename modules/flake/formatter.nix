{
  perSystem.treefmt.projectRootFile = ".envrc";

  perSystem.treefmt.programs = {
    nixfmt.enable = true;
    nixfmt.excludes = [ ".direnv" ];
    deadnix.enable = true;
    fish_indent.enable = true;
    kdlfmt.enable = true;
  };

  perSystem.treefmt.settings.global.excludes = [
    "flake.lock"
    ".envrc"
    ".leaderrc"
    "*.el" # TODO contribute an emacs treefmt
    "**/.gitignore"
    "*/config/ghostty/*"
    "*/config/wezterm/*"
    "*/vic/dots/vscode/*"
    "*/vic/dots/ssh/*"
    "*/vic/secrets/*"
  ];

}
