# Role wsl: a NixOS-WSL machine (form = wsl); its admin user is the default user.
{ inputs, sven, ... }:
{
  sven.aspects.wsl = {
    at = sven.lib.all [
      sven.helpers.linux
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

  sven.aspects.wsl-user = {
    at = sven.lib.all [
      sven.kinds.user
      (s: s.admin)
      (sven.lib.within sven.aspects.wsl)
    ];
    primary-user = { user, ... }: user.name;
  };
}
