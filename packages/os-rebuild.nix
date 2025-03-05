{ pkgs, inputs }:
let

  os-builder =
    name: os:
    let
      platform = os.config.nixpkgs.hostPlatform;
      darwin-rebuild = pkgs.lib.getExe inputs.nix-darwin.packages.${platform.system}.darwin-rebuild;
      nixos-rebuild = pkgs.lib.getExe pkgs.nixos-rebuild;
      flake-param = ''--flake "path:${inputs.self}#${name}"'';
      builder =
        if platform.isDarwin then
          ''
            ${darwin-rebuild} ${flake-param} "''${@:-check}"
          ''
        else
          ''
            ${nixos-rebuild} ${flake-param} "''${@:-test}"
          '';
    in
    pkgs.writeShellApplication {
      name = "${name}-os-rebuild";
      text = builder;
    };

  os-builders =
    (pkgs.lib.mapAttrs os-builder inputs.self.nixosConfigurations)
    // (pkgs.lib.mapAttrs os-builder inputs.self.darwinConfigurations);

  os-rebuild = pkgs.writeShellApplication {
    name = "os-rebuild";
    runtimeInputs = pkgs.lib.attrValues os-builders;
    text = ''
      if test "file" = "$(type -t "''${1:-_}-os-rebuild")"; then
        hostname="$1"
        shift
      else
        hostname="$(uname -n)"
      fi

      if test "file" = "$(type -t "$hostname-os-rebuild")"; then
        "$hostname-os-rebuild" "''${@}"
      else
        echo "No configuration found for host: $hostname"
        exit 1
      fi
    '';
  };

in
os-rebuild
