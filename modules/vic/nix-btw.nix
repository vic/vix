{
  # flake-file.inputs.ntv.url = "github:vic/ntv";

  vic.nix-btw = {

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.nix-search-cli
          pkgs.nixd # lsp
          pkgs.cachix
          pkgs.nix-inspect
          pkgs.nox
        ];

        programs.nh.enable = true;
        programs.home-manager.enable = true;
      };

  };

}
