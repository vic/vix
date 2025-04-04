{
  pname,
  pkgs,
  inputs,
  ...
}:
pkgs.writeShellApplication {
  name = pname;
  meta.mainProgram = pname;
  runtimeInputs = with pkgs; [
    jujutsu
    git
    fzf
    coreutils
    findutils
    gnused
    gnugrep
    gawk
    bash
  ];
  text = ''
    bash ${inputs.jj-fzf}/jj-fzf
  '';
}
