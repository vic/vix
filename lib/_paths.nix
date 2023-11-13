{ config, ...}: let 

  inherit (builtins) toPath;
  cfg = config.vix;

  paths.homes = rec {
    path = toPath "${cfg.self}/home-configurations";
    default = name: toPath "${path}/${name}/default.nix";
    configuration = name: toPath "${path}/${name}/homeConfiguration.nix";
    user = name: toPath "${path}/${name}/user.nix";
  };

  paths.nixos = rec {
    path = toPath "${cfg.self}/nixos-configurations";
    default = name: toPath "${path}/${name}/default.nix";
    configuration = name: toPath "${path}/${name}/configuration.nix";
  };

  paths.darwin = rec {
    path = toPath "${cfg.self}/darwin-configurations";
    default = name: toPath "${path}/${name}/default.nix";
    configuration = name: toPath "${path}/${name}/configuration.nix";
  };

  paths.wsl = rec {
    path = toPath "${cfg.self}/wsl-configurations";
    default = name: toPath "${path}/${name}/default.nix";
    configuration = name: toPath "${path}/${name}/configuration.nix";
  };

in {
  inherit paths;
}