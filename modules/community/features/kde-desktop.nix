{
  flake.modules.nixos.kde-desktop = {
    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.avahi = {
      nssmdns4 = true;
      enable = true;
      publish = {
        enable = true;
        userServices = true;
        domain = true;
      };
    };

  };
}
