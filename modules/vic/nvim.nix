{
  perSystem.treefmt.programs = {
    stylua.enable = true;
    fish_indent.enable = true;
  };

  vic.nvim.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    let
      vim_variant =
        name: runtimeInputs:
        pkgs.writeShellApplication {
          inherit name runtimeInputs;
          runtimeEnv = {
            NVIM_APPNAME = name;
          };
          text = ''exec nvim "$@"'';
        };
      astrovim = vim_variant "astrovim" [ ];
      lazyvim = vim_variant "lazyvim" [ ];
      vscode-vim = vim_variant "vscode-vim" [ ];
    in
    {
      home.packages = [
        lazyvim
        vscode-vim
        astrovim
        pkgs.neovim-remote
      ];
      home.sessionVariables.VISUAL = "vim";
      home.sessionVariables.EDITOR = "vim";
      programs.neovim.enable = true;
      programs.neovim.viAlias = true;
      programs.neovim.vimAlias = true;
      programs.neovim.withNodeJs = true;
      programs.neovim.extraPackages =
        (with pkgs; [
          sqlite
          treefmt
          gcc
          gnumake
        ])
        ++ (lib.optionals pkgs.stdenv.isLinux [ pkgs.zig ]);
      programs.neovim.plugins = with pkgs; [
        vimPlugins.nvim-treesitter-parsers.go
        vimPlugins.nvim-treesitter-parsers.rust
        vimPlugins.nvim-treesitter-parsers.yaml
        vimPlugins.nvim-treesitter-parsers.nix
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
    };
}
