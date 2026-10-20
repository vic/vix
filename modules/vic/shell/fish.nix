# fish: functions, aliases, abbreviations, television and fzf integration.
{ ren, ... }:
{
  # any feature emits fish functions; fish writes them once.
  ren.channels.fish-functions = {
    fold = ren.lib.fold.attrs;
    at = ren.kinds.user;
    to = e: e;
  };
  ren.aspects.fish = {
    at = ren.aspects.vic-headless;
    fish-functions = { ... }: import ./_fish/functions.nix { };
    homeManager =
      { pkgs, fish-functions, ... }:
      {
        home.file.".config/fish/conf.d/tv.fish".text = ''
          ${pkgs.television}/bin/tv init fish | source
        '';
        home.file.".config/fish/conf.d/tvtab.fish".source = ./_fish/tv.fish;
        programs.fzf.enable = true;
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
