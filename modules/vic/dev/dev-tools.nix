# dev-tools: general developer command line packages.
{ sven, ... }:
{
  sven.aspects.dev-tools = {
    at = sven.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.diffnav
          pkgs.gh
          pkgs.hyperfine
          pkgs.jq
          pkgs.difftastic
        ];
      };
  };
}
