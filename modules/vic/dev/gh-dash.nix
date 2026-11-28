# gh-dash: GitHub PR and issue dashboard.
{ yen, ... }:
{
  yen.aspects.gh-dash = {
    at = yen.aspects.vic-full;
    homeManager.programs.gh-dash.enable = true;
  };
}
