{ withSystem, ... }: {
  flake.nixosModules.with-system = { config, ... }:
    let
      withSystem' = withSystem config.nixpkgs.hostPlatform.system;
    in
    {
      _module.args = {
        inherit withSystem';
        channels' = withSystem' ({ channels', ... }: channels');
      };
    };
}
