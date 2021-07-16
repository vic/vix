{ config, lib, pkgs, USER, HOME, DOTS, ... }: {

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
        g = "git";
        gc = "git commit";
        gb = "git branch";
        gd = "git diff";
        gs = "git status";
        gco = "git checkout";
        gcb = "git checkout -b";
        gp = "git pull --rebase --no-commit";
        gz = "git stash";
        gza = "git stash apply";
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
      };

      loginShellInit = ''
        set -x PATH /nix/var/nix/profiles/system/sw/bin:$PATH
        set -x PATH /etc/profiles/per-user/${USER}/bin:$PATH
      '';

      functions = {
        rg-nixpkgs.description = "Search on current nixpkgs";
        rg-nixpkgs.body = ''command rg $argv $HOME/.nix-out/nixpkgs'';

        rg-home-manager.description = "Search on current home-manager";
        rg-home-manager.body = ''command rg $argv $HOME/.nix-out/home-manager'';

        rg-nix-darwin.description = "Search on current nix-darwin";
        rg-nix-darwin.body = ''command rg $argv $HOME/.nix-out/nix-darwin'';

        nixos-search-opt.description = "Open a browser on search.nixos.org for options";
        nixos-search-opt.body = ''command open "https://search.nixos.org/options?sort=relevance&query=$argv"'';

        nixos-search-pkg.description = "Open a browser on search.nixos.org for packages";
        nixos-search-pkg.body = ''command open "https://search.nixos.org/packages?sort=relevance&query=$argv"'';

        repology-search-nixpkgs.description = "Open a browser on search for nixpkgs on repology.org";
        repology-search-nixpkgs.body = ''open "https://repology.org/projects/?inrepo=nix_unstable&search=$argv"'';
      };
    };

    home.file = {
      ".local/share/fish/fish_history".source = "${DOTS}/fish/fish_history";
    };

  };

}
