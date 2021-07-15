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
        gd = "git diff";
        gs = "git status";
        gp = "git pull";
        gfap = "git fetch --all -p";
        groh = "git rebase remotes/origin/HEAD";
        grih = "git rebase -i remotes/origin/HEAD";
        gprh = "git push --force-with-lease origin HEAD";
        gfix = "git commit --all --fixup amend:HEAD";
        gcaa = "git commit --amend --all --reuse-message HEAD";
        gcam = "git commit --amend --all --message";
      };

      loginShellInit = ''
        set -x PATH /nix/var/nix/profiles/system/sw/bin:$PATH
        set -x PATH /etc/profiles/per-user/${USER}/bin:$PATH
      '';
    };

    home.file = {
      ".local/share/fish/fish_history".source = "${DOTS}/fish/fish_history";
    };

  };

}
