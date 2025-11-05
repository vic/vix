{ inputs, ... }:
{
  vic.fish.homeManager =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;

      code-visual = ''
        if test "$VSCODE_INJECTION" = "1"
          set -x VISUAL code
        end
      '';
    in
    {

      #home.file.".config/fish/conf.d/init-leader.fish".source =
      #  "${inputs.cli-leader.outPath}/assets/leader.fish.sh";
      home.file.".config/fish/conf.d/vscode-vim.fish".text = code-visual;
      home.file.".config/fish/conf.d/tv.fish".text = ''
        ${pkgs.television}/bin/tv init fish | source
      '';
      home.file.".config/fish/conf.d/tvtab.fish".source = ./_fish/tv.fish;

      programs.fzf.enable = true;
      # programs.fzf.enableFishIntegration = true;

      programs.fish = {
        enable = true;

        functions = import ./_fish/functions.nix { inherit inputs lib; };
        shellAliases = import ./_fish/aliases.nix;
        shellAbbrs = import ./_fish/abbrs.nix;

        plugins = [ ]; # pure done fzf.fish pisces z
      };

    };
}
