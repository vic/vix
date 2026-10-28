# nix-sweep: garbage collection of old generations and gc roots.
{ sven, ... }:
{
  sven.aspects.nix-sweep = {
    at = sven.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.nix-sweep ];
      };
  };
}
