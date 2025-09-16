{
  ls = "exa";
  top = "btm";
  cat = "bat";
  grep = "rg";
  find = "fd";
  nr = "nix run";
  nf = "fd --glob '*.nix' -X nixfmt {}";

  vir = {
    expansion = "nvim -c \"'0%\"";
    setCursor = true;
  };

  vt = {
    expansion = "nvim -c \":Tv %\"";
    setCursor = true;
  };

  # jj
  jz = "jj-fzf";
  lj = "lazyjj";
  jb = "jj bookmark";
  jc = "jj commit -i";
  jd = {
    expansion = "jj describe -m \"%\"";
    setCursor = true;
  };
  jdd = "jj diff";
  jdt = "jj show --tool difft";
  je = "jj edit";
  jf = "jj git fetch";
  jg = "jj git";
  jl = "jj log";
  jll = "jj ll";
  jm = "jj bookmark set main -r @";
  jm- = "jj bookmark set main -r @-";
  jn = "jj new";
  jN = {
    expansion = "jj new -m \"%\"";
    setCursor = true;
  };
  jp = "jj git push";
  jP = "jj git push && jj new -A main";
  jr = "jj rebase";
  jR = "jj restore -i";
  jS = "jj squash -i";
  js = "jj show --stat --no-pager";
  jss = "jj show --summary --no-pager";
  ju = "jjui";
  jdp = "jj-desc && jj bookmark set main -r @ && jj git push -r main";
  jcp = "jj commit -i && jj bookmark set main -r @- && jj git push -r main";

  # git
  lg = "lazygit";
  gr = "git recents";
  gc = "git commit";
  gb = "git branch";
  gd = "git dff";
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
  ga = "git commit --amend --reuse-message HEAD --all";
  gcam = "git commit --amend --all --message";
  gbDm = "git rm-merged";
  # Magit
  ms = "mg SPC g g";
  # status
  mc = "mg SPC g / c";
  # commit
  md = "mg SPC g / d u";
  # diff unstaged
  ml = "mg SPC g / l l";
  # log
  mr = "mg SPC g / r i";
  # rebase interactive
  mz = "mg SPC g / Z l";
}
