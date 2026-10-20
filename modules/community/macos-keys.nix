# macos-keys: keyd remap to macOS-style keys, on hosts with keyboard = macos.
{ ren, ... }:
{
  ren.aspects.macos-keys = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.keyboard == "macos"))
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
