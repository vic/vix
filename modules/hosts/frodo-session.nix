# frodo session: audio, apps and desktop of vic's laptop.
{
  ren.aspects.frodo-audio.nixos = {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
  ren.aspects.frodo-apps.nixos =
    { lib, pkgs, ... }:
    {
      programs.direnv.enable = true;
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      environment.systemPackages = lib.attrVals [
        "neovim"
        "jujutsu"
        "git"
        "nh"
        "just"
        "direnv"
        "ghostty"
        "niri"
        "wezterm"
        "foot"
        "fzf"
        "ripgrep"
        "fish"
        "fd"
        "jq"
        "noctalia-shell"
      ] pkgs;
      users.users.vic = {
        description = "vic";
        packages = [
          pkgs.chromium
          pkgs.flow-control
          pkgs.lapce
          pkgs.nodejs
          pkgs.power-profiles-daemon
          pkgs.uv
        ];
      };
    };
  ren.aspects.frodo-desktop.nixos = {
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
