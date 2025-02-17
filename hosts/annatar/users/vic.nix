{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.vic ];

  home.stateVersion = with import ./../static.nix; system.stateVersion;
}
