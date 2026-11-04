# NixOS: the host kind, the nixos sink (hosts build with the `configurations` battery), `os` (fans out to nixos) and
# `account` (users.users entry). Two eval cost levers, off unless a host opts in: shared pkgs and trimmed modules.
{ yen, lib, ... }:
let
  inherit (yen.lib) within same opt;
  # trimmed NixOS base module lists per host, for one nixpkgs rev (method: ~/hk/yen/vic/modlist-research.md)
  modlists = import ./_modlists.nix;
  callable = m: builtins.isFunction m || (builtins.isAttrs m && m ? __functor);
  # users.users is a shorthand submodule (config only): resolve content fns and `imports` here.
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
  # shortcut: account content sees the OS module args (pkgs), not the users.users submodule config.
  asUser =
    user: ms:
    # deadnix: skip -- pkgs is unused here but must be declared so the module system passes it into `a`
    { lib, pkgs, ... }@a:
    {
      users.users.${user.name} = lib.mkMerge (map (resolve a) ms);
    };
  # trimmedModules: the host evaluates a smaller base module list (_modlists.nix), in module-list.nix order
  trimmedOf = host: host.trimmedModules && modlists ? ${host.name};
  # filter module-list.nix itself: path entries kept by the list, inline entries kept, order kept
  baseOf =
    np: host:
    let
      keep = lib.genAttrs (map (p: builtins.unsafeDiscardStringContext "${np}/nixos/modules/${p}") (
        modlists.${host.name} or [ ]
      )) (_: true); # keys only: attr names hold no context
    in
    lib.filter (p: !(builtins.isPath p) || keep ? ${builtins.unsafeDiscardStringContext (toString p)}) (
      import "${np}/nixos/modules/module-list.nix"
    );
  # the NixOS system of host from modules ms, with its channel; `full` ignores trimmedModules (the oracle build)
  buildOf =
    host: full: ms:
    host.channel.nixpkgs.lib.nixosSystem (
      {
        system = host.system.name;
        modules = ms;
      }
      // lib.optionalAttrs (trimmedOf host && !full) { baseModules = baseOf host.channel.nixpkgs host; }
    );
  # the first sharing host of the host's (channel, system), from the `shared-pkgs` elements es
  leaderOf =
    host: es:
    lib.head (
      lib.sort (a: b: a < b) (
        map (e: e.from.name) (
          lib.filter (e: same e.from.channel host.channel && same e.from.system host.system) es
        )
      )
    );
  isFollower = host: es: host.sharedPkgs && leaderOf host es != host.name;
  readOnlyOf = np: shared: [
    np.nixosModules.readOnlyPkgs
    { options.nixpkgs.system = np.lib.mkOption { internal = true; }; }
    {
      nixpkgs.pkgs = shared;
      nixpkgs.overlays = np.lib.mkForce shared.overlays;
      nixpkgs.config = np.lib.mkForce shared.config;
    }
  ];
  # the host's modules, with the leader's pkgs (read through the `out` arg, lazily) when it follows
  modulesOf =
    host: ms: out: es:
    ms
    ++ lib.optionals (isFollower host es) (
      readOnlyOf host.channel.nixpkgs out.nixosConfigurations.${leaderOf host es}.pkgs
    );
  # nixosConfigurations.<host>, built with the `configurations` battery
  systemOf =
    { out, shared-pkgs, ... }@args:
    yen.lib.batteries.configurations {
      from = yen.kinds.host.sinks.nixos;
      output = "nixosConfigurations";
      build = host: ms: buildOf host false (modulesOf host ms out shared-pkgs);
    } args;
  # the reference builds for the oracles, and the host's share record
  oraclesOf =
    {
      host,
      nixos,
      out,
      shared-pkgs,
      unfree ? [ ],
      ...
    }:
    {
      # a follower with its own pkgs, a trimmed host with the full list: each gives the same toplevel drvPath
      nixosConfigurationsOwnPkgs = lib.optionalAttrs (isFollower host shared-pkgs) {
        ${host.name} = buildOf host true nixos;
      };
      nixosConfigurationsFull = lib.optionalAttrs (trimmedOf host) {
        ${host.name} = buildOf host true (modulesOf host nixos out shared-pkgs);
      };
      sharedPkgs = lib.optionalAttrs host.sharedPkgs {
        ${host.name} = {
          leader = leaderOf host shared-pkgs;
          follower = isFollower host shared-pkgs;
          unfree = lib.sort lib.lessThan unfree;
        };
      };
    };
in
{
  yen.kinds.machine.fields = {
    # reuse the pkgs of the first sharing host on the same channel and system (nixpkgs readOnlyPkgs)
    sharedPkgs = opt lib.types.bool false;
    # evaluate only the base NixOS modules in _modlists.nix for this host (same toplevel drvPath)
    trimmedModules = opt lib.types.bool false;
  };

  # a host on shared pkgs keeps docs off: the manual, man pages and option help differ when pkgs is shared
  yen.aspects.shared-pkgs-no-docs = {
    at = yen.lib.all [
      yen.kinds.host
      (s: s.sharedPkgs)
    ];
    nixos.documentation = {
      enable = false;
      nixos.enable = false;
      man.enable = false;
    };
  };
  # the hosts on shared pkgs, at the fleet: a host reads its group through this sink, so the read is an edge
  yen.kinds.fleet.sinks.shared-pkgs.reduce = yen.lib.reduce.elements;
  yen.aspects.shared-pkgs = {
    at = yen.lib.all [
      yen.kinds.host
      (s: s.sharedPkgs)
    ];
    shared-pkgs = { host, ... }: host.name;
  };

  # a group shares one nixpkgs.config: a follower whose unfree names differ from its leader's is an error record
  # shortcut: compares the `unfree` sink only, not other nixpkgs.config keys a host module sets by hand
  yen.aspects.shared-pkgs-group = {
    at = yen.kinds.fleet;
    errors =
      { out, ... }:
      lib.concatLists (
        lib.mapAttrsToList (
          h: s:
          lib.optional (
            s.follower && s.unfree != out.sharedPkgs.${s.leader}.unfree
          ) "sharedPkgs: ${h} allows other unfree packages than its leader ${s.leader}"
        ) (out.sharedPkgs or { })
      );
  };

  yen.kinds.host = {
    fields = yen.kinds.machine.fields;
    spawns.user = yen.helpers.usersOf;
    sinks = {
      nixos.out =
        {
          scope,
          sinks,
          host,
          nixos,
          out,
          shared-pkgs,
          unfree ? [ ],
          ...
        }@args:
        systemOf args // oraclesOf args;
      os.nixos = yen.lib.batteries.imports { from = yen.kinds.host.sinks.os; };
    };
  };
  # a guest's os is its own NixOS, as on a host
  yen.kinds.guest.sinks.os.nixos = yen.lib.batteries.imports { from = yen.kinds.guest.sinks.os; };

  yen.kinds.user.sinks.account = {
    at = within yen.helpers.machines;
    os = { user, account, ... }: asUser user account;
  };
}
