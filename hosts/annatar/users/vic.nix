{ inputs, ... }:
{
  imports = with inputs.self.homeModules; [
    vic
    vscode-server
  ];

  home.stateVersion = with import ./../static.nix; system.stateVersion;
}
