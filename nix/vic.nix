{ pkgs, ... }:

{
  home-manager.users.vic = {
    home.packages = with pkgs; [
      bat               # better cat
      browsh            # Firefox on shell
      coursier          # scala dependencies
      dbmate            # migrations
      direnv            # environment per project
      emacsMacport      # one editor to rule them all
      exa               # alias ls
      fd                # alias find
      fish              # thanks for all the fish
      fzf               # ctrl+r history
      gettext           # translations
      git-lfs           # large binary files in git
      kubernetes-helm   # deploy things
      jq                # query json
      mill              # build stuff
      niv               # manage nix dependencies
      nixfmt            # fmt nix sources
      nodejs            # whatnot
      nox               # quick installer for nix
      ripgrep           # grep faster
      ripgrep-all       # rg faster grep on many file types
      tig               # terminal git ui
      victor-mono       # fontz ligatures
      tor-browser       # darkz web
      beaker-browser    # p2p geocities
      firefox-developer # firefox with dev nicities
      iterm2            # terminal
      flux              # late programming
      pock              # make touchbar useful
      keybase           # secure comms
      jetbrains.idea-community # just to follow linked libs
      nodePackages.hyp  # hyperspace://
    ];

    programs.git = {
      enable = true;
      userName = "Victor Borja";
      userEmail = "vborja@apache.org";
    };

  };


}
