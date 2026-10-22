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
          url = "github:nix-community/nixos-wsl";
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
