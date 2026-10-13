{ ... }:
{
  vic.fonts.user =
    { pkgs, ... }:
    {
      description = "oeiuwq";
      packages = with pkgs.nerd-fonts; [
        victor-mono
        jetbrains-mono
        inconsolata
      ];
    };
}
