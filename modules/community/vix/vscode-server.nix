{ inputs, ... }:
{
  flake-file.inputs.vscode-server = {
    url = "github:nix-community/nixos-vscode-server";
  };

  vix.vscode-server = {

    homeManager = {
      imports = [
        "${inputs.vscode-server}/modules/vscode-server/home.nix"
      ];
    };

    hmLinux =
      { pkgs, ... }:
      {
        services.vscode-server = {
          enable = true;
          nodejsPackage = pkgs.nodejs_latest;
          extraRuntimeDependencies = with pkgs; [
            curl
            wget
          ];
        };
      };
  };
}
