{ inputs, ... }:
let
  flake.modules.nixos.vic.imports = [
    user
    linux
    autologin
    home
  ];

  flake.modules.darwin.vic.imports = [
    user
    darwin
    home
  ];

  home.home-manager.users.vic.imports = [
    inputs.self.homeModules.vic
  ];

  autologin =
    { config, lib, ... }:
    lib.mkIf config.services.displayManager.enable {
      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = "vic";
    };

  linux = {
    users.users.vic = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  darwin.system.primaryUser = "vic";

  user =
    { pkgs, ... }:
    {
      home-manager.backupFileExtension = "backup";

      programs.fish.enable = true;

      fonts.packages = with pkgs.nerd-fonts; [
        victor-mono
        jetbrains-mono
        inconsolata
      ];

      users.users.vic = {
        description = "vic";
        shell = pkgs.fish;
      };
    };
in
{
  inherit flake;
}
