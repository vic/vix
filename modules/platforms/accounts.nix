# Accounts: each user gets an account and a home on its machine; admins join wheel; the login shell is enabled.
# On NixOS the batteries of yen.lib.batteries.nixos write them (define-user, primary-user, user-shell); a user has no
# nixos sink, so its nixos keys go up to its host or guest. On a mac the `account` sink and darwin.primary-user do.
{ lib, yen, ... }:
let
  inherit (yen.helpers) place linux;
  inherit (yen.lib) all within;
  inherit (yen.lib.batteries) nixos darwin;
  homeOf =
    user: scope: if (place scope).system.darwin then "/Users/${user.name}" else "/home/${user.name}";
  withShell = all [
    yen.kinds.user
    (s: s.shell != null)
  ];
  onLinux = within linux;
  onMac = within yen.kinds.mac;
in
{
  yen.kinds.mac.sinks.login-shells.reduce = yen.lib.reduce.set; # the mac lists its users' shells in environment.shells
  # an element is a user name: the one admin of a mac (system.primaryUser) or of a wsl host (wsl.defaultUser)
  yen.kinds.host.sinks.primary-user.reduce = yen.lib.reduce.one;
  yen.kinds.mac.sinks.primary-user.reduce = yen.lib.reduce.one;

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
    at = all [
      yen.kinds.user
      onLinux
    ];
    nixos = nixos.define-user;
  };
  yen.aspects.admin = {
    at = all [
      yen.kinds.user
      onLinux
      (s: s.admin)
    ];
    nixos = nixos.primary-user { };
    account.extraGroups = [ "networkmanager" ];
  };
  # the admin user a mac reads as its one primary user: two admins are an error record
  yen.aspects.primary-user = {
    at = all [
      yen.kinds.user
      (s: s.admin)
      onMac
    ];
    primary-user = { user, ... }: user.name;
  };
  yen.aspects.primary-user-darwin = {
    at = yen.kinds.mac;
    darwin =
      { scope, primary-user, ... }@args:
      lib.optionalAttrs (primary-user != null) (darwin.primary-user { user = _: primary-user; } args);
  };
  yen.aspects.login-shell = {
    at = withShell;
    homeManager = { user, ... }: { programs.${user.shell}.enable = true; };
  };
  yen.aspects.login-shell-nixos = {
    at = all [
      withShell
      onLinux
    ];
    nixos = nixos.user-shell { shell = u: u.shell; };
  };
  yen.aspects.login-shell-darwin = {
    at = all [
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
