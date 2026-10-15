{
  den.aspects.frodo.users.nixos =
    { pkgs, ... }:
    {
      users.users.vic = {
        description = "vic";
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
