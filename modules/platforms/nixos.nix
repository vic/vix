# NixOS: the host kind, nixos/os/account sinks, and opt-in sharedPkgs leader/follower deduplication.
{
  yen,
  at,
  reduce,
  lib,
  ...
}:
let
  callable = m: builtins.isFunction m || (builtins.isAttrs m && m ? __functor);
  resolve =
    a: m:
    if callable m then
      resolve a (m a)
    else if builtins.isAttrs m && m ? imports then
      a.lib.mkMerge (
        [
          (removeAttrs m [
            "imports"
            "_file"
            "key"
          ])
        ]
        ++ map (resolve a) m.imports
      )
    else
      m;
  asUser =
    user: ms:
    {
      lib,
      pkgs,
      ...
    }@a:
    {
      users.users.${user.name} = lib.mkMerge (map (resolve a) ms);
    };
  buildOf =
    host: ms:
    host.channel.nixpkgs.lib.nixosSystem {
      system = host.system.name;
      modules = ms;
    };
  leaderOf =
    host: es:
    lib.head (
      lib.sort (a: b: a < b) (
        map (e: e.value.name) (
          lib.filter (
            e: yen.lib.same e.value.channel host.channel && yen.lib.same e.value.system host.system
          ) es
        )
      )
    );
  isFollower = host: es: host.sharedPkgs && es != [ ] && leaderOf host es != host.name;
  readOnlyOf = np: shared: [
    np.nixosModules.readOnlyPkgs
    { options.nixpkgs.system = np.lib.mkOption { internal = true; }; }
    {
      nixpkgs.pkgs = shared;
      nixpkgs.overlays = np.lib.mkForce shared.overlays;
      nixpkgs.config = np.lib.mkForce shared.config;
    }
  ];
  modulesOf =
    host: ms: out: es:
    ms
    ++ lib.optionals (isFollower host es) (
      readOnlyOf host.channel.nixpkgs out.nixosConfigurations.${leaderOf host es}.pkgs
    );
in
{
  yen.aspects.shared-pkgs-no-docs = {
    at = yen.kinds.host.where { sharedPkgs = true; };
    nixos.documentation = {
      enable = false;
      nixos.enable = false;
      man.enable = false;
    };
  };

  yen.kinds.root.sinks.shared-pkgs = {
    reduce = reduce.elements;
    allowOrphan = true;
  };

  yen.aspects.shared-pkgs = {
    at = yen.kinds.host.where { sharedPkgs = true; };
    shared-pkgs =
      { host, ... }:
      {
        inherit (host) name channel system;
      };
  };

  yen.aspects.shared-pkgs-group = {
    at = yen.root;
    errors =
      { out, ... }:
      lib.concatLists (
        lib.mapAttrsToList (
          h: s:
          lib.optional (
            s.follower && !lib.all (n: lib.elem n out.sharedPkgs.${s.leader}.unfree) s.unfree
          ) "sharedPkgs: ${h} names unfree packages its leader ${s.leader} does not allow"
        ) (out.sharedPkgs or { })
      );
  };

  yen.kinds.machine.sinks.os = {
    reduce = reduce.modules;
    allowOrphan = true;
  };

  yen.kinds.linux.sinks = {
    nixos = {
      reduce = reduce.modules;
      allowOrphan = true;
    };
    os.into.nixos = { os, ... }: yen.lib.many os;
  };

  yen.kinds.host = {
    spawns.user = yen.helpers.usersOf;
    sinks.nixos.into.out =
      {
        host,
        nixos,
        out,
        shared-pkgs ? [ ],
        unfree ? [ ],
        ...
      }:
      {
        nixosConfigurations.${host.name} = buildOf host (modulesOf host nixos out shared-pkgs);
      }
      // lib.optionalAttrs (isFollower host shared-pkgs) {
        nixosConfigurationsOwnPkgs.${host.name} = buildOf host nixos;
      }
      // lib.optionalAttrs host.sharedPkgs {
        sharedPkgs.${host.name} = {
          leader = leaderOf host shared-pkgs;
          follower = isFollower host shared-pkgs;
          unfree = lib.sort lib.lessThan unfree;
        };
      };
  };

  yen.kinds.user.sinks.account = {
    at = at.under yen.kinds.machine;
    reduce = reduce.modules;
    allowOrphan = true;
    intoParent.os = { user, account, ... }: asUser user account;
  };
}
