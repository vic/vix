# dev-tools: general developer command line packages.
{ yen, ... }:
{
  yen.aspects.dev-tools = {
    at = yen.aspects.vic-full;
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
