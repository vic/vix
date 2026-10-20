# nix-sweep: garbage collection of old generations and gc roots.
{ ren, ... }:
{
  ren.aspects.nix-sweep = {
    at = ren.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.nix-sweep ];
      };
  };
}
