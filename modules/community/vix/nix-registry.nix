{ inputs, lib, ... }:
{

  vix.nix-registry.homeManager.nix.registry = lib.mapAttrs (_name: v: { flake = v; }) (
    lib.filterAttrs (_name: value: value ? outputs) inputs
  );

}
