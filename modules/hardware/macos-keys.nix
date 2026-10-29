# macos-keys: keyd remap to macOS-style keys, on hosts with keyboard = macos.
{ yen, ... }:
{
  yen.aspects.macos-keys = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.keyboard == "macos")
    ];
    nixos =
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
      };
  };
}
