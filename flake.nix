{
  inputs = {
    flake-parts.url = "https://rime.cx/v1/github/hercules-ci/flake-parts/branch/main.tar.gz";

    nix-latest.url = "https://rime.cx/v1/github/NixOS/nix/version/2.18.1.tar.gz";
    # nix-latest.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager-stable.url = "github:nix-community/home-manager/release-23.05"; # IMPORTANT: must match stable nixpkgs. 
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixos-wsl-stable.url = "github:nix-community/NixOS-WSL/23.5.5.2";
    nixos-wsl-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    nixos-vscode-ssh.url = "github:mudrii/nixos-vscode-ssh-fix";
    nixos-vscode-ssh.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devenv.url = "github:cachix/devenv";

  };

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" "fetch-closure" ];
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./flake-modules;

}
