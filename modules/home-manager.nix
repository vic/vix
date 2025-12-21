{ den, inputs, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  den.default.includes = [ den._.home-manager den.aspects.hm den._.inputs' den._.self' ];

  den.aspects.hm.homeManager = { pkgs, ... }: {
    home.packages = [
      inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
