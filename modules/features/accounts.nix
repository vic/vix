# Accounts: each user gets an account and a home on its machine; admins join wheel; the login shell is enabled.
{ lib, ren, ... }:
let
  inherit (ren.helpers) place;
  inherit (ren.lib)
    and
    anyOf
    within
    when
    ;
  homeOf =
    user: parent: if (place parent).system.darwin then "/Users/${user.name}" else "/home/${user.name}";
  withShell = and [
    ren.kinds.user
    (when (s: s.user.shell != null))
  ];
in
{
  ren.channels.login-shells = {
    fold = ren.lib.fold.set;
    at = and [
      withShell
      (within ren.kinds.machine)
    ];
    to = e: ren.lib.has e; # the machine the user is on
  };

  ren.aspects.account = {
    at = ren.kinds.user;
    account =
      { user, parent, ... }:
      {
        name = user.name;
        home = homeOf user parent;
      };
    homeManager =
      { user, parent, ... }:
      {
        home.username = user.name;
        home.homeDirectory = homeOf user parent;
      };
  };
  ren.aspects.nixos-account = {
    at = and [
      ren.kinds.user
      (within ren.kinds.host)
    ];
    account.isNormalUser = true;
  };
  ren.aspects.admin = {
    at = and [
      ren.kinds.user
      (within ren.kinds.host)
      (when (s: s.user.admin))
    ];
    account.extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  ren.aspects.primary-user = {
    at = ren.lib.and [
      ren.kinds.mac
      (ren.lib.has (
        ren.lib.and [
          ren.kinds.user
          (ren.lib.when (s: s.user.admin))
        ]
      ))
    ]; # macs with an admin user
    darwin = { mac, ... }: {
      system.primaryUser = (builtins.head (builtins.filter (u: u.admin) mac.users)).name;
    };
  };
  ren.aspects.login-shell = {
    at = withShell;
    account = { user, pkgs, ... }: { shell = pkgs.${user.shell}; };
    homeManager = { user, ... }: { programs.${user.shell}.enable = true; };
    login-shells = { user, ... }: user.shell;
  };
  ren.aspects.login-shells = {
    at = anyOf [
      ren.kinds.host
      ren.kinds.mac
    ];
    os = { login-shells, ... }: {
      programs = lib.genAttrs login-shells (_: {
        enable = true;
      });
    };
  };
  ren.aspects.darwin-shells = {
    at = ren.kinds.mac;
    darwin = { login-shells, pkgs, ... }: { environment.shells = map (s: pkgs.${s}) login-shells; };
  };
}
