# NixOS: the host kind, the nixos class, `os` (either OS) and `account` (a user's users.users entry).
{ ren, usersOf, ... }:
let
  inherit (ren.lib) and within;
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
  ren.kinds.host = {
    is = ren.kinds.machine;
    below = [ ren.kinds.user ];
    spawns.user = s: usersOf s.host;
  };

  ren.classes.nixos = {
    at = ren.kinds.host;
    into = { host, ... }: ms: {
      nixosConfigurations.${host.name} = host.channel.nixpkgs.lib.nixosSystem {
        system = host.system.name;
        modules = ms;
      };
    };
  };

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
