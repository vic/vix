# darwin-base: trackpad and keyboard defaults, nix-darwin tools.
{ inputs, ... }:
{
  ren.aspects.darwin-base.darwin =
    { pkgs, ... }:
    {
      system.defaults.trackpad.Clicking = true;
      system.defaults.trackpad.TrackpadThreeFingerDrag = true;
      system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;
      environment.systemPackages = with inputs.darwin.packages.${pkgs.stdenvNoCC.hostPlatform.system}; [
        darwin-option
        darwin-rebuild
        darwin-version
        darwin-uninstaller
      ];
    };
}
