{ inputs, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default =
        let
          system = pkgs.stdenvNoCC.targetPlatform.system;
          apps = inputs.self.packages.${system};
          formatter = inputs.self.formatter.${system};

          fmtt = pkgs.writeShellApplication {
            name = "fmtt";
            text = ''
              ${lib.getExe formatter} "$@"
            '';
          };

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

          shellHook = ''
            export NIX_USER_CONF_FILES="${nix_conf_file}"
          '';

        in
        pkgs.mkShell {
          shellHook = shellHook;
          buildInputs = [
            fmtt
            apps.vic-sops-rotate
            apps.vic-sops-get
            # apps.edgevpn
            apps.gh-deps-update
            pkgs.nh
            pkgs.sops
            pkgs.just
            pkgs.npins
            pkgs.cachix
          ];
        };
    };
}
