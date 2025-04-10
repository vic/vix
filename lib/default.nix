{ inputs, ... }:
{

  treefmt = pkgs: pkgs.callPackage ./treefmt.nix { inherit inputs; };

  hostsBySystem =
    system:
    let
      # pkgs expects we run on a linux.
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = pkgs.lib;
      where =
        ({
          "x86_64-linux" = inputs.self.nixosConfigurations;
          "x86_64-darwin" = inputs.self.darwinConfigurations;
          "aarch64-darwin" = inputs.self.darwinConfigurations;
        }).${system} or (throw "Unsupported system: ${system}");
      sameSystem = lib.filterAttrs (_: v: v.config.nixpkgs.hostPlatform.system == system) where;
    in
    lib.attrNames sameSystem;

}
