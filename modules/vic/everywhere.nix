{
  den,
  vix,
  vic,
  ...
}:
{
  den.aspects.vic.includes = [ vic.everywhere ];
  vic.everywhere = {
    includes = [
      den.provides.primary-user
      vix.nix-index
      vix.nix-registry
    ];
    provides.to-hosts.nixos = { pkgs, ... }: {
      home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash-put";
    };
  };
}
