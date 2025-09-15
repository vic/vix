{
  perSystem.treefmt.programs = {
    stylua.enable = true;
  };

  flake.modules.homeManager.vic =
    { pkgs, lib, ... }:
    {
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
