import ./from-nix (
  {
    inputs,
    pkgs,
    lib,
    ...
  }:
  {

    imports = [

      (lib.importTOML ./nix.toml)

    ];

    commands = [
      {
        package = inputs.self.packages.${pkgs.system}.leader;
        help = "Leader key";
      }
      { package = pkgs.nh; }
      {
        name = "nh-all";
        command = "nix fmt && nh os switch && nh clean all && nh os boot";
        help = "Nix Format / OS Switch / NH Clean";
      }
      {
        name = "nr-switch";
        command = "sudo nixos-rebuild --flake . switch";
        help = "nixos-rebuild switch";
      }
    ];

  }
)
