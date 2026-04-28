{ vic, ... }:
{
  perSystem.treefmt.programs.stylua.enable = true;

  vic.everywhere.includes = [ vic.nvim ];
  vic.nvim = {
    homeManager =
      {
        config,
        pkgs,
        self',
        ...
      }:
      let
        vi = pkgs.writeShellApplication {
          name = "vi";
          text = ''exec nvim "$@"'';
        };
        vim = pkgs.writeShellApplication {
          name = "vim";
          text = ''exec nvim "$@"'';
        };

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

        neovim = vim_variant "neovim" [ self'.packages.neovim ];
        neovim-gui = neovide_variant "neovim-gui" neovim;

        astrovim = vim_variant "astrovim" [ pkgs.neovim ];
        astrovim-gui = neovide_variant "astrovim-gui" astrovim;

        lazyvim = vim_variant "lazyvim" [ pkgs.neovim ];
        lazyvim-gui = neovide_variant "lazyvim-gui" lazyvim;

        vim-gui = neovide_variant "vim-gui" pkgs.neovim;
        vscode-vim = vim_variant "vscode-vim" [ pkgs.neovim ];
      in
      {
        home.packages = [
          vi
          vim
          config.programs.neovim.package
          neovim
          neovim-gui
          astrovim
          astrovim-gui
          lazyvim
          lazyvim-gui
          pkgs.neovide
          pkgs.neovim-remote
          vim-gui
          vscode-vim
        ];

        home.sessionVariables.VISUAL = "vim-gui";
        home.sessionVariables.EDITOR = "vim";

        programs.neovim.plugins = [
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];
      };
  };
}
