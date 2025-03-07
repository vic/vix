{ perSystem, pkgs, ... }:
let
  nix-darwin-pkgs = with perSystem.nix-darwin; [
    darwin-option
    darwin-rebuild
    darwin-version
    darwin-uninstaller
  ];
in
{

  environment.systemPackages =
    nix-darwin-pkgs
    ++ (with pkgs; [
      iterm2
      wezterm
    ]);

  # Determinate uses its own daemon to manage the Nix installation
  nix.enable = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
}
