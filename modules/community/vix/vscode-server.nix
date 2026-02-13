{ inputs, ... }:
{
  flake-file.inputs = {
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  vix.vscode-server.homeManager =
    { pkgs, ... }:
    {
      imports = [
        inputs.vscode-server.homeModules.default
      ];

      services.vscode-server = {
        enable = true;
        nodejsPackage = pkgs.nodejs_latest;
        extraRuntimeDependencies = with pkgs; [
          curl
          wget
        ];
      };
    };
}
