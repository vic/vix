# Accounts: each user gets an account and home on its machine; admins join wheel; login shell is enabled.
{
  lib,
  yen,
  at,
  reduce,
  ...
}:
let
  inherit (yen.helpers) place;
  homeOf =
    user: scope: if (place scope).system.darwin then "/Users/${user.name}" else "/home/${user.name}";
  withShell = yen.kinds.user.where { shell = at.exists; };
  onLinux = at.under yen.kinds.linux;
  onMac = at.under yen.kinds.mac;
in
{
  yen.kinds.mac.sinks = {
    login-shells = {
      reduce = reduce.set;
      allowOrphan = true;
    };
    primary-user = {
      reduce = reduce.maybe;
      allowOrphan = true;
    };
  };

  yen.kinds.host.sinks.primary-user = {
    reduce = reduce.maybe;
    allowOrphan = true;
  };

  yen.aspects.account = {
    at = yen.kinds.user;
    account =
      { user, scope, ... }:
      {
        inherit (user) name;
        home = homeOf user scope;
      };
    homeManager =
      { user, scope, ... }:
      {
        home.username = user.name;
        home.homeDirectory = homeOf user scope;
      };
  };

  yen.aspects.nixos-account = {
    at = at.all [
      yen.kinds.user
      onLinux
    ];
    nixos =
      { user, ... }:
      {
        users.users.${user.name} = {
          isNormalUser = true;
          description = lib.mkDefault user.fullName;
        };
      };
  };

  yen.aspects.admin = {
    at = at.all [
      (yen.kinds.user.where { admin = true; })
      onLinux
    ];
    nixos =
      { user, ... }:
      {
        users.users.${user.name}.extraGroups = [ "wheel" ];
      };
    account.extraGroups = [ "networkmanager" ];
  };

  yen.aspects.primary-user = {
    at = at.all [
      (yen.kinds.user.where { admin = true; })
      onMac
    ];
    primary-user = { user, ... }: user.name;
  };

  yen.aspects.primary-user-darwin = {
    at = yen.kinds.mac;
    darwin =
      { primary-user, ... }:
      lib.optionalAttrs (primary-user != null) {
        system.primaryUser = primary-user;
      };
  };

  yen.aspects.login-shell = {
    at = withShell;
    homeManager = { user, ... }: { programs.${user.shell}.enable = true; };
  };

  yen.aspects.login-shell-nixos = {
    at = at.all [
      withShell
      onLinux
    ];
    nixos =
      { user, pkgs, ... }:
      {
        programs.${user.shell}.enable = true;
        users.users.${user.name}.shell = pkgs.${user.shell};
      };
  };

  yen.aspects.login-shell-darwin = {
    at = at.all [
      withShell
      onMac
    ];
    account = { user, pkgs, ... }: { shell = pkgs.${user.shell}; };
    login-shells = { user, ... }: user.shell;
  };

  yen.aspects.darwin-shells = {
    at = yen.kinds.mac;
    darwin =
      { login-shells, pkgs, ... }:
      {
        programs = lib.genAttrs login-shells (_: {
          enable = true;
        });
        environment.shells = map (s: pkgs.${s}) login-shells;
      };
  };
}
