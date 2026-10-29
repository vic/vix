# fonts: nerd fonts in the user's account packages (machines only, not standalone homes).
{ yen, ... }:
{
  yen.aspects.vic-fonts = {
    at = yen.lib.all [
      yen.aspects.vic-headless
      (yen.lib.within yen.helpers.machines) # account lands on nixos and darwin users
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
