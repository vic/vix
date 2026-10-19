# frodo: vic's laptop. This machine (hardware, mac keys, laptop), this role (base, audio, apps), this desktop (niri).
{
  ren,
  inputs,
  ...
}:
{
  ren.aspects.frodo-hardware.nixos = {
    imports = [
      ./frodo/_nixos/hardware-configuration.nix
      ./frodo/_nixos/disko.nix
      "${inputs.disko}/module.nix"
    ];
    hardware.facter.reportPath = ./frodo/_nixos/facter.json;
  };
  ren.aspects.frodo-base.nixos = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    networking.networkmanager.enable = true;
    time.timeZone = "America/Mexico_City";
    i18n.defaultLocale = "en_US.UTF-8";
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];
    system.stateVersion = "26.11";
  };
  ren.host.frodo = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    form = "laptop";
    keyboard = "macos";
    desktops = [ "niri" ];
  };

  ren.aspects.frodo = {
    at = ren.host.frodo;
    flake-inputs =
      { ... }:
      {
        disko = {
          url = "github:nix-community/disko/725ea35e410ad83be4931d1bff7e090eacaf3563";
          flake = false;
        };
      };
    includes = [
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.frodo-hardware
      ren.aspects.frodo-base
      ren.aspects.frodo-audio
      ren.aspects.frodo-apps
      ren.aspects.frodo-desktop
    ];
  };
}
