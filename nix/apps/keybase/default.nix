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
    mkdir -p $out/Applications $out/bin
    cp -a "Keybase.app" $out/Applications
    ln -s $out/Applications/Keybase.app/Contents/SharedSupport/bin/{git,k}* $out/bin
  '';
}
