{ config, pkgs, lib, vix, ... }@args:
let
  inherit (vix.inputs) mk-darwin-system nixpkgs;
  inherit (mk-darwin-system.inputs) home-manager nix-darwin;
  DOTS = lib.mds.mkOutOfStoreSymlink "/hk/dots";
  USER = "vic";
  HOME = "/v";
in {
  _module.args = { inherit HOME USER DOTS; };

  imports = [ ./git ./direnv ./ssh ./fish ./emacs ];

  users.users.${USER}.home = HOME;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "vscode" ];

  home-manager.users.${USER} = {
    programs.vscode = { enable = true; };

    programs.nix-index.enableFishIntegration = true;
    home.packages = config.pkgSets.${USER};

    home.file.".nix-out/vix".source = vix;
    home.file.".nix-out/dots".source = DOTS;
    home.file.".nix-out/nixpkgs".source = nixpkgs;
    home.file.".nix-out/nix-darwin".source = nix-darwin;
    home.file.".nix-out/home-manager".source = home-manager;
    home.file.".nix-out/openjdk".source = pkgs.openjdk;

    home.activation = {
      aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sfn $genProfilePath/home-path/Applications/* "$HOME/Applications/"
      '';
    };
  };

}
