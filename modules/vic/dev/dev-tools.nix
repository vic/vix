# dev-tools: general developer command line packages.
{ vicAt, ... }:
{
  ren.aspects.dev-tools = {
    at = vicAt.full;
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
