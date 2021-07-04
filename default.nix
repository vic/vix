{ 
vix-lib,
flake-utils, 
mkDarwinSystem, 
... }@args:
let
  userName = "vic";
  hostName = "oeiuwq";
  systems = [ "aarch64-darwin" ];
in
{ inherit hostName systems; } // 
(flake-utils.lib.eachSystem systems (system:
  mkDarwinSystem {
    inherit hostName system;
    nixosModules = [
      {
        imports = [
          ./modules/default.nix
          ./modules/oeiuwq-aarch64-darwin.nix
          ./modules/vic-at-oeiuwq-aarch64-darwin.nix
        ];
      }
    ];
  }))

