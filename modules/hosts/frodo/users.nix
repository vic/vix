{
  den.aspects.frodo.nixos =
    { lib, pkgs, ... }:
    {
      users.users.vic = {
        isNormalUser = true;
        description = lib.mkForce "vic"; # vix fonts.nix sets "oeiuwq"
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = [
          pkgs.chromium
          pkgs.flow-control
          pkgs.lapce
          pkgs.nodejs
          pkgs.power-profiles-daemon
          pkgs.uv
        ];
      };
    };
}
