{ pkgs, ... }:
{

  home.packages = with pkgs; [
    librewolf
    neovim
    vscode
    wezterm
    ghostty
  ];

}
