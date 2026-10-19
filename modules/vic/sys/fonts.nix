# fonts: nerd fonts in the user's account packages (machines only, not standalone homes).
{ ren, vicAt, ... }:
{
  ren.aspects.vic-fonts = {
    at = ren.lib.and [
      vicAt.core
      (ren.lib.within ren.kinds.host)
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
