# installer-base: the iso image base (installer cd) plus live-session users, on iso hosts.
{ yen, at, ... }:
{
  yen.aspects.installer-base = {
    at = yen.aspects.installer;
    nixos =
      {
        lib,
        modulesPath,
        config,
        ...
      }:
      {
        imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix" ];

        users.users.nixos.uid = 1001;

        isoImage.edition = lib.mkDefault config.networking.hostName;
        networking.wireless.enable = lib.mkImageMediaOverride false;
      };
  };

  yen.aspects.installer-user = {
    at = at.all [
      yen.kinds.user
      (at.under yen.aspects.installer-base)
    ];
    account.uid = 1000;
    os =
      { user, ... }:
      {
        lib.isoFileSystems."/home/${user.name}" = {
          device = "/dev/disk/by-label/${user.name}";
          fsType = "ext4";
        };
      };
  };
}
