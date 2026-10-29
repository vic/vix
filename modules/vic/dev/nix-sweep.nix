# nix-sweep: garbage collection of old generations and gc roots.
{ yen, ... }:
{
  yen.aspects.nix-sweep = {
    at = yen.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.nix-sweep ];
      };
  };
}
