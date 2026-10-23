# ircc: local IRC-like chat between Claude Code sessions on this machine.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{

  ren.aspects.ai-ircc = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        ircc = {
          url = "github:vic/ircc";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ (vix.perSystem pkgs inputs.ircc).packages.default ];
      };
  };
}
