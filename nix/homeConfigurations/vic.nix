{
  config,
  lib,
  pkgs,
  ...
}:
# for configurable home-manager modules see:
# https://github.com/nix-community/home-manager/blob/master/modules/modules.nix
{
  options = {
    dots = lib.mkOption {
      description = "Link to secret stuff";
      type = lib.types.package;
      default = config.lib.file.mkOutOfStoreSymlink /hk/dots;
      visible = false;
      readOnly = true;
    };
  };

  imports = [
    ./vic/git.nix
    ./vic/ssh
    ./vic/fish
    ./vic/emacs
  ];

  config = {
    manual.html.enable = false;
    manual.manpages.enable = false;

    # linkHomeApplications = true;

    home.packages = with pkgs; [
      bat
      bottom
      difftastic
      direnv
      exa
      fd
      git-lfs
      htop
      jq
      k9s
      ripgrep
      ripgrep-all
      unison-ucm
      nixVersions.stable

      # Install dmg applications versioned by niv.
      # See `nix develop -c niv show` on the root of your flake.
      #
      nivApps.FirefoxDevApp
      nivApps.IdeaApp
      nivApps.KeybaseApp
      nivApps.KeyttyApp
      nivApps.TelegramApp
      nivApps.TunnelblickApp
      nivApps.VimMotionApp
      # "Iterm2App"
      # "PosticoApp"
    ];

    # enable at least one shell. as for any other program, see customizable options at:
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/<program>.nix
    programs.direnv.enable = true;
  };
}
