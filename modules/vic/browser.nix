{

  flake-file.inputs.helium = {
    url = "github:vikingnope/helium-browser-nix-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  vic.browser = {

    homeManager =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.librewolf
          pkgs.qutebrowser
	  inputs'.helium.packages.helium
        ];
      };

  };
}
