# lightjj: browser UI for jj, served from wherever the repo lives (also headless vini).
{
  inputs,
  vicAt,
  mod,
  ...
}:
{

  ren.aspects.ai-lightjj = {
    at = vicAt.headless;
    flake-inputs =
      { ... }:
      {
        lightjj = {
          url = "github:chronologos/lightjj/42427a1093fc70c73d5d0010a8d59909fd48a722";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager = mod (
      { inputs', ... }:
      {
        home.packages = [ inputs'.lightjj.packages.default ];
        programs.claude-code.skills.lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";
      }
    );
  };
}
