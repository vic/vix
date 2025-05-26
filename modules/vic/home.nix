{ inputs, ... }:
let
  flake.homeConfigurations.vic = vic_at "mordor";
  flake.homeConfigurations."vic@mordor" = vic_at "mordor";

  vic_at =
    host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.self.nixosConfigurations.${host}.pkgs;
      modules = [ inputs.self.homeModules.vic ];
      extraSpecialArgs.osConfig = inputs.self.nixosConfigurations.${host}.config;
    };

  flake.homeModules.vic.imports = [
    inputs.self.modules.homeManager.vic
  ];

  flake.modules.homeManager.vic =
    { pkgs, lib, ... }:
    {
      home.username = lib.mkDefault "vic";
      home.homeDirectory = lib.mkDefault (if pkgs.stdenvNoCC.isDarwin then "/Users/vic" else "/home/vic");
      home.stateVersion = lib.mkDefault "25.05";
    };

in
{
  inherit flake;
}
