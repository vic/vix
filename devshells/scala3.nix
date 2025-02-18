{ pkgs, perSystem, ... }:
let
  jre = pkgs.graalvm-ce;

  mill = pkgs.mill.override { inherit jre; };
  scala-cli = pkgs.scala-cli.override { inherit jre; };
  sbt = pkgs.sbt.override { inherit jre; };
  metals = pkgs.metals.override { inherit jre; };
in
perSystem.devshell.mkShell {

  commands = [
    { package = mill; }
    { package = scala-cli; }
    { package = sbt; }
  ];

  devshell.packages = [ metals ];

}
