# Role wsl: a NixOS-WSL machine (form = yen.form.wsl); its admin user is the default user.
{
  inputs,
  yen,
  at,
  ...
}:
{
  yen.aspects.wsl = {
    at = yen.kinds.host.where { form = yen.form.wsl; };
    flake-file.inputs.nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.flake-compat.follows = "";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos =
      { primary-user, ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];
        wsl.enable = true;
        wsl.defaultUser = primary-user;
      };
  };

  yen.aspects.wsl-user = {
    at = at.all [
      (yen.kinds.user.where { admin = true; })
      (at.under yen.aspects.wsl)
    ];
    primary-user = { user, ... }: user.name;
  };
}
