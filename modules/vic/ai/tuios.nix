{
  yen,
  inputs,
  lib,
  ...
}:
{
  yen.aspects.ai-tuios = {
    at = yen.aspects.vic-headless;
    flake-file.inputs.tuios = {
      url = "github:Gaurav-Gosain/tuios";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-allow = [ "Bash(tuios *)" ];
    homeManager =
      { pkgs, ... }:
      let
        tuios = (yen.helpers.perSystem pkgs inputs.tuios).packages.default;
      in
      {
        home.packages = [ tuios ];
      };
  };
}
