{ config, lib, pkgs, vix, vix-lib, USER, HOME, DOTS, ... }: {

  home-manager.users.${USER} = {

    programs.fzf.enable = true;
    programs.fzf.enableFishIntegration = true;

    programs.fish = {
      enable = true;

      shellAliases = {
        l = "exa -l";
        ll = "exa -l -@ --git";
        tree = "exa -T";
        # "." = "exa -g";
        ".." = "cd ..";
      };

      shellAbbrs = {
        ls = "exa";
        cat = "bat";
        grep = "rg";
        find = "fd";
        nr = "nix run";
        nf = "fd --glob '*.nix' -X nixfmt {}";
        gc = "git commit";
        gb = "git branch";
        gd = "git diff";
        gs = "git status";
        gco = "git checkout";
        gcb = "git checkout -b";
        gp = "git pull --rebase --no-commit";
        gz = "git stash";
        gza = "git stash apply";
        gfp = "git push --force-with-lease";
        gfap = "git fetch --all -p";
        groh = "git rebase remotes/origin/HEAD";
        grih = "git rebase -i remotes/origin/HEAD";
        grom = "git rebase remotes/origin/master";
        grim = "git rebase -i remotes/origin/master";
        gpfh = "git push --force-with-lease origin HEAD";
        gfix = "git commit --all --fixup amend:HEAD";
        gcm = "git commit --all --message";
        gcaa = "git commit --amend --all --reuse-message HEAD";
        gcam = "git commit --amend --all --message";

        # Magit
        ms = "spc g g"; # status
        mc = "spc g / c"; # commit
        md = "spc g / d u"; # diff unstaged
        ml = "spc g / l l"; # log
        mr = "spc g / r i"; # rebase interactive
        mz = "spc g / Z l"; # list stash
      };

      loginShellInit = ''
        set -x PATH /nix/var/nix/profiles/system/sw/bin:$PATH
        set -x PATH /etc/profiles/per-user/${USER}/bin:$PATH
      '';

      interactiveShellInit = ''
        set -g fish_key_bindings fish_hybrid_key_bindings
      '';

      functions = {
        spc.body = "espace $argv -- -nw";
        vspc.body = "espace $argv -- -c";

        fish_hybrid_key_bindings.description =
          "Vi-style bindings that inherit emacs-style bindings in all modes";
        fish_hybrid_key_bindings.body = ''
          for mode in default insert visual
              fish_default_key_bindings -M $mode
          end
          fish_vi_key_bindings --no-erase
        '';

        vix-activate.description = "Activate a new vix system generation";
        vix-activate.body = "nix run /hk/vix";

        vix-nixpkg-search.description = "Nix search on vix's nixpkgs input";
        vix-nixpkg-search.body =
          "nix search --inputs-from $HOME/.nix-out/vix nixpkgs $argv";

        rg-vix-inputs.description = "Search on vix flake inputs";
        rg-vix-inputs.body = let
          flakePaths = flake:
            [ flake.outPath ]
            ++ lib.flatten (lib.mapAttrsToList (_: flakePaths) flake.inputs);

          paths = builtins.concatStringsSep " " (flakePaths vix);
        in "rg $argv ${paths}";

        rg-vix.description = "Search on current vix";
        rg-vix.body = "rg $argv $HOME/.nix-out/vix";

        rg-nixpkgs.description = "Search on current nixpkgs";
        rg-nixpkgs.body = "rg $argv $HOME/.nix-out/nixpkgs";

        rg-home-manager.description = "Search on current home-manager";
        rg-home-manager.body = "rg $argv $HOME/.nix-out/home-manager";

        rg-nix-darwin.description = "Search on current nix-darwin";
        rg-nix-darwin.body = "rg $argv $HOME/.nix-out/nix-darwin";

        nixos-opt.description =
          "Open a browser on search.nixos.org for options";
        nixos-opt.body = ''
          open "https://search.nixos.org/options?sort=relevance&query=$argv"'';

        nixos-pkg.description =
          "Open a browser on search.nixos.org for packages";
        nixos-pkg.body = ''
          open "https://search.nixos.org/packages?sort=relevance&query=$argv"'';

        repology-nixpkgs.description =
          "Open a browser on search for nixpkgs on repology.org";
        repology-nixpkgs.body = ''
          open "https://repology.org/projects/?inrepo=nix_unstable&search=$argv"'';
      };

      plugins =
        map vix-lib.nivFishPlugin [ "hydro" "done" "fzf.fish" "pisces" "z" ];
    };

    home.file = {
      ".local/share/fish/fish_history".source = "${DOTS}/fish/fish_history";
    };

  };

}
