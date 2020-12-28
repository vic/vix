{ pkgs, sources, ... }:

let
  source = sources.tunnelblick;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "Tunnelblick.app";
  version = source.version;
  src = source;
  preferLocalBuild = true;
  nativeBuildInputs = [ pkgs.undmg ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = ''
    undmg $src
  '';
  installPhase = ''
    mkdir -p $out/Applications
    cp -a Tunnelblick.app $out/Applications/
  '';
}
