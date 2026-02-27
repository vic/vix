{ lib, ... }:
let
  facter =
    pkgs:
    pkgs.writeShellApplication {
      name = "facter";
      text = ''
        set -e
        host="$1"
        shift
        sudo ${lib.getExe pkgs.nixos-facter} -o facter.json "$@"
        sudo chown "$USER" facter.json
        mv facter.json modules/hosts/"$host"/facter.json
      '';
    };
in
{
  dev.apps = pkgs: [ (facter pkgs) ];
}
