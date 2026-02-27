{ inputs, den, ... }:
let
  apps = den.lib.nh.denApps {
    fromFlake = false;
    outPrefix = [ "flake" ];
  };
in
{
  dev.apps = apps;
}
