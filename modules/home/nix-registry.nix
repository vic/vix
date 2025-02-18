{ inputs, pkgs, ... }:
{

  nix.registry =
    with pkgs.lib;
    mapAttrs (name: v: { flake = v; }) (filterAttrs (name: value: value ? outputs) inputs);

}
