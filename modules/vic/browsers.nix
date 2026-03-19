{ vic, inputs, ... }:
{
  flake-file.inputs.helium.url = "github:vikingnope/helium-browser-nix-flake";

  vic.everywhere.includes = [ vic.browsers ];
  vic.browsers = {
    hm =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.librewolf
          pkgs.qutebrowser
          inputs.helium.packages.${pkgs.stdenvNoCC.hostPlatform.system}.default
        ];
      };
  };
}
