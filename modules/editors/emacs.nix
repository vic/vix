# emacs: data kind describing an emacs distribution (no scopes) and its instances.
{
  sven,
  lib,
  inputs,
  ...
}:
let
  inherit (sven.lib) opt maybe;
  t = lib.types;
  doomRev = inputs.doom-emacs.rev;
in
{
  sven.kinds.emacs.fields = {
    initDir = maybe t.str; # --init-directory of the daemon
    daemon = opt t.bool false; # this distribution runs as the emacs service
    configDots = maybe t.str; # dots source linked at ~/.config/<name>
    wrapper = maybe t.str; # flake input whose package of the same name wraps our emacs
    bootstrap = maybe t.str; # activation script text; installed as <name>-install
    bins = opt (sven.helpers.attrsOf t.str) { }; # shell scripts put on PATH
    fish = opt (sven.helpers.attrsOf t.str) { }; # fish function bodies
  };

  sven.emacs.spc = {
    wrapper = "SPC";
    fish = {
      mg = "spc u SPC gg -r \"$PWD\" RET";
      spc = "SPC $argv -- -nw";
      vspc = "SPC $argv -- -c";
    };
  };

  sven.emacs.doom = {
    initDir = "~/.config/emacs";
    daemon = true;
    configDots = "config/doom";
    bins = {
      doom = ''exec $HOME/.config/emacs/bin/doom "$@"'';
      doomscript = ''exec $HOME/.config/emacs/bin/doomscript "$@"'';
      d = ''exec emacsclient -nw -a "doom run -nw --"  "$@"'';
    };
    bootstrap = ''
      set -e
      if test -f "$HOME"/.config/emacs/.local/etc/@/init*.el; then
        doom_rev="$(rg "put 'doom-version 'ref '\"(\w+)\"" \
          "$HOME"/.config/emacs/.local/etc/@/init*.el -or '$1' || true)"
      fi
      if test "''${doom_rev:-}" = "${doomRev}"; then
        echo "DOOM Emacs already at revision ${doomRev}"
        exit 0
      fi
      (
        echo "DOOM Emacs obtaining revision ${doomRev}"
        if ! test -d "$HOME/.config/emacs/.git"; then
          git clone --depth 1 https://github.com/doomemacs/doomemacs \
            "$HOME/.config/emacs"
        fi
        cd "$HOME/.config/emacs"
        git fetch --depth 1 origin "${doomRev}"
        git reset --hard "${doomRev}"
        bin/doom install --no-config --no-env --no-install --aot
        echo "DOOM Emacs updated to revision ${doomRev}"
        bin/doom sync -e --force
      )
    '';
  };

  sven.aspects.emacs-inputs = {
    at = sven.fleet.vix;
    flake-file.inputs.doom-emacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };
}
