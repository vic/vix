# emacs: kind describing an emacs distribution (data only, no scopes) and its instances.
{
  ren,
  lib,
  inputs,
  ...
}:
let
  vix = ren.helpers;
  t = lib.types;
  doomRev = inputs.doom-emacs.rev;
in
{
  ren.kinds.emacs = {
    initDir = vix.maybe t.str; # --init-directory of the daemon
    daemon = vix.opt t.bool false; # this distribution runs as the emacs service
    configDots = vix.maybe t.str; # dots source linked at ~/.config/<name>
    wrapper = vix.maybe t.str; # flake input whose package of the same name wraps our emacs
    bootstrap = vix.maybe t.str; # activation script text; installed as <name>-install
    bins = vix.opt (t.attrsOf t.str) { }; # shell scripts put on PATH
    fish = vix.opt (t.attrsOf t.str) { }; # fish function bodies
  };

  ren.emacs.spc = {
    wrapper = "SPC";
    fish = {
      mg = "spc u SPC gg -r \"$PWD\" RET";
      spc = "SPC $argv -- -nw";
      vspc = "SPC $argv -- -c";
    };
  };

  ren.emacs.doom = {
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

  ren.aspects.emacs-inputs = {
    at = ren.fleet.vix;
    flake-inputs =
      { ... }:
      {
        doom-emacs = {
          url = "github:doomemacs/doomemacs/59cdaa32ae933469bb6a1fb3cadee8a988c15968";
          flake = false;
        };
      };
  };
}
