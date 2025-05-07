{
  flake.modules.homeManager.vic =
    { pkgs, ... }:
    {
      home.sessionVariables.EDITOR = "vim";
      programs.neovim.enable = true;
      programs.neovim.viAlias = true;
      programs.neovim.vimAlias = true;
      programs.neovim.withNodeJs = true;
      programs.neovim.extraPackages = with pkgs; [
        zig
        sqlite
        treefmt
      ];

    };

}
