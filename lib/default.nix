{ nixpkgs, ... }:
{ pkgs, lib, ... }: rec {

  linkJvm = (name: jdk:
    pkgs.runCommand "link-jvm-${name}" { } ''
      mkdir -p $out/Library/Java/JavaVirtualMachines
      ln -s ${builtins.toPath jdk} $out/Library/Java/JavaVirtualMachines/${name}
    '');

  shellDirenv = name: shell:
    pkgs.runCommand "${name}-shell-direnv" {
      shell_input_derivation = shell.inputDerivation;
    } (builtins.readFile ./shell-direnv.bash);

  mkOutOfStoreSymlink = path:
    let
      pathStr = toString path;
      name = baseNameOf pathStr;
    in pkgs.runCommandLocal name { } "ln -s ${lib.escapeShellArg pathStr} $out";

  dots = mkOutOfStoreSymlink "/hk/dots";

}
