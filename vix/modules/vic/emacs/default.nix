{ lib, pkgs, config, vix, vix-lib, USER, HOME, ... }: {

  services.emacs = {
    enable = true;
    package = pkgs.EmacsApp;
  };

  home-manager.users.${USER} = {
    home.file.".doom.d".source = vix-lib.vixLink "vix/modules/vic/emacs/doom.d";
    home.file.".nix-out/doom-emacs".source = vix-lib.nivSources.emacs-doom;

    home.file.".emacs.d/init.el".source = "${vix-lib.nivSources.emacs-chemacs2}/init.el";
    home.file.".emacs.d/early-init.el".source = "${vix-lib.nivSources.emacs-chemacs2}/early-init.el";
    
    home.file.".emacs-profile".text = "doom";
    home.file.".emacs-profiles.el".text = ''
    (("doom" . ((user-emacs-directory . "~/.nix-out/doom-emacs")
                (env . (("DOOMDIR" . "~/.doom.d") 
                        ("DOOMLOCALDIR" . "~/.emacs.d/doom-local")
	               )))))
    '';

    home.packages = [
      (pkgs.writeScriptBin "doom" ''
      export DOOMDIR="~/.doom.d" 
      export DOOMLOCALDIR="~/.emacs.d/doom-local"
      export EMACSDIR="~/.nix-out/doom-emacs"
      exec $EMACSDIR/bin/doom "''${@}"
      '') 
    ];

  };
}