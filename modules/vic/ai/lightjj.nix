# lightjj: browser UI for jj, served from wherever the repo lives (also headless vini).
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{

  ren.aspects.ai-lightjj = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        lightjj = {
          url = "github:chronologos/lightjj/42427a1093fc70c73d5d0010a8d59909fd48a722";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ (vix.perSystem pkgs inputs.lightjj).packages.default ];
        programs.claude-code.skills.lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";
      };
  };
}
