{ inputs, ... }:
let
  flake.modules.homeManager.vic.imports = [
    unfree
  ];

  unfree = inputs.self.lib.unfree-module [
    "cursor"
    "vscode"
    "anydesk"
  ];
in
{
  inherit flake;
}
