{ inputs, ... }:
{
  imports = with inputs.self.homeModules; [
    vic
    vic-desktop
  ];
  home.stateVersion = with import ./../static.nix; system.stateVersion;
}
