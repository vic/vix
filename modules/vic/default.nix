{ config, pkgs, lib, vix-lib, home-manager, nix-darwin, nixpkgs, ... }@args: 
let 
  USER = "vic";
  HOME = "/v";
in
{
  _module.args = { inherit HOME USER; };

  imports = [ ./direnv.nix ./ssh.nix ];

  users.users.${USER}.home = HOME;

  home-manager.users.${USER} = {
    programs.nix-index.enableFishIntegration = true;
    home.packages = config.pkgSets.${USER};

    home.file.".nix-out/vix".source = ./../..;
    home.file.".nix-out/dots".source = vix-lib.dots;
    home.file.".nix-out/nixpkgs".source = nixpkgs;
    home.file.".nix-out/nix-darwin".source = nix-darwin;
    home.file.".nix-out/home-manager".source = home-manager;
    home.file.".nix-out/openjdk".source = pkgs.openjdk;
  };

}
