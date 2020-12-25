{ pkgs, sources, ... }:

let
  source = sources.keybase;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "Keybase.app";
  version = source.version;
  src = source;
  sourceRoot = ".";
  preferLocalBuild = true;
  nativeBuildInputs = [ pkgs.undmg ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = "undmg $src";
  installPhase = ''
    mkdir -p $out/Applications
    cp -a "Keybase.app" $out/Applications
  '';
}
