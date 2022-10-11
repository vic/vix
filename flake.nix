{
  inputs = {
    # change tag or commit of nixpkgs for your system
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # change main to a tag o git revision
    # mk-darwin-system.url = "github:vic/mk-darwin-system/main";
    mk-darwin-system.url = "path:/hk/mk-darwin-system";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {mk-darwin-system, ...}@inputs:
  let
    userName = "vic";
    userHome = "/v";
    hostName = "yavanna";

    darwinFlake = mk-darwin-system.mkFlake {
      inherit userName userHome hostName inputs; flake = ./.;
    };
  in darwinFlake;
}
