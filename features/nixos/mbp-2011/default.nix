{ lib, config, pkgs, ... }:
let
  cfg = config.vix.features.mbp-2011;
in
{
  options.vix.features.mbp-2011.enable = lib.options.mkEnableOption "Enable MBP 2011 support";

  config = lib.mkIf cfg.enable {

    boot.kernelPackages = pkgs.channels.nixpkgs-unstable.linuxPackages;
    services.mbpfan.enable = true;
    services.mbpfan.aggressive = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelModules = [ "kvm-intel" "wl" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

    hardware.enableAllFirmware = true;
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;


    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp2s0f0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  };
}
