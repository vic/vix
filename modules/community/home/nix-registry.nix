{ inputs, lib, ... }:
{

  flake.modules.homeManager.nix-registry.nix.registry = lib.mapAttrs (_name: v: { flake = v; }) (
    lib.filterAttrs (_name: value: value ? outputs) inputs
  );

}
