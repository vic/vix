{
  den.aspects.frodo.nixos =
    { pkgs, ... }:
    {
      programs.direnv.enable = true;
      programs.fish.enable = true;

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      environment.systemPackages = with pkgs; [
        neovim
        jujutsu
        git
        nh
        just
        direnv
        ghostty
        wezterm
        foot
        fzf

        gnome-keyring
        brightnessctl
        swaybg
        niri
        fuzzel
        swaybg
        xwayland-satellite
        grim
        slurp
        ripgrep
        fish
        fd
        jq

        noctalia-shell
      ];
    };
}
