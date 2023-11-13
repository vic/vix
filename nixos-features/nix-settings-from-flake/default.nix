{lib, config, flakeConfig, ...}:
let
  cfg = config.vix.features.nix-settings-from-flake;
in {
  options.vix.features.nix-settings-from-flake.enable = lib.mkEnableOption "Use nix settings as defined in flake.nix";
  config = lib.mkIf cfg.enable {
    nix.settings = (import "${flakeConfig.vix.self}/flake.nix").nixConfig;
  };
}
