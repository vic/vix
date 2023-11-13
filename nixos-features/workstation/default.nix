{ lib, pkgs, config, ... }:
let
  cfg = config.vix.features.workstation;
in
{
  options.vix.features.workstation = with lib.options; {
    enable = mkEnableOption "workstation feature";
  };

  config = lib.mkIf cfg.enable {


    nix.registry = {
      # nixpkgs-system.to = {
      #   type = "path";
      #   path = inputs.nixpkgs; # pkgs.path;
      # };
      # nixpkgs-main.to = {
      #   type = "github";
      #   owner = "NixOS";
      #   repo = "nixpkgs";
      # };
    };


    environment.systemPackages = [ pkgs.vim ];

    networking.networkmanager.enable = true;
    time.timeZone = "America/Mexico_City";
    i18n.defaultLocale = "en_US.UTF-8";
    services.openssh.enable = true;

  };
}
