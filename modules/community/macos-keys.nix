# macos-keys: keyd remap to macOS-style keys, on hosts with keyboard = macos.
{ mod, hostWhen, ... }:
{
  ren.aspects.macos-keys = {
    at = hostWhen (h: h.keyboard == "macos");
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
