# devshell: the vix maintainer shell (devShells.<sys>.default), a numtide/devshell with fmt/ci/hm and host commands.
{
  ren,
  inputs,
  ...
}:
{
  ren.aspects.maintainer-shell = {
    at = ren.kinds.system;
    checks = { system, ... }: {
      ${system.name}.devshell-default = inputs.self.devShells.${system.name}.default;
    };
    devshells =
      { system, ... }:
      let
        pkgs = system.legacyPackages;
        apps = inputs.self.packages.${system.name};
        s = inputs.self.nixosConfigurations.nargun.config.nix.settings; # a workstation: carries the vix cachix (as old vix)
        nixConf = pkgs.writeText "nix.conf" (
          pkgs.lib.concatStringsSep "\n" (
            map (n: "extra-${n} = ${pkgs.lib.concatStringsSep " " s.${n}}") [
              "experimental-features"
              "substituters"
              "trusted-public-keys"
            ]
          )
        );
        cmd = name: help: command: { inherit name help command; };
        # first arg is the host, defaults to this machine
        hostCmd =
          name: action:
          cmd name "nh os ${action} [host]" ''
            host="''${1:-$(hostname -s)}"
            shift || true
            nh os ${action} "$PRJ_ROOT#nixosConfigurations.$host" "$@"
          '';
      in
      {
        default = (import inputs.devshell { nixpkgs = pkgs; }).mkShell {
          name = "vix";
          env = [
            {
              name = "NIX_USER_CONF_FILES";
              value = "${nixConf}";
            }
          ];
          packages =
            inputs.self.devShells.${system.name}.nixenv.config.packages # nix tools: nixd nixfmt statix deadnix npins nix-unit
            ++ [
              pkgs.nix
              pkgs.nh
              pkgs.nix-unit
              pkgs.cachix
              pkgs.sops
              pkgs.age
              pkgs.ssh-to-age # vic-sops-get --setup derives the age key from the ssh key
              pkgs.just
              apps.vic-sops-get
              apps.vic-sops-rotate
              apps.gh-deps-update
              inputs.self.formatter.${system.name}
            ]
            # the README and flake.nix writers are built on x86_64-linux only (docs/files.nix, features/flake-inputs.nix)
            ++ builtins.attrValues (
              builtins.intersectAttrs {
                write-files = null;
                write-flake = null;
                write-lock = null;
              } apps
            );
          commands = [
            (cmd "fmt" "format the tree" ''nix fmt "$@"'')
            (cmd "ci" "flake check and CI job count" ''
              nix flake check --no-build "path:$PRJ_ROOT" "$@"
              nix eval "path:$PRJ_ROOT#ci.matrix" --apply builtins.length
            '')
            (cmd "hm" "switch this home" ''nh home switch "$PRJ_ROOT#$(whoami)@$(hostname -s)" "$@"'')
            (hostCmd "-build" "build")
            (hostCmd "-switch" "switch --ask")
            (hostCmd "-boot" "boot --ask")
            (cmd "-reboot" "boot a host config, then reboot" ''-boot "$@" && systemctl reboot'')
            (cmd "vini-hm" "build vini's home here, activate it on vini" ''
              set -euo pipefail
              test "''${1:-}" = activate || { echo "usage: vini-hm activate" >&2; exit 1; }
              drv=$(nix eval --raw "path:$PRJ_ROOT#homeConfigurations.\"vic@bitstream\".activationPackage.drvPath")
              nix build --no-link "$drv^out"
              NIX_SSHOPTS="-o BatchMode=yes" nix copy --derivation --to ssh-ng://vini "$drv"
              ssh vini "set -e; out=\$(nix build --no-link --print-out-paths --option fallback true --option connect-timeout 5 '$drv^out'); \$out/activate"
            '')
          ];
        };
      };
  };
}
