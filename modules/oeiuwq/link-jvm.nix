{ config, lib, pkgs, vix-lib, ... }: {

  environment.pathsToLink = [ "/Library/Java/JavaVirtualMachines" ];
  environment.systemPackages =
    [ (vix-lib.linkJvm pkgs.openjdk.name pkgs.openjdk) ];

  system.activationScripts.linkSystemJvm.text = ''
    echo "linking JVMs ..." >&2
    for f in $(ls "/run/current-system/sw/Library/Java/JavaVirtualMachines" 2>/dev/null); do
      if [ -L "$systemConfig/sw/Library/Java/JavaVirtualMachines/$f" ]; then
        rm -v "/Library/Java/JavaVirtualMachines/$f"
      fi
    done
    for f in $(ls "$systemConfig/sw/Library/Java/JavaVirtualMachines" 2>/dev/null); do
      ln -sfv "$systemConfig/sw/Library/Java/JavaVirtualMachines/$f" "/Library/Java/JavaVirtualMachines/$f"
    done
  '';

  system.activationScripts.postActivation.text =
    config.system.activationScripts.linkSystemJvm.text;

}
