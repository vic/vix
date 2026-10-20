# gh-dash: GitHub PR and issue dashboard.
{ ren, ... }:
{
  ren.aspects.gh-dash = {
    at = ren.aspects.vic-full;
    homeManager.programs.gh-dash.enable = true;
  };
}
