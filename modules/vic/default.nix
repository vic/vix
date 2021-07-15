{ config, nixpkgs, pkgs, lib, vix-lib, ... }@args: {

  imports = [ ./direnv.nix ];

  services.lorri.enable = true;

  home-manager.users.vic = {
    programs.nix-index.enableFishIntegration = true;
    home.packages = config.pkgSets.vic;

    home.file.".nix-out/vix".source = ./../..;
    home.file.".nix-out/dots".source = vix-lib.dots;
    home.file.".nix-out/nixpkgs".source = nixpkgs;
    home.file.".nix-out/openjdk".source = pkgs.openjdk;

    #home.activation.report-changes = lib.hm.dag.entryAnywhere ''
    #  ${pkgs.nvd}/bin/nvd $oldGenPath $newGenPath
    #'';

  };

}
