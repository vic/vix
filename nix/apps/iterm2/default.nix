{ pkgs, sources, ... }:

let
  source = sources.iterm2;
  mkDerivation = pkgs.stdenvNoCC.mkDerivation;
in
mkDerivation {
  pname = "iTerm2.app";
  version = source.version;
  src = source;
  preferLocalBuild = true;
  installPhase = ''
    mkdir -p $out/Applications
    cp -a $src $out/Applications/iTerm2.app
  '';
}
