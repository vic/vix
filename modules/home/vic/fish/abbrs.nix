{
  ls = "exa";
  top = "btm";
  cat = "bat";
  grep = "rg";
  find = "fd";
  nr = "nix run";
  nf = "fd --glob '*.nix' -X nixfmt {}";

  # jj
  jf = "jj-fzf";
  lj = "lazyjj";
  jb = "jj bookmark";
  jB = "jj bookmark set";
  jc = "jj commit";
  jD = "jj describe -m";
  jd = "jj diff";
  je = "jj edit";
  jF = "jj git fetch";
  jg = "jj git";
  jl = "jj log";
  jll = "jj ll";
  jM = "jj bookmark set main";
  jn = "jj new";
  jN = "jj new -m";
  jp = "jj git push";
  jP = "jj git push && jj new -A @";
  jr = "jj rebase";
  jR = "jj restore -i";
  jS = "jj squash -i";
  js = "jj status --no-pager";
  ju = "jjui";

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
