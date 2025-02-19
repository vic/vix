{ inputs, pkgs, ... }:
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
}
