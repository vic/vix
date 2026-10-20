# devshell: the vix maintainer shell (devShells.<sys>.default) with fmt/ci/hm and host commands.
{
  ren,
  inputs,
  ...
}:
{
  ren.aspects.maintainer-shell = {
    at = ren.kinds.system;
    devshells =
      { system, ... }:
      let
        pkgs = system.pkgs;
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
        cmd =
          name: text:
          pkgs.writeShellScriptBin name ''
            prj="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
            ${text}
          '';
        # first arg is the host, defaults to this machine
        hostCmd =
          name: action:
          cmd name ''
            host="''${1:-$(hostname -s)}"
            shift || true
            nh os ${action} "$prj#nixosConfigurations.$host" "$@"
          '';
      in
      {
        default = pkgs.mkShell {
          inputsFrom = [ inputs.self.devShells.${system.name}.nixenv ]; # nix tools: nixd nixfmt statix deadnix npins nix-unit
          NIX_USER_CONF_FILES = "${nixConf}";
          packages = [
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
            apps.write-files # regenerate README.md (docs/)
            apps.write-flake # regenerate flake.nix from flake-inputs
            apps.write-lock
            inputs.self.formatter.${system.name}
            (cmd "vix" ''
              echo "vix commands: fmt ci hm -build -switch -boot -reboot vini-hm"
              echo "vix tools:    vic-sops-get vic-sops-rotate gh-deps-update write-files write-flake write-lock sops age ssh-to-age nh cachix"
            '')
            (cmd "fmt" ''nix fmt "$@"'')
            (cmd "ci" ''
              nix flake check --no-build "path:$prj" "$@"
              nix eval "path:$prj#ci.matrix" --apply builtins.length
            '')
            (cmd "hm" ''nh home switch "$prj#$(whoami)@$(hostname -s)" "$@"'')
            (hostCmd "-build" "build")
            (hostCmd "-switch" "switch --ask")
            (hostCmd "-boot" "boot --ask")
            (cmd "-reboot" ''-boot "$@" && systemctl reboot'')
            (cmd "vini-hm" ''
              set -euo pipefail
              test "''${1:-}" = activate || { echo "usage: vini-hm activate" >&2; exit 1; }
              drv=$(nix eval --raw "path:$prj#homeConfigurations.\"vic@bitstream\".activationPackage.drvPath")
              nix build --no-link "$drv^out"
              NIX_SSHOPTS="-o BatchMode=yes" nix copy --derivation --to ssh-ng://vini "$drv"
              ssh vini "set -e; out=\$(nix build --no-link --print-out-paths --option fallback true --option connect-timeout 5 '$drv^out'); \$out/activate"
            '')
          ];
        };
      };
  };
}
