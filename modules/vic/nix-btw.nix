{
  # flake-file.inputs.ntv.url = "github:vic/ntv";

  vix.vic.provides.nix-btw = _: {

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.nix-search-cli
          pkgs.nixd # lsp
          pkgs.cachix
        ];

        programs.nh.enable = true;
        programs.home-manager.enable = true;
      };

  };

}
