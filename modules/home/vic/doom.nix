{ pkgs, lib, ... }: let

  doom-clone = pkgs.writeShellApplication {
    name = "doom-clone";
    runtimeInputs = with pkgs; [ git emacs ];
    text = ''
    # If doom already exists just exit
    test -f "$HOME/.config/emacs/bin/doom" && exit 0

    git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
    "$HOME/.config/emacs/bin/doom" install --no-config --no-env --install --force
    '';
  };

in
{
  programs.emacs.enable = true;
  services.emacs.enable = pkgs.stdenv.isLinux;

  home.packages = [
    (pkgs.writeShellScriptBin "doom" ''exec $HOME/.config/emacs/bin/doom "$@"'')
    (pkgs.writeShellScriptBin "doomscript" ''exec $HOME/.config/emacs/bin/doomscript "$@"'')
    (pkgs.writeShellScriptBin "d" ''exec emacsclient -nw -a "doom run -nw --"  "$@"'')
  ];

  home.activation.clone_doom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe doom-clone}
  '';

}
