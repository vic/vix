{ inputs, ... }:
{

  flake-file.inputs = {
    doom-emacs.flake = false;
    doom-emacs.url = "github:doomemacs/doomemacs";
    SPC.url = "github:vic/SPC";
  };

  vic.doom-btw = {
    homeManager =
      { pkgs, ... }:
      let
        emacsPkg = pkgs.emacs30;

        SPC = inputs.SPC.packages.${pkgs.system}.SPC.override { emacs = emacsPkg; };

      in
      {
        programs.emacs.enable = true;
        programs.emacs.package = emacsPkg;
        #services.emacs.enable = true;
        services.emacs.package = emacsPkg;
        services.emacs.extraOptions = [
          "--init-directory"
          "~/.config/emacs"
        ];

        home.packages = [
          SPC
          (pkgs.writeShellScriptBin "doom" ''exec $HOME/.config/emacs/bin/doom "$@"'')
          (pkgs.writeShellScriptBin "doomscript" ''exec $HOME/.config/emacs/bin/doomscript "$@"'')
          (pkgs.writeShellScriptBin "d" ''exec emacsclient -nw -a "doom run -nw --"  "$@"'')
        ];

        #home.activation.doom-install = lib.hm.dag.entryAfter [ "link-ssh-id" ] ''
        #  run ${lib.getExe doom-install}
        #'';
      };

  };

}
