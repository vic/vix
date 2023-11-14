top@{config, ...}: [
 config.flake.nixosModules.with-system
 # config.flake.nixosModules.${"features.all"}
 { _module.args.flakeConfig = config; }
]