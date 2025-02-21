{ inputs, pkgs, ... }:
let
  inherit (pkgs) lib;
in
{

  home.file.".config/fish/conf.d/init-leader.fish".source =
    "${inputs.cli-leader.outPath}/assets/leader.fish.sh";

  programs.fzf.enable = true;
  programs.fzf.enableFishIntegration = true;

  programs.fish = {
    enable = true;

    functions = import ./fish/functions.nix { inherit inputs lib; };
    shellAliases = import ./fish/aliases.nix;
    shellAbbrs = import ./fish/abbrs.nix;

    plugins = [ ]; # pure done fzf.fish pisces z
  };

}
