# fonts: nerd fonts in the user's account packages (machines only, not standalone homes).
{ ren, vicAt, ... }:
{
  ren.aspects.vic-fonts = {
    at = ren.lib.and [
      vicAt.core
      (ren.lib.within ren.kinds.machine) # account lands on nixos and darwin users
    ];
    account =
      { pkgs, ... }:
      {
        packages = with pkgs.nerd-fonts; [
          victor-mono
          jetbrains-mono
          inconsolata
        ];
      };
  };
}
