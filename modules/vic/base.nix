# base: nix-index, nix registry for vic; hm backup command on hosts with vic.
{ yen, inputs, ... }:
{
  yen.aspects.vic-nix-index = {
    at = yen.aspects.vic-headless;
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
  yen.aspects.vic-nix-registry = {
    at = yen.aspects.vic-headless;
    homeManager.nix.registry = { };
  };
  yen.aspects.vic-hm-backup = {
    at = yen.lib.all [
      yen.helpers.linux
      (yen.lib.has yen.user.vic)
    ];
    nixos = { pkgs, ... }: { home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash-put"; };
  };
}
