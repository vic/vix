# nix-settings: cachix substitutes, flakes, trusted users, weekly gc, on workstations and wsl (nixos and darwin).
{
  lib,
  ren,
  ...
}:
let
  vix = import ../_lib.nix { inherit lib; };
in
{
  ren.aspects.nix-settings.at = ren.lib.anyOf [
    (ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.workstation || s.host.form == "wsl"))
    ])
    (ren.lib.and [
      ren.kinds.mac
      (ren.lib.when (s: s.mac.workstation))
    ])
  ];
  ren.aspects.nix-settings.os = vix.mod (
    { pkgs, config, ... }:
    {
      nix = {
        optimise.automatic = true;
        settings = {
          substituters = [
            "https://vix.cachix.org"
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
        gc = pkgs.lib.optionalAttrs config.nix.enable {
          automatic = true;
          options = "--delete-older-than 7d";
        };
      };
    }
  );
}
