{ inputs, ... }:
{
  flake-file.inputs.jjdag = {
    url = "github:anthrofract/jjdag";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.jjui = {
    url = "github:idursun/jjui";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  vic.everywhere.user =
    { pkgs, system', ... }:
    {
      packages = with pkgs; [
        git
        jujutsu
        # (system' inputs.jjui).packages.jjui # NO unflake self.inputs!
        jjui
        (system' inputs.jjdag).packages.jjdag
      ];
    };
}
