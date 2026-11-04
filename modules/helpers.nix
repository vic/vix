# vix helpers: pure values every fleet file reads as `yen.helpers`.
{ yen, lib, ... }:
let
  inherit (yen.lib) all;
in
{
  yen.helpers = {
    # Ren `is`: a guest is a host, and host, guest and mac are machines
    machines = [
      yen.kinds.host
      yen.kinds.guest
      yen.kinds.mac
    ];
    linux = [
      yen.kinds.host
      yen.kinds.guest
    ];
    places = yen.helpers.machines ++ [ yen.kinds.home ];
    # nearest machine or home, ancestor-or-self; null at a scope above them
    place =
      s:
      lib.findFirst (
        x:
        lib.elem x.kind [
          "host"
          "guest"
          "mac"
          "home"
        ]
      ) null s.rup;
    # a machine's users by name (spawns.user of host, guest, mac)
    usersOf = m: lib.listToAttrs (map (u: lib.nameValuePair u.name u) m.users);
    # each flake's outputs for the system of `pkgs`: `(yen.helpers.perSystem pkgs inputs.jjui).packages.jjui`
    perSystem = pkgs: builtins.mapAttrs (_: v: v.${pkgs.stdenv.hostPlatform.system} or v);
    # sops-nix `secrets` of the secret refs rs, their data read from the fleet `sops` sink; `deploy = false` ones stay out
    sopsSecrets =
      sops: rs:
      lib.listToAttrs (
        map (
          s:
          lib.nameValuePair s.sopsKey (
            # named fields only
            lib.filterAttrs (_: v: v != null) {
              inherit (s) format sopsFile;
              path = s.sopsPath;
            }
          )
        ) (lib.filter (s: s.deploy) (map (r: sops.${r.name}) rs))
      );
    # nixpkgs of a machine or home: its channel, its system
    pkgsOf = m: m.channel.nixpkgs.legacyPackages.${m.system.name};
    # a predicate runs at every scope: test the kind first
    vimHas =
      f:
      all [
        yen.kinds.vim
        (s: lib.elem f s.features)
      ];
    envHas =
      l:
      all [
        yen.kinds.env
        (s: lib.elem l s.langs)
      ];
  };
}
