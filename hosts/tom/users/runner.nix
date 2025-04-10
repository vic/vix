{ inputs, ... }:
{
  imports = with inputs.self.homeModules; [
    runner
  ];
  home.stateVersion = "25.05";
}
