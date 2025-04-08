{ config, pkgs, ... }:
{
  imports = [
    ./nix-substituters.nix
    ./nixpkgs-unfree.nix
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        # "allow-import-from-derivation"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    gc = pkgs.lib.optionalAttrs config.nix.enable {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
