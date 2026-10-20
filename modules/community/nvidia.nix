# nvidia: proprietary driver, nouveau blacklisted, on nvidia hosts.
{
  lib,
  ren,
  ...
}:
let
  vix = import ../_lib.nix { inherit lib; };
in
{
  ren.aspects.nvidia.at = ren.lib.and [
    ren.kinds.host
    (ren.lib.when (s: s.host.gpu == "nvidia"))
  ];
  ren.aspects.nvidia.unfree = vix.allowUnfree [
    "nvidia-x11"
    "nvidia-settings"
  ];
  ren.aspects.nvidia.nixos = vix.mod (
    { config, ... }:
    {
      boot.initrd.kernelModules = [ "nvidia" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
      boot.blacklistedKernelModules = [ "nouveau" ];
      boot.extraModprobeConfig = ''
        blacklist nouveau
        options nouveau modeset=0
      '';
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics.enable = true;
      hardware.nvidia = rec {
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        modesetting.enable = true;
        prime = {
          offload.enable = powerManagement.finegrained;
          offload.enableOffloadCmd = prime.offload.enable;
        };
      };
    }
  );
}
