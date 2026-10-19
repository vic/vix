# frodo: vic's laptop. This machine (hardware, mac keys, laptop), this role (base, audio, apps), this desktop (niri).
{
  ren,
  inputs,
  mod,
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
  ren.aspects.frodo-apps.nixos = mod (
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
    }
  );
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
  ren.host.frodo = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
  };

  ren.aspects.frodo = {
    at = ren.host.frodo;
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.frodo-hardware
      ren.aspects.macos-keys
      ren.aspects.laptop
      ren.aspects.frodo-base
      ren.aspects.frodo-audio
      ren.aspects.frodo-apps
      ren.aspects.niri-desktop
      ren.aspects.frodo-desktop
    ];
  };
}
