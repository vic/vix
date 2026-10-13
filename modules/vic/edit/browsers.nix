{ ... }:
{
  flake-file.inputs.helium.url = "github:vikingnope/helium-browser-nix-flake";

  vic.browsers = {
    hm =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.chromium
          pkgs.librewolf
          pkgs.qutebrowser
          inputs'.helium.packages.default
        ];
      };
  };
}
