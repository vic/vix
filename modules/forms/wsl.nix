# Role wsl: a NixOS-WSL machine (form = wsl); its admin user is the default user.
{ inputs, yen, ... }:
{
  yen.aspects.wsl = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.form == "wsl")
    ];
    flake-file.inputs.nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.flake-compat.follows = "";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # primary-user reduces with `one`: two admins = an error record, not a module conflict
    nixos =
      { primary-user, ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];
        wsl.enable = true;
        wsl.defaultUser = primary-user;
      };
  };

  yen.aspects.wsl-user = {
    at = yen.lib.all [
      yen.kinds.user
      (s: s.admin)
      (yen.lib.within yen.aspects.wsl)
    ];
    primary-user = { user, ... }: user.name;
  };
}
