# autoinclude: a host with a hosts/<name>/_nixos directory gets its hardware files, disko and facter report without a line in its host file.
{
  sven,
  lib,
  inputs,
  ...
}:
{
  sven.aspects.autoinclude = {
    at = sven.lib.all [
      sven.kinds.host
      (s: builtins.pathExists (./. + "/${s.name}/_nixos"))
    ];
    flake-file.inputs.disko = {
      url = "github:nix-community/disko";
      flake = false;
    };
    nixos =
      { host, ... }:
      let
        d = ./. + "/${host.name}/_nixos";
        has = n: builtins.pathExists (d + "/${n}");
        file = n: lib.optional (has n) (d + "/${n}");
      in
      {
        imports =
          file "hardware-configuration.nix"
          ++ file "disko.nix"
          ++ lib.optional (has "disko.nix") "${inputs.disko}/module.nix";
        hardware.facter.reportPath = lib.mkIf (has "facter.json") (d + "/facter.json");
      };
  };
}
