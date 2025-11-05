{
  vic.fonts = _: {
    nixos =
      { pkgs, ... }:
      {
        fonts.packages = with pkgs.nerd-fonts; [
          victor-mono
          jetbrains-mono
          inconsolata
        ];
      };
  };
}
