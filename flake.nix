{
  inputs = {
    flake-parts.url = "https://rime.cx/v1/github/hercules-ci/flake-parts/branch/main.tar.gz";
    nix-latest.url = "https://rime.cx/v1/github/NixOS/nix/version/2.18.1.tar.gz";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager-unstable.url = "github:nix-community/home-manager";

  };

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" "fetch-closure" ];
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./flake-modules;

}
