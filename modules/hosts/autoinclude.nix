# autoinclude: a host with a hosts/<name>/_nixos directory gets its hardware files and disko automatically.
{
  yen,
  at,
  lib,
  inputs,
  ...
}:
let
  dir = h: ./. + "/${h.name}/_nixos";
  has = h: n: builtins.pathExists (dir h + "/${n}");
  hasDir = at.all [
    yen.kinds.host
    (at.pred "has-nixos-dir" (h: builtins.pathExists (dir h)))
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
