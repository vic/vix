{ pkgs, lib, ... }:
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

  home.activation.link-nvim-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ln -sfn $HOME/.flake/modules/home/vic/nvim $HOME/.config/
  '';

}
