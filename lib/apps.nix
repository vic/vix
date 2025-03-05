inputs:
let

  # This function might be the content of apps.nix, loaded by blueprint
  userExposedApps =
    { perSystem, pkgs }:
    {
      default = perSystem.self.packages.os-rebuild;
      inherit (pkgs) hello; # or any other derivation
    };

  # TODO: blueprint should expose apps on each system.
  # following functions are temporary til this functionality is implemented properly in blueprint
  # and are currently only for demo purposes.
  eachSystem = inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed;
  eachSystem' =
    f:
    eachSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        perSystem.self.packages = inputs.self.packages.${system};
      in
      f { inherit pkgs perSystem; }
    );

  flakeExposedApps = eachSystem' (
    { pkgs, perSystem }@args:
    let
      toFlakeApp = _name: deriv: {
        type = "app";
        program = pkgs.lib.getExe deriv;
      };
    in
    pkgs.lib.mapAttrs toFlakeApp (userExposedApps args)
  );

in
{
  apps = flakeExposedApps;
}
