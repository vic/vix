{ lib, pkgs, config, ... }: rec {


  linkJvm = (name: jdk:
    pkgs.runCommand "link-jvm-${name}" { } ''
      mkdir -p $out/Library/Java/JavaVirtualMachines
      ln -s ${builtins.toPath jdk} $out/Library/Java/JavaVirtualMachines/${name}
    '');

  shellDirenv = name: shell:
    pkgs.runCommand "${name}-shell-direnv" {
      shell_input_derivation = shell.inputDerivation;
    } (builtins.readFile ./shell-direnv.bash);

  nivSources = import ./../nix/sources.nix;

  nivFishPlugin = name: 
    { inherit name; src = nivSources."fish-${name}"; };

  nivDmgApp = name:
    let source = nivSources.${name};
    in pkgs.stdenvNoCC.mkDerivation {
      name = name;
      version = source.version;
      src = source;
      sourceRoot = ".";
      preferLocalBuild = true;
      nativeBuildInputs = [ pkgs.undmg ];
      phases = [ "unpackPhase" "installPhase" ];
      unpackPhase = "undmg $src";
      installPhase = ''
        mkdir -p $out/Applications
        cp -a *.app $out/Applications
      '';
    };

}
