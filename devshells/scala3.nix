import ./from-nix ({pkgs, perSystem, ...}: let
  jre = pkgs.graalvm-ce;

  mill = pkgs.mill.override { inherit jre; };
  scala-cli = pkgs.scala-cli.override { inherit jre; };
  sbt = pkgs.sbt.override { inherit jre; };
  metals = pkgs.metals.override { inherit jre; };
in {

  commands = [
    { package = mill; }
    { package = scala-cli; }
    { package = sbt; }
  ]; 

  devshell.packages = [ metals ];
 
})
