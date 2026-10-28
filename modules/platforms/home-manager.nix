# home-manager: the homeManager sink (users on hosts, guests, macs and standalone homes), its platform sub-sinks,
# the standalone home kind, and the hm module on machines that have users.
{ sven, lib, ... }:
let
  inherit (sven.lib)
    all
    within
    has
    opt
    ;
  inherit (sven.helpers) place linux;
  user = sven.kinds.user;
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
  sven.kinds.home = {
    fields = {
      user = user;
      system = sven.kinds.system;
      channel = opt sven.kinds.channel sven.channel.unstable;
      # the host this home lives on (Den #739): it reads the host's data, and builds its own homeConfigurations
      on = sven.lib.maybe sven.kinds.host;
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
  sven.kinds.host.spawns.home =
    s: lib.filterAttrs (_: h: h.on != null && sven.lib.same h.on s) sven.home;

  sven.kinds.user.sinks = {
    homeManager = {
      at = within sven.helpers.places;
      os = { user, homeManager, ... }: { home-manager.users.${user.name}.imports = homeManager; };
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
        lib.optionalAttrs (p.kind == "home" || p.kind != "mac" && !(sven.home ? ${p.name})) {
          homeConfigurations."${user.name}@${p.name}" = p.channel.home-manager.lib.homeManagerConfiguration {
            pkgs = sven.helpers.pkgsOf p;
            modules = homeManager;
          };
        };
    };
    homeLinux = {
      at = sven.aspects.on-linux;
      homeManager = { homeLinux, ... }: { imports = homeLinux; };
    };
    homeDarwin = {
      at = sven.aspects.on-darwin;
      homeManager = { homeDarwin, ... }: { imports = homeDarwin; };
    };
  };

  sven.aspects.hm-nixos = {
    at = all [
      linux
      (has user)
    ];
    nixos = { scope, ... }: { imports = [ scope.channel.home-manager.nixosModules.home-manager ]; };
  };
  sven.aspects.hm-darwin = {
    at = all [
      sven.kinds.mac
      (has user)
    ];
    darwin = { mac, ... }: { imports = [ mac.channel.home-manager.darwinModules.home-manager ]; };
  };

  sven.aspects.on-linux.at = onDarwin false;
  sven.aspects.on-darwin.at = onDarwin true;
}
