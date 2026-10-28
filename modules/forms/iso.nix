# installer-base: the iso image base (installer cd) plus live-session users, on iso hosts.
{ sven, ... }:
{
  sven.aspects.installer-base = {
    at = sven.lib.all [
      sven.helpers.linux
      (s: s.form == "iso")
    ];
    nixos =
      {
        lib,
        modulesPath,
        config,
        ...
      }:
      {
        imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix" ];

        system.stateVersion = "26.05";

        users.users.nixos.uid = 1001;

        isoImage.edition = lib.mkDefault config.networking.hostName;
        networking.networkmanager.enable = true;
        networking.wireless.enable = lib.mkImageMediaOverride false;

        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;
        services.blueman.enable = true;
        services.pulseaudio.enable = false;
      };
  };

  # the live session's users: home partition by label, fixed uid.
  sven.aspects.installer-user = {
    at = sven.lib.all [
      sven.kinds.user
      (sven.lib.within sven.aspects.installer-base)
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
