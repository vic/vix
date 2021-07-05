{ config, pkgs, vix-lib, lib, ... }:
let

in {
  options = with lib; {
    devShells = mkOption {
      type = types.attrsOf (types.listOf types.package);
      default = { };
      description = ''
        Dev Environments
      '';
    };
  };

  config = {

    devShells = with pkgs; {

      vic = [
        gping
        xsv
        broot
        htop
        # emacsMacport
        gitAndTools.delta
        gitui
        k9s
        hyperfine
        bat # better cat
        # browsh # Firefox on shell
        # emacsMacport # one editor to rule them all
        exa # alias ls
        fd # alias find
        fish # thanks for all the fish
        fzf # ctrl+r history
        git-lfs # large binary files in git
        jq # query json
        ripgrep # grep faster
        ripgrep-all # rg faster grep on many file types
        tig # terminal git ui
        # victor-mono # fontz ligatures
        # tor-browser # darkz web
        # beaker-browser # p2p geocities
        # firefox-developer # firefox with dev nicities
        # iterm2 # terminal
        # flux # late programming
        # pock # make touchbar useful
        # keybase # secure comms
        # jetbrains.idea-community # just to follow linked libs
        # nodePackages.hyp # hyperspace://
        git # work around patches
        # neovim # you can move, but there is no escape
      ];

      scala = [
        mill
        coursier
        dbmate
        gettext
        nodejs
        # google-cloud-sdk # TODO: BACKPORT
        # jdk # TODO: build
        kubectl
        # coursierPackages.graalvm
        postgresql
        metals
        kubernetes-helm # deploy things
      ];

      bash = [ shfmt shellcheck ];

      nix = [ 
        niv # manage nix dependencies
        nixfmt # fmt nix sources
        nox # quick installer for nix
      ];
    };

    home-manager.users.vic = {
      home.packages = (with pkgs; [ devEnvs.vic devEnvsNoGc ]);
    };

    nixpkgs.overlays = [
      (new: old: {
        devShells = lib.mapAttrs (name: buildInputs: old.mkShell {
          inherit name buildInputs;
        }) config.devShells;

        devEnvs = lib.mapAttrs (name: paths: old.buildEnv {
          inherit name paths;
        }) config.devShells;

        devEnvsNoGc = old.buildEnv { 
          name = "devEnvsNoGc";
          paths = [];
          buildInputs = lib.concatLists (lib.attrValues config.devShells);
        };
      })
    ];
  };
}
