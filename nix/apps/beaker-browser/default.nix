{ pkgs, sources, ... }:

let
  source = sources.beaker-browser;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation rec {
  app = source.app;
  pname = builtins.replaceStrings [" "] ["_"] source.app;
  version = source.version;
  src = source;
  sourceRoot = ".";
  preferLocalBuild = true;
  nativeBuildInputs = [ pkgs.undmg ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = "undmg $src";
  installPhase = ''
    mkdir -p $out/Applications
    cp -a "$app" $out/Applications
  '';
}
