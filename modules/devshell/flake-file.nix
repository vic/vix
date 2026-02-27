{ config, ... }:
{
  dev.apps = pkgs: [
    (config.flake-file.apps.write-inputs pkgs)
    (config.flake-file.apps.write-npins pkgs)
  ];
}
