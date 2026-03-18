{ den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "25.05";
    homeManager.home.stateVersion = "25.05";
    darwin.system.stateVersion = 6;

    includes = [
      den.provides.define-user
      den.provides.hostname
      den.provides.inputs'
    ];
  };
}
