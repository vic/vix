{ pkgs, ... }:
{

  home.packages = with pkgs; [
    librewolf
    neovim
    emacs
    vscode
    wezterm
    ghostty
  ];

}
