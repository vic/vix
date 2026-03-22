{ vic, ... }:
{
  perSystem.treefmt.programs.stylua.enable = true;

  vic.everywhere.includes = [ vic.nvim ];
  vic.nvim = {
    homeManager =
      {
        pkgs,
        self',
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

        neovide_variant =
          name: nvim:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ pkgs.neovide ];
            text = ''exec neovide --neovim-bin ${pkgs.lib.getExe nvim} "$@"'';
          };

        astrovim = vim_variant "astrovim" [ pkgs.neovim ];
        lazyvim = vim_variant "lazyvim" [ pkgs.neovim ];
        vscode-vim = vim_variant "vscode-vim" [ pkgs.neovim ];

        vim-gui = neovide_variant "vim-gui" self'.packages.neovim;
        lazyvim-gui = neovide_variant "lazyvim-gui" lazyvim;
        astrovim-gui = neovide_variant "astrovim-gui" astrovim;
      in
      {
        home.packages = [
          astrovim
          astrovim-gui
          lazyvim
          lazyvim-gui
          pkgs.neovide
          pkgs.neovim-remote
          self'.packages.neovim
          vim-gui
          vscode-vim
        ];

        home.sessionVariables.VISUAL = "vim-gui";
        home.sessionVariables.EDITOR = "vim";

        #programs.neovim.enable = true;
        #programs.neovim.finalPackage = self'.packages.neovim;
        #programs.neovim.viAlias = true;
        #programs.neovim.vimAlias = true;

        #programs.neovim.withNodeJs = true;
        #programs.neovim.extraPackages = with pkgs; [
        #  sqlite
        #  treefmt
        #  gcc
        #  gnumake
        #];
        #programs.neovim.plugins = with pkgs; [
        #  vimPlugins.nvim-treesitter-parsers.go
        #  vimPlugins.nvim-treesitter-parsers.rust
        #  vimPlugins.nvim-treesitter-parsers.yaml
        #  vimPlugins.nvim-treesitter-parsers.nix
        #  pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        # programs.neovim.extraPackages = [ pkgs.zig ];
        #];
      };
  };
}
