{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    nodePackages.node2nix
  ];

  shellHook = ''
    node --version
  '';
}
