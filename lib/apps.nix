inputs:
let
  os-configurations =
    with builtins;
    (attrValues inputs.self.nixosConfigurations) ++ (attrValues inputs.self.darwinConfigurations);

  systems = builtins.map (os: os.config.nixpkgs.hostPlatform.system) os-configurations;

  perSystem =
    f: with inputs.nixpkgs.lib; genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});

  os-rebuild =
    pkgs: os:
    let
      hostname = os.config.networking.hostName;
      platform = os.config.nixpkgs.hostPlatform;
      darwin-rebuild = inputs.nix-darwin.packages.${pkgs.system}.darwin-rebuild;
      nixos-rebuild = pkgs.nixos-rebuild;
      builder =
        if platform.isDarwin then
          "${darwin-rebuild}/bin/darwin-rebuild"
        else
          "${nixos-rebuild}/bin/nixos-rebuild";
      app = pkgs.writeShellApplication {
        name = "app";
        text = ''
          ${builder} --flake path:${inputs.self}#${hostname} "''${@:-boot}"
        '';
      };
    in
    pkgs.lib.optionalAttrs (platform.system == pkgs.system) {
      "${hostname}-rebuild" = {
        type = "app";
        program = "${app}/bin/app";
      };
    };

  nixos-hosts = pkgs: with pkgs.lib; mergeAttrsList (map (os-rebuild pkgs) os-configurations);

in
{
  apps = perSystem nixos-hosts;
}
