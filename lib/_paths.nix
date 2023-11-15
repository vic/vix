{ config, ...}: let 

  inherit (builtins) toPath;
  cfg = config.vix;

  paths.homes = rec {
    path = toPath "${cfg.self}/homes";
    default = name: toPath "${path}/${name}";
    userModule = name: toPath "${path}/${name}/userModule.nix";
    hostModule = name: toPath "${path}/${name}/hostModule.nix";
    flakeModule = name: toPath "${path}/${name}/flakeModule.nix";
  };

  osPaths = kind: rec {
    path = toPath "${cfg.self}/hosts/${kind}";
    default = name: toPath "${path}/${name}";
    setup = name: toPath "${path}/${name}/setupModule.nix";
  };

  paths.nixos  = osPaths "nixos";
  paths.darwin = osPaths "darwin";
  paths.wsl    = osPaths "wsl";

in {
  inherit paths;
}