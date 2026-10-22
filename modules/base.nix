# base: nix-index, nix registry for vic; hm backup command on hosts with vic.
{
  ren,
  inputs,
  ...
}:
{
  ren.aspects.vic-nix-index = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        nix-index-database = {
          url = "github:nix-community/nix-index-database";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];
      programs.nix-index.enable = true;
      programs.nix-index.enableFishIntegration = true;
      programs.nix-index-database.comma.enable = true;
    };
  };
  ren.aspects.vic-nix-registry = {
    at = ren.aspects.vic-headless;
    homeManager.nix.registry = { };
  };
  ren.aspects.vic-hm-backup = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.has ren.user.vic)
    ];
    nixos =
      { pkgs, ... }:
      {
        home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash-put";
      };
  };
}
