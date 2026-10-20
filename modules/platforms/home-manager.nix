# home-manager: the homeManager class (on hosts, macs and standalone homes), its platform sub-classes,
# the standalone home kind, and the hm module on machines that have users.
{
  ren,
  ...
}:
let
  vix = ren.helpers;
  inherit (ren.lib)
    and
    within
    has
    when
    ;
  user = ren.kinds.user;
  inPlace = { ... }: ms: { homeManager.imports = ms; }; # a sub-class, forwarded in place
  # a user on a darwin (or linux) machine or home
  onDarwin =
    d:
    and [
      user
      (when (s: vix.place s != null && (vix.place s).system.darwin == d))
    ];
in
{
  ren.kinds.home = {
    below = [ user ];
    spawns.user = s: { ${s.home.user.name} = s.home.user; };
    user = user;
    system = ren.kinds.system;
    channel = vix.opt ren.kinds.channel ren.channel.unstable;
  };

  ren.classes.homeManager = [
    {
      at = and [
        user
        (within ren.kinds.host)
      ];
      into = { user, ... }: ms: { nixos.home-manager.users.${user.name}.imports = ms; };
    }
    {
      at = and [
        user
        (within ren.kinds.mac)
      ];
      into = { user, ... }: ms: { darwin.home-manager.users.${user.name}.imports = ms; };
    }
    {
      at = and [
        user
        (within ren.kinds.home)
      ];
      into = { home, user, ... }: ms: {
        homeConfigurations."${user.name}@${home.name}" =
          home.channel.home-manager.lib.homeManagerConfiguration
            {
              pkgs = home.channel.nixpkgs.legacyPackages.${home.system.name};
              modules = ms;
            };
      };
    }
  ];
  ren.classes.homeLinux = {
    at = and [
      user
      ren.aspects.on-linux
    ];
    into = inPlace;
  };
  ren.classes.homeDarwin = {
    at = and [
      user
      ren.aspects.on-darwin
    ];
    into = inPlace;
  };

  ren.aspects.hm-nixos = {
    at = and [
      ren.kinds.host
      (has user)
    ];
    nixos = { host, ... }: { imports = [ host.channel.home-manager.nixosModules.home-manager ]; };
  };
  ren.aspects.hm-darwin = {
    at = and [
      ren.kinds.mac
      (has user)
    ];
    darwin = { mac, ... }: { imports = [ mac.channel.home-manager.darwinModules.home-manager ]; };
  };

  ren.aspects.on-linux.at = onDarwin false;
  ren.aspects.on-darwin.at = onDarwin true;
}
