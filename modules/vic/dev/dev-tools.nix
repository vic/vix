{ ... }:
{

  vic.dev-tools.hm =
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

}
