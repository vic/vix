# fonts: nerd fonts in the user's account packages (machines only, not standalone homes).
{ yen, at, ... }:
{
  yen.aspects.vic-fonts = {
    at = at.all [
      yen.aspects.vic-headless
      (at.under yen.kinds.machine)
    ];
    account =
      { pkgs, ... }:
      {
        packages = [
          pkgs.nerd-fonts.victor-mono
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.nerd-fonts.inconsolata
        ];
      };
  };
}
