{ vic, den, ... }:
{

  perSystem =
    { pkgs, ... }:
    {
      treefmt.programs = {
        stylua.enable = true;
        fish_indent.enable = true;
      };

      packages.vi = den.lib.nvf.package pkgs { } { };
    };

  vic.everywhere.includes = [ vic.nvim ];
  vic.nvim = {
    homeManager =
      {
        pkgs,
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

        astrovim = vim_variant "astrovim" [ ];
        lazyvim = vim_variant "lazyvim" [ ];
        vscode-vim = vim_variant "vscode-vim" [ ];

        vim-gui = neovide_variant "vim-gui" pkgs.neovim;
        lazyvim-gui = neovide_variant "lazyvim-gui" lazyvim;
        astrovim-gui = neovide_variant "astrovim-gui" astrovim;
      in
      {
        home.packages = [
          lazyvim
          vscode-vim
          astrovim
          pkgs.neovim-remote
          pkgs.neovide
          vim-gui
          lazyvim-gui
          astrovim-gui
        ];
        home.sessionVariables.VISUAL = "vim-gui";
        home.sessionVariables.EDITOR = "vim";
        programs.neovim.enable = true;
        programs.neovim.viAlias = true;
        programs.neovim.vimAlias = true;
        programs.neovim.withNodeJs = true;
        programs.neovim.extraPackages = with pkgs; [
          sqlite
          treefmt
          gcc
          gnumake
        ];
        programs.neovim.plugins = with pkgs; [
          vimPlugins.nvim-treesitter-parsers.go
          vimPlugins.nvim-treesitter-parsers.rust
          vimPlugins.nvim-treesitter-parsers.yaml
          vimPlugins.nvim-treesitter-parsers.nix
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];
      };

    hmLinux =
      { pkgs, ... }:
      {
        programs.neovim.extraPackages = [ pkgs.zig ];
      };
  };
}
