# nix-settings: cachix substitutes, flakes, trusted users, weekly gc, on workstations and wsl (nixos and darwin).
{ yen, ... }:
{
  yen.aspects.nix-settings = {
    at = [
      (yen.lib.all [
        yen.helpers.linux
        (s: s.workstation || s.form == "wsl")
      ])
      (yen.lib.all [
        yen.kinds.mac
        (s: s.workstation)
      ])
    ];
    os =
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
      };
  };

  # every machine, laptops and servers too
  yen.aspects.nix-tuning = {
    at = yen.helpers.machines;
    os.nix.settings = {
      min-free = 128 * 1024 * 1024; # gc starts when a build leaves less free
      max-free = 1024 * 1024 * 1024; # and frees up to this much
      connect-timeout = 5;
      fallback = true; # build locally when a substituter fails
      builders-use-substitutes = true;
      log-lines = 25; # more build error context per failure
    };
  };
}
