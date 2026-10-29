# Trimmed NixOS base module lists, per host: paths under nixos/modules of ONE nixpkgs rev, in module-list.nix order.
# Empty: no list is computed for vix's nixpkgs yet, so `trimmedModules` has no effect on any host.
# Compute one with the method of ~/hk/yen/vic/modlist-research.md §4 (closure of a learned core and the
# options the host defines). Oracle: nixosConfigurations.<h> and nixosConfigurationsFull.<h> give one drvPath.
{ }
