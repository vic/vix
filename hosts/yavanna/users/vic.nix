{ inputs, ... }:
{
  imports = with inputs.self.homeModules; [
    vic
  ];

  home.stateVersion = "25.05";
}
