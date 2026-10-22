# wrappers-inputs: nix-wrapper-modules, whose wrapped programs carry their config and replace dotfiles.
{ ren, ... }:
{
  ren.aspects.wrappers-inputs = {
    at = ren.fleet.vix;
    flake-inputs =
      { ... }:
      {
        nix-wrapper-modules = {
          url = "github:nix-community/nix-wrapper-modules";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
  };
}
