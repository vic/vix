{
  config,
  lib,
  pkgs,
  ...
}:
# for configurable nixos modules see (note that many of them might be linux-only):
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/module-list.nix
#
# for configurable nix-darwin modules see
# https://github.com/LnL7/nix-darwin/blob/master/modules/module-list.nix
{
  environment.systemPackages = with pkgs; [nixVersions.stable];
}
