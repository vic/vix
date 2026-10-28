# fonts: nerd fonts in the user's account packages (machines only, not standalone homes).
{ sven, ... }:
{
  sven.aspects.vic-fonts = {
    at = sven.lib.all [
      sven.aspects.vic-headless
      (sven.lib.within sven.helpers.machines) # account lands on nixos and darwin users
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
