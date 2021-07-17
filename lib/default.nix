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

  nivFishPlugin = name: {
    inherit name;
    src = nivSources."fish-${name}";
  };

  # Dirty hack to access OS provided tool.
  hdiutil = lib.mkOutOfStoreSymlink "/usr/bin/hdiutil";

  nivApp = name:
    let
      src = nivSources."${name}App";
      meta = { inherit name; description = "${name} App"; } // src;
    in pkgs.stdenvNoCC.mkDerivation rec {
      inherit (meta) name version;
      inherit src meta;
      pname = "${name}App";
      sourceRoot = ".";
      preferLocalBuild = true;
      phases = [ "unpackPhase" "installPhase" ];
      unpackPhase = ''
        mkdir -p mnt src
        ${hdiutil} attach -readonly -mountpoint mnt $src
        cp -r mnt src
        ${hdiutil} detach mnt
      '';
      installPhase = ''
        mkdir -p $out/Applications
        find src -mindepth 1 -maxdepth 2 -type d -iname "*.app" -exec cp -r {} $out/Applications/ \;
      '';
    };

}
