# NixOS: the host kind, the nixos class (metal hosts build; guests forward into their host), `os` and `account` (users.users entry).
{
  ren,
  ...
}:
let
  vix = ren.helpers;
  inherit (ren.lib) and within not;
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
  ren.aspects.metal.at = and [
    ren.kinds.host
    (not ren.kinds.guest)
  ]; # physical nixos hosts

  ren.kinds.host = {
    is = ren.kinds.machine;
    below = [ ren.kinds.user ];
    spawns.user = s: vix.usersOf s.host;
  };

  ren.classes.nixos = [
    {
      at = ren.aspects.metal;
      into = { host, ... }: ms: {
        nixosConfigurations.${host.name} = host.channel.nixpkgs.lib.nixosSystem {
          system = host.system.name;
          modules = ms;
        };
      };
    }
    {
      at = ren.kinds.guest; # forwards into its host's microvm.vms
      into = { guest, ... }: ms: {
        nixos.microvm.vms.${guest.name} = {
          pkgs = null; # microvm instantiates nixpkgs from the guest config, so unfree.nix applies
          nixpkgs = guest.channel.nixpkgs; # shortcut: built for the host system; set guest system when one differs
          config.imports = ms;
        };
      };
    }
  ];

  ren.classes.os = [
    {
      at = ren.kinds.host;
      into = { ... }: ms: { nixos.imports = ms; };
    }
    {
      at = ren.kinds.mac;
      into = { ... }: ms: { darwin.imports = ms; };
    }
  ];

  ren.classes.account = [
    {
      at = and [
        ren.kinds.user
        (within ren.kinds.host)
      ];
      into = { user, ... }: ms: { nixos = asUser user ms; };
    }
    {
      at = and [
        ren.kinds.user
        (within ren.kinds.mac)
      ];
      into = { user, ... }: ms: { darwin = asUser user ms; };
    }
  ];
}
