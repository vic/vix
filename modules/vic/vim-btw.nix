{
  vic.vim-btw = {

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let

        vim_variant =
          name: inputs:
          pkgs.writeShellApplication {
            inherit name;
            runtimeEnv = {
              NVIM_APPNAME = name;
            };
            runtimeInputs = [ config.programs.neovim.package ] ++ inputs;
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

  };
}
