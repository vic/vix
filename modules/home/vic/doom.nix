{ pkgs, lib, ... }:
{
  programs.emacs.enable = true;
  services.emacs.enable = pkgs.stdenv.isLinux;

  home.packages = [
    (pkgs.writeShellScriptBin "doom" ''exec $HOME/.config/emacs/bin/doom "$@"'')
    (pkgs.writeShellScriptBin "doomscript" ''exec $HOME/.config/emacs/bin/doomscript "$@"'')
    (pkgs.writeShellScriptBin "d" ''exec emacsclient -nw -a "doom run -nw --"  "$@"'')
  ];

  home.activation.link-doom-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ln -sfn $HOME/.flake/modules/home/vic/doom $HOME/.config/
  '';

}
