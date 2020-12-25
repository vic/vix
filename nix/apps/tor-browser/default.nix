{ pkgs, sources, ... }:

let
  source = sources.tor-browser;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "TorBrowser.app";
  version = source.version;
  src = source;
  sourceRoot = ".";
  preferLocalBuild = true;
  buildInputs = [ pkgs.p7zip ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = ''
    7z x $src
  '';
  installPhase = ''
    mkdir -p $out/Applications
    cp -R "Tor Browser.app" $out/Applications
  '';
}
