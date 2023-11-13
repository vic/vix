top@{config, lib, ...}: let
  vix-lib = (import ./dirApply.nix top) (f: import f top) ./.;
  paths = import ./_paths.nix top;
in lib.makeExtensible (self: vix-lib // paths)