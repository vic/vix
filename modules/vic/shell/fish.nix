# fish: functions, aliases, abbreviations, television and fzf integration.
{ yen, ... }:
{
  # the fish-functions sink (any feature emits fish functions; fish writes them once) is declared in topology/people.nix.
  yen.aspects.fish = {
    at = yen.aspects.vic-headless;
    fish-functions = { ... }: import ./_fish/functions.nix { };
    homeManager =
      { pkgs, fish-functions, ... }:
      {
        home.file.".config/fish/conf.d/tv.fish".text = ''
          ${pkgs.television}/bin/tv init fish | source
        '';
        home.file.".config/fish/conf.d/tvtab.fish".source = ./_fish/tv.fish;
        programs.fzf = {
          enable = true;
          # fzf's fish bindings take ctrl-r from tv's fish-history widget.
          enableFishIntegration = false;
        };
        programs.nix-your-shell.enable = true;
        programs.fish = {
          enable = true;
          functions = fish-functions;
          shellAliases = import ./_fish/aliases.nix;
          shellAbbrs = import ./_fish/abbrs.nix;
          plugins = [ ];
        };
      };
  };
}
