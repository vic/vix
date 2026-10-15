# lightjj: browser UI for jj, served from wherever the repo lives (also headless vini).
{ inputs, vic, ... }:
{
  flake-file.inputs.lightjj.url = "github:chronologos/lightjj";

  vic.ai.includes = [ vic.ai.lightjj ];
  vic.ai.lightjj.homeManager =
    { inputs', ... }:
    {
      home.packages = [ inputs'.lightjj.packages.default ];
      programs.claude-code.skills.lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";
    };
}
