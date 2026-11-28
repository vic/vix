# Package channels: which nixpkgs, home-manager and nix-darwin a machine builds with.
{
  yen,
  types,
  inputs,
  ...
}:
{
  yen.kinds.channel.fields = {
    nixpkgs = types.any;
    home-manager = types.any;
    darwin = types.any;
  };
  yen.channel.unstable = {
    inherit (inputs) nixpkgs home-manager darwin;
  };

  yen.aspects.channel-inputs = {
    at = yen.root;
    flake-file.inputs = {
      nixpkgs.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
