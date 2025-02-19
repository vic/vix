{pkgs, ...}:
{
  programs.emacs.enable = true;
  services.emacs.enable = true;

  # home.file.".config/doom".source = ./doom;
  home.packages = [
    (pkgs.writeShellScriptBin "doom" ''exec $HOME/.config/emacs/bin/doom "$@"'')
    (pkgs.writeShellScriptBin "doomscript" ''exec $HOME/.config/emacs/bin/doomscript "$@"'')
    (pkgs.writeShellScriptBin "d" ''exec emacsclient -nw -a "doom run -nw --"  "$@"'')
  ];

}
