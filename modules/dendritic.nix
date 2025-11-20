{ inputs, lib, ... }:
{
  flake-file.inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  flake-file.inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];
}
