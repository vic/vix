{ pkgs, sources, ... }:

let
  source = sources.idea;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation rec {
  app = "IntelliJ IDEA CE.app";
  pname = builtins.replaceStrings [" "] ["_"] app;
  version = source.version;
  src = source;
  sourceRoot = ".";
  preferLocalBuild = true;
  nativeBuildInputs = [ pkgs.undmg ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = "undmg $src";
  installPhase = ''
    mkdir -p $out/Applications $out/bin
    cp -a "$app" $out/Applications
    echo ln -s $out/Applications/$app/Contents/MacOS/idea $out/bin
  '';
}
