{ perSystem, ... }:
{

  environment.systemPackages = with perSystem.nix-darwin; [
    darwin-option
    darwin-rebuild
    darwin-version
    darwin-uninstaller
  ];

  # Determinate uses its own daemon to manage the Nix installation
  #nix.enable = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
}
