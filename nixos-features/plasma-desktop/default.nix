{ lib, config, pkgs, ... }:
let
  cfg = config.vix.features.plasma-desktop;
in
{
  options.vix.features.plasma-desktop = {
    enable = lib.options.mkEnableOption "plasma desktop";
  };

  config = lib.mkIf cfg.enable {

    services.blueman.enable = true;
    services.xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "";

      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };

    environment.systemPackages = with pkgs; with plasma5Packages; [
      kdeconnect # connect with your phone
      qmltermwidget # terminal for dolphin
      qtcurve # qtengine
      bismuth # tiling windows
    ];

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

  };

}
