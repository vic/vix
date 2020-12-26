{ config, lib, pkgs, ... }:

let
  nodePackages = import ./composition.nix {
    inherit pkgs;
  };
  hyp = nodePackages."@hyperspace/cli-1.3.x";
in
hyp.override (attrs: {
  packageName = "hyp";
  postInstall = ''
  mkdir -p $out/bin
  ln -s $out/lib/node_modules/hyp/bin/hyp.js $out/bin/hyp
  # ln -s $out/lib/node_modules/hyp/node_modules/.bin/hyper* $out/bin/hyp
  '';
})
