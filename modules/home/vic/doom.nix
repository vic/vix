{
  pkgs,
  lib,
  inputs,
  ...
}:
let

  doom-install = pkgs.writeShellApplication {
    name = "doom-install";
    runtimeInputs = with pkgs; [
      git
      emacs
      ripgrep
    ];
    text = ''
      set -xe
      if test -d "$HOME/.config/emacs/.local"; then
        doom_rev="$(rg "put 'doom-version 'ref '\"(\w+)\"" "$HOME"/.config/emacs/.local/etc/@/init*.el -or '$1')"
      fi

      if test "''${doom_rev:-}" = "${inputs.doom-emacs.rev}"; then
        exit 0 # doom already pointing to same revision
      fi

      (
        if ! test -d "$HOME/.config/emacs/.git"; then
          git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
        fi
        cd "$HOME/.config/emacs"
        git fetch --depth 1 origin "${inputs.doom-emacs.rev}"
        git reset --hard "${inputs.doom-emacs.rev}"
        bin/doom install --no-config --no-env --install --force
        bin/doom sync -e --gc --aot --force
      )
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

  home.activation.doom-install = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe doom-install}
  '';

}
