{ mod, ... }:
{
  ren.aspects.macos-keys = {
    nixos = mod (
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        services.keyd.enable = true;
        services.keyd.keyboards.default.ids = [ "*" ];
        services.keyd.keyboards.default.settings = import ./_macos-keys.nix { inherit lib pkgs config; };
      }
    );
  };
}
