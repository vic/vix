{
  inputs,
  lib,
  den,
  ...
}:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devshells.default =
        let
          apps = inputs.self.packages.${system};

          denApps = den.lib.nh.denApps {
            outPrefix = [ ];
            fromFlake = false;
          } pkgs;

          nix_conf = {
            inherit (inputs.self.nixosConfigurations.nargun.config.nix.settings)
              experimental-features
              substituters
              trusted-public-keys
              ;
          };

          nix_conf_file = pkgs.writeTextFile {
            name = "nix.conf";
            text = lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: value: "extra-${name} = ${lib.concatStringsSep " " value}") nix_conf
            );
          };

          # first arg is the host, defaults to this machine
          hostCmd = name: action: {
            inherit name;
            category = "hosts";
            help = "${action} host (default: this machine)";
            command = ''
              host="''${1:-$(hostname -s)}"
              shift || true
              "$host" ${action} "$@"
            '';
          };

          tool = category: package: { inherit category package; };
        in
        {
          env = [
            {
              name = "NIX_USER_CONF_FILES";
              value = "${nix_conf_file}";
            }
          ];
          packages = denApps;
          commands = [
            {
              name = "fmt";
              category = "dev";
              help = "format the repo";
              command = ''${lib.getExe inputs.self.formatter.${system}} "$@"'';
            }
            {
              name = "ci";
              category = "dev";
              help = "run nix-unit ci [test]";
              command = ''
                test="''${1:-}"
                shift || true
                nix-unit --expr "(import $PRJ_ROOT).ci \"${system}\" \"$test\"" "$@"
              '';
            }
            {
              name = "hm";
              category = "hosts";
              help = "switch home of $USER@this machine";
              command = ''"$(whoami)@$(hostname -s)" switch --ask "$@"'';
            }
            (hostCmd "build" "build")
            (hostCmd "switch" "switch --ask")
            (hostCmd "boot" "boot --ask")
            {
              name = "reboot";
              category = "hosts";
              help = "boot host then reboot";
              command = ''boot "$@" && systemctl reboot'';
            }
            (tool "dev" apps.write-npins)
            (tool "dev" pkgs.npins)
            (tool "dev" pkgs.nix-unit)
            (tool "dev" pkgs.nh)
            (tool "dev" pkgs.cachix)
            (tool "dev" apps.gh-deps-update)
            (tool "secrets" pkgs.sops)
            (tool "secrets" apps.vic-sops-rotate)
            (tool "secrets" apps.vic-sops-get)
          ];
        };
    };
}
