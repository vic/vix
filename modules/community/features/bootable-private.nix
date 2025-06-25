# this private file exists just to make an example
# how to hide private files from dennix, even in a
# community shared tree.
{
  flake.modules.nixos.bootable =
    { modulesPath, ... }:
    {

      time.timeZone = "America/Mexico_City";

      imports = [
        # include this once instead of doing in every host.
        (modulesPath + "/installer/scan/not-detected.nix")
      ];
    };
}
