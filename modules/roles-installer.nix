# installer-base: the iso image base (installer cd) plus live-session users; hosts with role installer include it (roles.nix owns `installer`).
{ mod, ... }:
{
  ren.aspects.installer-base.nixos = mod (
    {
      lib,
      modulesPath,
      config,
      ...
    }:
    {
      imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix" ];

      system.stateVersion = "26.05";

      lib.isoFileSystems."/home/vic" = {
        device = "/dev/disk/by-label/vic";
        fsType = "ext4";
      };

      users.users.vic.uid = 1000;
      users.users.nixos.uid = 1001;

      isoImage.edition = lib.mkDefault config.networking.hostName;
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkImageMediaOverride false;

      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable = true;
      services.pulseaudio.enable = false;
    }
  );
}
