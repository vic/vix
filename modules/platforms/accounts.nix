# Accounts: each user gets an account and a home on its machine; admins join wheel; the login shell is enabled.
{ lib, sven, ... }:
let
  inherit (sven.helpers) place machines linux;
  inherit (sven.lib) all within;
  homeOf =
    user: scope: if (place scope).system.darwin then "/Users/${user.name}" else "/home/${user.name}";
  withShell = all [
    sven.kinds.user
    (s: s.shell != null)
  ];
in
{
  # the machine the user is on reads it
  sven.kinds.host.sinks.login-shells.reduce = sven.lib.reduce.set;
  sven.kinds.mac.sinks.login-shells.reduce = sven.lib.reduce.set;
  # an element is a user name
  sven.kinds.host.sinks.primary-user.reduce = sven.lib.reduce.one;
  sven.kinds.mac.sinks.primary-user.reduce = sven.lib.reduce.one;

  sven.aspects.account = {
    at = sven.kinds.user;
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
  sven.aspects.nixos-account = {
    at = all [
      sven.kinds.user
      (within linux)
    ];
    account.isNormalUser = true;
  };
  sven.aspects.admin = {
    at = all [
      sven.kinds.user
      (within linux)
      (s: s.admin)
    ];
    account.extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  # the admin user a machine reads as its one primary user: two admins are an error record
  sven.aspects.primary-user = {
    at = all [
      sven.kinds.user
      (s: s.admin)
      (within sven.kinds.mac)
    ];
    primary-user = { user, ... }: user.name;
  };
  sven.aspects.primary-user-darwin = {
    at = sven.kinds.mac;
    darwin =
      { primary-user, ... }:
      lib.optionalAttrs (primary-user != null) { system.primaryUser = primary-user; };
  };
  sven.aspects.login-shell = {
    at = withShell;
    account = { user, pkgs, ... }: { shell = pkgs.${user.shell}; };
    homeManager = { user, ... }: { programs.${user.shell}.enable = true; };
    login-shells = { user, ... }: user.shell;
  };
  sven.aspects.login-shells = {
    at = machines;
    os = { login-shells, ... }: {
      programs = lib.genAttrs login-shells (_: {
        enable = true;
      });
    };
  };
  sven.aspects.darwin-shells = {
    at = sven.kinds.mac;
    darwin = { login-shells, pkgs, ... }: { environment.shells = map (s: pkgs.${s}) login-shells; };
  };
}
