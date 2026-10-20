# Role wsl: a NixOS-WSL machine (form = wsl); vic is the default user.
{ inputs, ren, ... }:
{
  ren.aspects.wsl = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.form == "wsl"))
    ];
    flake-inputs =
      { ... }:
      {
        nixos-wsl = {
          url = "github:nix-community/nixos-wsl/72c92b11bb8289e6651c7fef29cc0a885fd6a255";
          inputs.flake-compat.follows = "";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    nixos = {
      imports = [ inputs.nixos-wsl.nixosModules.default ];
      wsl.enable = true;
      wsl.defaultUser = "vic";
    };
  };
}
