# vix helpers: pure values every fleet file reads as `yen.helpers`.
{
  yen,
  at,
  lib,
  ...
}:
let
  placeKinds = [
    "host"
    "guest"
    "mac"
    "home"
  ];
in
{
  yen.helpers = {
    # Nearest machine or home, ancestor-or-self; null at a scope above them
    place = s: lib.findFirst (anc: builtins.elem (lib.last anc.kind) placeKinds) null s.rup;
    # A machine's users by name (`spawns.user` of host, guest, mac)
    usersOf = m: lib.listToAttrs (map (u: lib.nameValuePair u.name u) m.users);
    # This flake's own packages for the system of `pkgs`
    own = out: pkgs: out.packages.${pkgs.stdenv.hostPlatform.system};
    # Each flake's outputs for the system of `pkgs`
    perSystem = pkgs: builtins.mapAttrs (_: v: v.${pkgs.stdenv.hostPlatform.system} or v);
    # sops-nix `secrets` of the secret refs `rs`, their data read from the root `sops` sink
    sopsSecrets =
      sops: rs:
      lib.listToAttrs (
        map (
          s:
          lib.nameValuePair s.sopsKey (
            lib.filterAttrs (_: v: v != null) (
              {
                inherit (s) sopsFile;
                path = s.sopsPath;
              }
              // lib.optionalAttrs (s.format != null) { format = s.format.name; }
            )
          )
        ) (lib.filter (s: s.deploy) (map (r: sops.${r.name}) rs))
      );
    # nixpkgs of a machine or home: its channel, its system
    pkgsOf = m: m.channel.nixpkgs.legacyPackages.${m.system.name};
    # Declarative Datalog selectors for vim features and env languages (ref-typed!)
    vimHas = f: yen.kinds.vim.where { features = at.contains f; };
    envHas = l: yen.kinds.env.where { langs = at.contains l; };
  };
}
