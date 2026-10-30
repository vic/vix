# nix-settings: cachix substitutes, flakes, trusted users, weekly gc, on workstations and wsl (nixos and darwin).
# The `caches` sink: machines trust its caches in nix.settings, the fleet in flake.nix nixConfig (cachix batteries).
{ yen, ... }:
let
  inherit (yen.lib.batteries) cachix;
  vix = {
    name = "vix";
    publicKey = "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI=";
  };
  devenv = {
    name = "devenv";
    publicKey = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
  };
  # an element is a list of caches; it goes to the nearest machine, or the fleet
  caches = k: {
    reduce = yen.helpers.flat;
    os = cachix.caches { from = k.sinks.caches; };
  };
in
{
  yen.kinds.host.sinks.caches = caches yen.kinds.host;
  yen.kinds.guest.sinks.caches = caches yen.kinds.guest;
  yen.kinds.mac.sinks.caches = caches yen.kinds.mac;
  yen.kinds.fleet.sinks.caches = {
    reduce = yen.helpers.flat;
    flake-file = cachix.flake-config { from = yen.kinds.fleet.sinks.caches; };
  };

  yen.aspects.vix-cache = {
    at = yen.fleet.vix;
    caches = [ vix ];
  };

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
    caches = [
      vix
      devenv
    ];
    os =
      { pkgs, config, ... }:
      {
        nix = {
          optimise.automatic = true;
          settings = {
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
