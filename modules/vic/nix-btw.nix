{
  # flake-file.inputs.ntv.url = "github:vic/ntv";
  flake-file.inputs.trix = { 
    url = "github:aanderse/trix";
    inputs.nixpkgs.follows = "nixpkgs";
  };


  vic.nix-btw = {

    homeManager =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.nix-search-cli
          pkgs.nixd # lsp
          pkgs.cachix
          pkgs.nix-inspect
          pkgs.nox
	  inputs'.trix.packages.trix
        ];

        programs.nh.enable = true;
        programs.home-manager.enable = true;
      };

  };

}
