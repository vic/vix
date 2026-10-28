# darwin-base: trackpad and keyboard defaults, nix-darwin tools, on workstation macs.
{ sven, inputs, ... }:
{
  sven.aspects.darwin-base = {
    at = sven.lib.all [
      sven.kinds.mac
      (s: s.workstation)
    ];
    darwin =
      { lib, pkgs, ... }:
      {
        system.defaults.trackpad.Clicking = true;
        system.defaults.trackpad.TrackpadThreeFingerDrag = true;
        system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
        system.keyboard.enableKeyMapping = true;
        system.keyboard.remapCapsLockToControl = true;
        environment.systemPackages = lib.attrVals [
          "darwin-option"
          "darwin-rebuild"
          "darwin-version"
          "darwin-uninstaller"
        ] inputs.darwin.packages.${pkgs.stdenvNoCC.hostPlatform.system};
      };
  };
}
