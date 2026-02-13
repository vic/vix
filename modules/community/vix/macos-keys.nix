{
  vix.macos-keys.nixos =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      services.keyd.enable = true;
      services.keyd.keyboards.default.ids = [ "*" ]; # apply on all devices
      services.keyd.keyboards.default.settings = import ./_macos-keys.nix { inherit lib pkgs config; };
    };
}
