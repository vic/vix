{ pkgs, ... }:
{

  home.packages = with pkgs; [
    librewolf
    vscode
    wezterm
    ghostty
  ];

}
