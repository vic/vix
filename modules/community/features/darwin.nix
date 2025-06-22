{ inputs, ... }:
let
  flake.modules.darwin.darwin.imports = [
    inputs.home-manager.darwinModules.home-manager
    nix-darwin-pkgs
    darwin-cfg
  ];

  darwin-cfg = {
    # Determinate uses its own daemon to manage the Nix installation
    nix.enable = false;

    system.defaults.trackpad.Clicking = true;
    system.defaults.trackpad.TrackpadThreeFingerDrag = true;
    system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToControl = true;
  };

  nix-darwin-pkgs =
    { pkgs, ... }:
    {
      environment.systemPackages = with inputs.nix-darwin.packages.${pkgs.system}; [
        darwin-option
        darwin-rebuild
        darwin-version
        darwin-uninstaller
      ];
    };
in
{
  inherit flake;
}
