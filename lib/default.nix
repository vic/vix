{ nixpkgs, ... }:
{ pkgs, ... }:
self: super: rec {

  shellDirenv = name: shell:
    pkgs.runCommand "${name}-shell-direnv" {
      shell_input_derivation = shell.inputDerivation;
    } (builtins.readFile ./shell-direnv.bash);

  mkOutOfStoreSymlink = path:
    let
      pathStr = toString path;
      name = baseNameOf pathStr;
    in pkgs.runCommandLocal name { }
    "ln -s ${super.escapeShellArg pathStr} $out";

  dots = mkOutOfStoreSymlink "/hk/dots";

}
