{lib, ...}: {
  flake.modules.nixos.niri-desktop = {
    programs.niri.enable = true;
    services.displayManager.defaultSession = lib.mkForce "niri";
  };
}
