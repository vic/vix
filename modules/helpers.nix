# vix helpers: pure values every fleet file reads as `yen.helpers`.
{ yen, lib, ... }:
let
  inherit (yen.lib) is all;
in
{
  yen.helpers = {
    # types with a strict check: lib.types.listOf and attrsOf only test the container
    listOf = t: is (v: lib.isList v && lib.all t.check v);
    attrsOf = t: is (v: lib.isAttrs v && lib.all t.check (lib.attrValues v));
    enum = xs: is (v: lib.elem v xs);
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
    # unfree sink element: `unfree = yen.helpers.allowUnfree [ "name" ];`
    allowUnfree = names: lib.genAttrs names (_: true);
    # each flake's outputs for the system of `pkgs`: `(yen.helpers.perSystem pkgs inputs.jjui).packages.jjui`
    perSystem = pkgs: builtins.mapAttrs (_: v: v.${pkgs.stdenv.hostPlatform.system} or v);
    # sink reduce for list elements: unique concat in first-seen order, as `lib.unique (concatLists ..)`
    flat = {
      name = "flat";
      __functor = _: es: {
        value = lib.unique (lib.concatMap (e: e.value) es);
        errors = [ ];
      };
    };
    # sops-nix `secrets` from secret instances; `deploy = false` ones stay out
    sopsSecrets =
      ss:
      lib.listToAttrs (
        map (
          s:
          lib.nameValuePair s.sopsKey (
            # named fields only: an instance also carries scope keys (key, path, ...)
            lib.filterAttrs (_: v: v != null) {
              inherit (s) format sopsFile;
              path = s.sopsPath;
            }
          )
        ) (lib.filter (s: s.deploy) ss)
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
