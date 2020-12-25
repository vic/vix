{ pkgs, sources, ... }:

let
  source = sources.flux;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "Flux.app";
  version = source.version;
  src = source;
  preferLocalBuild = true;
  installPhase = ''
    mkdir -p $out/Applications
    cp -a $src $out/Applications/Flux.app
  '';
}
