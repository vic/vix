# dev-tools: general developer command line packages.
{ ren, ... }:
{
  ren.aspects.dev-tools = {
    at = ren.aspects.vic-full;
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
