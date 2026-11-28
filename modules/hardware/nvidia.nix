# nvidia: proprietary driver, nouveau blacklisted, on hosts with yen.gpu.nvidia.
{ yen, ... }:
{
  yen.aspects.nvidia = {
    at = yen.kinds.host.where { gpu = yen.gpu.nvidia; };
    unfree = [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-kernel-modules"
    ];
    nixos =
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
        hardware.nvidia = {
          open = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          powerManagement.enable = true;
          powerManagement.finegrained = false;
          modesetting.enable = true;
          prime = {
            offload.enable = false;
            offload.enableOffloadCmd = false;
          };
        };
      };
  };
}
