{
  lib,
  pkgs,
  config,
  vix,
  USER,
  DOTS,
  ...
}: {
  home-manager.users.${USER} = let
    emacsPkg = pkgs.emacs;
    doomDir = "~/.doom.d";
    doomLocalDir = "~/.emacs.d/doom-local";
    doomEmacs = "~/.nix-out/doom-emacs";
    doomConf = vix.lib.vixLink "vix/modules/vic/emacs/doom.d";
  in {
    home.file.".doom.d".source = doomConf;
    home.file.".nix-out/doom-emacs".source = vix.lib.nivSources.emacs-doom;
    home.file.".emacs.d/init.el".source = "${vix.lib.nivSources.emacs-chemacs2}/init.el";
    home.file.".emacs.d/early-init.el".source = "${vix.lib.nivSources.emacs-chemacs2}/early-init.el";
    home.file.".emacs-profile".text = "doom";
    home.file.".emacs-profiles.el".text = ''
      (("doom" . ((user-emacs-directory . "${doomEmacs}")
                  (server-name . "doom")
                  (server-socket-dir . "${doomLocalDir}/server-socks")
                  (custom-file . "${DOTS}/emacs.d/custom.el")
                  (env . (("DOOMDIR" . "${doomDir}")
                          ("DOOMLOCALDIR" . "${doomLocalDir}")
        )))))
    '';
    home.packages = [
      pkgs.EmacsApp
      (pkgs.writeScriptBin "doom-daemon" ''
        exec ${emacsPkg}/bin/emacs --with-profile doom --daemon doom "''${@}"
      '')
      (pkgs.writeScriptBin "ve" ''
        exec ${emacsPkg}/bin/emacsclient -s doom -c "''${@}"
      '')
      (pkgs.writeScriptBin "e" ''
        exec ${emacsPkg}/bin/emacsclient -s doom -nw "''${@}"
      '')
      (pkgs.writeScriptBin "emacsclient" ''
        exec ${emacsPkg}/bin/emacsclient -s doom "''${@}"
      '')
      (pkgs.writeScriptBin "SPC" ''
        export DOOMDIR="${doomDir}"
        export DOOMLOCALDIR="${doomLocalDir}"
        export EMACSDIR="${doomEmacs}"
        export SPC_CLIENT_CMD="${emacsPkg}/bin/emacsclient"
        exec ${pkgs.SPC}/bin/SPC "''${@}"
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
