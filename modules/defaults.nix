{ den, lib, ... }:
{
  den.default = {
    nixos.system.stateVersion = lib.mkDefault "25.05";
    homeManager.home.stateVersion = lib.mkDefault "25.05";
    darwin.system.stateVersion = lib.mkDefault 6;

    includes = [
      den.provides.define-user
      den.provides.hostname
      den.provides.inputs'
      den.provides.self'
    ];
  };
}
