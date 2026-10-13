{
  den.aspects.frodo.nixos = {
    services.xserver.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "vic";

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
