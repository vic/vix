{ config, lib, pkgs, ... }:

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
    # Install dmg applications versioned by niv.
    # See `nix develop -c niv show` on the root of your flake.
    home.appsFromDmg = [
      "FirefoxDevApp"
      "IdeaApp"
      "KeybaseApp"
      "KeyttyApp"
      "TelegramApp"
      "TunnelblickApp"
      "VimMotionApp"
      # "Iterm2App"
      # "PosticoApp"
    ];

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
      ripgrep-all
    ];

    # enable at least one shell. as for any other program, see customizable options at:
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/<program>.nix
    programs.direnv.enable = true;
  };
}
