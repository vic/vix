{ den, ... }:
{
  # Developer CLIs, the niri session tools and the terminals frodo uses.
  den.aspects.frodo.packages.nixos =
    { lib, pkgs, ... }:
    {
      programs.direnv.enable = true;

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      environment.systemPackages = lib.attrVals [
        "neovim"
        "jujutsu"
        "git"
        "nh"
        "just"
        "direnv"
        "ghostty"
        "niri"
        "wezterm"
        "foot"
        "fzf"

        "ripgrep"
        "fish"
        "fd"
        "jq"

        "noctalia-shell"
      ] pkgs;
    };
}
