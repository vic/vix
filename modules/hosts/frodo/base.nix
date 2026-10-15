{ den, ... }:
{
  # Boot, network, locale and the nix features frodo needs.
  den.aspects.frodo.base.nixos = {
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
}
