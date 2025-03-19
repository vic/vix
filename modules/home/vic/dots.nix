{ config, ... }:
let
  dotsLink =
    path:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.flake/modules/home/vic/dots/${path}";
in
{
  home.activation.link-flake = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    echo Checking that "$HOME/.flake" exists.
    test -L "$HOME/.flake"
  '';

  home.file.".ssh" = {
    recursive = true;
    source = ./dots/ssh;
  };

  home.file.".config/nvim".source = dotsLink "config/nvim";
  home.file.".config/doom".source = dotsLink "config/doom";
  home.file.".config/wezterm".source = dotsLink "config/wezterm";
  home.file.".config/ghostty".source = dotsLink "config/ghostty";

}
