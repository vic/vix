{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
# for configurable nixos modules see (note that many of them might be linux-only):
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/module-list.nix
#
# for configurable nix-darwin modules see
# https://github.com/LnL7/nix-darwin/blob/master/modules/module-list.nix
{
  environment.systemPackages = with pkgs; [nixVersions.stable];
  documentation.enable = false;

  nixpkgs.overlays = [
    (import ./../overlays/unison.nix inputs.nivSources)
  ];



  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "left";
      };

      trackpad = { 
        Clicking = true; 
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3.0;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 1;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        ApplePressAndHoldEnabled = false;
      };

     #CustomUserPreferences = {};
     #CustomSystemPreferences = {};
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

  };

}
