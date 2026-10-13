{ ... }:
{
  vic.fonts.user =
    { pkgs, ... }:
    {
      packages = with pkgs.nerd-fonts; [
        victor-mono
        jetbrains-mono
        inconsolata
      ];
    };
}
