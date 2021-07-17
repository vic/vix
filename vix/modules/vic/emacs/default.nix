{ lib, pkgs, config, vix, vix-lib, USER, HOME, ... }: {

  home-manager.users.${USER} = let
    emacsPkg = pkgs.EmacsApp;
    doomDir = "~/.doom.d";
    doomLocalDir = "~/.emacs.d/doom-local";
    doomEmacs = "~/.nix-out/doom-emacs";
    doomConf = vix-lib.vixLink "vix/modules/vic/emacs/doom.d";
  in {
    home.file.".doom.d".source = doomConf;
    home.file.".nix-out/doom-emacs".source = vix-lib.nivSources.emacs-doom;

    home.file.".emacs.d/init.el".source =
      "${vix-lib.nivSources.emacs-chemacs2}/init.el";

    home.file.".emacs.d/early-init.el".source =
      "${vix-lib.nivSources.emacs-chemacs2}/early-init.el";

    home.file.".emacs-profile".text = "doom";

    home.file.".emacs-profiles.el".text = ''
      (("doom" . ((user-emacs-directory . "${doomEmacs}")
                  (env . (("DOOMDIR" . "${doomDir}")
                          ("DOOMLOCALDIR" . "${doomLocalDir}")
        )))))
    '';

    home.packages = [
      pkgs.EmacsApp
      (pkgs.writeScriptBin "doom-daemon" ''
        ${emacsPkg}/bin/emacs --with-profile doom --daemon doom
      '')
      (pkgs.writeScriptBin "ve" ''
        ${emacsPkg}/bin/emacsclient -c
      '')
      (pkgs.writeScriptBin "e" ''
        ${emacsPkg}/bin/emacsclient -nw
      '')
      (pkgs.writeScriptBin "espace" ''
        SPC="SPC "
        while [ -n "$1" ]; do
          if [ "--" == "$1" ]; then
            shift
            break
          fi
          SPC="$SPC $1"
          shift
        done
        ${emacsPkg}/bin/emacsclient --eval '(call-interactively (lambda () (interactive) (execute-kbd-macro (kbd "'"$SPC"'"))))' "''${@}"
      '')
      (pkgs.writeScriptBin "doom" ''
        export DOOMDIR="${doomDir}"
        export DOOMLOCALDIR="${doomLocalDir}"
        export EMACSDIR="${doomEmacs}"
        exec $EMACSDIR/bin/doom "''${@}"
      '')
    ];

  };
}
