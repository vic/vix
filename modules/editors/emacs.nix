# emacs: data kind describing an emacs distribution (no scopes) and its instances.
{
  yen,
  types,
  inputs,
  ...
}:
let
  doomRev = inputs.doom-emacs.rev;
in
{
  yen.kinds.emacs.fields = {
    initDir = types.maybe types.str;
    daemon = types.opt types.bool false;
    configDots = types.maybe types.str;
    wrapper = types.maybe types.str;
    bootstrap = types.maybe types.str;
    bins = types.opt (types.attrsOf types.str) { };
    fish = types.opt (types.attrsOf types.str) { };
  };

  yen.emacs.spc = {
    wrapper = "SPC";
    fish = {
      mg = "spc u SPC gg -r \"$PWD\" RET";
      spc = "SPC $argv -- -nw";
      vspc = "SPC $argv -- -c";
    };
  };

  yen.emacs.doom = {
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

  yen.aspects.emacs-inputs = {
    at = yen.root;
    flake-file.inputs.doom-emacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };
}
