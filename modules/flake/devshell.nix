# devshell: the vix maintainer shell (devShells.<sys>.default), a numtide/devshell with fmt/ci and host/-hm commands.
{ yen, inputs, ... }:
let
  cmd = name: help: command: { inherit name help command; };
  # first arg is the nh action; switch/boot ask before activating
  nhCmd =
    name: actions: help: run:
    cmd name "${actions} ${help}" ''
      set -euo pipefail
      action="''${1:-}"
      case "$action" in
        ${actions}) shift ;;
        *) echo "usage: ${name} ${actions} ${help}" >&2; exit 1 ;;
      esac
      ask=()
      [ "$action" = build ] || ask=(--ask)
      ${run}
    '';
  commands = [
    (cmd "fmt" "format the tree" ''nix fmt "$@"'')
    (cmd "ci" "flake check and CI job count" ''
      nix flake check --no-build "path:$PRJ_ROOT" "$@"
      nix eval "path:$PRJ_ROOT#ci.matrix" --apply builtins.length
    '')
    (nhCmd "-hm" "build|switch" "[nh args]: this user@host home" ''
      nh home "$action" "path:$PRJ_ROOT" -c "$(whoami)@$(hostname -s)" "''${ask[@]}" "$@"
    '')
    # second arg is the host, defaults to this machine
    (nhCmd "-os" "build|switch|boot" "[host] [nh args]" ''
      host="$(hostname -s)"
      if [ $# -gt 0 ] && [ "''${1#-}" = "$1" ]; then host="$1"; shift; fi
      nh os "$action" "$PRJ_ROOT#nixosConfigurations.$host" "''${ask[@]}" "$@"
    '')
    (cmd "vini-hm" "build vini's home here, activate it on vini" ''
      set -euo pipefail
      test "''${1:-}" = activate || { echo "usage: vini-hm activate" >&2; exit 1; }
      drv=$(nix eval --raw "path:$PRJ_ROOT#homeConfigurations.\"vic@bitstream\".activationPackage.drvPath")
      nix build --no-link "$drv^out"
      NIX_SSHOPTS="-o BatchMode=yes" nix copy --derivation --to ssh-ng://vini "$drv"
      ssh vini "set -e; out=\$(nix build --no-link --print-out-paths --option fallback true --option connect-timeout 5 '$drv^out'); \$out/activate"
    '')
  ];
in
{
  yen.aspects.maintainer-shell = {
    at = yen.kinds.system;
    checks =
      { system, out, ... }:
      {
        ${system.name}.devshell-default = out.devShells.${system.name}.default;
      };
    devshells =
      { system, out, ... }:
      let
        pkgs = system.legacyPackages;
        apps = out.packages.${system.name};
        s = out.nixosConfigurations.nargun.config.nix.settings; # a workstation: carries the vix cachix (as old vix)
        nixConf = pkgs.writeText "nix.conf" (
          pkgs.lib.concatStringsSep "\n" (
            map (n: "extra-${n} = ${pkgs.lib.concatStringsSep " " s.${n}}") [
              "experimental-features"
              "substituters"
              "trusted-public-keys"
            ]
          )
        );
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
            out.devShells.${system.name}.nixenv.config.packages # nix tools: nixd nixfmt statix deadnix npins nix-unit
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
              out.formatter.${system.name}
            ]
            # the README and flake.nix writers are built on x86_64-linux only (flake/files.nix, flake/flake-file.nix)
            ++ builtins.attrValues (
              builtins.intersectAttrs {
                write-files = null;
                write-flake = null;
                write-lock = null;
              } apps
            );
          inherit commands;
        };
      };
  };
}
