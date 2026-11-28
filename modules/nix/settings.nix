# nix-settings: cachix substitutes, flakes, trusted users, weekly gc, on workstations and wsl.
{
  yen,
  at,
  reduce,
  ...
}:
let
  vix = {
    name = "vix";
    publicKey = "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI=";
  };
  devenv = {
    name = "devenv";
    publicKey = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
  };
  subUrl = c: "https://${c.name}.cachix.org";
in
{
  yen.kinds.machine.sinks.caches = {
    reduce = reduce.flat;
    allowOrphan = true;
    into.os =
      { caches, ... }:
      {
        nix.settings = {
          substituters = map subUrl caches;
          trusted-public-keys = map (c: c.publicKey) caches;
        };
      };
  };

  yen.kinds.root.sinks.caches = {
    reduce = reduce.flat;
    into.flake-file =
      { caches, ... }:
      {
        nixConfig = {
          extra-substituters = map subUrl caches;
          extra-trusted-public-keys = map (c: c.publicKey) caches;
        };
      };
  };

  yen.aspects.vix-cache = {
    at = yen.root;
    caches = [ vix ];
  };

  yen.aspects.nix-settings = {
    at = at.anyOf [
      (yen.kinds.host.where { workstation = true; })
      (yen.kinds.host.where { form = yen.form.wsl; })
      (yen.kinds.mac.where { workstation = true; })
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
          settings.trusted-users = [
            "root"
            "@wheel"
          ];
          gc = pkgs.lib.optionalAttrs config.nix.enable {
            automatic = true;
            options = "--delete-older-than 7d";
          };
        };
      };
  };

  yen.aspects.nix-tuning = {
    at = yen.kinds.machine;
    os.nix.settings = {
      min-free = 128 * 1024 * 1024;
      max-free = 1024 * 1024 * 1024;
      connect-timeout = 5;
      fallback = true;
      builders-use-substitutes = true;
      log-lines = 25;
    };
  };
}
