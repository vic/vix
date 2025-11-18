{ inputs, ... }:
let

  flake-file.inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
  };

  vix.darwin.darwin.imports = [
    nix-darwin-pkgs
    darwin-cfg
  ];

  darwin-cfg = {
    # Determinate uses its own daemon to manage the Nix installation
    # nix.enable = false;

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

  # TODO: link home-manager apps.
in
{
  inherit vix flake-file;
}
