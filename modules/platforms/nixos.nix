# NixOS: the host kind, the nixos class (metal hosts build; guests forward into their host), `os` and `account` (users.users entry).
{
  ren,
  lib,
  usersOf,
  ...
}:
let
  inherit (ren.lib) and within not;
  metal = and [
    ren.kinds.host
    (not ren.kinds.guest)
  ]; # physical nixos hosts
  guestsOf = h: lib.filterAttrs (_: g: ren.lib.same g.on h) ren.guest; # h: a host instance
  callable = m: builtins.isFunction m || (builtins.isAttrs m && m ? __functor);
  # shortcut: account content sees the OS module args (pkgs), not the users.users submodule config.
  asUser =
    user: ms:
    # deadnix: skip -- pkgs is unused here but must be declared so the module system passes it into `a`
    { lib, pkgs, ... }@a:
    {
      users.users.${user.name} = lib.mkMerge (map (m: if callable m then m a else m) ms); # shorthand submodule: no imports
    };
in
{
  _module.args = {
    inherit metal guestsOf;
  };

  ren.kinds.host = {
    is = ren.kinds.machine;
    below = [
      ren.kinds.user
      ren.kinds.guest
    ];
    spawns.user = s: usersOf s.host;
    spawns.guest = s: guestsOf s.host;
  };

  ren.classes.nixos = [
    {
      at = metal;
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
