{ vix, den, ... }:
{
  den.hosts.x86_64-linux.nargun.users.vic = { };
  den.hosts.x86_64-linux.nargun-vm.users.vic = { };

  den.default.host._.host.includes = [
    vix.host-profile
    den.home-manager
    (den.import-tree._.host { root = ../non-dendritic/hosts; })
  ];

  den.default.user._.user.includes = [
    vix.user-profile
  ];

  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
}
