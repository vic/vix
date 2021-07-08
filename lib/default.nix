{ nixpkgs, self, ... }:
{ pkgs, lib, ... }: {

  shellDirenv = name: shell:
    pkgs.runCommand "${name}-shell-direnv" {
      shell_name = shell.name;
      shell_intput_derivation = shell.inputDerivation;
    } (builtins.readFile ./shell-direnv.bash);

}
