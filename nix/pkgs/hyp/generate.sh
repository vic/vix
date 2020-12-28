#!/usr/bin/env sh
nix shell "../../..#nodePackages.node2nix" -c node2nix -i node-packages.json -o node-packages.nix -c composition.nix --pkg-name nodejs-15_x
