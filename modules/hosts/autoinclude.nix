# autoinclude: a host with a hosts/<name>/_nixos directory gets its hardware files and disko without a line in its host file.
{
  yen,
  lib,
  inputs,
  ...
}:
let
  inherit (yen.lib) all;
  dir = h: ./. + "/${h.name}/_nixos";
  has = h: n: builtins.pathExists (dir h + "/${n}");
  hasDir = all [
    yen.kinds.host
    (h: builtins.pathExists (dir h))
  ];
in
{
  yen.aspects.autoinclude = {
    at = hasDir;
    flake-file.inputs.disko = {
      url = "github:nix-community/disko";
      flake = false;
    };
    nixos =
      { host, ... }:
      {
        imports =
          lib.optional (has host "hardware-configuration.nix") (dir host + "/hardware-configuration.nix")
          ++ lib.optionals (has host "disko.nix") [
            (dir host + "/disko.nix")
            "${inputs.disko}/module.nix"
          ];
      };
  };
}
