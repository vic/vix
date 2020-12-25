{ pkgs, sources, ... }:

let
  source = sources.firefox-developer;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "FirefoxDeveloperEdition.app";
  version = source.version;
  src = source;
  sourceRoot = ".";
  preferLocalBuild = true;
  nativeBuildInputs = [ pkgs.undmg ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = "undmg $src";
  installPhase = ''
    mkdir -p $out/Applications
    cp -a "Firefox Developer Edition.app" $out/Applications
  '';
}
