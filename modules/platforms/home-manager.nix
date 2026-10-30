# home-manager: the homeManager sink (users on hosts, guests, macs and standalone homes), its platform sub-sinks,
# the standalone home kind, and the hm module on machines that have users.
{ yen, lib, ... }:
let
  inherit (yen.lib)
    all
    within
    has
    opt
    ;
  inherit (yen.helpers) place linux;
  user = yen.kinds.user;
  # a user on a darwin (or linux) machine or home
  onDarwin =
    d:
    all [
      user
      (
        s:
        let
          p = place s;
        in
        p != null && p.system.darwin == d
      )
    ];
in
{
  yen.kinds.home = {
    fields = {
      user = user;
      system = yen.kinds.system;
      channel = opt yen.kinds.channel yen.channel.unstable;
      # the host this home lives on (Den #739): it reads the host's data, and builds its own homeConfigurations
      on = yen.lib.maybe yen.kinds.host;
    };
    spawns.user = s: { ${s.user.name} = s.user; };
    # walls: a home's users never write the system of a host above it (a sink with no keys stops elements)
    sinks = lib.genAttrs [
      "nixos"
      "os"
      "login-shells"
      "nix-features"
      "persist"
      "ports"
      "primary-user"
      "secrets"
      "unfree"
    ] (_: { });
  };
  yen.kinds.host.spawns.home =
    s: lib.filterAttrs (_: h: h.on != null && yen.lib.same h.on s) yen.home;

  yen.kinds.user.sinks = {
    homeManager = {
      at = within yen.helpers.places;
      os = yen.lib.batteries.home-manager.into-host { from = yen.kinds.user.sinks.homeManager; };
      # the same modules also build standalone as `homeConfigurations."<user>@<place>"` (not on macs)
      out =
        {
          user,
          scope,
          homeManager,
          ...
        }:
        let
          p = place scope;
        in
        # a declared home owns its name: host nargun's user would clash with home nargun (vix: fold conflict)
        lib.optionalAttrs (p.kind == "home" || p.kind != "mac" && !(yen.home ? ${p.name})) {
          homeConfigurations."${user.name}@${p.name}" = p.channel.home-manager.lib.homeManagerConfiguration {
            pkgs = yen.helpers.pkgsOf p;
            modules = homeManager;
          };
        };
    };
    homeLinux = {
      at = yen.aspects.on-linux;
      homeManager = { homeLinux, ... }: { imports = homeLinux; };
    };
    homeDarwin = {
      at = yen.aspects.on-darwin;
      homeManager = { homeDarwin, ... }: { imports = homeDarwin; };
    };
  };

  yen.aspects.hm-nixos = {
    at = all [
      linux
      (has user)
    ];
    nixos = { scope, ... }: { imports = [ scope.channel.home-manager.nixosModules.home-manager ]; };
  };
  yen.aspects.hm-darwin = {
    at = all [
      yen.kinds.mac
      (has user)
    ];
    darwin = { mac, ... }: { imports = [ mac.channel.home-manager.darwinModules.home-manager ]; };
  };

  yen.aspects.on-linux.at = onDarwin false;
  yen.aspects.on-darwin.at = onDarwin true;
}
