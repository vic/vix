{ config, pkgs, lib, vix-lib, home-manager, nix-darwin, nixpkgs, ... }@args: {

  _module.args = {
    USER = "vic";
    HOME = config.home-manager.users.vic.home.homeDirectory;
    CONF = "home-manager.users.vic";
  };

  imports = [ ./direnv.nix ./ssh.nix ];

  services.lorri.enable = true;

  users.users.vic.home = "/v";

  home-manager.users.vic = {
    programs.nix-index.enableFishIntegration = true;
    home.packages = config.pkgSets.vic;

    home.file.".nix-out/vix".source = ./../..;
    home.file.".nix-out/dots".source = vix-lib.dots;
    home.file.".nix-out/nixpkgs".source = nixpkgs;
    home.file.".nix-out/nix-darwin".source = nix-darwin;
    home.file.".nix-out/home-manager".source = home-manager;
    home.file.".nix-out/openjdk".source = pkgs.openjdk;

  };

}
