{
  lib,
  pkgs,
  config,
  inputs,
  flake,
  ...
}: let
  inherit (inputs) nivSources;
  emacsPkg = pkgs.emacs28;
  doomDir = "~/.doom.d";
  doomLocalDir = "~/.emacs.d/doom-local";
  doomEmacs = "~/.nix-out/doom-emacs";
  doomConf = config.lib.file.mkOutOfStoreSymlink "/hk/vix/nix/homeConfigurations/vic/emacs/doom.d";
in {
  programs.emacs.enable = true;

  home.file.".doom.d".source = doomConf;
  home.file.".nix-out/doom-emacs".source = nivSources.emacs-doom;
  home.file.".emacs.d/init.el".source = "${nivSources.emacs-chemacs2}/init.el";
  home.file.".emacs.d/early-init.el".source = "${nivSources.emacs-chemacs2}/early-init.el";
  home.file.".emacs-profile".text = "doom";
  home.file.".emacs-profiles.el".text = ''
    (("doom" . ((user-emacs-directory . "${doomEmacs}")
                (server-name . "doom")
                (server-socket-dir . "${doomLocalDir}/server-socks")
                (custom-file . "${config.dots}/emacs.d/custom.el")
                (env . (("DOOMDIR" . "${doomDir}")
                        ("DOOMLOCALDIR" . "${doomLocalDir}")
                )))))
  '';
  home.packages = [
    (pkgs.writeScriptBin "alejandra-quiet" ''
      exec ${pkgs.alejandra}/bin/alejandra --quiet "''${@}"
    '')
    (pkgs.writeScriptBin "doom-daemon" ''
      exec ${emacsPkg}/bin/emacs --with-profile doom --daemon=doom "''${@}"
    '')
    (pkgs.writeScriptBin "ve" ''
      exec ${emacsPkg}/bin/emacsclient -s doom -c "''${@}"
    '')
    (pkgs.writeScriptBin "e" ''
      exec ${emacsPkg}/bin/emacsclient -s doom -nw "''${@}"
    '')
    # (pkgs.writeScriptBin "emacsclient" ''
    #     exec ${emacsPkg}/bin/emacsclient "''${@}"
    #   '')
    #(pkgs.writeScriptBin "SPC" ''
    #    export SPC_CLIENT_CMD="${emacsPkg}/bin/emacsclient"
    #    export SPC_CLIENT_OPTS="-s doom"
    #    exec ${pkgs.SPC}/bin/SPC "''${@}"
    #  '')
    (pkgs.writeScriptBin "doom" ''
      export DOOMDIR="${doomDir}"
      export DOOMLOCALDIR="${doomLocalDir}"
      export EMACSDIR="${doomEmacs}"
      exec $EMACSDIR/bin/doom "''${@}"
    '')
  ];
}
