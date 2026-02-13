{
  dev.apps.nh = pkgs: pkgs.nh;
  dev.apps.os =
    pkgs:
    pkgs.writeShellApplication {
      name = "os";
      text = ''
        set -euo pipefail
        task="''${1:-build}"
        host="''${2:-$(hostname -s)}"
        nh os "$task" --file . flake.nixosConfigurations."$host" "''${@:3}"
      '';
    };
}
