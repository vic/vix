{ vic, ... }:
{
  flake-file.inputs.helium.url = "github:vikingnope/helium-browser-nix-flake";

  vic.everywhere.includes = [ vic.browsers ];
  vic.browsers = {
    hm =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.librewolf
          pkgs.qutebrowser
          inputs'.helium.packages.default
        ];
      };
  };
}
