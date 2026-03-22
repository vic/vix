{ vic, inputs, ... }:
{
  flake-file.inputs = {
    doom-emacs.flake = false;
    doom-emacs.url = "github:doomemacs/doomemacs";
    SPC.url = "github:vic/SPC";
  };

  vic.everywhere.includes = [ vic.doom ];
  vic.doom.homeManager =
    {
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      emacsPkg = pkgs.emacs30;
      doom-install = pkgs.writeShellApplication {
        name = "doom-install";
        runtimeInputs = with pkgs; [
          git
          emacsPkg
          ripgrep
          openssh
        ];
        text = ''
          set -e
          if test -f "$HOME"/.config/emacs/.local/etc/@/init*.el; then
            doom_rev="$(rg "put 'doom-version 'ref '\"(\w+)\"" \
              "$HOME"/.config/emacs/.local/etc/@/init*.el -or '$1')"
          fi
          if test "''${doom_rev:-}" = "${inputs.doom-emacs.rev}"; then
            echo "DOOM Emacs already at revision ${inputs.doom-emacs.rev}"
            exit 0
          fi
          (
            echo "DOOM Emacs obtaining revision ${inputs.doom-emacs.rev}"
            if ! test -d "$HOME/.config/emacs/.git"; then
              git clone --depth 1 https://github.com/doomemacs/doomemacs \
                "$HOME/.config/emacs"
            fi
            cd "$HOME/.config/emacs"
            git fetch --depth 1 origin "${inputs.doom-emacs.rev}"
            git reset --hard "${inputs.doom-emacs.rev}"
            bin/doom install --no-config --no-env --no-install \
              --no-hooks --aot
            echo "DOOM Emacs updated to revision ${inputs.doom-emacs.rev}"
            bin/doom sync -e --force
          )
        '';
      };
      SPC = inputs'.SPC.packages.SPC.override {
        emacs = emacsPkg;
      };
    in
    {
      programs.emacs.enable = true;
      programs.emacs.package = emacsPkg;
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
      home.activation.doom-install = {
        after = [ "link-ssh-id" ];
        before = [ ];
        data = ''
          run ${lib.getExe doom-install}
        '';
      };
    };
}
