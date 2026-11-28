# radios: NetworkManager and bluetooth, with pipewire in place of pulseaudio. Workstations and installer images both have them.
{ yen, ... }:
{
  yen.aspects.radios = {
    at = [
      yen.aspects.bootable
      yen.aspects.installer-base
    ];
    nixos = {
      networking.networkmanager.enable = true;
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable = true;
      services.pulseaudio.enable = false;
    };
  };
}
