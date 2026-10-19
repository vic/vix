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
    homeManager = mod (
      { inputs', ... }:
      {
        home.packages = [ inputs'.lightjj.packages.default ];
        programs.claude-code.skills.lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";
      }
    );
  };
}
