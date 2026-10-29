# Accounts: each user gets an account and a home on its machine; admins join wheel; the login shell is enabled.
{ lib, yen, ... }:
let
  inherit (yen.helpers) place machines linux;
  inherit (yen.lib) all within;
  homeOf =
    user: scope: if (place scope).system.darwin then "/Users/${user.name}" else "/home/${user.name}";
  withShell = all [
    yen.kinds.user
    (s: s.shell != null)
  ];
in
{
  # the machine the user is on reads it
  yen.kinds.host.sinks.login-shells.reduce = yen.lib.reduce.set;
  yen.kinds.mac.sinks.login-shells.reduce = yen.lib.reduce.set;
  # an element is a user name
  yen.kinds.host.sinks.primary-user.reduce = yen.lib.reduce.one;
  yen.kinds.mac.sinks.primary-user.reduce = yen.lib.reduce.one;

  yen.aspects.account = {
    at = yen.kinds.user;
    account =
      { user, scope, ... }:
      {
        name = user.name;
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
    at = all [
      yen.kinds.user
      (within linux)
    ];
    account.isNormalUser = true;
  };
  yen.aspects.admin = {
    at = all [
      yen.kinds.user
      (within linux)
      (s: s.admin)
    ];
    account.extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  # the admin user a machine reads as its one primary user: two admins are an error record
  yen.aspects.primary-user = {
    at = all [
      yen.kinds.user
      (s: s.admin)
      (within yen.kinds.mac)
    ];
    primary-user = { user, ... }: user.name;
  };
  yen.aspects.primary-user-darwin = {
    at = yen.kinds.mac;
    darwin =
      { primary-user, ... }:
      lib.optionalAttrs (primary-user != null) { system.primaryUser = primary-user; };
  };
  yen.aspects.login-shell = {
    at = withShell;
    account = { user, pkgs, ... }: { shell = pkgs.${user.shell}; };
    homeManager = { user, ... }: { programs.${user.shell}.enable = true; };
    login-shells = { user, ... }: user.shell;
  };
  yen.aspects.login-shells = {
    at = machines;
    os = { login-shells, ... }: {
      programs = lib.genAttrs login-shells (_: {
        enable = true;
      });
    };
  };
  yen.aspects.darwin-shells = {
    at = yen.kinds.mac;
    darwin = { login-shells, pkgs, ... }: { environment.shells = map (s: pkgs.${s}) login-shells; };
  };
}
