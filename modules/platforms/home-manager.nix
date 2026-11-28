# home-manager: walled standalone `home` kind (`wall = true` replaces 8-sink string walls!),
# `homeManager` + `homeLinux`/`homeDarwin` sinks, and pure-Datalog `at.nearest` platform selectors.
{
  yen,
  at,
  types,
  reduce,
  lib,
  ...
}:
let
  inherit (yen.helpers) place;
in
{
  yen.kinds.home = {
    extends = yen.kinds.place;
    wall = true;
    passUp = [
      yen.kinds.root.sinks.out
      yen.kinds.root.sinks.checks
      yen.kinds.root.sinks.flake-file
      yen.kinds.root.sinks.ci-jobs
      yen.kinds.root.sinks.served
    ];
    fields = {
      user = yen.kinds.user;
      on = types.maybe yen.kinds.host;
      graphical = types.opt types.bool false;
    };
    spawns.user = s: { ${s.user.name} = s.user; };
  };

  yen.kinds.host.spawns.home = yen.lib.pointing yen.kinds.home.fields.on yen.home;

  yen.kinds.user.sinks = {
    homeManager = {
      at = at.under yen.kinds.place;
      reduce = reduce.modules;
      allowOrphan = true;
      intoParent.os =
        { user, homeManager, ... }:
        {
          home-manager.users.${user.name}.imports = homeManager;
        };
      into.out =
        {
          user,
          scope,
          homeManager,
          ...
        }:
        (
          p:
          lib.optionalAttrs
            (p != null && (lib.last p.kind == "home" || (lib.last p.kind != "mac" && !(yen.home ? ${p.name}))))
            {
              homeConfigurations."${user.name}@${p.name}" = p.channel.home-manager.lib.homeManagerConfiguration {
                pkgs = yen.helpers.pkgsOf p;
                modules = homeManager;
              };
            }
        )
          (place scope);
    };
    homeLinux = {
      at = yen.aspects.on-linux;
      reduce = reduce.modules;
      allowOrphan = true;
      into.homeManager = { homeLinux, ... }: yen.lib.many homeLinux;
    };
    homeDarwin = {
      at = yen.aspects.on-darwin;
      reduce = reduce.modules;
      allowOrphan = true;
      into.homeManager = { homeDarwin, ... }: yen.lib.many homeDarwin;
    };
  };

  yen.aspects.hm-nixos = {
    at = at.all [
      yen.kinds.linux
      (at.has yen.kinds.user)
    ];
    nixos = { scope, ... }: { imports = [ scope.channel.home-manager.nixosModules.home-manager ]; };
  };

  yen.aspects.hm-darwin = {
    at = at.all [
      yen.kinds.mac
      (at.has yen.kinds.user)
    ];
    darwin = { mac, ... }: { imports = [ mac.channel.home-manager.darwinModules.home-manager ]; };
  };

  yen.aspects.on-linux.at = at.all [
    yen.kinds.user
    (at.nearest yen.kinds.place (yen.kinds.place.where { system.darwin = false; }))
  ];
  yen.aspects.on-darwin.at = at.all [
    yen.kinds.user
    (at.nearest yen.kinds.place (yen.kinds.place.where { system.darwin = true; }))
  ];
}
