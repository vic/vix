# frodo gaming: Steam on vic's laptop. programs.steam enables the 32-bit graphics it needs on AMD.
{ yen, ... }:
{
  yen.aspects.frodo-gaming = {
    at = yen.host.frodo;
    unfree = [
      "steam"
      "steam-unwrapped"
    ];
    nixos = {
      programs.steam.enable = true;
    };
  };
}
