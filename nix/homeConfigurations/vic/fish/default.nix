{ config, lib, pkgs, inputs, ... }:

{
  programs.fzf.enable = true;
  programs.fzf.enableFishIntegration = true;
  programs.fish = {
    enable = true;

    functions = import ./functions.nix { inherit inputs lib; };
    shellAliases = import ./aliases.nix;
    shellAbbrs = import ./abbrs.nix;

    interactiveShellInit = ''
        set -g fish_key_bindings fish_hybrid_key_bindings
        direnv hook fish | source
      '';

    plugins = map (name: {inherit name; src = inputs.nivSources."fish-${name}";})
      ["pure" "done" "fzf.fish" "pisces" "z"];
  };

  home.file = {
    ".local/share/fish/fish_history".source = "${config.dots}/fish/fish_history";
  };
}
