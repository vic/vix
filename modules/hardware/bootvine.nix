{ yen, inputs, ... }:
{
  yen.aspects.bootvine = {
    at = yen.kinds.host;
    flake-file.inputs.bootvine = {
      url = "git+https://codeberg.org/wvhulle/bootvine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos.imports = [ inputs.bootvine.nixosModules.default ];
    nixos.services.bootvine.enable = true;
  };
}
