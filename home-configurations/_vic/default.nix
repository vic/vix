{ lib, osConfig, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      eza
      anydesk
      authenticator
      autokey
      bat
      bluedevil
      bottom
      cachix
      comma
      direnv
      fd
      file
      fira-code-nerdfont
      fish
      fzf
      git
      htop
      inconsolata-nerdfont
      jetbrains-mono
      jq
      julia-mono
      kate
      krita
      lazygit
      librewolf
      lynx
      neovim
      nushell
      procs
      ripgrep
      steamcmd
      tig
      tmux
      tree
      unzip
      victor-mono
      vscode
      warpd
      wezterm
    ];
  };
}
