{ pkgs, sources, ... }:

let
  source = sources.pock;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "Pock.app";
  version = source.version;
  src = source;
  preferLocalBuild = true;
  installPhase = ''
    mkdir -p $out/Applications
    cp -a $src $out/Applications/Pock.app
  '';
}
