# base: nix-index, nix registry for vic; hm backup command on hosts with vic.
{ sven, inputs, ... }:
{
  sven.aspects.vic-nix-index = {
    at = sven.aspects.vic-headless;
    flake-file.inputs.nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeManager = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];
      programs.nix-index.enable = true;
      programs.nix-index.enableFishIntegration = true;
      programs.nix-index-database.comma.enable = true;
    };
  };
  sven.aspects.vic-nix-registry = {
    at = sven.aspects.vic-headless;
    homeManager.nix.registry = { };
  };
  sven.aspects.vic-hm-backup = {
    at = sven.lib.all [
      sven.helpers.linux
      (sven.lib.has sven.user.vic)
    ];
    nixos = { pkgs, ... }: { home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash-put"; };
  };
}
