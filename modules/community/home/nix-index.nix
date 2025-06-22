{ inputs, ... }:
{
  flake.modules.homeManager.nix-index = {
    imports = [
      inputs.nix-index-database.hmModules.nix-index
    ];

    programs.nix-index.enable = true;
    programs.nix-index.enableFishIntegration = true;
    programs.nix-index-database.comma.enable = true;
  };
}
