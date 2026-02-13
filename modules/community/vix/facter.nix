{ lib, ... }:
{

  vix.facter =
    hostsDir:
    { OS, host, ... }:
    let
      reportPath = "${hostsDir}/${host.hostName}/facter.json";
    in
    {
      includes = lib.optional (builtins.pathExists reportPath) {
        nixos.hardware.facter = { inherit reportPath; };
      };
    };

}
