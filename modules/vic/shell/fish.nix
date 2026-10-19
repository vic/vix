# fish: functions, aliases, abbreviations, television and fzf integration.
{ vicAt, ... }:
{
  ren.aspects.fish = {
    at = vicAt.core;
    homeManager =
      { pkgs, ... }:
      {
        home.file.".config/fish/conf.d/tv.fish".text = ''
          ${pkgs.television}/bin/tv init fish | source
        '';
        home.file.".config/fish/conf.d/tvtab.fish".source = ./_fish/tv.fish;
        programs.fzf.enable = true;
        programs.fish = {
          enable = true;
          functions = import ./_fish/functions.nix { };
          shellAliases = import ./_fish/aliases.nix;
          shellAbbrs = import ./_fish/abbrs.nix;
          plugins = [ ];
        };
      };
  };
}
