# NixOS: the host kind, the nixos sink (hosts build), `os` (fans out to nixos) and `account` (users.users entry).
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
in
{
  # eval cost levers (yen fleet G:450-481): both off unless a host opts in
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
          host,
          nixos,
          out,
          unfree ? { },
          ...
        }:
        let
          np = host.channel.nixpkgs;
          trimmed = host.trimmedModules && modlists ? ${host.name};
          # filter module-list.nix itself: path entries kept by the list, inline entries kept, order kept
          keep = lib.genAttrs (map (p: builtins.unsafeDiscardStringContext "${np}/nixos/modules/${p}") (
            modlists.${host.name} or [ ]
          )) (_: true);
          base = lib.filter (
            p: !(builtins.isPath p) || keep ? ${builtins.unsafeDiscardStringContext (toString p)}
          ) (import "${np}/nixos/modules/module-list.nix");
          build' =
            full: ms:
            np.lib.nixosSystem (
              {
                system = host.system.name;
                modules = ms;
              }
              // lib.optionalAttrs (trimmed && !full) { baseModules = base; }
            );
          group = lib.sort (a: b: a < b) (
            lib.attrNames (
              lib.filterAttrs (
                _: h: h.sharedPkgs && same h.channel host.channel && same h.system host.system
              ) yen.host
            )
          );
          leader = lib.head group;
          follower = host.sharedPkgs && leader != host.name;
          shared = out.nixosConfigurations.${leader}.pkgs;
          readOnly = [
            np.nixosModules.readOnlyPkgs
            { options.nixpkgs.system = np.lib.mkOption { internal = true; }; }
            {
              nixpkgs.pkgs = shared;
              nixpkgs.overlays = np.lib.mkForce shared.overlays;
              nixpkgs.config = np.lib.mkForce shared.config;
            }
          ];
        in
        {
          nixosConfigurations.${host.name} = build' false (nixos ++ lib.optionals follower readOnly);
          # reference builds for the oracles: a follower with its own pkgs, a trimmed host with the full list
          nixosConfigurationsOwnPkgs = lib.optionalAttrs follower { ${host.name} = build' true nixos; };
          nixosConfigurationsFull = lib.optionalAttrs trimmed {
            ${host.name} = build' true (nixos ++ lib.optionals follower readOnly);
          };
          sharedPkgs = lib.optionalAttrs host.sharedPkgs {
            ${host.name} = {
              inherit leader follower;
              unfree = lib.attrNames unfree;
            };
          };
        };
      os.nixos = { os, ... }: { imports = os; };
    };
  };

  yen.kinds.user.sinks.account = {
    at = within yen.helpers.machines;
    os = { user, account, ... }: asUser user account;
  };
}
