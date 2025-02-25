{ inputs, pkgs, ... }:
{

  nix.registry =
    with pkgs.lib;
    mapAttrs (_name: v: { flake = v; }) (filterAttrs (_name: value: value ? outputs) inputs);

}
