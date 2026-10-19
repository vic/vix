# nvim: vi/vim wrappers and NVIM_APPNAME variants; gui variants through neovide on the desktop.
{
  ren,
  vicAt,
  mod,
  ...
}:
let
  vim_variant =
    pkgs: name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      runtimeEnv = {
        NVIM_APPNAME = name;
      };
      text = ''exec nvim "$@"'';
    };

  neovide_variant =
    pkgs: name: nvim:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.neovide ];
      text = ''exec neovide --neovim-bin ${pkgs.lib.getExe nvim} "$@"'';
    };
in
{
  ren.aspects.vic-nvim = {
    at = vicAt.core;
    homeManager = mod (
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
      in
      {
        home.packages = [
          vi
          vim
          config.programs.neovim.package
          (vim_variant pkgs "neovim" [ self'.packages.neovim ])
          (vim_variant pkgs "astrovim" [ pkgs.neovim ])
          (vim_variant pkgs "lazyvim" [ pkgs.neovim ])
          pkgs.neovim-remote
        ];

        home.sessionVariables.EDITOR = "vim";

        programs.neovim.plugins = [
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];
      }
    );
  };

  ren.aspects.vic-nvim-gui = {
    at = vicAt.desktop;
    homeManager =
      { pkgs, self', ... }:
      let
        neovim = vim_variant pkgs "neovim" [ self'.packages.neovim ];
        astrovim = vim_variant pkgs "astrovim" [ pkgs.neovim ];
        lazyvim = vim_variant pkgs "lazyvim" [ pkgs.neovim ];
      in
      {
        home.packages = [
          (neovide_variant pkgs "neovim-gui" neovim)
          (neovide_variant pkgs "astrovim-gui" astrovim)
          (neovide_variant pkgs "lazyvim-gui" lazyvim)
          pkgs.neovide
          (neovide_variant pkgs "vim-gui" pkgs.neovim)
          (vim_variant pkgs "vscode-vim" [ pkgs.neovim ])
        ];

        home.sessionVariables.VISUAL = "vim-gui";
      };
  };
}
