# gh-dash: GitHub PR and issue dashboard.
{ sven, ... }:
{
  sven.aspects.gh-dash = {
    at = sven.aspects.vic-full;
    homeManager.programs.gh-dash.enable = true;
  };
}
