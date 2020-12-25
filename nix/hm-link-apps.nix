{ config, lib, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/issues/1341#issuecomment-687286866
  config = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
    # Install MacOS applications to the user environment.
    home.file."Applications/Home Manager Apps".source = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in "${apps}/Applications";
  };
}
