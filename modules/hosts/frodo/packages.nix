{
  den.aspects.frodo.nixos =
    { pkgs, ... }:
    {
      programs.direnv.enable = true;

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

        niri
        fuzzel
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
