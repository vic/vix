{ vic, ... }:
{
  vic.everywhere.includes = [ vic.dev-tools ];

  vic.dev-tools.hm =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.yazi
        pkgs.zoxide
        pkgs.ispell
        pkgs.gh
        pkgs.multimarkdown
      ];
    };

  vic.dev-tools.hmLinux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.nix-search-cli
        pkgs.nixd
        pkgs.nixfmt
      ];
    };

}
